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

class SettingsViewController: UIViewController, ToolTipable {
    
    //MARK: Notifications
    
    @IBOutlet weak var isNotificationEnabledSwitch: UISwitch!
    
    @IBAction func didToggleNotificationEnabled(_ sender: Any) {
        //Notifications not authorized, it is also know that they MUST be disabled then and the switch is going from off to on
        if NotificationConstant.isNotificationAuthorized == false {
            Utils.willShowAlert(title: "Notifcations Disabled", message: "To enable notifications go to the Settings App -> Notifications -> APP NAME and enable \"Allow Notifications\"")
            
            let switchDisableTimer = Timer(fireAt: Date().addingTimeInterval(0.15), interval: -1, target: self, selector: #selector(disableIsNotificationEnabledSwitch), userInfo: nil, repeats: false)
            
            RunLoop.main.add(switchDisableTimer, forMode: .common)
            
        }
        //Notifications authorized
        else {
            //notications enabled, going from on to off
            if NotificationConstant.isNotificationEnabled == true {
                NotificationConstant.isNotificationEnabled = false
                synchronizeWillFollowUp(animated: true)
            }
            //notifications disabled, going from off to on
            else {
                NotificationConstant.isNotificationEnabled = true
                synchronizeWillFollowUp(animated: true)
            }
        }
    }
    
    @objc private func disableIsNotificationEnabledSwitch(){
        self.isNotificationEnabledSwitch.setOn(false, animated: true)
    }
    
    func refreshNotificationSwitches(animated: Bool){
        //If disconnect between stored and displayed
        if isNotificationEnabledSwitch.isOn != NotificationConstant.isNotificationEnabled {
            isNotificationEnabledSwitch.setOn(NotificationConstant.isNotificationEnabled, animated: true)
        }
        self.synchronizeWillFollowUp(animated: animated)
    }
    
    private func synchronizeWillFollowUp(animated: Bool){
        //animated
        if animated == true {
            //notifications are enabled
            if NotificationConstant.isNotificationEnabled == true {
                willFollowUp.isEnabled = true
            }
            //notifications are disabled
            else {
                willFollowUp.isEnabled = false
                willFollowUp.setOn(false, animated: true)
                NotificationConstant.willFollowUp = false
            }
        }
        //not animated
        else {
            //notifications are enabled
            if NotificationConstant.isNotificationEnabled == true {
                willFollowUp.isEnabled = true
            }
            //notifications are disabled
            else {
                willFollowUp.isEnabled = false
                willFollowUp.isOn = false
                NotificationConstant.willFollowUp = false
            }
        }
    }
    
    //MARK: Follow Up Notification
    
    @IBOutlet weak var willFollowUp: UISwitch!
    @IBAction func didToggleFollowUp(_ sender: Any) {
        NotificationConstant.willFollowUp = willFollowUp.isOn
    }
    
    
    
    //MARK: Pause
    ///Switch for pause all timers
    @IBOutlet weak var isPaused: UISwitch!
    
    ///If the pause all timers switch it triggered, calls thing function
    @IBAction private func didTogglePause(_ sender: Any) {
        delegate.didTogglePause(newPauseState: isPaused.isOn)
    }
    
    //MARK: Snooze
    
    @IBOutlet weak var snoozeInterval: UIDatePicker!
    
    @IBAction private func didUpdateSnoozeInterval(_ sender: Any) {
        TimerConstant.defaultSnooze = snoozeInterval.countDownDuration
    }
    
    //MARK: Tool Tip
    
    
        
        private var currentToolTip: ToolTipView?
        
        @IBOutlet weak var toolTipButton: UIButton!
        @IBAction func toolTip(_ sender: Any) {
            toolTipButton.isUserInteractionEnabled = false
            if currentToolTip != nil {
                hideToolTip(sourceButton: toolTipButton)
            }
            else {
                showToolTip(sourceButton: toolTipButton, message: "Sends a follow up \nnotification if the first one\nis not responded to\nwithin five minutes")
            }
        }
        
        func showToolTip(sourceButton: UIButton, message: String) {
            let tipView = ToolTipView(sourceView: sourceButton, message: message, toolTipPosition: .middle)
            view.addSubview(tipView)
            currentToolTip = tipView
            performToolTipShow(sourceButton: sourceButton, tipView)
        }
        
        func hideToolTip(sourceButton: UIButton? = nil) {
            if sourceButton != nil && currentToolTip != nil{
                
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.currentToolTip!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                }) { finished in
                    self.currentToolTip?.removeFromSuperview()
                    self.currentToolTip = nil
                    sourceButton!.isUserInteractionEnabled = true
                    
                }
            }
            else if currentToolTip != nil{
                toolTipButton.isUserInteractionEnabled = true
                currentToolTip?.removeFromSuperview()
                currentToolTip = nil
            }
        }
    
    //MARK: Properties
    
    var delegate: SettingsViewControllerDelegate! = nil
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        snoozeInterval.countDownDuration = TimerConstant.defaultSnooze
        isPaused.isOn = TimingManager.isPaused
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNotificationEnabledSwitch.isOn = NotificationConstant.isNotificationEnabled
        synchronizeWillFollowUp(animated: false)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideToolTip()
    }
}
