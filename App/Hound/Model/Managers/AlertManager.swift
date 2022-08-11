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
import NotificationBannerSwift

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
        contactingServerAlertController.view.heightAnchor.constraint(equalToConstant: defaultContactingServerAlertControllerHeight * heightMultiplier).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: contactingServerAlertController.view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: contactingServerAlertController.view.bottomAnchor, constant: -20).isActive = true
        
        contactingServerAlertController.view.addSubview(activityIndicator)
        contactingServerAlertController.view.tag = VisualConstant.ViewTagConstant.contactingServerAlertController
        
    }
    
    // MARK: - Static Properties
    
    static var shared = AlertManager()
    
    private static var storedGlobalPresenter: UIViewController?
    /// Default sender used to present, this is necessary if an alert to be shown is called from a non GeneralUIAlertController class as that is not in the view heirarchy and physically cannot present a view, so this is used instead.
    static var globalPresenter: UIViewController? {
        get {
            return storedGlobalPresenter
        }
        set (newGlobalPresenter) {
            // If we new global presenter is just nil, then simply set to nil and return
            guard let newGlobalPresenter = newGlobalPresenter else {
                storedGlobalPresenter = nil
                return
            }
            
            checkParent(forViewController: newGlobalPresenter)
            // Recursively go up the higharchy of parent view controllers
            func checkParent(forViewController viewController: UIViewController) {
                // Check to make sure the view controller has a parent
                guard let parentViewController = viewController.parent else {
                    // The view controller has no parent, therefore we stop and set the global presenter equal to this view controller
                    storedGlobalPresenter = viewController
                    return
                }
                
                // The view controller has a parent
                // Check if the parent has a loaded view and has a window, this checks if it's still loaded and can function as a globalPresenter (aka is it capable of presenting AlertControllers)
                
                guard parentViewController.isViewLoaded == true && parentViewController.view.window != nil else {
                    // The parent view controller is not eligible to be a global presenter, therefore stop and set global presenter equal to this view controller
                    storedGlobalPresenter = viewController
                    return
                }
                
                // The view controller's parent is eligible to be a globalPresenter so continue recursive parent search to find highest level parent view controller
                checkParent(forViewController: parentViewController)
            }
        }
    }
    
    // MARK: - Static Functions
    
    static func enqueueBannerForPresentation(forTitle title: String, forSubtitle subtitle: String?, forStyle: BannerStyle) {
        // Reduce the availble styles into a smaller 3 tier group
        // Success
        // Info
        // Danger
        let style: BannerStyle = {
            switch forStyle {
            case .success:
                return .success
            case .info:
                return .info
            case .danger:
                return .danger
            default:
                return .success
            }
        }()
        
        // Create a left view image that corresponds to the style selected
        let leftViewImage: UIImageView = {
            var image: UIImage = UIImage.init(systemName: "checkmark.circle") ?? UIImage()
            switch style {
            case .success:
                image = UIImage.init(systemName: "checkmark.circle") ?? image
            case .info:
                image = UIImage.init(systemName: "info.circle") ?? image
            case .danger:
                image = UIImage.init(systemName: "exclamationmark.triangle") ?? image
            default:
                image = UIImage.init(systemName: "exclamationmark.triangle") ?? image
            }
            return UIImageView(image: image)
        }()
        
        leftViewImage.translatesAutoresizingMaskIntoConstraints = false
        leftViewImage.tintColor = .white
        
        let banner = GrowingNotificationBanner(title: title, subtitle: subtitle, leftView: leftViewImage, style: style)
        banner.contentMode = .scaleAspectFit
        
        // Select a haptic feedback that corresponds to the style. A more important style requires a heavier haptic
        banner.haptic = {
            switch style {
            case .success:
                return .light
            case .info:
                return .medium
            case .danger:
                return .heavy
            default:
                return .light
            }
        }()
        
        // Select a banner duration that corresponds to the style. A more important style requires a longer duration
        banner.duration = {
            // This is the duration for a title-only banner
            let successDuration = 1.25
            var bannerDuration = successDuration
            switch style {
            case .success:
                bannerDuration = successDuration
            case .info:
                bannerDuration = 1.75
            case .danger:
                bannerDuration = 2.25
            default:
                bannerDuration = successDuration
            }
            
            // If a non-nil and non-blank subtitle was provided, give the user extra reading time
            if let subtitle = subtitle, subtitle.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                // The average person reads at 300 WPM, that is 5 words per second
                // The average word in one of these subtitle messages is 6 characters (excluding white spaces)
                // That the average person can read 30 non-whitespace characters a second, or 1 character per 0.033 seconds
                let subtitleCharacters = subtitle.filter { character in
                    return character.isWhitespace == false
                }
                let extraSubtitleReadingTime = Double(subtitleCharacters.count) * 0.032
                
                bannerDuration += extraSubtitleReadingTime
            }
            return bannerDuration
        }()
        
        // Select a banner color that corresponds to the style
        banner.backgroundColor = {
            switch style {
            case .success:
                return .systemGreen
            case .info:
                return .systemBlue
            case .danger:
                return .systemRed
            default:
                return .systemGreen
            }
        }()
        
        banner.show(on: AlertManager.globalPresenter)
    }
    
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
    
    // MARK: - Properties
    
    let contactingServerAlertController = GeneralUIAlertController(title: "Contacting _____'s Server...", message: nil, preferredStyle: .alert)
    
    private var locked = false
    private var currentAlertPresented: GeneralUIAlertController?
    
    // MARK: - Queue
    
    private var alertQueue: [GeneralUIAlertController] = []
    
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
        if alertController.view.tag == VisualConstant.ViewTagConstant.contactingServerAlertController && containsContactingServerAlertController == true {
            return
        }
        
        alertQueue.append(alertController)
    }
    
    // MARK: - Alert Queue Management
    
    private func showNextAlert() {
        func waitLoop() {
            AppDelegate.generalLogger.info("showNextAlert waitLoop")
            guard let globalPresenter = AlertManager.globalPresenter, globalPresenter.isBeingDismissed == false, globalPresenter.presentedViewController == nil else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    waitLoop()
                }
                return
            }
            
            showNextAlert()
            
        }
        
        guard let globalPresenter = AlertManager.globalPresenter, globalPresenter.isBeingDismissed == false, globalPresenter.presentedViewController == nil else {
            waitLoop()
            return
        }
        
        guard alertQueue.isEmpty == false && locked == false else {
            return
        }
        
        locked = true
        currentAlertPresented = alertQueue.removeFirst()
        
        guard let currentAlertPresented = currentAlertPresented else {
            locked = false
            return
        }
        
       globalPresenter.present(currentAlertPresented, animated: true)
        
    }
    
    /// Invoke when the alert has finished being presented and a new alert is able to take its place
    func alertDidComplete() {
        locked = false
        currentAlertPresented = nil
        showNextAlert()
    }
}
