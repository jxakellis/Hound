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
        delegate.didToggleIsPaused(newIsPaused: isPausedSwitch.isOn)
    }

    /// Synchronizes the isPaused switch enable and isOn variables to reflect that amount of timers active, if non are active then locks user from changing switch
    private func synchronizeIsPaused() {
        if MainTabBarViewController.staticDogManager.enabledTimersCount == 0 {
            UserConfiguration.isPaused = false
            isPausedSwitch.isOn = false
            isPausedSwitch.isEnabled = false
        }
        else {
            isPausedSwitch.isOn = UserConfiguration.isPaused
            isPausedSwitch.isEnabled = true
        }
    }

    // MARK: Snooze Length

    @IBOutlet private weak var snoozeLength: UIDatePicker!

    @IBAction private func didUpdateSnoozeLength(_ sender: Any) {
        UserConfiguration.snoozeLength = snoozeLength.countDownDuration
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
