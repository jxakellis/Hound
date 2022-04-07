//
//  SettingsRemindersViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsRemindersViewControllerDelegate: AnyObject {
    func didToggleIsPaused(newIsPaused: Bool)
}

class SettingsRemindersViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Properties
    
    weak var delegate: SettingsRemindersViewControllerDelegate! = nil
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        snoozeLength.countDownDuration = UserConfiguration.snoozeLength
        
        // fixes issue with first time datepicker updates not triggering function
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.snoozeLength.countDownDuration = UserConfiguration.snoozeLength
        }
        
        isPausedSwitch.isOn = UserConfiguration.isPaused
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
        
        synchronizeIsPaused()
    }
    
    // MARK: - Individual Settings
    
    // MARK: Pause
    /// Switch for pause all timers
    @IBOutlet private weak var isPausedSwitch: UISwitch!
    
    /// If the pause all timers switch it triggered, calls thing function
    @IBAction private func didToggleIsPaused(_ sender: Any) {
        
        // TO DO re-enable the pause all reminders switch. to do so, make sure this feature syncs across all family members so that reminder timing (no matter where you are in the app) is accurate. also make this page sync so pause all reminders switch is updated if a fam member changed it.
        
        // save and changes values
        let beforeUpdateIsPaused = UserConfiguration.isPaused
        UserConfiguration.isPaused = isPausedSwitch.isOn
        
        // inform delegate so appropiate actions can be taken, e.g. stop all timers
        delegate.didToggleIsPaused(newIsPaused: isPausedSwitch.isOn)
        
        let body = [ServerDefaultKeys.isPaused.rawValue: UserConfiguration.isPaused]
        UserRequest.update(body: body) { requestWasSuccessful in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.isPaused = beforeUpdateIsPaused
                self.delegate.didToggleIsPaused(newIsPaused: UserConfiguration.isPaused)
                self.isPausedSwitch.setOn(UserConfiguration.isPaused, animated: true)
            }
        }
    }
    
    /// Synchronizes the isPaused switch enable and isOn variables to reflect that amount of timers active, if non are active then locks user from changing switch
    private func synchronizeIsPaused() {
        isPausedSwitch.isOn = UserConfiguration.isPaused
        // no timers enabled so no use for isPaused, therefore we disable it until enabled reminder
        if MainTabBarViewController.staticDogManager.enabledTimersCount == 0 {
            isPausedSwitch.isEnabled = false
        }
        else {
            isPausedSwitch.isEnabled = true
        }
    }
    
    // MARK: Snooze Length
    
    @IBOutlet private weak var snoozeLength: UIDatePicker!
    
    @IBAction private func didUpdateSnoozeLength(_ sender: Any) {
        let beforeUpdateSnoozeLength = UserConfiguration.snoozeLength
        UserConfiguration.snoozeLength = snoozeLength.countDownDuration
        let body = [ServerDefaultKeys.snoozeLength.rawValue: UserConfiguration.snoozeLength]
        UserRequest.update(body: body) { requestWasSuccessful in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.snoozeLength = beforeUpdateSnoozeLength
                self.snoozeLength.countDownDuration = UserConfiguration.snoozeLength
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
