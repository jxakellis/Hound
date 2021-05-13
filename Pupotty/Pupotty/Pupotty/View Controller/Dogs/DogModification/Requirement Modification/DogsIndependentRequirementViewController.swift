//
//  DogsIndependentRequirementViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsIndependentRequirementViewControllerDelegate {
    func didUpdateRequirement(sender: Sender, parentDogName: String, updatedRequirement: Requirement) throws
    func didAddRequirement(sender: Sender, parentDogName: String, newRequirement: Requirement)
    func didRemoveRequirement(sender: Sender, parentDogName: String, removedRequirementUUID: String)
}

class DogsIndependentRequirementViewController: UIViewController, DogsRequirementManagerViewControllerDelegate {
    
    
    //MARK: - DogsRequirementManagerViewControllerDelegate

    func didAddRequirement(newRequirement: Requirement) {
        fatalError("shouldn't be possible")
    }
    
    func didUpdateRequirement(updatedRequirement: Requirement) {
        do {
            if isUpdating == true {
                try delegate.didUpdateRequirement(sender: Sender(origin: self, localized: self), parentDogName: parentDogName, updatedRequirement: updatedRequirement)
            }
            else {
                delegate.didAddRequirement(sender: Sender(origin: self, localized: self), parentDogName: parentDogName, newRequirement: updatedRequirement)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
    }
    
    //MARK: - IB
    
    //Buttons to manage the information fate, whether to update or to cancel
    
    @IBOutlet weak var pageNavigationBar: UINavigationItem!
    @IBOutlet private weak var saveRequirementButton: UIButton!
    @IBOutlet private weak var saveRequirementButtonBackground: UIButton!
    
    @IBOutlet private weak var cancelUpdateRequirementButton: UIButton!
    
    @IBOutlet private weak var cancelUpdateRequirementButtonBackground: UIButton!
    
    ///Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured requirement to DogsViewController
    @IBAction private func willSave(_ sender: Any) {
        
        dogsRequirementManagerViewController.willSaveRequirement()
        
    }
    
    @IBOutlet weak var requirementRemoveButton: UIBarButtonItem!
    
    @IBAction func willRemoveRequirement(_ sender: Any) {
        let removeRequirementConfirmation = GeneralAlertController(title: "Are you sure you want to delete \"\(dogsRequirementManagerViewController.requirementAction.text ?? targetRequirement.requirementType.rawValue)\"", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            self.delegate.didRemoveRequirement(sender: Sender(origin: self, localized: self), parentDogName: self.parentDogName, removedRequirementUUID: self.targetRequirement.uuid)
            //self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
            self.navigationController?.popViewController(animated: true)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeRequirementConfirmation.addAction(alertActionRemove)
        removeRequirementConfirmation.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueAlertForPresentation(removeRequirementConfirmation)
    }
    
    ///The cancel / exit button was pressed, dismisses view to complete intended action
    @IBAction private func willCancel(_ sender: Any) {
        //"Any changes you have made won't be saved"
        if dogsRequirementManagerViewController.initalValuesChanged == true {
            let unsavedInformationConfirmation = GeneralAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
            
            let alertActionExit = UIAlertAction(title: "Yes, I don't want to save my new changes", style: .default) { (UIAlertAction) in
                //self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
                self.navigationController?.popViewController(animated: true)
            }
            
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            unsavedInformationConfirmation.addAction(alertActionExit)
            unsavedInformationConfirmation.addAction(alertActionCancel)
            
            AlertPresenter.shared.enqueueAlertForPresentation(unsavedInformationConfirmation)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    //MARK: - Properties
    
    var delegate: DogsIndependentRequirementViewControllerDelegate! = nil
    
    var dogsRequirementManagerViewController: DogsRequirementManagerViewController = DogsRequirementManagerViewController()
    
    var targetRequirement: Requirement = Requirement()
    var isUpdating: Bool = false
    
    var parentDogName: String! = nil
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUpdating == true {
            pageNavigationBar.title = "Edit Reminder"
            pageNavigationBar.rightBarButtonItem!.isEnabled = true
        }
        else {
            pageNavigationBar.title = "Create Reminder"
            pageNavigationBar.rightBarButtonItem!.isEnabled = false
        }
        
        self.view.bringSubviewToFront(saveRequirementButtonBackground)
        self.view.bringSubviewToFront(saveRequirementButton)
        
        self.view.bringSubviewToFront(cancelUpdateRequirementButtonBackground)
        self.view.bringSubviewToFront(cancelUpdateRequirementButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Utils.presenter = self
    }
    
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsUpdateRequirementManagerViewController"{
            dogsRequirementManagerViewController = segue.destination as! DogsRequirementManagerViewController
            dogsRequirementManagerViewController.targetRequirement = self.targetRequirement
            dogsRequirementManagerViewController.delegate = self
        }
    }
    

}
