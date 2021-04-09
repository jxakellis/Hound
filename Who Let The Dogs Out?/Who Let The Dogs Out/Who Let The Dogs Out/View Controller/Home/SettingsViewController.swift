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
    
    @IBOutlet private weak var isNotificationEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleNotificationEnabled(_ sender: Any) {
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
                synchronizeFollowUpComponents(animated: true)
            }
            //notifications disabled, going from off to on
            else {
                NotificationConstant.isNotificationEnabled = true
                synchronizeFollowUpComponents(animated: true)
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
        self.synchronizeFollowUpComponents(animated: animated)
    }
    
    
    
    //MARK: Follow Up Notification
    
    @IBOutlet weak var followUpReminderLabel: CustomLabel!
    
    @IBOutlet private weak var shouldFollowUp: UISwitch!
    
    @IBAction private func didToggleFollowUp(_ sender: Any) {
        NotificationConstant.shouldFollowUp = shouldFollowUp.isOn
    }
    
    private func synchronizeFollowUpComponents(animated: Bool){
        //animated
        if animated == true {
            //notifications are enabled
            if NotificationConstant.isNotificationEnabled == true {
                shouldFollowUp.isEnabled = true
                shouldFollowUp.isOn = NotificationConstant.shouldFollowUp
                
                followUpDelayInterval.isEnabled = true
            }
            //notifications are disabled
            else {
                shouldFollowUp.isEnabled = false
                shouldFollowUp.setOn(false, animated: true)
                NotificationConstant.shouldFollowUp = false
                
                followUpDelayInterval.isEnabled = false
            }
        }
        //not animated
        else {
            //notifications are enabled
            if NotificationConstant.isNotificationEnabled == true {
                shouldFollowUp.isEnabled = true
                shouldFollowUp.isOn = NotificationConstant.shouldFollowUp
                
                followUpDelayInterval.isEnabled = true
            }
            //notifications are disabled
            else {
                shouldFollowUp.isEnabled = false
                shouldFollowUp.isOn = false
                NotificationConstant.shouldFollowUp = false
                
                followUpDelayInterval.isEnabled = false
            }
        }
    }
    
    //MARK: Follow Up Delay
    
    @IBOutlet weak var followUpDelayInterval: UIDatePicker!
    
    @IBAction func didUpdateFollowUpDelay(_ sender: Any) {
        NotificationConstant.followUpDelay = followUpDelayInterval.countDownDuration
    }
    
    
    //MARK: Pause
    ///Switch for pause all timers
    @IBOutlet private weak var isPaused: UISwitch!
    
    ///If the pause all timers switch it triggered, calls thing function
    @IBAction private func didTogglePause(_ sender: Any) {
        delegate.didTogglePause(newPauseState: isPaused.isOn)
    }
    
    ///Synchronizes the isPaused switch enable and isOn variables to reflect that amount of timers active, if non are active then locks user from changing switch
    private func synchronizeIsPaused(){
        if MainTabBarViewController.staticDogManager.enabledTimersCount == 0{
            TimingManager.isPaused = false
            self.isPaused.isOn = false
            self.isPaused.isEnabled = false
        }
        else {
            self.isPaused.isEnabled = true
        }
    }
    
    //MARK: Snooze
    
    @IBOutlet private weak var snoozeInterval: UIDatePicker!
    
    @IBAction private func didUpdateSnoozeInterval(_ sender: Any) {
        TimerConstant.defaultSnooze = snoozeInterval.countDownDuration
    }
    
    //MARK: Tool Tip
    
    
        
        private var currentToolTip: ToolTipView?
        
        @IBOutlet private weak var toolTipButton: UIButton!
        @IBAction private func toolTip(_ sender: Any) {
            toolTipButton.isUserInteractionEnabled = false
            if currentToolTip != nil {
                hideToolTip(sourceButton: toolTipButton)
            }
            else {
                showToolTip(sourceButton: toolTipButton, message: "Sends a follow up \nnotification if the first one\nis not responded to")
            }
        }
        
        func showToolTip(sourceButton: UIButton, message: String) {
            let tipView = ToolTipView(sourceView: sourceButton, message: message, toolTipPosition: .middle)
            sourceButton.superview?.addSubview(tipView)
            currentToolTip = tipView
            performToolTipShow(sourceButton: sourceButton, tipView)
        }
        
        func hideToolTip(sourceButton: UIButton? = nil) {
                if self.currentToolTip != nil{
                    UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                        self.currentToolTip!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    }) { finished in
                        self.currentToolTip?.removeFromSuperview()
                        self.currentToolTip = nil
                        if sourceButton != nil {
                            sourceButton!.isUserInteractionEnabled = true
                        }
                        
                    }
                }
            
            
        }
    
    ///If hideToolTip is exposed to objc and used in selector for tap gesture recognizer then for some reason
    @objc private func willHideToolTip(){
        hideToolTip()
    }
    
    //MARK: Reset
    
    @IBOutlet private weak var resetButton: UIButton!
    
    @IBAction private func willReset(_ sender: Any) {
        
         let alertController = CustomAlertController(
             title: "Are you sure you want to reset?",
             message: "This action will delete and reset all data to default, in the process restarting the app",
             preferredStyle: .alert)
         
         let alertReset = UIAlertAction(
             title:"Reset",
            style: .destructive,
             handler:
                 {
                     (alert: UIAlertAction!)  in
                    UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.shouldPerformCleanInstall.rawValue)
                    
                    let restartTimer = Timer(fireAt: Date(), interval: -1, target: self, selector: #selector(self.showRestartMessage), userInfo: nil, repeats: false)
                    
                    RunLoop.main.add(restartTimer, forMode: .common)
                 })
        
        let alertCancel = UIAlertAction(
            title:"Cancel",
            style: .cancel,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    
                })
         
         alertController.addAction(alertReset)
         alertController.addAction(alertCancel)
         
         AlertPresenter.shared.enqueueAlertForPresentation(alertController)
         
    }
    
    @objc private func showRestartMessage(){
        let alertController = CustomAlertController(
            title: "Restarting now....",
            message: nil,
            preferredStyle: .alert)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            exit(-1)
        }
    }
    
    //MARK: Properties
    
    var delegate: SettingsViewControllerDelegate! = nil
    
    @IBOutlet weak var pageTitle: CustomLabel!
    
    @IBOutlet weak var scrollViewContainerForAll: UIView!
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followUpDelayInterval.countDownDuration = NotificationConstant.followUpDelay
        snoozeInterval.countDownDuration = TimerConstant.defaultSnooze
        isPaused.isOn = TimingManager.isPaused
        resetButton.layer.cornerRadius = 8.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(willHideToolTip))
        self.view.addGestureRecognizer(tap)
        
        var followUpReminderLabelWidth: CGFloat {
            let neededConstraintSpace: CGFloat = 10.0 + 10.0 + 2.0 + 45.0
            let otherButtonSpace: CGFloat = shouldFollowUp.frame.width + toolTipButton.frame.width
            let maximumWidth: CGFloat = view.frame.width - otherButtonSpace - neededConstraintSpace
            
            let neededLabelSize: CGSize = (followUpReminderLabel.text?.withBoundedWidth(font: followUpReminderLabel.font, height: followUpReminderLabel.frame.height))!
            
            let neededLabelWidth: CGFloat = neededLabelSize.width
            
            if neededLabelWidth > maximumWidth {
                return maximumWidth
            }
            else {
                return neededLabelWidth
            }
        }
        
        followUpReminderLabel.frame = CGRect(x: followUpReminderLabel.frame.origin.x, y: followUpReminderLabel.frame.origin.y, width: followUpReminderLabelWidth, height: followUpReminderLabel.frame.height)
        
        /*
        let pageTitleSeperatorLine = UIView(frame: CGRect(x: pageTitle.frame.origin.x, y: pageTitle.frame.maxY + 3.0, width: pageTitle.frame.width, height: 4.5))
        pageTitleSeperatorLine.backgroundColor = .link
        pageTitleSeperatorLine.layer.cornerRadius = (pageTitleSeperatorLine.frame.height-1)/2
        view.addSubview(pageTitleSeperatorLine)
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNotificationEnabledSwitch.isOn = NotificationConstant.isNotificationEnabled
        synchronizeFollowUpComponents(animated: false)
        synchronizeIsPaused()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideToolTip()
    }
}
