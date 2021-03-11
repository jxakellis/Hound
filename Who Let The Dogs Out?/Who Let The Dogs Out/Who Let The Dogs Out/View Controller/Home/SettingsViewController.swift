//
//  SettingsViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func didTogglePause(newPauseState: Bool)
}

class SettingsViewController: UIViewController {

    var delegate: SettingsViewControllerDelegate! = nil
    
    //MARK: Pause All Alarms
    ///Switch for pause all alarms
    @IBOutlet weak var isPaused: UISwitch!
    
    ///If the pause all alarms switch it triggered, calls thing function
    @IBAction func didTogglePause(_ sender: Any) {
        delegate.didTogglePause(newPauseState: isPaused.isOn)
    }
    
    //MARK: Default Snooze
    
    @IBOutlet weak var snoozeInterval: UIDatePicker!
    
    @IBAction func didUpdateSnoozeInterval(_ sender: Any) {
        TimerConstant.defaultSnooze = snoozeInterval.countDownDuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        snoozeInterval.countDownDuration = UserDefaults.standard.value(forKey: "defaultSnooze") as! TimeInterval
        isPaused.isOn = UserDefaults.standard.value(forKey: "isPaused") as! Bool
    }
}
