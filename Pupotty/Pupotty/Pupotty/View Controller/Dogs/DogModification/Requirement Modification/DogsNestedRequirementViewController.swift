//
//  DogsNestedRequirementViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

//Delegate to pass setup requirement back to table view
protocol DogsNestedRequirementViewControllerDelegate {
    func didAddRequirement(sender: Sender, newRequirement: Requirement) throws
    func didUpdateRequirement(sender: Sender, updatedRequirement: Requirement) throws
    func didRemoveRequirement(sender: Sender, removedRequirementUUID: String)
}

class DogsNestedRequirementViewController: UIViewController, DogsRequirementManagerViewControllerDelegate{
    
    //MARK: - Auto Save Trigger
    
    func didUpdateInformation() {
        //do nothing as the only auto save warning should be when the master is exited (this is the sub requirement add field of the super dog updator/adder)
    }
    
    
    //MARK: - DogsRequirementManagerViewControllerDelegate
    
    func didAddRequirement(newRequirement: Requirement) {
        do {
            try delegate.didAddRequirement(sender: Sender(origin: self, localized: self), newRequirement: newRequirement)
            navigationController?.popViewController(animated: true)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
        
    }
    
    func didUpdateRequirement(updatedRequirement: Requirement) {
        do {
            try delegate.didUpdateRequirement(sender: Sender(origin: self, localized: self), updatedRequirement: updatedRequirement)
            navigationController?.popViewController(animated: true)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
    }
    
    //MARK: - IB
    
    @IBOutlet weak var pageNavigationBar: UINavigationItem!
    
    @IBOutlet private weak var saveButton: UIBarButtonItem!
        
    @IBAction private func backButton(_ sender: Any) {
        //self.performSegue(withIdentifier: "unwindToAddDogRequirementTableView", sender: self)
        self.navigationController?.popViewController(animated: true)
        }
    
    @IBOutlet weak var requirementRemoveButton: UIBarButtonItem!
    
    @IBAction func willRemoveRequirement(_ sender: Any) {
        let removeRequirementConfirmation = GeneralAlertController(title: "Are you sure you want to delete \"\(dogsRequirementManagerViewController.requirementAction.text ?? targetRequirement!.requirementType.rawValue)\"", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            self.delegate.didRemoveRequirement(sender: Sender(origin: self, localized: self), removedRequirementUUID: self.targetRequirement!.uuid)
            //self.performSegue(withIdentifier: "unwindToAddDogRequirementTableView", sender: self)
            self.navigationController?.popViewController(animated: true)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeRequirementConfirmation.addAction(alertActionRemove)
        removeRequirementConfirmation.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueAlertForPresentation(removeRequirementConfirmation)
    }
    
    //Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured requirement back to table view.
        @IBAction private func willSave(_ sender: Any) {
            
            dogsRequirementManagerViewController.willSaveRequirement()
          
        }
        
    //MARK: - Properties
    
    var delegate: DogsNestedRequirementViewControllerDelegate! = nil
    
    var dogsRequirementManagerViewController = DogsRequirementManagerViewController()
    
    var targetRequirement: Requirement?
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetRequirement != nil {
            requirementRemoveButton.isEnabled = true
            saveButton.title = "Save"
            pageNavigationBar.title = "Edit Reminder"
        }
        else {
            requirementRemoveButton.isEnabled = false
            saveButton.title = "Add"
            pageNavigationBar.title = "Create Reminder"
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsNestedRequirementManagerViewController"{
            dogsRequirementManagerViewController = segue.destination as! DogsRequirementManagerViewController
            dogsRequirementManagerViewController.delegate = self
            dogsRequirementManagerViewController.targetRequirement = targetRequirement
        }
    }
    
    
}
