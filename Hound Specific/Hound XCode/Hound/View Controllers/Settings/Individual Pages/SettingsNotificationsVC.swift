//
//  SettingsNotificationsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsViewController: UIViewController, UIGestureRecognizerDelegate, DropDownUIViewDataSourceProtocol {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Properties
    
    /// holds all the views inside except for the notification sound label. Alls for hiding of the dropDown when anywhere else is clocked
    @IBOutlet weak var containerViewForAll: UIView!
    
    /// Holds containerViewForAll, notificationSound label, and notificationSound drop down
    @IBOutlet weak var scrollView: UIScrollView!
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // values
        followUpDelayInterval.countDownDuration = UserConfiguration.followUpDelay
        
        // fixes issue with first time datepicker updates not triggering function
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.followUpDelayInterval.countDownDuration = UserConfiguration.followUpDelay
        }
        
        notificationSound.text = UserConfiguration.notificationSound.rawValue
        
        // gestures
        self.notificationSound.isUserInteractionEnabled = true
        notificationSound.isEnabled = true
        let notificationSoundTapGesture = UITapGestureRecognizer(target: self, action: #selector(willShowNotificationSound))
        self.notificationSound.addGestureRecognizer(notificationSoundTapGesture)
        // hide drop down when other things touched
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideDropDown))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        containerViewForAll.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
        
        synchronizeAllNotificationSwitches(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDown()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // cant use self.hideDropDown
        AudioManager.stopAudio()
        dropDown.hideDropDown(removeFromSuperview: true)
    }
    
    // MARK: - Individual Settings
    
    // MARK: Use Notifications
    
    @IBOutlet private weak var notificationToggleSwitch: UISwitch!
    
    @IBAction private func didToggleNotificationEnabled(_ sender: Any) {
        self.hideDropDown()
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        let beforeUpdateIsFollowUpEnabled = UserConfiguration.isFollowUpEnabled
        
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    
                    // notications enabled, going from on to off
                    if UserConfiguration.isNotificationEnabled == true {
                        UserConfiguration.isNotificationEnabled = false
                    }
                    // notifications disabled, going from off to on
                    else {
                        UserConfiguration.isNotificationEnabled = true
                    }
                    self.synchronizeNotificationsComponents(animated: true)
                    
                    updateServerUserConfiguration()
                }
            case .denied:
                DispatchQueue.main.async {
                    AlertManager.willShowAlert(title: "Notifcations Disabled", message: "To enable notifications go to the Settings App -> Notifications -> Hound and enable \"Allow Notifications\"")
                    
                    let switchDisableTimer = Timer(fire: Date().addingTimeInterval(0.22), interval: -1, repeats: false) { _ in
                        self.synchronizeAllNotificationSwitches(animated: true)
                    }
                    
                    RunLoop.main.add(switchDisableTimer, forMode: .common)
                    
                    // nothing to update (as permissions denied) so we don't tell the server anything
                    
                }
            case .notDetermined:
                NotificationManager.requestNotificationAuthorization { _ in
                    self.synchronizeAllNotificationSwitches(animated: true)
                }
            case .provisional:
                AppDelegate.generalLogger.fault(".provisional")
            case .ephemeral:
                AppDelegate.generalLogger.fault(".ephemeral")
            @unknown default:
                AppDelegate.generalLogger.fault("unknown auth status")
            }
        }
        
        /// Contact the server about the updated values and, if there is no response or a bad response, revert the values to their previous values. isNotificationAuthorized purposefully excluded as server doesn't need to know that and its value cant exactly just be flipped (as tied to apple notif auth status)
        func updateServerUserConfiguration() {
            var body: [String: Any] = [:]
            // check for if values were changed, if there were then tell the server
            if UserConfiguration.isNotificationEnabled != beforeUpdateIsNotificationEnabled {
                body[UserDefaultsKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
            }
            if UserConfiguration.isLoudNotification != beforeUpdateIsLoudNotification {
                body[UserDefaultsKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
            }
            if UserConfiguration.isFollowUpEnabled != beforeUpdateIsFollowUpEnabled {
                body[UserDefaultsKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
            }
            if body.keys.isEmpty == false {
                UserRequest.update(body: body) { requestWasSuccessful in
                    if requestWasSuccessful == false {
                        // error, revert to previousUserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                        UserConfiguration.isLoudNotification = beforeUpdateIsLoudNotification
                        UserConfiguration.isFollowUpEnabled = beforeUpdateIsFollowUpEnabled
                        
                        self.synchronizeAllNotificationSwitches(animated: true)
                    }
                }
            }
            
        }
        
    }
    /// If disconnect between stored and displayed
    func synchronizeAllNotificationSwitches(animated: Bool) {
        // If disconnect between stored and displayed
        if notificationToggleSwitch.isOn != UserConfiguration.isNotificationEnabled {
            notificationToggleSwitch.setOn(UserConfiguration.isNotificationEnabled, animated: animated)
        }
        self.synchronizeNotificationsComponents(animated: animated)
    }
    
    // MARK: Notification Sound
    
    @IBOutlet weak var notificationSound: BorderedUILabel!
    
    @objc private func willShowNotificationSound(_ sender: Any) {
        if dropDown.isDown == false {
            self.dropDown.showDropDown(height: dropDownRowHeight * 6.5, selectedIndexPath: IndexPath(row: NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound)!, section: 1))
        }
        else {
            self.hideDropDown()
        }
        
    }
    
    // MARK: Notification Sound Drop Down
    
    private let dropDown = DropDownUIView()
    
    private let dropDownRowHeight: CGFloat = 30
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, DropDownUIViewIdentifier: String) {
        let customCell = cell as! DropDownDefaultTableViewCell
        customCell.adjustLeadingTrailing(newConstant: 12.0)
        
        customCell.label.text = NotificationSound.allCases[indexPath.row].rawValue
        
        if NotificationSound.allCases[indexPath.row] == UserConfiguration.notificationSound {
            customCell.didToggleSelect(newSelectionStatus: true)
        }
        else {
            customCell.didToggleSelect(newSelectionStatus: false)
        }
        
        if NotificationSound.allCases[indexPath.row] == NotificationSound.radar {
            customCell.label.text = "Radar (Default)"
        }
        
        // adjust customCell based on indexPath
    }
    
    func numberOfRows(forSection: Int, DropDownUIViewIdentifier: String) -> Int {
        return NotificationSound.allCases.count
    }
    
    func numberOfSections(DropDownUIViewIdentifier: String) -> Int {
        
        return 1
        
    }
    
    func selectItemInDropDown(indexPath: IndexPath, DropDownUIViewIdentifier: String) {
        
        // do actions based on a cell selected at a indexPath given a DropDownUIViewIdentifier
        // want to hide the drop down after something is selected
        
        let beforeUpdateNotificationSound = UserConfiguration.notificationSound
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
        let selectedNotificationSound = NotificationSound.allCases[indexPath.row]
        
        // the new cell selected is different that the current sound saved
        if selectedNotificationSound != UserConfiguration.notificationSound {
            
            DispatchQueue.main.async {
                let unselectedCellIndexPath: IndexPath! = IndexPath(row: NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound)!, section: 0)
                let unselectedCell = self.dropDown.dropDownTableView!.cellForRow(at: unselectedCellIndexPath) as? DropDownDefaultTableViewCell
                unselectedCell?.didToggleSelect(newSelectionStatus: false)
                
                selectedCell.didToggleSelect(newSelectionStatus: true)
                UserConfiguration.notificationSound = selectedNotificationSound
                self.notificationSound.text = selectedNotificationSound.rawValue
                
                AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())", isLoud: false)
                
                let body = [UserDefaultsKeys.notificationSound.rawValue: UserConfiguration.notificationSound.rawValue]
                UserRequest.update(body: body) { requestWasSuccessful in
                    if requestWasSuccessful == false {
                        // error, revert to previous
                        UserConfiguration.notificationSound = beforeUpdateNotificationSound
                        self.notificationSound.text = beforeUpdateNotificationSound.rawValue
                    }
                }
                
            }
            
            // AudioManager.stopAudio()
            // self.dropDown.hideDropDown()
        }
        // cell selected is the same as the current sound saved, do nothing
        else {
            DispatchQueue.global().async {
                AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())", isLoud: false)
            }
            
        }
        
    }
    
    // MARK: Notification Sound Drop Down Functions
    
    private func setUpDropDown() {
        dropDown.DropDownUIViewIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.DropDownUIViewDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: notificationSound.frame, offset: 0.0)
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        scrollView.addSubview(dropDown)
    }
    
    @objc private func hideDropDown() {
        AudioManager.stopAudio()
        dropDown.hideDropDown()
    }
    
    // MARK: - Loud Notifications
    
    @IBOutlet private weak var loudNotificationsToggleSwitch: UISwitch!
    
    @IBAction private func didToggleLoudNotifications(_ sender: Any) {
        self.hideDropDown()
        
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        UserConfiguration.isLoudNotification = loudNotificationsToggleSwitch.isOn
        let body = [UserDefaultsKeys.isLoudNotification.rawValue: UserConfiguration.isLoudNotification]
        UserRequest.update(body: body) { requestWasSuccessful in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.isLoudNotification = beforeUpdateIsLoudNotification
                self.loudNotificationsToggleSwitch.setOn(UserConfiguration.isLoudNotification, animated: true)
            }
        }
    }
    
    // MARK: - Follow Up Notification
    
    @IBOutlet private weak var followUpToggleSwitch: UISwitch!
    
    @IBAction private func didToggleFollowUp(_ sender: Any) {
        self.hideDropDown()
        
        let beforeUpdateIsFollowUpEnabled =  UserConfiguration.isFollowUpEnabled
        UserConfiguration.isFollowUpEnabled = followUpToggleSwitch.isOn
        
        if followUpToggleSwitch.isOn == true {
            followUpDelayInterval.isEnabled = true
        }
        else {
            followUpDelayInterval.isEnabled = false
        }
        
        let body = [UserDefaultsKeys.isFollowUpEnabled.rawValue: UserConfiguration.isFollowUpEnabled]
        UserRequest.update(body: body) { requestWasSuccessful in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.isFollowUpEnabled = beforeUpdateIsFollowUpEnabled
                self.followUpToggleSwitch.setOn(UserConfiguration.isFollowUpEnabled, animated: true)
                if UserConfiguration.isFollowUpEnabled {
                    self.followUpDelayInterval.isEnabled = true
                }
                else {
                    self.followUpDelayInterval.isEnabled = false
                }
            }
        }
    }
    
    private func synchronizeNotificationsComponents(animated: Bool) {
        // notifications are enabled
        if UserConfiguration.isNotificationEnabled == true {
            
            notificationSound.isUserInteractionEnabled = true
            notificationSound.isEnabled = true
            
            loudNotificationsToggleSwitch.isEnabled = true
            loudNotificationsToggleSwitch.setOn(UserConfiguration.isLoudNotification, animated: animated)
            
            followUpToggleSwitch.isEnabled = true
            followUpToggleSwitch.setOn(UserConfiguration.isFollowUpEnabled, animated: animated)
            
            if followUpToggleSwitch.isOn == true {
                followUpDelayInterval.isEnabled = true
            }
            else {
                followUpDelayInterval.isEnabled = false
            }
        }
        // notifications are disabled
        else {
            
            notificationSound.isUserInteractionEnabled = false
            notificationSound.isEnabled = false
            
            self.hideDropDown()
            
            loudNotificationsToggleSwitch.isEnabled = false
            loudNotificationsToggleSwitch.setOn(false, animated: animated)
            UserConfiguration.isLoudNotification = false
            
            followUpToggleSwitch.isEnabled = false
            followUpToggleSwitch.setOn(false, animated: animated)
            UserConfiguration.isFollowUpEnabled = false
            
            followUpDelayInterval.isEnabled = false
        }
    }
    
    // MARK: - Follow Up Delay
    
    @IBOutlet weak var followUpDelayInterval: UIDatePicker!
    
    @IBAction private func didUpdateFollowUpDelay(_ sender: Any) {
        self.hideDropDown()
        
        let beforeUpdateFollowUpDelay = UserConfiguration.followUpDelay
        UserConfiguration.followUpDelay = followUpDelayInterval.countDownDuration
        
        let body = [UserDefaultsKeys.followUpDelay.rawValue: UserConfiguration.followUpDelay]
        UserRequest.update(body: body) { requestWasSuccessful in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.followUpDelay = beforeUpdateFollowUpDelay
                self.followUpDelayInterval.countDownDuration = UserConfiguration.followUpDelay
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
