//
//  DogsRequirementManagerViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementManagerViewControllerDelegate{
    func didAddRequirement(newRequirement: Requirement)
    func didUpdateRequirement(updatedRequirement: Requirement)
}

class DogsRequirementManagerViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, DogsRequirementCountDownViewControllerDelegate, DogsRequirementWeeklyViewControllerDelegate, MakeDropDownDataSourceProtocol, DogsRequirementMonthlyViewControllerDelegate, DogsRequirementOnceViewControllerDelegate{
    
    //MARK: Auto Save Trigger
    
    
    //MARK: - DogsRequirementCountDownViewControllerDelegate and DogsRequirementWeeklyViewControllerDelegate
    
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
    
    //MARK: - MakeDropDownDataSourceProtocol
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
            
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustConstraints(newValue: 8.0)
            
            if selectedIndexPath == indexPath{
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
            customCell.label.text = ScheduledLogType.allCases[indexPath.row].rawValue
        }
    }
    
    func numberOfRows(forSection: Int, makeDropDownIdentifier: String) -> Int {
        return ScheduledLogType.allCases.count
    }
    
    func numberOfSections(makeDropDownIdentifier: String) -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, makeDropDownIdentifier: String) {
        
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
        
        selectedCell.didToggleSelect(newSelectionStatus: true)
        self.selectedIndexPath = indexPath
        
        requirementAction.text = ScheduledLogType.allCases[indexPath.row].rawValue
        self.dismissAll()
        
        //if log type is custom, then it doesn't hide the special input fields. == -> true -> isHidden: false.
        toggleCustomLogTypeName(isHidden: !(requirementAction.text == KnownLogType.custom.rawValue))
        
        
    }
    
    //MARK: - IB
    
    
    @IBOutlet private weak var containerForAll: UIView!
    
    @IBOutlet private weak var onceContainerView: UIView!
    @IBOutlet private weak var countDownContainerView: UIView!
    @IBOutlet private weak var weeklyContainerView: UIView!
    @IBOutlet private weak var monthlyContainerView: UIView!
    
    @IBOutlet weak var requirementAction: BorderedLabel!
    
    ///label for customLogType, not used for input
    @IBOutlet private weak var customRequirementActionName: CustomLabel!
    ///Used for reconfiguring layout when visability changed
    @IBOutlet private weak var customRequirementActionNameBottomConstraint: NSLayoutConstraint!
    ///Text input for customLogTypeName
    @IBOutlet private weak var customRequirementActionTextField: UITextField!
    
    @IBOutlet private weak var requirementToggleSwitch: UISwitch!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction private func segmentedControl(_ sender: UISegmentedControl) {
        onceContainerView.isHidden = !(sender.selectedSegmentIndex == 0)
        countDownContainerView.isHidden = !(sender.selectedSegmentIndex == 1)
        weeklyContainerView.isHidden = !(sender.selectedSegmentIndex == 2)
        monthlyContainerView.isHidden = !(sender.selectedSegmentIndex == 3)
    }
    
    //MARK: - Properties
    
    var delegate: DogsRequirementManagerViewControllerDelegate! = nil
    
    var targetRequirement: Requirement? = nil
    
    private var initalRequirementAction: ScheduledLogType? = nil
    private var initalCustomRequirementAction: String? = nil
    private var initalEnableStatus: Bool? = nil
    private var initalSegmentedIndex: Int? = nil
    
    var initalValuesChanged: Bool {
        if requirementAction.text != initalRequirementAction?.rawValue{
            return true
        }
        else if requirementAction.text == KnownLogType.custom.rawValue && initalCustomRequirementAction != customRequirementActionTextField.text{
            return true
        }
        else if requirementToggleSwitch.isOn != initalEnableStatus{
            return true
        }
        else if segmentedControl.selectedSegmentIndex != initalSegmentedIndex{
            return true
        }
        else {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                return dogsRequirementOnceViewController.initalValuesChanged
            case 1:
                return dogsRequirementCountDownViewController.initalValuesChanged
            case 2:
                return dogsRequirementWeeklyViewController.initalValuesChanged
            case 3:
                return dogsRequirementMonthlyViewController.initalValuesChanged
            default:
                return false
            }
        }
    }
    private var dogsRequirementOnceViewController = DogsRequirementOnceViewController()
    
    private var dogsRequirementCountDownViewController = DogsRequirementCountDownViewController()
    
    private var dogsRequirementWeeklyViewController = DogsRequirementWeeklyViewController()
    
    private var dogsRequirementMonthlyViewController = DogsRequirementMonthlyViewController()
    
    private let dropDown = MakeDropDown()
    
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
    
    @objc internal override func dismissKeyboard() {
        super.dismissKeyboard()
        if  MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController?.topViewController !=  nil && MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController!.topViewController! is DogsAddDogViewController{
            MainTabBarViewController.mainTabBarViewController.dogsViewController.navigationController!.topViewController!.dismissKeyboard()
        }
    }
    
    func willSaveRequirement(){
        let updatedRequirement: Requirement!
        if targetRequirement != nil{
            updatedRequirement = targetRequirement!.copy() as? Requirement
        }
        else {
            updatedRequirement = Requirement()
        }
        
        
        do {
            
            var trimmedCustomRequirementAction: String? {
                if customRequirementActionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    return nil
                }
                else {
                    return customRequirementActionTextField.text
                }
            }
            
            updatedRequirement.uuid = targetRequirement?.uuid ?? updatedRequirement.uuid
            updatedRequirement.requirementType = ScheduledLogType(rawValue: requirementAction.text!)!
            
            if requirementAction.text == KnownLogType.custom.rawValue{
                updatedRequirement.customTypeName = trimmedCustomRequirementAction
            }
            updatedRequirement.setEnable(newEnableStatus: requirementToggleSwitch.isOn)
            
            if segmentedControl.selectedSegmentIndex == 0 {
                //cannot switch an already created requirement to one time, can possible delete its past logs when one time alarm completes and self destructures
                //if targetRequirement != nil && targetRequirement!.timingStyle != .oneTime{
                //    throw OneTimeComponentsError.requirementAlreadyCreated
               // }
                updatedRequirement.changeTimingStyle(newTimingStyle: .oneTime)
                try! updatedRequirement.oneTimeComponents.changeTimeOfDayComponent(newOneTimeComponents: dogsRequirementOnceViewController.dateComponents!)
            }
            //only saves countdown if selected
            else if segmentedControl.selectedSegmentIndex == 1{
                updatedRequirement.changeTimingStyle(newTimingStyle: .countDown)
                updatedRequirement.countDownComponents.changeExecutionInterval(newExecutionInterval: dogsRequirementCountDownViewController.countDown.countDownDuration)
            }
            //only saves weekly if selected
            else if segmentedControl.selectedSegmentIndex == 2{
                
                let weekdays = dogsRequirementWeeklyViewController.weekdays
                
                if weekdays == nil {
                    throw TimeOfDayComponentsError.invalidWeekdayArray
                }
                
                updatedRequirement.changeTimingStyle(newTimingStyle: .weekly)
                try updatedRequirement.timeOfDayComponents.changeWeekdays(newWeekdays: weekdays)
                try updatedRequirement.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.current.dateComponents([.hour, .minute], from: dogsRequirementWeeklyViewController.timeOfDay.date))
            }
            //only saves monthly if selected
            else {
                updatedRequirement.changeTimingStyle(newTimingStyle: .monthly)
                try! updatedRequirement.timeOfDayComponents.changeDayOfMonth(newDayOfMonth: dogsRequirementMonthlyViewController.dayOfMonth)
                try! updatedRequirement.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.current.dateComponents([.hour, .minute], from: dogsRequirementMonthlyViewController.datePicker.date))
            }
            
            if targetRequirement == nil {
                delegate.didAddRequirement(newRequirement: updatedRequirement)
            }
            else {
                
                //Checks for differences in time of day, execution interval, weekdays, or time of month.
                //If you were 5 minutes in to a 1 hour countdown but then change it to 30 minutes, you would want to be 0 minutes into the new timer and not 5 minutes in like previously.
                
                if updatedRequirement.timingStyle == .oneTime{
                    if updatedRequirement.oneTimeComponents.dateComponents != targetRequirement!.oneTimeComponents.dateComponents{
                        updatedRequirement.timerReset(shouldLogExecution: false)
                    }
                }
                else if updatedRequirement.timingStyle == .countDown{
                    //execution interval changed
                    if updatedRequirement.countDownComponents.executionInterval != targetRequirement!.countDownComponents.executionInterval{
                    updatedRequirement.timerReset(shouldLogExecution: false)
                    }
                }
                //weekly
                else if updatedRequirement.timingStyle == .weekly{
                    //time of day or weekdays changed
                    if updatedRequirement.timeOfDayComponents.timeOfDayComponent != targetRequirement!.timeOfDayComponents.timeOfDayComponent || updatedRequirement.timeOfDayComponents.weekdays != targetRequirement!.timeOfDayComponents.weekdays{
                        updatedRequirement.timerReset(shouldLogExecution: false)
                    }
                }
                //monthly
                else {
                    //time of day or day of month changed
                    if updatedRequirement.timeOfDayComponents.timeOfDayComponent != targetRequirement!.timeOfDayComponents.timeOfDayComponent || updatedRequirement.timeOfDayComponents.dayOfMonth != targetRequirement!.timeOfDayComponents.dayOfMonth{
                        
                        updatedRequirement.timerReset(shouldLogExecution: false)
                    }
                }
                
                delegate.didUpdateRequirement(updatedRequirement: updatedRequirement)
            }
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
    }
    
    ///Toggles visability of optional custom log type components, used for a custom name for it
    private func toggleCustomLogTypeName(isHidden: Bool){
        if isHidden == false {
            for constraint in customRequirementActionName.constraints{
                if constraint.firstAttribute == .height{
                    constraint.constant = 40.0
                }
            }
            customRequirementActionNameBottomConstraint.constant = 10.0
            customRequirementActionName.isHidden = false
            customRequirementActionTextField.isHidden = false
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
        else {
            for constraint in customRequirementActionName.constraints{
                if constraint.firstAttribute == .height{
                    constraint.constant = 0.0
                }
            }
            customRequirementActionNameBottomConstraint.constant = 0.0
            customRequirementActionName.isHidden = true
            customRequirementActionTextField.isHidden = true
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
    }
    
    ///Sets up the values of different variables that is found out from information passed
    private func setupValues(){
        
        if targetRequirement != nil {
            selectedIndexPath = IndexPath(row: ScheduledLogType.allCases.firstIndex(of: targetRequirement!.requirementType)!, section: 0)
        }
        
        //Data setup
        requirementAction.text = targetRequirement?.requirementType.rawValue ?? RequirementConstant.defaultType.rawValue
        initalRequirementAction = targetRequirement?.requirementType ?? RequirementConstant.defaultType
        
        customRequirementActionTextField.text = targetRequirement?.customTypeName ?? ""
        initalCustomRequirementAction = customRequirementActionTextField.text
        customRequirementActionTextField.delegate = self
        //if == is true, that means it is custom, which means it shouldn't hide so ! reverses to input isHidden: false, reverse for if type is not custom. This is because this text input field is only used for custom types.
        toggleCustomLogTypeName(isHidden: !(targetRequirement?.requirementType == .custom))
        
        requirementToggleSwitch.isOn = targetRequirement?.getEnable() ?? RequirementConstant.defaultEnable
        initalEnableStatus = targetRequirement?.getEnable() ?? RequirementConstant.defaultEnable
    }
    
    private func setupSegmentedControl(){
        self.segmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white], for: .normal)
        self.segmentedControl.backgroundColor = .systemGray4
        
        //creating new
        if targetRequirement == nil {
            segmentedControl.selectedSegmentIndex = 1
            initalSegmentedIndex = 1
            onceContainerView.isHidden = true
            countDownContainerView.isHidden = false
            weeklyContainerView.isHidden = true
            monthlyContainerView.isHidden = true
            
            requirementAction.text = RequirementConstant.defaultType.rawValue
            
            requirementToggleSwitch.isOn = true
        }
        //editing current
        else{
            if targetRequirement!.timingStyle == .oneTime {
                segmentedControl.selectedSegmentIndex = 0
                initalSegmentedIndex = 0
                onceContainerView.isHidden = false
                countDownContainerView.isHidden = true
                weeklyContainerView.isHidden = true
                monthlyContainerView.isHidden = true
            }
            //Segmented control setup
            else if targetRequirement!.timingStyle == .countDown {
                segmentedControl.selectedSegmentIndex = 1
                initalSegmentedIndex = 1
                onceContainerView.isHidden = true
                countDownContainerView.isHidden = false
                weeklyContainerView.isHidden = true
                monthlyContainerView.isHidden = true
                
            }
            else if targetRequirement!.timingStyle == .weekly{
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
        dropDown.makeDropDownIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.makeDropDownDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: requirementAction.frame, offset: 2.0)
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDown)
    }
    
    ///Sets up gestureRecognizer for dog selector drop down
    private func setUpGestures(){
        self.requirementAction.isUserInteractionEnabled = true
        let requirementActionTapGesture = UITapGestureRecognizer(target: self, action: #selector(requirementActionTapped))
        self.requirementAction.addGestureRecognizer(requirementActionTapGesture)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAll))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        containerForAll.addGestureRecognizer(tap)
    }
    
    
    @objc private func requirementActionTapped(){
        self.dismissKeyboard()
        self.dropDown.showDropDown(height: self.dropDownRowHeight * 6.5, selectedIndexPath: selectedIndexPath)
    }
    
    @objc private func dismissAll(){
        self.dismissKeyboard()
        self.dropDown.hideDropDown()
    }
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsRequirementOnceViewController"{
            dogsRequirementOnceViewController = segue.destination as! DogsRequirementOnceViewController
            dogsRequirementOnceViewController.delegate = self
            var calculatedPassedDate: Date? {
                if targetRequirement == nil || targetRequirement!.oneTimeComponents.executionDate == nil{
                    return nil
                }
                else if Date().distance(to: targetRequirement!.oneTimeComponents.executionDate!) < 0{
                    return nil
                }
                else {
                    return targetRequirement!.oneTimeComponents.executionDate!
                }
            }
            dogsRequirementOnceViewController.passedDate = calculatedPassedDate
        }
        if segue.identifier == "dogsRequirementCountDownViewController"{
            dogsRequirementCountDownViewController = segue.destination as! DogsRequirementCountDownViewController
            dogsRequirementCountDownViewController.delegate = self
            dogsRequirementCountDownViewController.passedInterval = targetRequirement?.countDownComponents.executionInterval
            
        }
        if segue.identifier == "dogsRequirementWeeklyViewController"{
            dogsRequirementWeeklyViewController = segue.destination as! DogsRequirementWeeklyViewController
            dogsRequirementWeeklyViewController.delegate = self
            
            if targetRequirement != nil {
                if targetRequirement!.timeOfDayComponents.timeOfDayComponent.hour != nil{
                    dogsRequirementWeeklyViewController.passedTimeOfDay = targetRequirement!.timeOfDayComponents.traditionalNextTimeOfDay(executionBasis: targetRequirement!.executionBasis)
                }
                dogsRequirementWeeklyViewController.passedWeekDays = targetRequirement!.timeOfDayComponents.weekdays
            }
            
        }
        if segue.identifier == "dogsRequirementMonthlyViewController"{
            dogsRequirementMonthlyViewController = segue.destination as! DogsRequirementMonthlyViewController
            dogsRequirementMonthlyViewController.delegate = self
            
            if targetRequirement != nil {
                if targetRequirement!.timeOfDayComponents.timeOfDayComponent.hour != nil{
                    dogsRequirementMonthlyViewController.passedTimeOfDay = targetRequirement!.timeOfDayComponents.traditionalNextTimeOfDay(executionBasis: targetRequirement!.executionBasis)
                }
                dogsRequirementMonthlyViewController.passedDayOfMonth = targetRequirement!.timeOfDayComponents.dayOfMonth
                
            }
        }
        
    }
    
    
}
