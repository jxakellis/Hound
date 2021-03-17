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
    
    //MARK: Notifications
    
    static var isNotificationAuthorized: Bool {
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue) as! Bool }
        set(newBool) {
            UserDefaults.standard.setValue(newBool, forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue)
        }
    }
    static var isNotificationEnabled: Bool {
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool }
        set(newBool) {
            UserDefaults.standard.setValue(newBool, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
        }
    }
    
    @IBOutlet weak var isNotificationEnabledSwitch: UISwitch!
    
    @IBAction func didToggleNotificationEnabled(_ sender: Any) {
        //Notifications not authorized, it is also know that they MUST be disabled then and the switch is going from off to on
        if SettingsViewController.isNotificationAuthorized == false {
            Utils.willShowAlert(title: "Notifcations Disabled", message: "To enable notifications go to the Settings App -> Notifications -> APP NAME and enable \"Allow Notifications\"")
            
            let switchDisableTimer = Timer(fireAt: Date().addingTimeInterval(0.15), interval: -1, target: self, selector: #selector(disableIsNotificationEnabledSwitch), userInfo: nil, repeats: false)
            
            RunLoop.main.add(switchDisableTimer, forMode: .common)
            
        }
        //Notifications authorized
        else {
            //notications enabled, going from on to off
            if SettingsViewController.isNotificationEnabled == true {
                SettingsViewController.isNotificationEnabled = false
            }
            //notifications disabled, going from off to on
            else {
                SettingsViewController.isNotificationEnabled = true
            }
        }
    }
    
    @objc private func disableIsNotificationEnabledSwitch(){
        self.isNotificationEnabledSwitch.setOn(false, animated: true)
    }
    
    
    //MARK: Pause
    ///Switch for pause all timers
    @IBOutlet weak var isPaused: UISwitch!
    
    ///If the pause all timers switch it triggered, calls thing function
    @IBAction func didTogglePause(_ sender: Any) {
        delegate.didTogglePause(newPauseState: isPaused.isOn)
    }
    
    //MARK: Snooze
    
    @IBOutlet weak var snoozeInterval: UIDatePicker!
    
    @IBAction func didUpdateSnoozeInterval(_ sender: Any) {
        TimerConstant.defaultSnooze = snoozeInterval.countDownDuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        snoozeInterval.countDownDuration = TimerConstant.defaultSnooze
        isPaused.isOn = TimingManager.isPaused
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNotificationEnabledSwitch.isOn = SettingsViewController.isNotificationEnabled
    }
    
    
}
