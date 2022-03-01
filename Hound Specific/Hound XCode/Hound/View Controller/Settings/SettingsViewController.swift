//
//  SettingsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didTogglePause(newPauseState: Bool)
}

class SettingsViewController: UIViewController, DropDownUIViewDataSourceProtocol, UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Logs

    // MARK: - Dark Mode / Theme

    @IBOutlet private weak var darkModeSegmentedControl: UISegmentedControl!

    @IBAction private func segmentedControl(_ sender: Any) {
        self.hideDropDown()

        switch darkModeSegmentedControl.selectedSegmentIndex {
        case 0:
            for window in UIApplication.shared.windows {
                window.overrideUserInterfaceStyle = .light
                AppearanceConstant.darkModeStyle = .light
            }
        case 1:
            for window in UIApplication.shared.windows {
                window.overrideUserInterfaceStyle = .dark
                AppearanceConstant.darkModeStyle = .dark
            }
        default:
            for window in UIApplication.shared.windows {
                window.overrideUserInterfaceStyle = .unspecified
                AppearanceConstant.darkModeStyle = .unspecified
            }
        }
    }

    // MARK: Logs Overview Mode

    @IBOutlet private weak var logsViewModeSegmentedControl: UISegmentedControl!

    @IBAction private func didUpdateLogsViewModeSegmentedControl(_ sender: Any) {
        self.hideDropDown()

        if logsViewModeSegmentedControl.selectedSegmentIndex == 0 {
            AppearanceConstant.isCompactView = true
        }
        else {
            AppearanceConstant.isCompactView = false
        }
    }

    // MARK: - Reminders

    // MARK: - Pause
    /// Switch for pause all timers
    @IBOutlet private weak var pauseToggleSwitch: UISwitch!

    /// If the pause all timers switch it triggered, calls thing function
    @IBAction private func didTogglePause(_ sender: Any) {
        self.hideDropDown()

        delegate.didTogglePause(newPauseState: pauseToggleSwitch.isOn)
    }

    /// Synchronizes the isPaused switch enable and isOn variables to reflect that amount of timers active, if non are active then locks user from changing switch
    private func synchronizeIsPaused() {

        if MainTabBarViewController.staticDogManager.enabledTimersCount == 0 {
            TimingConstant.isPaused = false
            self.pauseToggleSwitch.isOn = false
            self.pauseToggleSwitch.isEnabled = false
        }
        else {
            pauseToggleSwitch.isOn = TimingConstant.isPaused
            self.pauseToggleSwitch.isEnabled = true
        }
    }

    // MARK: - Snooze Length

    @IBOutlet private weak var snoozeLengthLabel: ScaledUILabel!
    @IBOutlet private weak var snoozeInterval: UIDatePicker!

    @IBAction private func didUpdateSnoozeInterval(_ sender: Any) {
        self.hideDropDown()

        TimingConstant.defaultSnoozeLength = snoozeInterval.countDownDuration
    }

    // MARK: - Notifications

    // MARK: - Use Notifications

    @IBOutlet private weak var notificationToggleSwitch: UISwitch!

    @IBAction private func didToggleNotificationEnabled(_ sender: Any) {
        self.hideDropDown()

        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    // notications enabled, going from on to off
                    if NotificationConstant.isNotificationEnabled == true {
                        NotificationConstant.isNotificationEnabled = false
                    }
                    // notifications disabled, going from off to on
                    else {
                        NotificationConstant.isNotificationEnabled = true
                    }
                    self.synchronizeNotificationsComponents(animated: true)
                }
            case .denied:
                DispatchQueue.main.async {
                    AlertManager.willShowAlert(title: "Notifcations Disabled", message: "To enable notifications go to the Settings App -> Notifications -> Hound and enable \"Allow Notifications\"")

                    let switchDisableTimer = Timer(fire: Date().addingTimeInterval(0.22), interval: -1, repeats: false) { _ in
                        self.synchronizeAllNotificationSwitches(animated: true)
                    }

                    RunLoop.main.add(switchDisableTimer, forMode: .common)

                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, _) in
                    NotificationConstant.isNotificationAuthorized = isGranted
                    NotificationConstant.isNotificationEnabled = isGranted
                    NotificationConstant.shouldLoudNotification = isGranted
                    NotificationConstant.shouldFollowUp = isGranted

                    DispatchQueue.main.async {
                        self.synchronizeAllNotificationSwitches(animated: true)
                    }

                }
            case .provisional:
                AppDelegate.generalLogger.fault(".provisional")
            case .ephemeral:
                AppDelegate.generalLogger.fault(".ephemeral")
            @unknown default:
                AppDelegate.generalLogger.fault("unknown auth status")
            }
        }

    }
    /// If disconnect between stored and displayed
    func synchronizeAllNotificationSwitches(animated: Bool) {
        // If disconnect between stored and displayed
        if notificationToggleSwitch.isOn != NotificationConstant.isNotificationEnabled {
            notificationToggleSwitch.setOn(NotificationConstant.isNotificationEnabled, animated: animated)
        }
        self.synchronizeNotificationsComponents(animated: animated)
    }

    // MARK: - Notification Sound

    @IBOutlet weak var notificationSoundLabel: ScaledUILabel!

    @IBOutlet weak var notificationSound: BorderedUILabel!

    @objc private func willShowNotificationSound(_ sender: Any) {
        if dropDown.isDown == false {
            self.dropDown.showDropDown(height: dropDownRowHeight * 6.5, selectedIndexPath: IndexPath(row: NotificationSound.allCases.firstIndex(of: NotificationConstant.notificationSound)!, section: 1))
        }
        else {
            self.hideDropDown()
        }

    }

    // MARK: - DropDownUIViewDataSourceProtocol

    private let dropDown = DropDownUIView()

    private let dropDownRowHeight: CGFloat = 30

    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, DropDownUIViewIdentifier: String) {
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: 12.0)

        customCell.label.text = NotificationSound.allCases[indexPath.row].rawValue

        if NotificationSound.allCases[indexPath.row] == NotificationConstant.notificationSound {
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

        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
        let selectedNotificationSound = NotificationSound.allCases[indexPath.row]

        // the new cell selected is different that the current sound saved
        if selectedNotificationSound != NotificationConstant.notificationSound {

            let unselectedCellIndexPath: IndexPath! = IndexPath(row: NotificationSound.allCases.firstIndex(of: NotificationConstant.notificationSound)!, section: 0)
            let unselectedCell = dropDown.dropDownTableView!.cellForRow(at: unselectedCellIndexPath) as? DropDownDefaultTableViewCell
            unselectedCell?.didToggleSelect(newSelectionStatus: false)

            selectedCell.didToggleSelect(newSelectionStatus: true)
            NotificationConstant.notificationSound = selectedNotificationSound
            notificationSound.text = selectedNotificationSound.rawValue

            DispatchQueue.global().async {
                AudioManager.playAudio(forAudioPath: "\(NotificationConstant.notificationSound.rawValue.lowercased())", isLoud: false)

            }

            // AudioManager.stopAudio()
            // self.dropDown.hideDropDown()
        }
        // cell selected is the same as the current sound saved, do nothing
        else {
            DispatchQueue.global().async {
                AudioManager.playAudio(forAudioPath: "\(NotificationConstant.notificationSound.rawValue.lowercased())", isLoud: false)
            }

        }

    }

    // MARK: - Drop Down Functions

    private func setUpDropDown() {
        dropDown.DropDownUIViewIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.DropDownUIViewDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: notificationSound.frame, offset: 0.0)
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.scrollViewContainerForAll.addSubview(dropDown)
    }

    @objc private func hideDropDown() {
        AudioManager.stopAudio()
        dropDown.hideDropDown()
    }

    // MARK: - Loud Notifications

    @IBOutlet private weak var loudNotificationsLabel: ScaledUILabel!

    @IBOutlet private weak var loudNotificationsToggleSwitch: UISwitch!

    @IBAction private func didToggleLoudNotifications(_ sender: Any) {
        self.hideDropDown()

        NotificationConstant.shouldLoudNotification = loudNotificationsToggleSwitch.isOn
    }

    // MARK: - Follow Up Notification

    @IBOutlet private weak var followUpReminderLabel: ScaledUILabel!

    @IBOutlet private weak var followUpToggleSwitch: UISwitch!

    @IBAction private func didToggleFollowUp(_ sender: Any) {
        self.hideDropDown()

        NotificationConstant.shouldFollowUp = followUpToggleSwitch.isOn

        if followUpToggleSwitch.isOn == true {
            followUpDelayInterval.isEnabled = true
        }
        else {
            followUpDelayInterval.isEnabled = false
        }
    }

    private func synchronizeNotificationsComponents(animated: Bool) {
        // notifications are enabled
        if NotificationConstant.isNotificationEnabled == true {

            notificationSound.isUserInteractionEnabled = true
            notificationSound.isEnabled = true

            loudNotificationsToggleSwitch.isEnabled = true
            loudNotificationsToggleSwitch.setOn(NotificationConstant.shouldLoudNotification, animated: animated)

            followUpToggleSwitch.isEnabled = true
            followUpToggleSwitch.setOn(NotificationConstant.shouldFollowUp, animated: animated)

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
                NotificationConstant.shouldLoudNotification = false

                followUpToggleSwitch.isEnabled = false
                followUpToggleSwitch.setOn(false, animated: animated)
                NotificationConstant.shouldFollowUp = false

            followUpDelayInterval.isEnabled = false
        }
    }

    // MARK: - Follow Up Delay

    @IBOutlet weak var followUpDelayInterval: UIDatePicker!

    @IBAction private func didUpdateFollowUpDelay(_ sender: Any) {
        self.hideDropDown()

        NotificationConstant.followUpDelay = followUpDelayInterval.countDownDuration
    }

    // MARK: - App Info

    @IBOutlet private weak var buildNumber: ScaledUILabel!

    @IBOutlet private weak var copyright: ScaledUILabel!

    // MARK: - Reset
    /*\
     @IBAction private func willReset(_ sender: Any) {
         
         let alertController = GeneralUIAlertController(
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
         
         AlertManager.shared.enqueueAlertForPresentation(alertController)
         
     }
     */

    @objc private func showRestartMessage() {
        let alertController = GeneralUIAlertController(
            title: "Restarting now....",
            message: nil,
            preferredStyle: .alert)

        AlertManager.shared.enqueueAlertForPresentation(alertController)

        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            exit(-1)
        }
    }

    // MARK: - Properties

    weak var delegate: SettingsViewControllerDelegate! = nil

    @IBOutlet private weak var scrollViewContainerForAll: UIView!
    @IBOutlet private weak var scollViewNestedView: UIView!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        // DARK MODE
        darkModeSegmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white], for: .normal)
        darkModeSegmentedControl.backgroundColor = .systemGray4

        // LOGS OVERVIEW MODE
        self.logsViewModeSegmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.white], for: .normal)
        self.logsViewModeSegmentedControl.backgroundColor = .systemGray4

        setUpValues()

        setUpGestures()

        // setupConstraints()
    }

    private func setUpValues() {
        if AppearanceConstant.isCompactView == true {
            logsViewModeSegmentedControl.selectedSegmentIndex = 0
        }
        else {
            logsViewModeSegmentedControl.selectedSegmentIndex = 1
        }

        followUpDelayInterval.countDownDuration = NotificationConstant.followUpDelay
        snoozeInterval.countDownDuration = TimingConstant.defaultSnoozeLength

        // fixes issue with first time datepicker updates not triggering function
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.followUpDelayInterval.countDownDuration = NotificationConstant.followUpDelay
            self.snoozeInterval.countDownDuration = TimingConstant.defaultSnoozeLength
        }

        pauseToggleSwitch.isOn = TimingConstant.isPaused

        notificationSound.text = NotificationConstant.notificationSound.rawValue

        self.buildNumber.text = "Version \(UIApplication.appVersion ?? "nil") - Build \(UIApplication.appBuild)"
        self.copyright.text = "© \(Calendar.current.component(.year, from: Date())) Jonathan Xakellis"
    }

    private func setUpGestures() {
        self.notificationSound.isUserInteractionEnabled = true
        notificationSound.isEnabled = true

        let notificationSoundTapGesture = UITapGestureRecognizer(target: self, action: #selector(willShowNotificationSound))
        self.notificationSound.addGestureRecognizer(notificationSoundTapGesture)

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideDropDown))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        scollViewNestedView.addGestureRecognizer(tap)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self

        // DARK MODE
        switch AppearanceConstant.darkModeStyle.rawValue {
        // system/unspecified
        case 0:
            darkModeSegmentedControl.selectedSegmentIndex = 2
        // light
        case 1:
            darkModeSegmentedControl.selectedSegmentIndex = 0
        // dark
        case 2:
            darkModeSegmentedControl.selectedSegmentIndex = 1
        default:
            darkModeSegmentedControl.selectedSegmentIndex = 2
        }

        // ELSE
        synchronizeAllNotificationSwitches(animated: false)
        synchronizeIsPaused()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDown()
    }

    private func setupConstraints() {

            /*
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
             */

        func setupSnoozeLengthLabelWidth() {
            var snoozeLengthLabelWidth: CGFloat {
                let neededConstraintSpace: CGFloat = 10.0 + 3.0 + 3.0 + 45.0
                let otherButtonSpace: CGFloat = snoozeLengthLabel.frame.width
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

        func setupLoudNotificationLabelWidth() {
            var loudNotificationLabelWidth: CGFloat {
                let neededConstraintSpace: CGFloat = 10.0 + 3.0 + 3.0 + 45.0
                let otherButtonSpace: CGFloat = loudNotificationsLabel.frame.width
                let maximumWidth: CGFloat = view.frame.width - otherButtonSpace - neededConstraintSpace

                let neededLabelSize: CGSize = (loudNotificationsLabel.text?.boundingFrom(font: loudNotificationsLabel.font, height: loudNotificationsLabel.frame.height))!

                let neededLabelWidth: CGFloat = neededLabelSize.width

                if neededLabelWidth > maximumWidth {
                    return maximumWidth
                }
                else {
                    return neededLabelWidth
                }
            }

            let loudNotificationLengthConstraint = NSLayoutConstraint(item: loudNotificationsLabel!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: loudNotificationLabelWidth)
            loudNotificationsLabel.addConstraint(loudNotificationLengthConstraint)
            NSLayoutConstraint.activate([loudNotificationLengthConstraint])
        }

        // setupFollowUpLabelWidth()
        setupSnoozeLengthLabelWidth()
        // setupLoudNotificationLabelWidth()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // cant use self.hideDropDown
        AudioManager.stopAudio()
        dropDown.hideDropDown(removeFromSuperview: true)
    }
}
