//
//  DogsRequirementManagerViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementManagerViewControllerDelegate{
    func didAddRequirement(newRequirement: Requirement)
    func didUpdateRequirement(updatedRequirement: Requirement)
}

class DogsRequirementManagerViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, DogsRequirementCountDownViewControllerDelegate, DogsRequirementTimeOfDayViewControllerDelegate, MakeDropDownDataSourceProtocol{
    
    //MARK: Auto Save Trigger
    
    
    //MARK: - DogsRequirementCountDownViewControllerDelegate and DogsRequirementTimeOfDayViewControllerDelegate
    
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
    }
    
    //MARK: - IB
    
    
    @IBOutlet private weak var containerForAll: UIView!
    
    @IBOutlet private weak var countDownContainerView: UIView!
    
    @IBOutlet private weak var timeOfDayContainerView: UIView!
    
    @IBOutlet weak var requirementAction: BorderedLabel!
    
    @IBOutlet private weak var requirementToggleSwitch: UISwitch!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            countDownContainerView.isHidden = false
            timeOfDayContainerView.isHidden = true
        }
        else {
            countDownContainerView.isHidden = true
            timeOfDayContainerView.isHidden = false
        }
    }
    
    //MARK: - Properties
    
    var delegate: DogsRequirementManagerViewControllerDelegate! = nil
    
    var targetRequirement: Requirement? = nil
    
    var initalRequirementAction: ScheduledLogType? = nil
    var initalEnableStatus: Bool? = nil
    var initalSegmentedIndex: Int? = nil
    
    var initalValuesChanged: Bool {
        if requirementAction.text != initalRequirementAction?.rawValue{
            return true
        }
        else if requirementToggleSwitch.isOn != initalEnableStatus{
            return true
        }
        else if segmentedControl.selectedSegmentIndex != initalSegmentedIndex{
            return true
        }
        else if dogsRequirementCountDownViewController.initalValuesChanged == true{
            return true
        }
        else if dogsRequirementTimeOfDayViewController.initalValuesChanged == true {
            return true
        }
        else {
            return false
        }
    }
    
    private var dogsRequirementCountDownViewController = DogsRequirementCountDownViewController()
    
    private var dogsRequirementTimeOfDayViewController = DogsRequirementTimeOfDayViewController()
    
    private let dropDown = MakeDropDown()
    
    private var dropDownRowHeight: CGFloat = 40
    
    private var selectedIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGestures()
        
        setupSegmentedControl()
        
        if targetRequirement != nil {
            selectedIndexPath = IndexPath(row: ScheduledLogType.allCases.firstIndex(of: targetRequirement!.requirementType)!, section: 0)
        }
        
        //Data setup
        requirementAction.text = targetRequirement?.requirementType.rawValue ?? RequirementConstant.defaultType.rawValue
        initalRequirementAction = targetRequirement?.requirementType ?? RequirementConstant.defaultType
        
        requirementToggleSwitch.isOn = targetRequirement?.getEnable() ?? RequirementConstant.defaultEnable
        initalEnableStatus = targetRequirement?.getEnable() ?? RequirementConstant.defaultEnable
        // Do any additional setup after loading the view.
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
            
            updatedRequirement.uuid = targetRequirement?.uuid ?? updatedRequirement.uuid
            updatedRequirement.requirementType = ScheduledLogType(rawValue: requirementAction.text!)!
            //try updatedRequirement.changeRequirementDescription(newRequirementDescription: requirementDescription.text)
            updatedRequirement.setEnable(newEnableStatus: requirementToggleSwitch.isOn)
            
            let selectedWeekdays = dogsRequirementTimeOfDayViewController.weekdays
            let selectedDayOfMonth = dogsRequirementTimeOfDayViewController.dayOfMonth
            
            if selectedWeekdays != nil && selectedDayOfMonth != nil {
                throw TimeOfDayComponentsError.bothDayIndicatorsActive
            }
            else if selectedWeekdays != nil {
                //even if TOD is not selected, still saves week days
                try updatedRequirement.timeOfDayComponents.changeWeekdays(newWeekdays: selectedWeekdays)
            }
            //day of month
            else {
                try updatedRequirement.timeOfDayComponents.changeDayOfMonth(newDayOfMonth: selectedDayOfMonth)
            }
            
            
            //only saves countdown if countdown mode is selected
            if segmentedControl.selectedSegmentIndex == 0{
                updatedRequirement.changeTimingStyle(newTimingStyle: .countDown)
                updatedRequirement.countDownComponents.changeExecutionInterval(newExecutionInterval: dogsRequirementCountDownViewController.countDown.countDownDuration)
            }
            //only saves TOD if TOD mode is selected, this makes it so if the TOD is not configured and selected then the next time it is opened the datePicker time of day is set to the current (rounded up to neared 5 minutes)
            else if segmentedControl.selectedSegmentIndex == 1{
                updatedRequirement.changeTimingStyle(newTimingStyle: .timeOfDay)
                try! updatedRequirement.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.current.dateComponents([.hour, .minute], from: dogsRequirementTimeOfDayViewController.timeOfDay.date))
                
                
            }
            
            if targetRequirement == nil {
                delegate.didAddRequirement(newRequirement: updatedRequirement)
            }
            else {
                
                //If the executionInterval (the countdown duration) is changed then is changes its execution interval, this is because (for example) if you were 5 minutes in to a 1 hour countdown but then change it to 30 minutes, you would want to be 0 minutes into the new timer and not 5 minutes in like previously.
                if updatedRequirement.countDownComponents.executionInterval != targetRequirement!.countDownComponents.executionInterval && updatedRequirement.timingStyle == .countDown{
                    updatedRequirement.timerReset(shouldLogExecution: false)
                }
                else if updatedRequirement.timingStyle == .timeOfDay &&  (updatedRequirement.timeOfDayComponents.timeOfDayComponent != targetRequirement!.timeOfDayComponents.timeOfDayComponent || updatedRequirement.timeOfDayComponents.weekdays != targetRequirement!.timeOfDayComponents.weekdays || updatedRequirement.timeOfDayComponents.dayOfMonth != targetRequirement!.timeOfDayComponents.dayOfMonth){
                    updatedRequirement.timerReset(shouldLogExecution: false)
                }
                
                delegate.didUpdateRequirement(updatedRequirement: updatedRequirement)
            }
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
    }
    
    private func setupSegmentedControl(){
        self.segmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.white], for: .normal)
        self.segmentedControl.backgroundColor = ColorConstant.gray.rawValue
        
        if targetRequirement == nil {
            segmentedControl.selectedSegmentIndex = 0
            initalSegmentedIndex = 0
            countDownContainerView.isHidden = false
            timeOfDayContainerView.isHidden = true
            
            requirementAction.text = RequirementConstant.defaultType.rawValue
            
            requirementToggleSwitch.isOn = true
        }
        else{
            
            //Segmented control setup
            if targetRequirement!.timingStyle == .countDown {
                segmentedControl.selectedSegmentIndex = 0
                initalSegmentedIndex = 0
                countDownContainerView.isHidden = false
                timeOfDayContainerView.isHidden = true
                
            }
            else {
                segmentedControl.selectedSegmentIndex = 1
                initalSegmentedIndex = 1
                countDownContainerView.isHidden = true
                timeOfDayContainerView.isHidden = false
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
        self.dropDown.showDropDown(height: self.dropDownRowHeight * 5.5, selectedIndexPath: selectedIndexPath)
    }
    
    @objc private func dismissAll(){
        self.dismissKeyboard()
        self.dropDown.hideDropDown()
    }
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsRequirementCountDownViewController"{
            dogsRequirementCountDownViewController = segue.destination as! DogsRequirementCountDownViewController
            dogsRequirementCountDownViewController.delegate = self
            dogsRequirementCountDownViewController.passedInterval = targetRequirement?.countDownComponents.executionInterval
            
        }
        if segue.identifier == "dogsRequirementTimeOfDayViewController"{
            dogsRequirementTimeOfDayViewController = segue.destination as! DogsRequirementTimeOfDayViewController
            dogsRequirementTimeOfDayViewController.delegate = self
            
            if targetRequirement != nil {
                if targetRequirement!.timeOfDayComponents.timeOfDayComponent.hour != nil{
                    dogsRequirementTimeOfDayViewController.passedTimeOfDay = targetRequirement!.timeOfDayComponents.nextTimeOfDay(requirementExecutionBasis: targetRequirement!.executionBasis)
                }
                dogsRequirementTimeOfDayViewController.passedWeekDays = targetRequirement!.timeOfDayComponents.weekdays
                dogsRequirementTimeOfDayViewController.passedDayOfMonth = targetRequirement!.timeOfDayComponents.dayOfMonth
            }
            
            
        }
        
    }
    
    
}
