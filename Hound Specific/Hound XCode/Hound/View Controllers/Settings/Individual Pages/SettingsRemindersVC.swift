//
//  SettingsRemindersViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsRemindersViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO DO split this page.
        // pause all reminders will go on the family page
        // snooze length will go on notifications
        
        snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength
        
        // fixes issue with first time datepicker updates not triggering function
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength
        }
        
        isPausedSwitch.isOn = FamilyConfiguration.isPaused
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Individual Settings
    
    // MARK: Pause
    /// Switch for pause all timers
    @IBOutlet private weak var isPausedSwitch: UISwitch!
    
    /// If the pause all timers switch it triggered, calls thing function
    @IBAction private func didToggleIsPaused(_ sender: Any) {
        TimingManager.willToggleIsPaused(forDogManager: MainTabBarViewController.staticDogManager, newIsPaused: isPausedSwitch.isOn)
    }
    
    // MARK: Snooze Length
    
    @IBOutlet private weak var snoozeLengthDatePicker: UIDatePicker!
    
    @IBAction private func didUpdateSnoozeLength(_ sender: Any) {
        let beforeUpdateSnoozeLength = UserConfiguration.snoozeLength
        UserConfiguration.snoozeLength = snoozeLengthDatePicker.countDownDuration
        let body = [ServerDefaultKeys.snoozeLength.rawValue: UserConfiguration.snoozeLength]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.snoozeLength = beforeUpdateSnoozeLength
                self.snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
