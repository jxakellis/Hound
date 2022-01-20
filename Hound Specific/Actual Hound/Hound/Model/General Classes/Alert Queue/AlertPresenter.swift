//
//  AlertPresenter.swift
//  AlertQueue-Example
//
//  Created by William Boles on 26/05/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//
//  Modified by Jonathan Xakellis on 2/5/21.
//

import UIKit

class AlertPresenter: NSObject{
    
    //MARK: - NSCoding
    /*
    required init?(coder aDecoder: NSCoder) {
        alertQueue = aDecoder.decodeObject(forKey: "alertQueue") as! Queue<GeneralUIAlertController>
        locked = aDecoder.decodeBool(forKey: "locked")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(alertQueue, forKey: "alertQueue")
        aCoder.encode(locked, forKey: "locked")
    }
     */
    
    //static var supportsSecureCoding: Bool = true
    
    override init(){
        super.init()
    }
    
    private var alertQueue = Queue<GeneralUIAlertController>()
    private var locked = false
    private var halted = false
    var currentPresentation: GeneralUIAlertController?
    
    static var shared = AlertPresenter()
    
    // MARK: - Present
    
    func enqueueAlertForPresentation(_ alertController: GeneralUIAlertController) {
        guard alertController.preferredStyle == .alert else {
            fatalError("use enqueueActionSheetForPresentation instead")
        }
        
        alertQueue.enqueue(alertController)
        
        showNextAlert()
    }
    
    func enqueueActionSheetForPresentation(_ alertController: GeneralUIAlertController, sourceView: UIView, permittedArrowDirections: UIPopoverArrowDirection){
        guard alertController.preferredStyle == .actionSheet else {
            fatalError("use enqueueAlertForPresentation instead")
        }
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        default:
            break
        }
        
        alertQueue.enqueue(alertController)
        
        showNextAlert()
    }
    
    private func showNextAlert() {
        guard halted == false else {
            return
        }
        
        func waitLoop(){
            AppDelegate.generalLogger.notice("waitLoop due to being unable to present UIAlertController")
            if Utils.presenter == nil {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    waitLoop()
                }
            }
            else if Utils.presenter!.isBeingDismissed{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    waitLoop()
                }
            }
            else{
                showNextAlert()
            }
            
        }
        if Utils.presenter == nil {
            AppDelegate.generalLogger.notice("Utils.presenter is nil, initiating waitLoop")
            waitLoop()
            
        }
        else if Utils.presenter!.isBeingDismissed{
            AppDelegate.generalLogger.notice("Util.presenter is being dismissed, initiating waitLoop")
            waitLoop()
        }
        else {
            if alertQueue.queuePresent() && locked == false{
                locked = true
                currentPresentation = alertQueue.elements.first
                Utils.presenter!.present(currentPresentation!, animated: true)
            }
        }
        
    }
    
    func viewDidComplete() {
        locked = false
        currentPresentation = nil
        alertQueue.elements.removeFirst()
        showNextAlert()
    }
    
    func refresh(dogManager: DogManager){
        halted = true
        if currentPresentation == nil {
            for d in dogManager.dogs{
                for r in d.dogReminders.reminders{
                    if r.isPresentationHandled == true {
                        TimingManager.willShowTimer(dogName: d.dogTraits.dogName, reminder: r)
                    }
                }
            }
        }
        halted = false
        showNextAlert()
    }
}

