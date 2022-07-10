//
//  RemindersIntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/6/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol RemindersIntroductionViewControllerDelegate: AnyObject {
    func didComplete(sender: Sender, forDogManager dogManager: DogManager)
}

class RemindersIntroductionViewController: UIViewController {

    // MARK: - IB

    @IBOutlet private weak var remindersTitle: ScaledUILabel!
    
    @IBOutlet private weak var remindersTitleDescription: ScaledUILabel!
    
    @IBOutlet private weak var remindersHeader: ScaledUILabel!
    
    @IBOutlet private weak var remindersBody: ScaledUILabel!
    
    @IBOutlet private weak var remindersToggleSwitch: UISwitch!
    
    @IBOutlet private weak var continueButton: UIButton!
    @IBAction private func willContinue(_ sender: Any) {
        
        continueButton.isEnabled = false
        
        NotificationManager.requestNotificationAuthorization {
            // wait the user to select an grant or deny notification permission (and for the server to response if situation requires the use of it) before continuing
            
            // the user has no reminders so they are therefore able to add default reminders AND they chose to add default reminders
            if self.dogManager.hasCreatedReminder == false && self.remindersToggleSwitch.isOn == true {
                // the user has a dog to add the default reminders too
                if self.dogManager.hasCreatedDog == true {
                    RemindersRequest.create(invokeErrorManager: true, forDogId: self.dogManager.dogs[0].dogId, forReminders: ReminderConstant.defaultReminders) { reminders, _ in
                       
                        // dont let the user close this menu without adding a dog.
                        if reminders != nil {
                            // if we were able to add the reminders, then append to the dogManager
                            self.dogManager.dogs[0].dogReminders.addReminders(newReminders: reminders!)
                            self.delegate.didComplete(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                            LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = true
                            self.dismiss(animated: true, completion: nil)
                        }
                        self.continueButton.isEnabled = true
                    }
                }
                // the user has no dog to add the default reminders too
                else {
                    ErrorManager.alert(forMessage: "Your pre-created dog is missing and we're unable to add your default reminders. Please use the blue plus button on the Reminder page to create a dog.")
                    // have to segment so we can wait for async server call
                    self.continueButton.isEnabled = true
                    LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = true
                    self.dismiss(animated: true, completion: nil)
                }
            }
            // the user already has reminders so no need for default ones (we dont even give them the option) OR the user has no reminders but chose to not add default reminders
            else {
                self.continueButton.isEnabled = true
                LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = true
                self.dismiss(animated: true, completion: nil)
            }
            
        }
            
    }
    
    // MARK: - Properties

    weak var delegate: RemindersIntroductionViewControllerDelegate! = nil
    
    var dogManager: DogManager!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        remindersBody.text = dogManager.hasCreatedReminder == false ? "We'll create reminders that are useful for most dogs. Do you want to use them? You can always create more or edit reminders later." : "It appears that your family has already created a few reminders for your dog\(dogManager.dogs.count > 1 ? "s" : ""). Hopefully they cover everything you need. If not, you can always create more or edit reminders. Enjoy!"
        remindersToggleSwitch.isEnabled = !dogManager.hasCreatedReminder
        remindersToggleSwitch.isOn = !dogManager.hasCreatedReminder
        
        if dogManager.hasCreatedReminder == true {
            remindersToggleSwitch.removeFromSuperview()
            remindersBody.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10.0).isActive = true
        }
        
        continueButton.layer.cornerRadius = 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }

}
