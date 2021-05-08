//
//  SettingsViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func didTogglePause(newPauseState: Bool)
}

class SettingsViewController: UIViewController, ToolTipable {
    
    //MARK: - Notifications
    
    @IBOutlet private weak var notificationToggleSwitch: UISwitch!
    
    @IBAction private func didToggleNotificationEnabled(_ sender: Any) {
        
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    //notications enabled, going from on to off
                    if NotificationConstant.isNotificationEnabled == true {
                        NotificationConstant.isNotificationEnabled = false
                    }
                    //notifications disabled, going from off to on
                    else {
                        NotificationConstant.isNotificationEnabled = true
                    }
                    self.synchronizeFollowUpComponents(animated: true)
                }
            case .denied:
                DispatchQueue.main.async {
                    Utils.willShowAlert(title: "Notifcations Disabled", message: "To enable notifications go to the Settings App -> Notifications -> Pupotty and enable \"Allow Notifications\"")
                    
                    let switchDisableTimer = Timer(fireAt: Date().addingTimeInterval(0.15), interval: -1, target: self, selector: #selector(self.disableIsNotificationEnabledSwitch), userInfo: nil, repeats: false)
                    
                    RunLoop.main.add(switchDisableTimer, forMode: .common)
                    
                    self.synchonrizeAllNotificationSwitches(animated: true)
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, error) in
                    NotificationConstant.isNotificationAuthorized = isGranted
                    NotificationConstant.isNotificationEnabled = isGranted
                    NotificationConstant.shouldFollowUp = isGranted
                    
                    DispatchQueue.main.async {
                        self.synchonrizeAllNotificationSwitches(animated: true)
                    }
                    
                }
            case .provisional:
                print(".provisional")
            case .ephemeral:
                print(".ephemeral")
            @unknown default:
                print("unknown auth status")
            }
        }
        
        
        
    }
    
    @objc private func disableIsNotificationEnabledSwitch(){
        self.notificationToggleSwitch.setOn(false, animated: true)
    }
    
    func synchonrizeAllNotificationSwitches(animated: Bool){
        //If disconnect between stored and displayed
        if notificationToggleSwitch.isOn != NotificationConstant.isNotificationEnabled {
            notificationToggleSwitch.setOn(NotificationConstant.isNotificationEnabled, animated: true)
        }
        self.synchronizeFollowUpComponents(animated: animated)
    }
    
    
    //MARK: - Follow Up Notification
    
    @IBOutlet weak var followUpReminderLabel: CustomLabel!
    
    @IBOutlet private weak var followUpToggleSwitch: UISwitch!
    
    @IBAction private func didToggleFollowUp(_ sender: Any) {
        NotificationConstant.shouldFollowUp = followUpToggleSwitch.isOn
    }
    
    private func synchronizeFollowUpComponents(animated: Bool){
            //notifications are enabled
            if NotificationConstant.isNotificationEnabled == true {
                followUpToggleSwitch.isEnabled = true
                followUpToggleSwitch.setOn(NotificationConstant.shouldFollowUp, animated: animated)
                
                followUpDelayInterval.isEnabled = true
            }
            //notifications are disabled
            else {
                followUpToggleSwitch.isEnabled = false
                followUpToggleSwitch.setOn(false, animated: animated)
                NotificationConstant.shouldFollowUp = false
                
                followUpDelayInterval.isEnabled = false
            }
    }
    
    //MARK: - Follow Up Delay
    
    @IBOutlet weak var followUpDelayInterval: UIDatePicker!
    
    @IBAction func didUpdateFollowUpDelay(_ sender: Any) {
        NotificationConstant.followUpDelay = followUpDelayInterval.countDownDuration
    }
    
    
    //MARK: - Pause
    ///Switch for pause all timers
    @IBOutlet private weak var pauseToggleSwitch: UISwitch!
    
    ///If the pause all timers switch it triggered, calls thing function
    @IBAction private func didTogglePause(_ sender: Any) {
        delegate.didTogglePause(newPauseState: pauseToggleSwitch.isOn)
    }
    
    ///Synchronizes the isPaused switch enable and isOn variables to reflect that amount of timers active, if non are active then locks user from changing switch
    private func synchronizeIsPaused(){
        if MainTabBarViewController.staticDogManager.enabledTimersCount == 0{
            TimingManager.isPaused = false
            self.pauseToggleSwitch.isOn = false
            self.pauseToggleSwitch.isEnabled = false
        }
        else {
            self.pauseToggleSwitch.isEnabled = true
        }
    }
    
    //MARK: - Snooze
    
    @IBOutlet private weak var snoozeLengthLabel: CustomLabel!
    @IBOutlet private weak var snoozeInterval: UIDatePicker!
    
    @IBAction private func didUpdateSnoozeInterval(_ sender: Any) {
        TimerConstant.defaultSnooze = snoozeInterval.countDownDuration
    }
    
    //MARK: - Tool Tip
    
    
        
        private var currentToolTip: ToolTipView?
        
        @IBOutlet private weak var followUpNotificationToolTip: UIButton!
    
        @IBAction private func didClickFollowUpNotificationToolTip(_ sender: Any) {
            followUpNotificationToolTip.isUserInteractionEnabled = false
            
            if currentToolTip != nil {
                hideToolTip(sourceButton: followUpNotificationToolTip)
            }
            else {
                showToolTip(sourceButton: followUpNotificationToolTip, message: "Sends a follow up \nnotification if you don't\nrespond to the first one.")
                //"Sends a follow up \nnotification if the first one\nis not responded to"
            }
        }
    
    @IBOutlet private weak var snoozeLengthToolTip: UIButton!
    
    @IBAction private func didClickSnoozeLengthToolTip(_ sender: Any) {
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
    
    //MARK: - Reset
    @IBAction private func willReset(_ sender: Any) {
        
         let alertController = GeneralAlertController(
             title: "Are you sure you want to reset?",
             message: "This action will delete and reset all data to default, in the process restarting the app.",
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
        
        let alertCancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
         
         alertController.addAction(alertReset)
         alertController.addAction(alertCancel)
         
         AlertPresenter.shared.enqueueAlertForPresentation(alertController)
         
    }
    
    @objc private func showRestartMessage(){
        let alertController = GeneralAlertController(
            title: "Restarting now....",
            message: nil,
            preferredStyle: .alert)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            exit(-1)
        }
    }
    
    //MARK: - Properties
    
    var delegate: SettingsViewControllerDelegate! = nil
    
    @IBOutlet weak var scrollViewContainerForAll: UIView!
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followUpDelayInterval.countDownDuration = NotificationConstant.followUpDelay
        snoozeInterval.countDownDuration = TimerConstant.defaultSnooze
        pauseToggleSwitch.isOn = TimingManager.isPaused
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(willHideToolTip))
        self.view.addGestureRecognizer(tap)
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
        
        notificationToggleSwitch.isOn = NotificationConstant.isNotificationEnabled
        synchronizeFollowUpComponents(animated: false)
        synchronizeIsPaused()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideToolTip()
    }
    
    private func setupConstraints(){
        func setupFollowUpLabelWidth(){
            var followUpReminderLabelWidth: CGFloat {
                let neededConstraintSpace: CGFloat = 10.0 + 3.0 + 3.0 + 45.0
                let otherButtonSpace: CGFloat = followUpToggleSwitch.frame.width + followUpNotificationToolTip.frame.width
                let maximumWidth: CGFloat = view.frame.width - otherButtonSpace - neededConstraintSpace
                
                let neededLabelSize: CGSize = (followUpReminderLabel.text?.boundingFrom(font: followUpReminderLabel.font, height: followUpReminderLabel.frame.height))!
                
                let neededLabelWidth: CGFloat = neededLabelSize.width
                
                if neededLabelWidth > maximumWidth {
                    return maximumWidth
                }
                else {
                    return neededLabelWidth
                }
            }
            
            let followUpLabelConstraint = NSLayoutConstraint(item: followUpReminderLabel!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: followUpReminderLabelWidth)
            followUpReminderLabel.addConstraint(followUpLabelConstraint)
            NSLayoutConstraint.activate([followUpLabelConstraint])
        }
        
         func setupSnoozeLengthLabelWidth(){
             var snoozeLengthLabelWidth: CGFloat {
                 let neededConstraintSpace: CGFloat = 10.0 + 3.0 + 3.0 + 45.0
                 let otherButtonSpace: CGFloat = snoozeLengthLabel.frame.width + snoozeLengthToolTip.frame.width
                 let maximumWidth: CGFloat = view.frame.width - otherButtonSpace - neededConstraintSpace
                 
                 let neededLabelSize: CGSize = (snoozeLengthLabel.text?.boundingFrom(font: snoozeLengthLabel.font, height: snoozeLengthLabel.frame.height))!
                 
                 let neededLabelWidth: CGFloat = neededLabelSize.width
                 
                 if neededLabelWidth > maximumWidth {
                     return maximumWidth
                 }
                 else {
                     return neededLabelWidth
                 }
             }
             
             let snoozeLengthConstraint = NSLayoutConstraint(item: snoozeLengthLabel!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: snoozeLengthLabelWidth)
            snoozeLengthLabel.addConstraint(snoozeLengthConstraint)
             NSLayoutConstraint.activate([snoozeLengthConstraint])
         }
         
        
       
        
        setupFollowUpLabelWidth()
        setupSnoozeLengthLabelWidth()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
}
