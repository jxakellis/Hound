//
//  SettingsNotificationsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsViewController: UIViewController, UIGestureRecognizerDelegate, DropDownUIViewDataSource {
    
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
        followUpDelayDatePicker.countDownDuration = UserConfiguration.followUpDelay
        
        // fixes issue with first time datepicker updates not triggering function
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.followUpDelayDatePicker.countDownDuration = UserConfiguration.followUpDelay
        }
        
        notificationSoundLabel.text = UserConfiguration.notificationSound.rawValue
        
        // gestures
        self.notificationSoundLabel.isUserInteractionEnabled = true
        notificationSoundLabel.isEnabled = true
        let notificationSoundLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(willShowNotificationSoundDropDown))
        self.notificationSoundLabel.addGestureRecognizer(notificationSoundLabelTapGesture)
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
    
    @IBOutlet private weak var isNotificationEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleIsNotificationEnabled(_ sender: Any) {
        self.hideDropDown()
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        let beforeUpdateIsFollowUpEnabled = UserConfiguration.isFollowUpEnabled
        
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                // needed as  UNUserNotificationCenter.current().getNotificationSettings on other thread
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
                // needed as  UNUserNotificationCenter.current().getNotificationSettings on other thread
                DispatchQueue.main.async {
                    AlertManager.willShowAlert(title: "Notifcations Disabled", message: "To enable notifications go to the Settings App -> Notifications -> Hound and enable \"Allow Notifications\"")
                    
                    let switchDisableTimer = Timer(fire: Date().addingTimeInterval(0.22), interval: -1, repeats: false) { _ in
                        self.synchronizeAllNotificationSwitches(animated: true)
                    }
                    
                    RunLoop.main.add(switchDisableTimer, forMode: .common)
                    
                    // nothing to update (as permissions denied) so we don't tell the server anything
                    
                }
            case .notDetermined:
                NotificationManager.requestNotificationAuthorization {
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
                body[ServerDefaultKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
            }
            if UserConfiguration.isLoudNotification != beforeUpdateIsLoudNotification {
                body[ServerDefaultKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
            }
            if UserConfiguration.isFollowUpEnabled != beforeUpdateIsFollowUpEnabled {
                body[ServerDefaultKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
            }
            if body.keys.isEmpty == false {
                UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
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
        if isNotificationEnabledSwitch.isOn != UserConfiguration.isNotificationEnabled {
            isNotificationEnabledSwitch.setOn(UserConfiguration.isNotificationEnabled, animated: animated)
        }
        self.synchronizeNotificationsComponents(animated: animated)
    }
    
    // MARK: Notification Sound
    
    @IBOutlet weak var notificationSoundLabel: BorderedUILabel!
    
    @objc private func willShowNotificationSoundDropDown(_ sender: Any) {
        if dropDown.isDown == false {
            self.dropDown.showDropDown(numberOfRowsToShow: 6.5, selectedIndexPath: IndexPath(row: NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound)!, section: 1))
        }
        else {
            self.hideDropDown()
        }
        
    }
    
    // MARK: Notification Sound Drop Down
    
    private let dropDown = DropDownUIView()
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        let customCell = cell as! DropDownDefaultTableViewCell
        customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForBorderedUILabel)
        
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
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        return NotificationSound.allCases.count
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        
        // do actions based on a cell selected at a indexPath given a dropDownUIViewIdentifier
        // want to hide the drop down after something is selected
        
        let beforeUpdateNotificationSound = UserConfiguration.notificationSound
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
        let selectedNotificationSound = NotificationSound.allCases[indexPath.row]
        
        // the new cell selected is different that the current sound saved
        if selectedNotificationSound != UserConfiguration.notificationSound {
            
                let unselectedCellIndexPath: IndexPath! = IndexPath(row: NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound)!, section: 0)
                let unselectedCell = self.dropDown.dropDownTableView!.cellForRow(at: unselectedCellIndexPath) as? DropDownDefaultTableViewCell
                unselectedCell?.didToggleSelect(newSelectionStatus: false)
                
                selectedCell.didToggleSelect(newSelectionStatus: true)
                UserConfiguration.notificationSound = selectedNotificationSound
                self.notificationSoundLabel.text = selectedNotificationSound.rawValue
                
                AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())")
                
                let body = [ServerDefaultKeys.notificationSound.rawValue: UserConfiguration.notificationSound.rawValue]
            UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
                    if requestWasSuccessful == false {
                        // error, revert to previous
                        UserConfiguration.notificationSound = beforeUpdateNotificationSound
                        self.notificationSoundLabel.text = beforeUpdateNotificationSound.rawValue
                    }
                }
        }
        // cell selected is the same as the current sound saved
        else {
            AudioManager.stopAudio()
            self.dropDown.hideDropDown()
        }
        
    }
    
    // MARK: Notification Sound Drop Down Functions
    
    private func setUpDropDown() {
        /// only one dropdown used on the dropdown instance so no identifier needed
        dropDown.dropDownUIViewIdentifier = ""
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.dataSource = self
        dropDown.setUpDropDown(viewPositionReference: notificationSoundLabel.frame, offset: 0.0)
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: DropDownUIView.rowHeightForBorderedUILabel)
        scrollView.addSubview(dropDown)
    }
    
    @objc private func hideDropDown() {
        AudioManager.stopAudio()
        dropDown.hideDropDown()
    }
    
    // MARK: - Loud Notifications
    
    @IBOutlet private weak var isLoudNotificationSwitch: UISwitch!
    
    @IBAction private func didToggleIsLoudNotification(_ sender: Any) {
        self.hideDropDown()
        
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        UserConfiguration.isLoudNotification = isLoudNotificationSwitch.isOn
        let body = [ServerDefaultKeys.isLoudNotification.rawValue: UserConfiguration.isLoudNotification]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.isLoudNotification = beforeUpdateIsLoudNotification
                self.isLoudNotificationSwitch.setOn(UserConfiguration.isLoudNotification, animated: true)
            }
        }
    }
    
    // MARK: - Follow Up Notification
    
    @IBOutlet private weak var isFollowUpEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleIsFollowUpEnabled(_ sender: Any) {
        self.hideDropDown()
        
        let beforeUpdateIsFollowUpEnabled =  UserConfiguration.isFollowUpEnabled
        UserConfiguration.isFollowUpEnabled = isFollowUpEnabledSwitch.isOn
        
        if isFollowUpEnabledSwitch.isOn == true {
            followUpDelayDatePicker.isEnabled = true
        }
        else {
            followUpDelayDatePicker.isEnabled = false
        }
        
        let body = [ServerDefaultKeys.isFollowUpEnabled.rawValue: UserConfiguration.isFollowUpEnabled]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.isFollowUpEnabled = beforeUpdateIsFollowUpEnabled
                self.isFollowUpEnabledSwitch.setOn(UserConfiguration.isFollowUpEnabled, animated: true)
                if UserConfiguration.isFollowUpEnabled {
                    self.followUpDelayDatePicker.isEnabled = true
                }
                else {
                    self.followUpDelayDatePicker.isEnabled = false
                }
            }
        }
    }
    
    private func synchronizeNotificationsComponents(animated: Bool) {
        // notifications are enabled
        if UserConfiguration.isNotificationEnabled == true {
            
            notificationSoundLabel.isUserInteractionEnabled = true
            notificationSoundLabel.isEnabled = true
            
            isLoudNotificationSwitch.isEnabled = true
            isLoudNotificationSwitch.setOn(UserConfiguration.isLoudNotification, animated: animated)
            
            isFollowUpEnabledSwitch.isEnabled = true
            isFollowUpEnabledSwitch.setOn(UserConfiguration.isFollowUpEnabled, animated: animated)
            
            if isFollowUpEnabledSwitch.isOn == true {
                followUpDelayDatePicker.isEnabled = true
            }
            else {
                followUpDelayDatePicker.isEnabled = false
            }
        }
        // notifications are disabled
        else {
            
            notificationSoundLabel.isUserInteractionEnabled = false
            notificationSoundLabel.isEnabled = false
            
            self.hideDropDown()
            
            isLoudNotificationSwitch.isEnabled = false
            isLoudNotificationSwitch.setOn(false, animated: animated)
            UserConfiguration.isLoudNotification = false
            
            isFollowUpEnabledSwitch.isEnabled = false
            isFollowUpEnabledSwitch.setOn(false, animated: animated)
            UserConfiguration.isFollowUpEnabled = false
            
            followUpDelayDatePicker.isEnabled = false
        }
    }
    
    // MARK: - Follow Up Delay
    
    @IBOutlet weak var followUpDelayDatePicker: UIDatePicker!
    
    @IBAction private func didUpdateFollowUpDelay(_ sender: Any) {
        self.hideDropDown()
        
        let beforeUpdateFollowUpDelay = UserConfiguration.followUpDelay
        UserConfiguration.followUpDelay = followUpDelayDatePicker.countDownDuration
        
        let body = [ServerDefaultKeys.followUpDelay.rawValue: UserConfiguration.followUpDelay]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UserConfiguration.followUpDelay = beforeUpdateFollowUpDelay
                self.followUpDelayDatePicker.countDownDuration = UserConfiguration.followUpDelay
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
