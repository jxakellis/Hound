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
        dismissKeyboard()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
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
        
        // inside of the predefined ReminderAction
        if indexPath.row < ReminderAction.allCases.count {
            customCell.label.text = ReminderAction.allCases[indexPath.row].rawValue
        }
        // a user generated custom name
        else {
            customCell.label.text = "Custom: \(LocalConfiguration.reminderCustomActionNames[indexPath.row - ReminderAction.allCases.count])"
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        return ReminderAction.allCases.count + LocalConfiguration.reminderCustomActionNames.count
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
        selectedCell.didToggleSelect(newSelectionStatus: true)
        selectedIndexPath = indexPath
        
        // inside of the predefined LogAction
        if indexPath.row < ReminderAction.allCases.count {
            reminderActionLabel.text = ReminderAction.allCases[indexPath.row].rawValue
            selectedReminderAction = ReminderAction.allCases[indexPath.row]
        }
        // a user generated custom name
        else {
            reminderActionLabel.text = "Custom: \(LocalConfiguration.reminderCustomActionNames[indexPath.row - ReminderAction.allCases.count])"
            selectedReminderAction = ReminderAction.custom
            reminderCustomActionNameTextField.text = LocalConfiguration.reminderCustomActionNames[indexPath.row - ReminderAction.allCases.count]
        }
        
        dismissKeyboardAndDropDown()
        
        // "Custom" is the last item in ReminderAction
        if indexPath.row < ReminderAction.allCases.count - 1 {
            toggleReminderCustomActionNameTextField(isHidden: true)
        }
        else {
            // if reminder action is custom, then it doesn't hide the special input fields.
            toggleReminderCustomActionNameTextField(isHidden: false)
        }
        
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var containerForAll: UIView!
    
    @IBOutlet private weak var onceContainerView: UIView!
    @IBOutlet private weak var countdownContainerView: UIView!
    @IBOutlet private weak var weeklyContainerView: UIView!
    @IBOutlet private weak var monthlyContainerView: UIView!
    
    @IBOutlet private weak var reminderActionLabel: BorderedUILabel!
    
    /// Text input for customLogActionName
    @IBOutlet private weak var reminderCustomActionNameTextField: BorderedUITextField!
    @IBOutlet private weak var reminderCustomActionNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderCustomActionNameBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderIsEnabledSwitch: UISwitch!
    
    @IBOutlet weak var reminderTypeSegmentedControl: UISegmentedControl!
    
    @IBAction private func didUpdateReminderType(_ sender: UISegmentedControl) {
        onceContainerView.isHidden = !(sender.selectedSegmentIndex == 0)
        countdownContainerView.isHidden = !(sender.selectedSegmentIndex == 1)
        weeklyContainerView.isHidden = !(sender.selectedSegmentIndex == 2)
        monthlyContainerView.isHidden = !(sender.selectedSegmentIndex == 3)
    }
    
    // MARK: - Properties
    
    var targetReminder: Reminder?
    
    private var dogsReminderOneTimeViewController = DogsReminderOneTimeViewController()
    
    private var dogsReminderCountdownViewController = DogsReminderCountdownViewController()
    
    private var dogsReminderWeeklyViewController = DogsReminderWeeklyViewController()
    
    private var dogsReminderMonthlyViewController = DogsReminderMonthlyViewController()
    
    private var initalReminderAction: ReminderAction!
    private var initalReminderCustomActionName: String?
    private var initalReminderIsEnabled: Bool!
    private var initalReminderTypeSegmentedControlIndex: Int!
    
    var initalValuesChanged: Bool {
        if initalReminderAction != selectedReminderAction {
            return true
        }
        else if selectedReminderAction == ReminderAction.custom && initalReminderCustomActionName != reminderCustomActionNameTextField.text {
            return true
        }
        else if initalReminderIsEnabled != reminderIsEnabledSwitch.isOn {
            return true
        }
        else if initalReminderTypeSegmentedControlIndex != reminderTypeSegmentedControl.selectedSegmentIndex {
            return true
        }
        else {
            switch reminderTypeSegmentedControl.selectedSegmentIndex {
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
    
    private let dropDown = DropDownUIView()
    
    private var selectedIndexPath: IndexPath?
    var selectedReminderAction: ReminderAction?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneTimeSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        repeatableSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDown.hideDropDown(removeFromSuperview: true)
    }
    
    // MARK: - Setup
    
    private func oneTimeSetup() {
        setupValues()
        setupGestures()
        setupSegmentedControl()
        
        /// Sets up the values of different variables that is found out from information passed
        func setupValues() {
            
            if targetReminder != nil {
                selectedIndexPath = IndexPath(row: ReminderAction.allCases.firstIndex(of: targetReminder!.reminderAction)!, section: 0)
            }
            
            reminderActionLabel.text = targetReminder?.reminderAction.rawValue ?? ""
            reminderActionLabel.placeholder = "Select an action..."
            selectedReminderAction = targetReminder?.reminderAction ?? ReminderConstant.defaultAction
            
            initalReminderAction = targetReminder?.reminderAction ?? ReminderConstant.defaultAction
            
            reminderCustomActionNameTextField.text = targetReminder?.reminderCustomActionName
            reminderCustomActionNameTextField.placeholder = " Enter a custom action name..."
            reminderCustomActionNameTextField.delegate = self
            
            initalReminderCustomActionName = reminderCustomActionNameTextField.text
            // if == is true, that means it is custom, which means it shouldn't hide so ! reverses to input isHidden: false, reverse for if type is not custom. This is because this text input field is only used for custom types.
            toggleReminderCustomActionNameTextField(isHidden: !(targetReminder?.reminderAction == .custom))
            
            reminderIsEnabledSwitch.isOn = targetReminder?.reminderIsEnabled ?? ReminderConstant.defaultEnable
            
            initalReminderIsEnabled = targetReminder?.reminderIsEnabled ?? ReminderConstant.defaultEnable
        }
        
        /// Sets up gestureRecognizer for dog selector drop down
        func setupGestures() {
            reminderActionLabel.isUserInteractionEnabled = true
            let reminderActionTapGesture = UITapGestureRecognizer(target: self, action: #selector(reminderActionTapped))
            reminderActionTapGesture.delegate = self
            reminderActionTapGesture.cancelsTouchesInView = false
            reminderActionLabel.addGestureRecognizer(reminderActionTapGesture)
            
            let dismissKeyboardAndDropDownTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAndDropDown))
            dismissKeyboardAndDropDownTapGesture.delegate = self
            dismissKeyboardAndDropDownTapGesture.cancelsTouchesInView = false
            containerForAll.addGestureRecognizer(dismissKeyboardAndDropDownTapGesture)
        }
        
        func setupSegmentedControl() {
            reminderTypeSegmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white], for: .normal)
            reminderTypeSegmentedControl.backgroundColor = .systemGray4
            
            onceContainerView.isHidden = true
            countdownContainerView.isHidden = true
            weeklyContainerView.isHidden = true
            monthlyContainerView.isHidden = true
            
            // creating new
            if targetReminder == nil {
                reminderTypeSegmentedControl.selectedSegmentIndex = 1
                countdownContainerView.isHidden = false
            }
            // editing current
            else {
                if targetReminder!.reminderType == .oneTime {
                    reminderTypeSegmentedControl.selectedSegmentIndex = 0
                    onceContainerView.isHidden = false
                }
                // Segmented control setup
                else if targetReminder!.reminderType == .countdown {
                    reminderTypeSegmentedControl.selectedSegmentIndex = 1
                    countdownContainerView.isHidden = false
                }
                else if targetReminder!.reminderType == .weekly {
                    reminderTypeSegmentedControl.selectedSegmentIndex = 2
                    weeklyContainerView.isHidden = false
                }
                else {
                    reminderTypeSegmentedControl.selectedSegmentIndex = 3
                    monthlyContainerView.isHidden = false
                }
            }
            
            // assign value to inital parameter
            initalReminderTypeSegmentedControlIndex = reminderTypeSegmentedControl.selectedSegmentIndex
        }
    }
    
    private func repeatableSetup () {
        setupDropDown()
        func setupDropDown() {
            /// only one dropdown used on the dropdown instance so no identifier needed
            dropDown.dropDownUIViewIdentifier = ""
            dropDown.cellReusableIdentifier = "dropDownCell"
            dropDown.dataSource = self
            dropDown.setUpDropDown(viewPositionReference: reminderActionLabel.frame, offset: 2.0)
            dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
            dropDown.setRowHeight(height: DropDownUIView.rowHeightForBorderedUILabel)
            view.addSubview(dropDown)
        }
    }
    
    // MARK: - Functions
    
    /// Attempts to either create a new reminder or update an existing reminder from the settings chosen by the user. If there are invalid settings (e.g. no weekdays), an error message is sent to the user and nil is returned. If the reminder is valid, a reminder is returned that is ready to be sent to the server.
    func applyReminderSettings() -> Reminder? {
        do {
            guard selectedReminderAction != nil else {
               throw ReminderActionError.blankReminderAction
            }
            
            let reminder: Reminder!
            if targetReminder != nil {
                reminder = targetReminder!.copy() as? Reminder
            }
            else {
                reminder = Reminder()
            }
            
            var trimmedReminderCustomActionName: String? {
                if reminderCustomActionNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    return nil
                }
                else {
                    return reminderCustomActionNameTextField.text
                }
            }
            
            reminder.reminderId = targetReminder?.reminderId ?? reminder.reminderId
            reminder.reminderAction = selectedReminderAction!
            
            if selectedReminderAction == ReminderAction.custom {
                reminder.reminderCustomActionName = trimmedReminderCustomActionName
            }
            reminder.reminderIsEnabled = reminderIsEnabledSwitch.isOn
            
            switch reminderTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                reminder.changeReminderType(newReminderType: .oneTime)
                reminder.oneTimeComponents.oneTimeDate = dogsReminderOneTimeViewController.oneTimeDate
            case 1:
                reminder.changeReminderType(newReminderType: .countdown)
                reminder.countdownComponents.changeExecutionInterval(newExecutionInterval: dogsReminderCountdownViewController.countdown.countDownDuration)
            case 2:
                let weekdays = dogsReminderWeeklyViewController.weekdays
                if weekdays == nil {
                    throw WeeklyComponentsError.weekdayArrayInvalid
                }
                reminder.changeReminderType(newReminderType: .weekly)
                try reminder.weeklyComponents.changeWeekdays(newWeekdays: weekdays!)
                reminder.weeklyComponents.changeDateComponents(newDateComponents: Calendar.current.dateComponents([.hour, .minute], from: dogsReminderWeeklyViewController.timeOfDay.date))
            case 3:
                reminder.changeReminderType(newReminderType: .monthly)
                try reminder.monthlyComponents.changeMonthlyDay(newMonthlyDay: dogsReminderMonthlyViewController.monthlyDay!)
                reminder.monthlyComponents.changeDateComponents(newDateComponents: Calendar.current.dateComponents([.hour, .minute], from: dogsReminderMonthlyViewController.datePicker.date))
            default: break
            }
            
            // updating an existing reminder
            if targetReminder != nil {
                // Checks for differences in time of day, execution interval, weekdays, or time of month. If one is detected then we reset the reminder's whole timing to default
                // If you were 5 minutes in to a 1 hour countdown but then change it to 30 minutes, you would want to be 0 minutes into the new timer and not 5 minutes in like previously.
                
                switch reminder.reminderType {
                case .oneTime:
                    // execution date changed
                    if reminder.oneTimeComponents.oneTimeDate != targetReminder!.oneTimeComponents.oneTimeDate {
                        reminder.prepareForNextAlarm()
                    }
                case .countdown:
                    // execution interval changed
                    if reminder.countdownComponents.executionInterval != targetReminder!.countdownComponents.executionInterval {
                        reminder.prepareForNextAlarm()
                    }
                case .weekly:
                    // time of day or weekdays changed
                    if reminder.weeklyComponents.dateComponents != targetReminder!.weeklyComponents.dateComponents || reminder.weeklyComponents.weekdays != targetReminder!.weeklyComponents.weekdays {
                        reminder.prepareForNextAlarm()
                    }
                case .monthly:
                    // time of day or day of month changed
                    if reminder.monthlyComponents.dateComponents != targetReminder!.monthlyComponents.dateComponents || reminder.monthlyComponents.monthlyDay != targetReminder!.monthlyComponents.monthlyDay {
                        reminder.prepareForNextAlarm()
                    }
                }
            }
            
            return reminder
        }
        catch {
            ErrorManager.alert(forError: error)
            return nil
        }
    }
    
    /// Toggles visability of optional custom log type components, used for a custom name for it
    private func toggleReminderCustomActionNameTextField(isHidden: Bool) {
        if isHidden == false {
            reminderCustomActionNameHeightConstraint.constant = 40.0
            reminderCustomActionNameBottomConstraint.constant = 10.0
            reminderCustomActionNameTextField.isHidden = false
            
        }
        else {
            reminderCustomActionNameHeightConstraint.constant = 0.0
            reminderCustomActionNameBottomConstraint.constant = 0.0
            reminderCustomActionNameTextField.isHidden = true
        }
        containerForAll.setNeedsLayout()
        containerForAll.layoutIfNeeded()
    }
    
    // MARK: - @objc
    
    @objc private func reminderActionTapped() {
        dismissKeyboard()
        dropDown.showDropDown(numberOfRowsToShow: 6.5, selectedIndexPath: selectedIndexPath)
    }
    
    @objc internal override func dismissKeyboard() {
        super.dismissKeyboard()
        if  MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController?.topViewController !=  nil && MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController!.topViewController! is DogsAddDogViewController {
            MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController!.topViewController!.dismissKeyboard()
        }
    }
    
    @objc private func dismissKeyboardAndDropDown() {
        dismissKeyboard()
        dropDown.hideDropDown()
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
