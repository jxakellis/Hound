//
//  DogsRequirementManagerViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementManagerViewControllerDelegate{
    func didAddRequirement(newRequirement: Requirement)
    func didUpdateRequirement(formerName: String, updatedRequirement: Requirement)
}

class DogsRequirementManagerViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, DogsRequirementCountDownViewControllerDelegate, DogsRequirementTimeOfDayViewControllerDelegate{
    
    //MARK: DogsRequirementCountDownViewControllerDelegate and DogsRequirementTimeOfDayViewControllerDelegate
    
    func willDismissKeyboard() {
        self.dismissKeyboard()
    }
    
    
    //MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: IB
    
    
    
    @IBOutlet private weak var countDownContainerView: UIView!
    
    @IBOutlet private weak var timeOfDayContainerView: UIView!
    
    @IBOutlet private weak var requirementName: UITextField!
    @IBOutlet private weak var requirementDescription: UITextField!
    @IBOutlet private weak var requirementEnableStatus: UISwitch!
    
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
    
    //MARK: Properties
    
    var delegate: DogsRequirementManagerViewControllerDelegate! = nil
    
    var targetRequirement: Requirement? = nil
    
    private var dogsRequirementCountDownViewController = DogsRequirementCountDownViewController()
    
    private var dogsRequirementTimeOfDayViewController = DogsRequirementTimeOfDayViewController()
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.white], for: .normal)
        self.segmentedControl.backgroundColor = ColorConstant.gray.rawValue
        
        if targetRequirement == nil {
            segmentedControl.selectedSegmentIndex = 0
            countDownContainerView.isHidden = false
            timeOfDayContainerView.isHidden = true
            
            requirementName.text = nil
            
            requirementDescription.text = nil
            
            requirementEnableStatus.isOn = true
        }
        else{
            
            //Segmented control setup
            if targetRequirement!.timingStyle == .countDown {
                segmentedControl.selectedSegmentIndex = 0
                countDownContainerView.isHidden = false
                timeOfDayContainerView.isHidden = true
                
            }
            else {
                segmentedControl.selectedSegmentIndex = 1
                countDownContainerView.isHidden = true
                timeOfDayContainerView.isHidden = false
            }
            
            //Data setup
            requirementName.text = targetRequirement!.requirementName
            requirementDescription.text = targetRequirement!.requirementDescription
            requirementEnableStatus.isOn = targetRequirement!.getEnable()
        }
        
        //Keyboard first responder management
        self.setupToHideKeyboardOnTapOnView()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        dogsRequirementCountDownViewController.countDown.addGestureRecognizer(tap)
        dogsRequirementTimeOfDayViewController.timeOfDay.addGestureRecognizer(tap)
        requirementName.delegate = self
        requirementDescription.delegate = self
        
        
        // Do any additional setup after loading the view.
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
            try updatedRequirement.changeRequirementName(newRequirementName: requirementName.text)
            try updatedRequirement.changeRequirementDescription(newRequirementDescription: requirementDescription.text)
            updatedRequirement.setEnable(newEnableStatus: requirementEnableStatus.isOn)
            
            //even if TOD is not selected, still saves week days
            try updatedRequirement.timeOfDayComponents.changeWeekdays(newWeekdays: dogsRequirementTimeOfDayViewController.weekdays)
            
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
                    updatedRequirement.timerReset(didExecuteToUser: false)
                }
                else if updatedRequirement.timingStyle == .timeOfDay &&  (updatedRequirement.timeOfDayComponents.timeOfDayComponent != targetRequirement!.timeOfDayComponents.timeOfDayComponent || updatedRequirement.timeOfDayComponents.weekdays != targetRequirement!.timeOfDayComponents.weekdays){
                    updatedRequirement.timerReset(didExecuteToUser: false)
                }
                
                delegate.didUpdateRequirement(formerName: targetRequirement!.requirementName, updatedRequirement: updatedRequirement)
            }
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
    }
    
    
    
    //MARK: Navigation
    
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
            }
            
            
        }
        
    }
    
    
}
