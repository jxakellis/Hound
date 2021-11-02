//
//  DogsIndependentReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsIndependentReminderViewControllerDelegate {
    func didUpdateReminder(sender: Sender, parentDogName: String, updatedReminder: Reminder) throws
    func didAddReminder(sender: Sender, parentDogName: String, newReminder: Reminder)
    func didRemoveReminder(sender: Sender, parentDogName: String, removedReminderUUID: String)
}

class DogsIndependentReminderViewController: UIViewController, DogsReminderManagerViewControllerDelegate {
    
    
    //MARK: - DogsReminderManagerViewControllerDelegate

    func didAddReminder(newReminder: Reminder) {
        delegate.didAddReminder(sender: Sender(origin: self, localized: self), parentDogName: parentDogName, newReminder: newReminder)
        self.navigationController?.popViewController(animated: true)
    }
    
    func didUpdateReminder(updatedReminder: Reminder) {
        do {
            if isUpdating == true {
                try delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), parentDogName: parentDogName, updatedReminder: updatedReminder)
            }
            else {
                delegate.didAddReminder(sender: Sender(origin: self, localized: self), parentDogName: parentDogName, newReminder: updatedReminder)
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
    @IBOutlet private weak var saveReminderButton: UIButton!
    @IBOutlet private weak var saveReminderButtonBackground: UIButton!
    
    @IBOutlet private weak var cancelUpdateReminderButton: UIButton!
    
    @IBOutlet private weak var cancelUpdateReminderButtonBackground: UIButton!
    
    ///Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder to DogsViewController
    @IBAction private func willSave(_ sender: Any) {
        
        dogsReminderManagerViewController.willSaveReminder()
        
    }
    
    @IBOutlet weak var reminderRemoveButton: UIBarButtonItem!
    
    @IBAction func willRemoveReminder(_ sender: Any) {
        guard targetReminder != nil else {
            return
        }
        let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogsReminderManagerViewController.reminderAction.text ?? targetReminder!.displayTypeName)?", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), parentDogName: self.parentDogName, removedReminderUUID: self.targetReminder!.uuid)
            //self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
            self.navigationController?.popViewController(animated: true)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeReminderConfirmation.addAction(alertActionRemove)
        removeReminderConfirmation.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueAlertForPresentation(removeReminderConfirmation)
    }
    
    ///The cancel / exit button was pressed, dismisses view to complete intended action
    @IBAction private func willCancel(_ sender: Any) {
        //"Any changes you have made won't be saved"
        if dogsReminderManagerViewController.initalValuesChanged == true {
            let unsavedInformationConfirmation = GeneralUIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
            
            let alertActionExit = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { (UIAlertAction) in
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
    
    var delegate: DogsIndependentReminderViewControllerDelegate! = nil
    
    var dogsReminderManagerViewController: DogsReminderManagerViewController = DogsReminderManagerViewController()
    
    var targetReminder: Reminder? = nil
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
        
        self.view.bringSubviewToFront(saveReminderButtonBackground)
        self.view.bringSubviewToFront(saveReminderButton)
        
        self.view.bringSubviewToFront(cancelUpdateReminderButtonBackground)
        self.view.bringSubviewToFront(cancelUpdateReminderButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsUpdateReminderManagerViewController"{
            dogsReminderManagerViewController = segue.destination as! DogsReminderManagerViewController
            dogsReminderManagerViewController.targetReminder = self.targetReminder
            dogsReminderManagerViewController.delegate = self
        }
    }
    

}
