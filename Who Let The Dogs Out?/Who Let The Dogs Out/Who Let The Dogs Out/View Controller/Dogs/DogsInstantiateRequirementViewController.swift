//
//  DogsInstantiateRequirementViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

//Delegate to pass setup requirement back to table view
protocol DogsInstantiateRequirementViewControllerDelegate {
    func didAddRequirement(newRequirement: Requirement) throws
    func didUpdateRequirement(formerName: String, updatedRequirement: Requirement) throws
}

class DogsInstantiateRequirementViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate{
    
    //MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    //MARK: Properties
    
    var delegate: DogsInstantiateRequirementViewControllerDelegate! = nil
    
    @IBOutlet private weak var requirementName: UITextField!
    @IBOutlet private weak var requirementDescription: UITextField!
    @IBOutlet private weak var requirementInterval: UIDatePicker!
    @IBOutlet private weak var requirementEnableStatus: UISwitch!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func requirementIntervalValueChanged(_ sender: Any) {
        self.dismissKeyboard()
    }
    
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "unwindToAddRequirementTableView", sender: self)
    }
    
    
    //Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured requirement back to table view.
    @IBAction private func willSave(_ sender: Any) {
        let tempRequirement = Requirement()
        
        do {
            try tempRequirement.changeRequirementName(newRequirementName: requirementName.text)
            try tempRequirement.changeRequirementDescription(newRequirementDescription: requirementDescription.text)
            tempRequirement.countDownComponents.changeExecutionInterval(newExecutionInterval: requirementInterval.countDownDuration)
            tempRequirement.setEnable(newEnableStatus: requirementEnableStatus.isOn)
            if setupTuple.1 == false {
                try delegate.didAddRequirement(newRequirement: tempRequirement)
            }
            else {
                try delegate.didUpdateRequirement(formerName: setupTuple.0.requirementName, updatedRequirement: tempRequirement)
            }
            navigationController?.popViewController(animated: true)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
        
    }
    
    var setupTuple: (Requirement, Bool) = (RequirementConstant.defaultRequirement, false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keyboard first responder management
        self.setupToHideKeyboardOnTapOnView()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        requirementInterval.addGestureRecognizer(tap)
        
        requirementName.text = setupTuple.0.requirementName
        requirementDescription.text = setupTuple.0.requirementDescription
        requirementInterval.countDownDuration = setupTuple.0.countDownComponents.executionInterval
        requirementEnableStatus.isOn = setupTuple.0.getEnable()
        if setupTuple.1 == true {
            saveButton.title = "Update"
        }
        else {
            saveButton.title = "Add"
        }
        
        requirementName.delegate = self
        requirementDescription.delegate = self
        
    }
    
    @objc internal override func dismissKeyboard() {
        MainTabBarViewController.mainTabBarViewController.dogsViewController.presentedViewController?.dismissKeyboard()
    }
}
