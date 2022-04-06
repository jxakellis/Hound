//
//  RemindersIntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/6/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol RemindersIntroductionViewControllerDelegate: AnyObject {
    func didComplete(sender: Sender, forReminders: [Reminder])
}

class RemindersIntroductionViewController: UIViewController {

    // MARK: - IB

    @IBOutlet private weak var introductionBody: ScaledUILabel!

    @IBOutlet private weak var remindersBody: ScaledUILabel!
    @IBOutlet private weak var remindersToggleSwitch: UISwitch!
    @IBOutlet private weak var continueButton: UIButton!
    @IBAction private func willContinue(_ sender: Any) {
        
        continueButton.isEnabled = false
        
        NotificationManager.requestNotificationAuthorization {
            // wait the user to select an grant or deny notification permission (and for the server to respond if granted) before continusing
            self.queryDefaultReminders(shouldUseDefaultReminders: self.remindersToggleSwitch.isOn) { reminders in
                if reminders != nil {
                    self.delegate.didComplete(sender: Sender(origin: self, localized: self), forReminders: reminders!)
                    
                }
                else {
                    self.delegate.didComplete(sender: Sender(origin: self, localized: self), forReminders: [])
                }
                LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = true
                self.dismiss(animated: true, completion: nil)
            }
        }
            
    }
    
    private func queryDefaultReminders(shouldUseDefaultReminders: Bool, completionHandler: @escaping (([Reminder]?) -> Void)) {
        // make sure the user wants default reminders
        if shouldUseDefaultReminders == true {
            // make sure there is a dog to add them too
            if dogManager.hasCreatedDog == true {
                let dog = dogManager.dogs[0]
                // use custom request
                RemindersRequest.create(forDogId: dog.dogId, forReminders: ReminderConstant.defaultReminders) { reminders in
                    // dont care about success, just pass through
                    completionHandler(reminders)
                }
            }
            else {
                ErrorManager.alert(forMessage: "Something must've happened to your pre-created dog! You seem to being missing it and we're unable to add your default reminders. Please use the blue plus button on the Reminder page to create a dog.")
                completionHandler([])
            }
        }
        else {
            completionHandler([])
        }
    }
    
    // MARK: - Properties

    weak var delegate: RemindersIntroductionViewControllerDelegate! = nil
    
    var dogManager: DogManager!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.layer.cornerRadius = 8.0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}
