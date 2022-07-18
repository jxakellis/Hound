//
//  AlertManager.swift
//  AlertQueue-Example
//
//  Created by William Boles on 26/05/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//
//  Modified by Jonathan Xakellis on 2/5/21.
//

import UIKit

final class AlertManager: NSObject {
    
    override init() {
        super.init()
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        contactingServerAlertController.view.addSubview(activityIndicator)
        
        let defaultContactingServerAlertControllerHeight = 95.0
        // the bold text accessibilty causes the uilabel in the alertcontroller to become two lines instead of one. We cannot get the UILabel's frame so we must manually make a guess on expanding the alertController's height. If we don't then the activity indicator and the 'Contacting Hound's Server' label will over lap
        let heightMultiplier = UIAccessibility.isBoldTextEnabled ? 1.18 : 1.0
        contactingServerAlertController.view.heightAnchor.constraint(equalToConstant: defaultContactingServerAlertControllerHeight*heightMultiplier).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: contactingServerAlertController.view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: contactingServerAlertController.view.bottomAnchor, constant: -20).isActive = true
        
        contactingServerAlertController.view.addSubview(activityIndicator)
        contactingServerAlertController.view.tag = VisualConstant.ViewTagConstant.contactingServerAlertController
        
    }
    
        // MARK: - Public Properties
    
    let contactingServerAlertController = GeneralUIAlertController(title: "Contacting _____'s Server...", message: nil, preferredStyle: .alert)
    
    static var shared = AlertManager()
    
    /// Default sender used to present, this is necessary if an alert to be shown is called from a non UIViewController class as that is not in the view heirarchy and physically cannot present a view, so this is used instead.
    static var globalPresenter: UIViewController?
    
    // MARK: - Private Properties
    
    private var locked = false
    private var currentAlertPresented: GeneralUIAlertController?
    
    // MARK: - Queue
    
    private var alertQueue: [GeneralUIAlertController] = []
    
    /// Checks to see if the queue has any server related alerts inside of it.
    private var containsServerRelatedAlert: Bool {
        // check queue for server related
        for alert in alertQueue where alert.view.tag == VisualConstant.ViewTagConstant.serverRelatedViewController {
            return true
        }
        // check current presentation
        if currentAlertPresented?.view.tag == VisualConstant.ViewTagConstant.serverRelatedViewController {
            return true
        }
        else {
            return false
        }
    }
    
    /// Checks to see if the queue has any loading view controllers
    private var containsContactingServerAlertController: Bool {
        // check queue for loading view controller
        for alert in alertQueue where alert.view.tag == VisualConstant.ViewTagConstant.contactingServerAlertController {
            return true
        }
        // check current presentation
        if currentAlertPresented?.view.tag == VisualConstant.ViewTagConstant.contactingServerAlertController {
            return true
        }
        else {
            return false
        }
    }
    
    private func enqueue(_ alertController: GeneralUIAlertController) {
         // if this is a server related alert and there is already a server related alert, we don't want to add a second one. no need to barrage the user with server failure messages.
        if alertController.view.tag == VisualConstant.ViewTagConstant.serverRelatedViewController && containsServerRelatedAlert == true {
                return
        }
        // if this is a loading view controller and loading view controller, we don't want to add a second one.
        else if alertController.view.tag == VisualConstant.ViewTagConstant.contactingServerAlertController && containsContactingServerAlertController == true {
            return
        }
        
        alertQueue.append(alertController)
    }
    
    // MARK: - Alert Presentation
    
    /// Function used to present alertController. If the alert is related to a server query message, specifiy as so. This stops the user from being spammed with multiple server messages if there are multiple failure messages at once.
    static func willShowAlert(title: String, message: String?, hasOKAlertAction: Bool = true, serverRelated: Bool = false) {
        var trimmedMessage: String? = message
        
        if message?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            trimmedMessage = nil
        }
        
        let alertController = GeneralUIAlertController(
            title: title,
            message: trimmedMessage,
            preferredStyle: .alert)
        alertController.view.tag = VisualConstant.ViewTagConstant.serverRelatedViewController
        
        if hasOKAlertAction == true {
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(alertAction)
        }
        
        enqueueAlertForPresentation(alertController)
        
    }
    
    // MARK: - Alert Queue Management
    
    static func enqueueAlertForPresentation(_ alertController: GeneralUIAlertController) {
        guard alertController.preferredStyle == .alert else {
            return
        }
        
        shared.enqueue(alertController)
        
        shared.showNextAlert()
    }
    
    static func enqueueActionSheetForPresentation(_ alertController: GeneralUIAlertController, sourceView: UIView, permittedArrowDirections: UIPopoverArrowDirection) {
        guard alertController.preferredStyle == .actionSheet else {
            return
        }
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        default:
            break
        }
        
        shared.enqueue(alertController)
        
        shared.showNextAlert()
    }
    
    private func showNextAlert() {
        func waitLoop() {
            AppDelegate.generalLogger.info("showNextAlert waitLoop")
            guard let globalPresenter = AlertManager.globalPresenter, globalPresenter.isBeingDismissed == false, globalPresenter.presentedViewController == nil else {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                    waitLoop()
                }
                return
            }
            
            showNextAlert()
            
        }
        
        if AlertManager.globalPresenter == nil {
            waitLoop()
        }
        else if AlertManager.globalPresenter!.isBeingDismissed {
            waitLoop()
        }
        else {
            if alertQueue.isEmpty == false && locked == false {
                locked = true
                currentAlertPresented = alertQueue.first
                alertQueue.removeFirst()
                AlertManager.globalPresenter!.present(currentAlertPresented!, animated: true)
            }
        }
        
    }
    
    /// Invoke when the alert has finished being presented and a new alert is able to take its place
    func alertDidComplete() {
        locked = false
        currentAlertPresented = nil
        showNextAlert()
    }
}
