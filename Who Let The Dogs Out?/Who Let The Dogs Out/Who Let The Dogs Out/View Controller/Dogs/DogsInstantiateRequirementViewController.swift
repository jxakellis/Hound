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
    func didAddToList (requirement: Requirement) throws
}

class DogsInstantiateRequirementViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    //MARK: Properties
    
    var delegate: DogsInstantiateRequirementViewControllerDelegate! = nil
    
    @IBOutlet private weak var addToList: UIButton!
    @IBOutlet private weak var requirementName: UITextField!
    @IBOutlet private weak var requirementDescription: UITextField!
    @IBOutlet private weak var requirementInterval: UIDatePicker!
    
    //Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured requirement back to table view.
    @IBAction private func didAddToList(_ sender: Any) {
        var tempRequirement = Requirement(initDate: Date())
        
        do {
            try tempRequirement.changeLabel(newLabel: requirementName.text)
            try tempRequirement.changeDescription(newDescription: requirementDescription.text)
            try tempRequirement.changeInterval(newInterval: requirementInterval.countDownDuration)
            try delegate.didAddToList(requirement: tempRequirement)
            navigationController?.popViewController(animated: true)
        }
        catch {
            ErrorProcessor.handleError(error: error, sender: self)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults()
        
        requirementName.delegate = self
        requirementName.returnKeyType = .done
        
        requirementDescription.delegate = self
        requirementDescription.returnKeyType = .done
        
    }
    
    //default values and configs
    private func defaults(){
        requirementName.text = RequirementConstant.defaultLabel
        requirementDescription.text = RequirementConstant.defaultDescription
        requirementInterval.countDownDuration = TimeInterval(RequirementConstant.defaultTimeInterval)
        
        addToList.layer.cornerRadius = 8.0
    }
}
