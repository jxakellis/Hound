//
//  DogsIntroductionViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 5/6/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsIntroductionViewControllerDelegate{
    func didSetDefaultReminderState(sender: Sender, newDefaultReminderStatus: Bool)
}

class DogsIntroductionViewController: UIViewController {
    
    //MARK: - IB
    
    @IBOutlet private weak var introductionBody: CustomLabel!
    
    @IBOutlet private weak var remindersBody: CustomLabel!
    @IBOutlet private weak var remindersToggleSwitch: UISwitch!
    
    @IBOutlet private weak var notificationsBody: CustomLabel!
    @IBOutlet private weak var notificationsToggleSwitch: UISwitch!
    ///Handles the toggling of the notification switch, if its the first time then it requests notification authorization.
    @IBAction private func didToggleNotifications(_ sender: Any) {
        if notificationsToggleSwitch.isOn == true {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, error) in
                NotificationConstant.isNotificationAuthorized = isGranted
                NotificationConstant.isNotificationEnabled = isGranted
                NotificationConstant.shouldLoudNotification = isGranted
                NotificationConstant.shouldFollowUp = isGranted
                
                DispatchQueue.main.async {
                    self.notificationsToggleSwitch.setOn(isGranted, animated: true)
                    self.notificationsToggleSwitch.isEnabled = isGranted
                }
                
            }
        }
    }
    
    @IBOutlet private weak var continueButton: UIButton!
    @IBAction private func willContinue(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Properties
    
    var delegate: DogsIntroductionViewControllerDelegate! = nil
    
    //MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.layer.cornerRadius = 8.0
        
       // notificationsToggleSwitch.isOn = NotificationConstant.isNotificationEnabled
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DogsNavigationViewController.hasBeenLoadedBefore = true
        
        delegate.didSetDefaultReminderState(sender: Sender(origin: self, localized: self), newDefaultReminderStatus: remindersToggleSwitch.isOn)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, error) in
            NotificationConstant.isNotificationAuthorized = isGranted
            NotificationConstant.isNotificationEnabled = isGranted
            NotificationConstant.shouldLoudNotification = isGranted
            NotificationConstant.shouldFollowUp = isGranted
            
        }
        
       // NotificationConstant.isNotificationEnabled = notificationsToggleSwitch.isOn
        //NotificationConstant.shouldFollowUp = notificationsToggleSwitch.isOn
    }

}
