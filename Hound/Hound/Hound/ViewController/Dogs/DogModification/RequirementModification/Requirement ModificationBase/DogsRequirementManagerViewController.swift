//
//  DogsReminderManagerViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderManagerViewControllerDelegate{
    func didAddReminder(newReminder: Reminder)
    func didUpdateReminder(updatedReminder: Reminder)
}

class DogsReminderManagerViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, DogsReminderCountDownViewControllerDelegate, DogsReminderWeeklyViewControllerDelegate, DropDownUIViewDataSourceProtocol, DogsReminderMonthlyViewControllerDelegate, DogsReminderOnceViewControllerDelegate{
    
    //MARK: Auto Save Trigger
    
    
    //MARK: - DogsReminderCountDownViewControllerDelegate and DogsReminderWeeklyViewControllerDelegate
    
    func willDismissKeyboard() {
        self.dismissKeyboard()
    }
    
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - DropDownUIViewDataSourceProtocol
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, DropDownUIViewIdentifier: String) {
        if DropDownUIViewIdentifier == "DROP_DOWN_NEW"{
            
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: 8.0)
            
            if selectedIndexPath == indexPath{
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
            customCell.label.text = ScheduledLogType.allCases[indexPath.row].rawValue
        }
    }
    
    func numberOfRows(forSection: Int, DropDownUIViewIdentifier: String) -> Int {
        return ScheduledLogType.allCases.count
    }
    
    func numberOfSections(DropDownUIViewIdentifier: String) -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, DropDownUIViewIdentifier: String) {
        
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
        
        selectedCell.didToggleSelect(newSelectionStatus: true)
        self.selectedIndexPath = indexPath
        
        reminderAction.text = ScheduledLogType.allCases[indexPath.row].rawValue
        self.dismissAll()
        
        //if log type is custom, then it doesn't hide the special input fields. == -> true -> isHidden: false.
        toggleCustomLogTypeName(isHidden: !(reminderAction.text == KnownLogType.custom.rawValue))
        
        
    }
    
    //MARK: - IB
    
    
    @IBOutlet private weak var containerForAll: UIView!
    
    @IBOutlet private weak var onceContainerView: UIView!
    @IBOutlet private weak var countDownContainerView: UIView!
    @IBOutlet private weak var weeklyContainerView: UIView!
    @IBOutlet private weak var monthlyContainerView: UIView!
    
    @IBOutlet weak var reminderAction: BorderedUILabel!
    
    ///label for customLogType, not used for input
    @IBOutlet private weak var customReminderActionName: ScaledUILabel!
    ///Used for reconfiguring layout when visability changed
    @IBOutlet private weak var customReminderActionNameBottomConstraint: NSLayoutConstraint!
    ///Text input for customLogTypeName
    @IBOutlet private weak var customReminderActionTextField: UITextField!
    
    @IBOutlet private weak var reminderToggleSwitch: UISwitch!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction private func segmentedControl(_ sender: UISegmentedControl) {
        onceContainerView.isHidden = !(sender.selectedSegmentIndex == 0)
        countDownContainerView.isHidden = !(sender.selectedSegmentIndex == 1)
        weeklyContainerView.isHidden = !(sender.selectedSegmentIndex == 2)
        monthlyContainerView.isHidden = !(sender.selectedSegmentIndex == 3)
    }
    
    //MARK: - Properties
    
    var delegate: DogsReminderManagerViewControllerDelegate! = nil
    
    var targetReminder: Reminder? = nil
    
    private var initalReminderAction: ScheduledLogType? = nil
    private var initalCustomReminderAction: String? = nil
    private var initalEnableStatus: Bool? = nil
    private var initalSegmentedIndex: Int? = nil
    
    var initalValuesChanged: Bool {
        if reminderAction.text != initalReminderAction?.rawValue{
            return true
        }
        else if reminderAction.text == KnownLogType.custom.rawValue && initalCustomReminderAction != customReminderActionTextField.text{
            return true
        }
        else if reminderToggleSwitch.isOn != initalEnableStatus{
            return true
        }
        else if segmentedControl.selectedSegmentIndex != initalSegmentedIndex{
            return true
        }
        else {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                return dogsReminderOnceViewController.initalValuesChanged
            case 1:
                return dogsReminderCountDownViewController.initalValuesChanged
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
    
    private var dogsReminderCountDownViewController = DogsReminderCountDownViewController()
    
    private var dogsReminderWeeklyViewController = DogsReminderWeeklyViewController()
    
    private var dogsReminderMonthlyViewController = DogsReminderMonthlyViewController()
    
    private let dropDown = DropDownUIView()
    
    private var dropDownRowHeight: CGFloat = 40
    
    private var selectedIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    
    //MARK: - Main
    
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
        if  MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController?.topViewController !=  nil && MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController!.topViewController! is DogsAddDogViewController{
            MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController!.topViewController!.dismissKeyboard()
        }
    }
    
    func willSaveReminder(){
        let updatedReminder: Reminder!
        if targetReminder != nil{
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
            
            updatedReminder.uuid = targetReminder?.uuid ?? updatedReminder.uuid
            updatedReminder.reminderType = ScheduledLogType(rawValue: reminderAction.text!)!
            
            if reminderAction.text == KnownLogType.custom.rawValue{
                updatedReminder.customTypeName = trimmedCustomReminderAction
            }
            updatedReminder.setEnable(newEnableStatus: reminderToggleSwitch.isOn)
            
            if segmentedControl.selectedSegmentIndex == 0 {
                //cannot switch an already created reminder to one time, can possible delete its past logs when one time alarm completes and self destructures
                //if targetReminder != nil && targetReminder!.timingStyle != .oneTime{
                //    throw OneTimeComponentsError.reminderAlreadyCreated
               // }
                updatedReminder.changeTimingStyle(newTimingStyle: .oneTime)
                try! updatedReminder.oneTimeComponents.changeTimeOfDayComponent(newOneTimeComponents: dogsReminderOnceViewController.dateComponents!)
            }
            //only saves countdown if selected
            else if segmentedControl.selectedSegmentIndex == 1{
                updatedReminder.changeTimingStyle(newTimingStyle: .countDown)
                updatedReminder.countDownComponents.changeExecutionInterval(newExecutionInterval: dogsReminderCountDownViewController.countDown.countDownDuration)
            }
            //only saves weekly if selected
            else if segmentedControl.selectedSegmentIndex == 2{
                
                let weekdays = dogsReminderWeeklyViewController.weekdays
                
                if weekdays == nil {
                    throw TimeOfDayComponentsError.invalidWeekdayArray
                }
                
                updatedReminder.changeTimingStyle(newTimingStyle: .weekly)
                try updatedReminder.timeOfDayComponents.changeWeekdays(newWeekdays: weekdays)
                try updatedReminder.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.current.dateComponents([.hour, .minute], from: dogsReminderWeeklyViewController.timeOfDay.date))
            }
            //only saves monthly if selected
            else {
                updatedReminder.changeTimingStyle(newTimingStyle: .monthly)
                try! updatedReminder.timeOfDayComponents.changeDayOfMonth(newDayOfMonth: dogsReminderMonthlyViewController.dayOfMonth)
                try! updatedReminder.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.current.dateComponents([.hour, .minute], from: dogsReminderMonthlyViewController.datePicker.date))
            }
            
            if targetReminder == nil {
                delegate.didAddReminder(newReminder: updatedReminder)
            }
            else {
                
                //Checks for differences in time of day, execution interval, weekdays, or time of month.
                //If you were 5 minutes in to a 1 hour countdown but then change it to 30 minutes, you would want to be 0 minutes into the new timer and not 5 minutes in like previously.
                
                if updatedReminder.timingStyle == .oneTime{
                    if updatedReminder.oneTimeComponents.dateComponents != targetReminder!.oneTimeComponents.dateComponents{
                        updatedReminder.timerReset(shouldLogExecution: false)
                    }
                }
                else if updatedReminder.timingStyle == .countDown{
                    //execution interval changed
                    if updatedReminder.countDownComponents.executionInterval != targetReminder!.countDownComponents.executionInterval{
                    updatedReminder.timerReset(shouldLogExecution: false)
                    }
                }
                //weekly
                else if updatedReminder.timingStyle == .weekly{
                    //time of day or weekdays changed
                    if updatedReminder.timeOfDayComponents.timeOfDayComponent != targetReminder!.timeOfDayComponents.timeOfDayComponent || updatedReminder.timeOfDayComponents.weekdays != targetReminder!.timeOfDayComponents.weekdays{
                        updatedReminder.timerReset(shouldLogExecution: false)
                    }
                }
                //monthly
                else {
                    //time of day or day of month changed
                    if updatedReminder.timeOfDayComponents.timeOfDayComponent != targetReminder!.timeOfDayComponents.timeOfDayComponent || updatedReminder.timeOfDayComponents.dayOfMonth != targetReminder!.timeOfDayComponents.dayOfMonth{
                        
                        updatedReminder.timerReset(shouldLogExecution: false)
                    }
                }
                
                delegate.didUpdateReminder(updatedReminder: updatedReminder)
            }
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
    }
    
    ///Toggles visability of optional custom log type components, used for a custom name for it
    private func toggleCustomLogTypeName(isHidden: Bool){
        if isHidden == false {
            for constraint in customReminderActionName.constraints{
                if constraint.firstAttribute == .height{
                    constraint.constant = 40.0
                }
            }
            customReminderActionNameBottomConstraint.constant = 10.0
            customReminderActionName.isHidden = false
            customReminderActionTextField.isHidden = false
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
        else {
            for constraint in customReminderActionName.constraints{
                if constraint.firstAttribute == .height{
                    constraint.constant = 0.0
                }
            }
            customReminderActionNameBottomConstraint.constant = 0.0
            customReminderActionName.isHidden = true
            customReminderActionTextField.isHidden = true
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
    }
    
    ///Sets up the values of different variables that is found out from information passed
    private func setupValues(){
        
        if targetReminder != nil {
            selectedIndexPath = IndexPath(row: ScheduledLogType.allCases.firstIndex(of: targetReminder!.reminderType)!, section: 0)
        }
        
        //Data setup
        reminderAction.text = targetReminder?.reminderType.rawValue ?? ReminderConstant.defaultType.rawValue
        initalReminderAction = targetReminder?.reminderType ?? ReminderConstant.defaultType
        
        customReminderActionTextField.text = targetReminder?.customTypeName ?? ""
        initalCustomReminderAction = customReminderActionTextField.text
        customReminderActionTextField.delegate = self
        //if == is true, that means it is custom, which means it shouldn't hide so ! reverses to input isHidden: false, reverse for if type is not custom. This is because this text input field is only used for custom types.
        toggleCustomLogTypeName(isHidden: !(targetReminder?.reminderType == .custom))
        
        reminderToggleSwitch.isOn = targetReminder?.getEnable() ?? ReminderConstant.defaultEnable
        initalEnableStatus = targetReminder?.getEnable() ?? ReminderConstant.defaultEnable
    }
    
    private func setupSegmentedControl(){
        self.segmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white], for: .normal)
        self.segmentedControl.backgroundColor = .systemGray4
        
        //creating new
        if targetReminder == nil {
            segmentedControl.selectedSegmentIndex = 1
            initalSegmentedIndex = 1
            onceContainerView.isHidden = true
            countDownContainerView.isHidden = false
            weeklyContainerView.isHidden = true
            monthlyContainerView.isHidden = true
            
            reminderAction.text = ReminderConstant.defaultType.rawValue
            
            reminderToggleSwitch.isOn = true
        }
        //editing current
        else{
            if targetReminder!.timingStyle == .oneTime {
                segmentedControl.selectedSegmentIndex = 0
                initalSegmentedIndex = 0
                onceContainerView.isHidden = false
                countDownContainerView.isHidden = true
                weeklyContainerView.isHidden = true
                monthlyContainerView.isHidden = true
            }
            //Segmented control setup
            else if targetReminder!.timingStyle == .countDown {
                segmentedControl.selectedSegmentIndex = 1
                initalSegmentedIndex = 1
                onceContainerView.isHidden = true
                countDownContainerView.isHidden = false
                weeklyContainerView.isHidden = true
                monthlyContainerView.isHidden = true
                
            }
            else if targetReminder!.timingStyle == .weekly{
                segmentedControl.selectedSegmentIndex = 2
                initalSegmentedIndex = 2
                onceContainerView.isHidden = true
                countDownContainerView.isHidden = true
                weeklyContainerView.isHidden = false
                monthlyContainerView.isHidden = true
            }
            else {
                segmentedControl.selectedSegmentIndex = 3
                initalSegmentedIndex = 3
                onceContainerView.isHidden = true
                countDownContainerView.isHidden = true
                weeklyContainerView.isHidden = true
                monthlyContainerView.isHidden = false
            }
        }
    }
    
    //MARK: - Drop Down Functions
    
    private func setUpDropDown(){
        dropDown.DropDownUIViewIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.DropDownUIViewDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: reminderAction.frame, offset: 2.0)
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDown)
    }
    
    ///Sets up gestureRecognizer for dog selector drop down
    private func setUpGestures(){
        self.reminderAction.isUserInteractionEnabled = true
        let reminderActionTapGesture = UITapGestureRecognizer(target: self, action: #selector(reminderActionTapped))
        self.reminderAction.addGestureRecognizer(reminderActionTapGesture)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAll))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        containerForAll.addGestureRecognizer(tap)
    }
    
    
    @objc private func reminderActionTapped(){
        self.dismissKeyboard()
        self.dropDown.showDropDown(height: self.dropDownRowHeight * 6.5, selectedIndexPath: selectedIndexPath)
    }
    
    @objc private func dismissAll(){
        self.dismissKeyboard()
        self.dropDown.hideDropDown()
    }
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsReminderOnceViewController"{
            dogsReminderOnceViewController = segue.destination as! DogsReminderOnceViewController
            dogsReminderOnceViewController.delegate = self
            var calculatedPassedDate: Date? {
                if targetReminder == nil || targetReminder!.oneTimeComponents.executionDate == nil{
                    return nil
                }
                else if Date().distance(to: targetReminder!.oneTimeComponents.executionDate!) < 0{
                    return nil
                }
                else {
                    return targetReminder!.oneTimeComponents.executionDate!
                }
            }
            dogsReminderOnceViewController.passedDate = calculatedPassedDate
        }
        if segue.identifier == "dogsReminderCountDownViewController"{
            dogsReminderCountDownViewController = segue.destination as! DogsReminderCountDownViewController
            dogsReminderCountDownViewController.delegate = self
            dogsReminderCountDownViewController.passedInterval = targetReminder?.countDownComponents.executionInterval
            
        }
        if segue.identifier == "dogsReminderWeeklyViewController"{
            dogsReminderWeeklyViewController = segue.destination as! DogsReminderWeeklyViewController
            dogsReminderWeeklyViewController.delegate = self
            
            if targetReminder != nil {
                if targetReminder!.timeOfDayComponents.timeOfDayComponent.hour != nil{
                    dogsReminderWeeklyViewController.passedTimeOfDay = targetReminder!.timeOfDayComponents.traditionalNextTimeOfDay(executionBasis: targetReminder!.executionBasis)
                }
                dogsReminderWeeklyViewController.passedWeekDays = targetReminder!.timeOfDayComponents.weekdays
            }
            
        }
        if segue.identifier == "dogsReminderMonthlyViewController"{
            dogsReminderMonthlyViewController = segue.destination as! DogsReminderMonthlyViewController
            dogsReminderMonthlyViewController.delegate = self
            
            if targetReminder != nil {
                if targetReminder!.timeOfDayComponents.timeOfDayComponent.hour != nil{
                    dogsReminderMonthlyViewController.passedTimeOfDay = targetReminder!.timeOfDayComponents.traditionalNextTimeOfDay(executionBasis: targetReminder!.executionBasis)
                }
                dogsReminderMonthlyViewController.passedDayOfMonth = targetReminder!.timeOfDayComponents.dayOfMonth
                
            }
        }
        
    }
    
    
}
