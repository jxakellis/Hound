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

class DogsInstantiateRequirementViewController: UIViewController, DogsRequirementManagerViewControllerDelegate{
    
    
    //MARK: DogsRequirementManagerViewControllerDelegate
    
    func didAddRequirement(newRequirement: Requirement) {
        do {
            try delegate.didAddRequirement(newRequirement: newRequirement)
            navigationController?.popViewController(animated: true)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
        
    }
    
    func didUpdateRequirement(formerName: String, updatedRequirement: Requirement) {
        do {
            try delegate.didUpdateRequirement(formerName: formerName, updatedRequirement: updatedRequirement)
            navigationController?.popViewController(animated: true)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
    }
    
    //MARK: IB
    
    @IBOutlet private weak var saveButton: UIBarButtonItem!
        
    @IBAction private func backButton(_ sender: Any) {
            performSegue(withIdentifier: "unwindToAddDogRequirementTableView", sender: self)
        }
    //Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured requirement back to table view.
        @IBAction private func willSave(_ sender: Any) {
            
            dogsRequirementManagerViewController.willSaveRequirement()
          
        }
        
    //MARK: Properties
    
    var delegate: DogsInstantiateRequirementViewControllerDelegate! = nil
    
    var dogsRequirementManagerViewController = DogsRequirementManagerViewController()
    
    var setupTuple: (Requirement, Bool) = (RequirementConstant.defaultRequirement, false)
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if setupTuple.1 == true {
            saveButton.title = "Update"
        }
        else {
            saveButton.title = "Add"
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsInstantiateRequirementManagerViewController"{
            dogsRequirementManagerViewController = segue.destination as! DogsRequirementManagerViewController
            dogsRequirementManagerViewController.delegate = self
            dogsRequirementManagerViewController.isUpdating = setupTuple.1
            dogsRequirementManagerViewController.targetRequirement = setupTuple.0
        }
    }
    
    
}
