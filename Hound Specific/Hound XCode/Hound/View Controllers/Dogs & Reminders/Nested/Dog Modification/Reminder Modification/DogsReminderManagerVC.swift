//
//  DogsReminderManagerViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

/*
protocol DogsReminderManagerViewControllerDelegate: AnyObject {
    func didAddReminder(newReminder: Reminder)
    func didUpdateReminder(updatedReminder: Reminder)
}
 */

class DogsReminderManagerViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, DogsReminderCountdownViewControllerDelegate, DogsReminderWeeklyViewControllerDelegate, DropDownUIViewDataSource, DogsReminderMonthlyViewControllerDelegate, DogsReminderOneTimeViewControllerDelegate {

    // MARK: Auto Save Trigger

    // MARK: - DogsReminderCountdownViewControllerDelegate and DogsReminderWeeklyViewControllerDelegate

    func willDismissKeyboard() {
        self.dismissKeyboard()
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    // MARK: - DropDownUIViewDataSource

    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForBorderedUILabel)

            if selectedIndexPath == indexPath {
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }

            customCell.label.text = ReminderAction.allCases[indexPath.row].rawValue
    }

    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        return ReminderAction.allCases.count
    }

    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        return 1
    }

    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {

        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell

        selectedCell.didToggleSelect(newSelectionStatus: true)
        self.selectedIndexPath = indexPath

        reminderAction.text = ReminderAction.allCases[indexPath.row].rawValue
        self.dismissAll()

        // if log type is custom, then it doesn't hide the special input fields. == -> true -> isHidden: false.
        toggleCustomLogActionName(isHidden: !(reminderAction.text == LogAction.custom.rawValue))

    }

    // MARK: - IB

    @IBOutlet private weak var containerForAll: UIView!

    @IBOutlet private weak var onceContainerView: UIView!
    @IBOutlet private weak var countdownContainerView: UIView!
    @IBOutlet private weak var weeklyContainerView: UIView!
    @IBOutlet private weak var monthlyContainerView: UIView!

    @IBOutlet weak var reminderAction: BorderedUILabel!
    
    /// Text input for customLogActionName
    @IBOutlet private weak var customReminderAction: BorderedUITextField!
    @IBOutlet private weak var customReminderActionHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var customReminderActionBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderToggleSwitch: UISwitch!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction private func segmentedControl(_ sender: UISegmentedControl) {
        onceContainerView.isHidden = !(sender.selectedSegmentIndex == 0)
        countdownContainerView.isHidden = !(sender.selectedSegmentIndex == 1)
        weeklyContainerView.isHidden = !(sender.selectedSegmentIndex == 2)
        monthlyContainerView.isHidden = !(sender.selectedSegmentIndex == 3)
    }

    // MARK: - Properties

    // weak var delegate: DogsReminderManagerViewControllerDelegate! = nil

    var targetReminder: Reminder?

    private var initalReminderAction: ReminderAction?
    private var initalCustomReminderAction: String?
    private var initalEnableStatus: Bool?
    private var initalSegmentedIndex: Int?

    var initalValuesChanged: Bool {
        if reminderAction.text != initalReminderAction?.rawValue {
            return true
        }
        else if reminderAction.text == LogAction.custom.rawValue && initalCustomReminderAction != customReminderAction.text {
            return true
        }
        else if reminderToggleSwitch.isOn != initalEnableStatus {
            return true
        }
        else if segmentedControl.selectedSegmentIndex != initalSegmentedIndex {
            return true
        }
        else {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                return dogsReminderOneTimeViewController.initalValuesChanged
            case 1:
                return dogsReminderCountdownViewController.initalValuesChanged
            case 2:
                return dogsReminderWeeklyViewController.initalValuesChanged
            case 3:
                return dogsReminderMonthlyViewController.initalValuesChanged
            default:
                return false
            }
        }
    }
    private var dogsReminderOneTimeViewController = DogsReminderOneTimeViewController()

    private var dogsReminderCountdownViewController = DogsReminderCountdownViewController()

    private var dogsReminderWeeklyViewController = DogsReminderWeeklyViewController()

    private var dogsReminderMonthlyViewController = DogsReminderMonthlyViewController()

    private let dropDown = DropDownUIView()

    private var selectedIndexPath: IndexPath?

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpGestures()

        setupSegmentedControl()

        setupValues()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDown()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDown.hideDropDown(removeFromSuperview: true)
    }

    @objc internal override func dismissKeyboard() {
        super.dismissKeyboard()
        if  MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController?.topViewController !=  nil && MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController!.topViewController! is DogsAddDogViewController {
            MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController!.topViewController!.dismissKeyboard()
        }
    }

    /// Attempts to either create a new reminder or update an existing reminder from the settings chosen by the user. If there are invalid settings (e.g. no weekdays), an error message is sent to the user and nil is returned. If the reminder is valid, a reminder is returned that is ready to be sent to the server.
    func applyReminderSettings() -> Reminder? {
        let updatedReminder: Reminder!
        if targetReminder != nil {
            updatedReminder = targetReminder!.copy() as? Reminder
        }
        else {
            updatedReminder = Reminder()
        }

        do {
            
            if reminderAction.text == nil || reminderAction.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                throw ReminderActionError.blankReminderAction
            }

            var trimmedCustomReminderAction: String? {
                if customReminderAction.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    return nil
                }
                else {
                    return customReminderAction.text
                }
            }

            updatedReminder.reminderId = targetReminder?.reminderId ?? updatedReminder.reminderId
            updatedReminder.reminderAction = ReminderAction(rawValue: reminderAction.text!)!

            if reminderAction.text == LogAction.custom.rawValue {
                updatedReminder.reminderCustomActionName = trimmedCustomReminderAction
            }
            updatedReminder.reminderIsEnabled = reminderToggleSwitch.isOn

            switch segmentedControl.selectedSegmentIndex {
            case 0:
                
                updatedReminder.changeReminderType(newReminderType: .oneTime)
                updatedReminder.oneTimeComponents.oneTimeDate = dogsReminderOneTimeViewController.oneTimeDate
            case 1:
                updatedReminder.changeReminderType(newReminderType: .countdown)
                updatedReminder.countdownComponents.changeExecutionInterval(newExecutionInterval: dogsReminderCountdownViewController.countdown.countDownDuration)
            case 2:
                let weekdays = dogsReminderWeeklyViewController.weekdays
                if weekdays == nil {
                    throw WeeklyComponentsError.weekdayArrayInvalid
                }
                updatedReminder.changeReminderType(newReminderType: .weekly)
                try updatedReminder.weeklyComponents.changeWeekdays(newWeekdays: weekdays!)
                updatedReminder.weeklyComponents.changeDateComponents(newDateComponents: Calendar.current.dateComponents([.hour, .minute], from: dogsReminderWeeklyViewController.timeOfDay.date))
            case 3:
                updatedReminder.changeReminderType(newReminderType: .monthly)
                try updatedReminder.monthlyComponents.changeMonthlyDay(newMonthlyDay: dogsReminderMonthlyViewController.monthlyDay!)
                updatedReminder.monthlyComponents.changeDateComponents(newDateComponents: Calendar.current.dateComponents([.hour, .minute], from: dogsReminderMonthlyViewController.datePicker.date))
            default: break
            }

            // creating a new reminder
            if targetReminder == nil {
                return updatedReminder

            }
            // updating an existing reminder
            else {
                // Checks for differences in time of day, execution interval, weekdays, or time of month. If one is detected then we reset the reminder's whole timing to default
                // If you were 5 minutes in to a 1 hour countdown but then change it to 30 minutes, you would want to be 0 minutes into the new timer and not 5 minutes in like previously.

                switch updatedReminder.reminderType {
                case .oneTime:
                    // execution date changed
                    if updatedReminder.oneTimeComponents.oneTimeDate != targetReminder!.oneTimeComponents.oneTimeDate {
                        
                        updatedReminder.prepareForNextAlarm()
                    }

                case .countdown:
                    // execution interval changed
                    if updatedReminder.countdownComponents.executionInterval != targetReminder!.countdownComponents.executionInterval {
                    updatedReminder.prepareForNextAlarm()
                    }
                case .weekly:
                    // time of day or weekdays changed
                    if updatedReminder.weeklyComponents.dateComponents != targetReminder!.weeklyComponents.dateComponents || updatedReminder.weeklyComponents.weekdays != targetReminder!.weeklyComponents.weekdays {
                        updatedReminder.prepareForNextAlarm()
                    }
                case .monthly:
                    // time of day or day of month changed
                    if updatedReminder.monthlyComponents.dateComponents != targetReminder!.monthlyComponents.dateComponents || updatedReminder.monthlyComponents.monthlyDay != targetReminder!.monthlyComponents.monthlyDay {

                        updatedReminder.prepareForNextAlarm()
                    }
                }

                return updatedReminder

            }
        }
        catch {
            ErrorManager.alert(forError: error)
            return nil
        }
    }

    /// Toggles visability of optional custom log type components, used for a custom name for it
    private func toggleCustomLogActionName(isHidden: Bool) {
        if isHidden == false {
            customReminderActionHeightConstraint.constant = 40.0
            customReminderActionBottomConstraint.constant = 10.0
            customReminderAction.isHidden = false
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
        else {
            customReminderActionHeightConstraint.constant = 0.0
            customReminderActionBottomConstraint.constant = 0.0
            customReminderAction.isHidden = true
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
    }

    /// Sets up the values of different variables that is found out from information passed
    private func setupValues() {

        if targetReminder != nil {
            selectedIndexPath = IndexPath(row: ReminderAction.allCases.firstIndex(of: targetReminder!.reminderAction)!, section: 0)
        }

        // Data setup
        // reminderAction.text = targetReminder?.reminderAction.rawValue ?? ReminderConstant.defaultAction.rawValue
        reminderAction.text = targetReminder?.reminderAction.rawValue ?? ""
        reminderAction.placeholder = "Select an action..."
        initalReminderAction = targetReminder?.reminderAction ?? ReminderConstant.defaultAction

        customReminderAction.text = targetReminder?.reminderCustomActionName ?? ""
        customReminderAction.placeholder = " Enter a custom action name..."
        initalCustomReminderAction = customReminderAction.text
        customReminderAction.delegate = self
        // if == is true, that means it is custom, which means it shouldn't hide so ! reverses to input isHidden: false, reverse for if type is not custom. This is because this text input field is only used for custom types.
        toggleCustomLogActionName(isHidden: !(targetReminder?.reminderAction == .custom))

        reminderToggleSwitch.isOn = targetReminder?.reminderIsEnabled ?? ReminderConstant.defaultEnable
        initalEnableStatus = targetReminder?.reminderIsEnabled ?? ReminderConstant.defaultEnable
    }

    private func setupSegmentedControl() {
        self.segmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white], for: .normal)
        self.segmentedControl.backgroundColor = .systemGray4

        // creating new
        if targetReminder == nil {
            segmentedControl.selectedSegmentIndex = 1
            initalSegmentedIndex = 1
            onceContainerView.isHidden = true
            countdownContainerView.isHidden = false
            weeklyContainerView.isHidden = true
            monthlyContainerView.isHidden = true
        }
        // editing current
        else {
            if targetReminder!.reminderType == .oneTime {
                segmentedControl.selectedSegmentIndex = 0
                initalSegmentedIndex = 0
                onceContainerView.isHidden = false
                countdownContainerView.isHidden = true
                weeklyContainerView.isHidden = true
                monthlyContainerView.isHidden = true
            }
            // Segmented control setup
            else if targetReminder!.reminderType == .countdown {
                segmentedControl.selectedSegmentIndex = 1
                initalSegmentedIndex = 1
                onceContainerView.isHidden = true
                countdownContainerView.isHidden = false
                weeklyContainerView.isHidden = true
                monthlyContainerView.isHidden = true

            }
            else if targetReminder!.reminderType == .weekly {
                segmentedControl.selectedSegmentIndex = 2
                initalSegmentedIndex = 2
                onceContainerView.isHidden = true
                countdownContainerView.isHidden = true
                weeklyContainerView.isHidden = false
                monthlyContainerView.isHidden = true
            }
            else {
                segmentedControl.selectedSegmentIndex = 3
                initalSegmentedIndex = 3
                onceContainerView.isHidden = true
                countdownContainerView.isHidden = true
                weeklyContainerView.isHidden = true
                monthlyContainerView.isHidden = false
            }
        }
    }

    // MARK: - Drop Down Functions

    private func setUpDropDown() {
        /// only one dropdown used on the dropdown instance so no identifier needed
        dropDown.dropDownUIViewIdentifier = ""
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.dataSource = self
        dropDown.setUpDropDown(viewPositionReference: reminderAction.frame, offset: 2.0)
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: DropDownUIView.rowHeightForBorderedUILabel)
        self.view.addSubview(dropDown)
    }

    /// Sets up gestureRecognizer for dog selector drop down
    private func setUpGestures() {
        self.reminderAction.isUserInteractionEnabled = true
        let reminderActionTapGesture = UITapGestureRecognizer(target: self, action: #selector(reminderActionTapped))
        self.reminderAction.addGestureRecognizer(reminderActionTapGesture)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAll))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        containerForAll.addGestureRecognizer(tap)
    }

    @objc private func reminderActionTapped() {
        self.dismissKeyboard()
        self.dropDown.showDropDown(numberOfRowsToShow: 6.5, selectedIndexPath: selectedIndexPath)
    }

    @objc private func dismissAll() {
        self.dismissKeyboard()
        self.dropDown.hideDropDown()
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsReminderOneTimeViewController"{
            dogsReminderOneTimeViewController = segue.destination as! DogsReminderOneTimeViewController
            dogsReminderOneTimeViewController.delegate = self
            var calculatedPassedDate: Date? {
                if targetReminder == nil || Date().distance(to: targetReminder!.oneTimeComponents.oneTimeDate) < 0 {
                    return nil
                }
                else {
                    return targetReminder!.oneTimeComponents.oneTimeDate
                }
            }
            dogsReminderOneTimeViewController.passedDate = calculatedPassedDate
        }
        else if segue.identifier == "dogsReminderCountdownViewController"{
            dogsReminderCountdownViewController = segue.destination as! DogsReminderCountdownViewController
            dogsReminderCountdownViewController.delegate = self
            dogsReminderCountdownViewController.passedInterval = targetReminder?.countdownComponents.executionInterval

        }
        else if segue.identifier == "dogsReminderWeeklyViewController"{
            dogsReminderWeeklyViewController = segue.destination as! DogsReminderWeeklyViewController
            dogsReminderWeeklyViewController.delegate = self

            if targetReminder != nil {
                if targetReminder!.weeklyComponents.dateComponents.hour != nil {
                    dogsReminderWeeklyViewController.passedTimeOfDay = targetReminder!.weeklyComponents.notSkippingExecutionDate(reminderExecutionBasis: targetReminder!.reminderExecutionBasis)
                }
                dogsReminderWeeklyViewController.passedWeekDays = targetReminder!.weeklyComponents.weekdays
            }

        }
        else if segue.identifier == "dogsReminderMonthlyViewController"{
            dogsReminderMonthlyViewController = segue.destination as! DogsReminderMonthlyViewController
            dogsReminderMonthlyViewController.delegate = self

            if targetReminder != nil {
                if targetReminder!.monthlyComponents.dateComponents.hour != nil {
                    dogsReminderMonthlyViewController.passedTimeOfDay = targetReminder!.monthlyComponents.notSkippingExecutionDate(reminderExecutionBasis: targetReminder!.reminderExecutionBasis)
                }
                dogsReminderMonthlyViewController.passedMonthlyDay = targetReminder!.monthlyComponents.monthlyDay

            }
        }

    }

}
