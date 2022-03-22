//
//  DogsReminderManagerViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderManagerViewControllerDelegate: AnyObject {
    func didAddReminder(newReminder: Reminder)
    func didUpdateReminder(updatedReminder: Reminder)
}

class DogsReminderManagerViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, DogsReminderCountdownViewControllerDelegate, DogsReminderWeeklyViewControllerDelegate, DropDownUIViewDataSourceProtocol, DogsReminderMonthlyViewControllerDelegate, DogsReminderOnceViewControllerDelegate {

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

    // MARK: - DropDownUIViewDataSourceProtocol

    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, DropDownUIViewIdentifier: String) {
        if DropDownUIViewIdentifier == "DROP_DOWN_NEW"{

            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: 8.0)

            if selectedIndexPath == indexPath {
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }

            customCell.label.text = ReminderAction.allCases[indexPath.row].rawValue
        }
    }

    func numberOfRows(forSection: Int, DropDownUIViewIdentifier: String) -> Int {
        return ReminderAction.allCases.count
    }

    func numberOfSections(DropDownUIViewIdentifier: String) -> Int {
        return 1
    }

    func selectItemInDropDown(indexPath: IndexPath, DropDownUIViewIdentifier: String) {

        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell

        selectedCell.didToggleSelect(newSelectionStatus: true)
        self.selectedIndexPath = indexPath

        reminderAction.text = ReminderAction.allCases[indexPath.row].rawValue
        self.dismissAll()

        // if log type is custom, then it doesn't hide the special input fields. == -> true -> isHidden: false.
        toggleCustomLogTypeName(isHidden: !(reminderAction.text == LogType.custom.rawValue))

    }

    // MARK: - IB

    @IBOutlet private weak var containerForAll: UIView!

    @IBOutlet private weak var onceContainerView: UIView!
    @IBOutlet private weak var countdownContainerView: UIView!
    @IBOutlet private weak var weeklyContainerView: UIView!
    @IBOutlet private weak var monthlyContainerView: UIView!

    @IBOutlet weak var reminderAction: BorderedUILabel!

    /// label for customLogType, not used for input
    @IBOutlet private weak var customReminderActionName: ScaledUILabel!
    /// Used for reconfiguring layout when visability changed
    @IBOutlet private weak var customReminderActionNameBottomConstraint: NSLayoutConstraint!
    /// Text input for customLogTypeName
    @IBOutlet private weak var customReminderActionTextField: UITextField!

    @IBOutlet private weak var reminderToggleSwitch: UISwitch!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction private func segmentedControl(_ sender: UISegmentedControl) {
        onceContainerView.isHidden = !(sender.selectedSegmentIndex == 0)
        countdownContainerView.isHidden = !(sender.selectedSegmentIndex == 1)
        weeklyContainerView.isHidden = !(sender.selectedSegmentIndex == 2)
        monthlyContainerView.isHidden = !(sender.selectedSegmentIndex == 3)
    }

    // MARK: - Properties

    weak var delegate: DogsReminderManagerViewControllerDelegate! = nil

    var targetReminder: Reminder?

    private var initalReminderAction: ReminderAction?
    private var initalCustomReminderAction: String?
    private var initalEnableStatus: Bool?
    private var initalSegmentedIndex: Int?

    var initalValuesChanged: Bool {
        if reminderAction.text != initalReminderAction?.rawValue {
            return true
        }
        else if reminderAction.text == LogType.custom.rawValue && initalCustomReminderAction != customReminderActionTextField.text {
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
                return dogsReminderOnceViewController.initalValuesChanged
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
    private var dogsReminderOnceViewController = DogsReminderOnceViewController()

    private var dogsReminderCountdownViewController = DogsReminderCountdownViewController()

    private var dogsReminderWeeklyViewController = DogsReminderWeeklyViewController()

    private var dogsReminderMonthlyViewController = DogsReminderMonthlyViewController()

    private let dropDown = DropDownUIView()

    private var dropDownRowHeight: CGFloat = 40

    private var selectedIndexPath: IndexPath? = IndexPath(row: 0, section: 0)

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

    func willSaveReminder(parentDogId: Int) {
        let updatedReminder: Reminder!
        if targetReminder != nil {
            updatedReminder = targetReminder!.copy() as? Reminder
        }
        else {
            updatedReminder = Reminder()
        }

        do {

            var trimmedCustomReminderAction: String? {
                if customReminderActionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    return nil
                }
                else {
                    return customReminderActionTextField.text
                }
            }

            updatedReminder.reminderId = targetReminder?.reminderId ?? updatedReminder.reminderId
            updatedReminder.reminderAction = ReminderAction(rawValue: reminderAction.text!)!

            if reminderAction.text == LogType.custom.rawValue {
                updatedReminder.customTypeName = trimmedCustomReminderAction
            }
            updatedReminder.isEnabled = reminderToggleSwitch.isOn

            switch segmentedControl.selectedSegmentIndex {
            case 0:
                updatedReminder.changeReminderType(newReminderType: .oneTime)
                updatedReminder.oneTimeComponents.executionDate = dogsReminderOnceViewController.executionDate
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
                try updatedReminder.monthlyComponents.changeDayOfMonth(newDayOfMonth: dogsReminderMonthlyViewController.dayOfMonth!)
                updatedReminder.monthlyComponents.changeDateComponents(newDateComponents: Calendar.current.dateComponents([.hour, .minute], from: dogsReminderMonthlyViewController.datePicker.date))
            default: break
            }

            // creating a new reminder
            if targetReminder == nil {
                // query server
                RemindersRequest.create(forDogId: parentDogId, forReminder: updatedReminder) { reminderId in
                    // query complete
                    if reminderId != nil {
                        // successful and able to get reminderId, persist locally
                        updatedReminder.reminderId = reminderId!
                        self.delegate.didAddReminder(newReminder: updatedReminder)
                    }
                }

            }
            // updating an existing reminder
            else {

                // Checks for differences in time of day, execution interval, weekdays, or time of month. If one is detected then we reset the reminder's whole timing to default
                // If you were 5 minutes in to a 1 hour countdown but then change it to 30 minutes, you would want to be 0 minutes into the new timer and not 5 minutes in like previously.

                switch updatedReminder.reminderType {
                case .oneTime:
                    // execution date changed
                    if updatedReminder.oneTimeComponents.executionDate != targetReminder!.oneTimeComponents.executionDate {
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
                    if updatedReminder.monthlyComponents.dateComponents != targetReminder!.monthlyComponents.dateComponents || updatedReminder.monthlyComponents.dayOfMonth != targetReminder!.monthlyComponents.dayOfMonth {

                        updatedReminder.prepareForNextAlarm()
                    }
                }

                RemindersRequest.update(forDogId: parentDogId, forReminder: updatedReminder) { requestWasSuccessful in
                    if requestWasSuccessful == true {
                        // successful so we can persist the data locally
                        self.delegate.didUpdateReminder(updatedReminder: updatedReminder)
                    }
                }

            }
        }
        catch {
            ErrorManager.alert(forError: error)
        }
    }

    /// Toggles visability of optional custom log type components, used for a custom name for it
    private func toggleCustomLogTypeName(isHidden: Bool) {
        if isHidden == false {
            for constraint in customReminderActionName.constraints where constraint.firstAttribute == .height {
                constraint.constant = 40.0
            }
            customReminderActionNameBottomConstraint.constant = 10.0
            customReminderActionName.isHidden = false
            customReminderActionTextField.isHidden = false
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
        else {
            for constraint in customReminderActionName.constraints where constraint.firstAttribute == .height {
                constraint.constant = 0.0
            }
            customReminderActionNameBottomConstraint.constant = 0.0
            customReminderActionName.isHidden = true
            customReminderActionTextField.isHidden = true
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
        reminderAction.text = targetReminder?.reminderAction.rawValue ?? ReminderConstant.defaultAction.rawValue
        initalReminderAction = targetReminder?.reminderAction ?? ReminderConstant.defaultAction

        customReminderActionTextField.text = targetReminder?.customTypeName ?? ""
        initalCustomReminderAction = customReminderActionTextField.text
        customReminderActionTextField.delegate = self
        // if == is true, that means it is custom, which means it shouldn't hide so ! reverses to input isHidden: false, reverse for if type is not custom. This is because this text input field is only used for custom types.
        toggleCustomLogTypeName(isHidden: !(targetReminder?.reminderAction == .custom))

        reminderToggleSwitch.isOn = targetReminder?.isEnabled ?? ReminderConstant.defaultEnable
        initalEnableStatus = targetReminder?.isEnabled ?? ReminderConstant.defaultEnable
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

            reminderAction.text = ReminderConstant.defaultType.rawValue

            reminderToggleSwitch.isOn = true
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
        dropDown.DropDownUIViewIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.DropDownUIViewDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: reminderAction.frame, offset: 2.0)
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
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
        self.dropDown.showDropDown(height: self.dropDownRowHeight * 6.5, selectedIndexPath: selectedIndexPath)
    }

    @objc private func dismissAll() {
        self.dismissKeyboard()
        self.dropDown.hideDropDown()
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsReminderOnceViewController"{
            dogsReminderOnceViewController = segue.destination as! DogsReminderOnceViewController
            dogsReminderOnceViewController.delegate = self
            var calculatedPassedDate: Date? {
                if targetReminder == nil || Date().distance(to: targetReminder!.oneTimeComponents.executionDate) < 0 {
                    return nil
                }
                else {
                    return targetReminder!.oneTimeComponents.executionDate
                }
            }
            dogsReminderOnceViewController.passedDate = calculatedPassedDate
        }
        if segue.identifier == "dogsReminderCountdownViewController"{
            dogsReminderCountdownViewController = segue.destination as! DogsReminderCountdownViewController
            dogsReminderCountdownViewController.delegate = self
            dogsReminderCountdownViewController.passedInterval = targetReminder?.countdownComponents.executionInterval

        }
        if segue.identifier == "dogsReminderWeeklyViewController"{
            dogsReminderWeeklyViewController = segue.destination as! DogsReminderWeeklyViewController
            dogsReminderWeeklyViewController.delegate = self

            if targetReminder != nil {
                if targetReminder!.weeklyComponents.dateComponents.hour != nil {
                    dogsReminderWeeklyViewController.passedTimeOfDay = targetReminder!.weeklyComponents.notSkippingExecutionDate(reminderExecutionBasis: targetReminder!.executionBasis)
                }
                dogsReminderWeeklyViewController.passedWeekDays = targetReminder!.weeklyComponents.weekdays
            }

        }
        if segue.identifier == "dogsReminderMonthlyViewController"{
            dogsReminderMonthlyViewController = segue.destination as! DogsReminderMonthlyViewController
            dogsReminderMonthlyViewController.delegate = self

            if targetReminder != nil {
                if targetReminder!.monthlyComponents.dateComponents.hour != nil {
                    dogsReminderMonthlyViewController.passedTimeOfDay = targetReminder!.monthlyComponents.notSkippingExecutionDate(reminderExecutionBasis: targetReminder!.executionBasis)
                }
                dogsReminderMonthlyViewController.passedDayOfMonth = targetReminder!.monthlyComponents.dayOfMonth

            }
        }

    }

}
