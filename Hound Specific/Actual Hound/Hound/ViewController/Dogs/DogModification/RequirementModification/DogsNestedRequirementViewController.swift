//
//  DogsNestedReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

//Delegate to pass setup reminder back to table view
protocol DogsNestedReminderViewControllerDelegate {
    func didAddReminder(sender: Sender, newReminder: Reminder) throws
    func didUpdateReminder(sender: Sender, updatedReminder: Reminder) throws
    func didRemoveReminder(sender: Sender, removedReminderUUID: String)
}

class DogsNestedReminderViewController: UIViewController, DogsReminderManagerViewControllerDelegate{
    
    
    //MARK: - DogsReminderManagerViewControllerDelegate
    
    func didAddReminder(newReminder: Reminder) {
        do {
            try delegate.didAddReminder(sender: Sender(origin: self, localized: self), newReminder: newReminder)
            navigationController?.popViewController(animated: true)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
        
    }
    
    func didUpdateReminder(updatedReminder: Reminder) {
        do {
            try delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), updatedReminder: updatedReminder)
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
        //self.performSegue(withIdentifier: "unwindToAddDogReminderTableView", sender: self)
        self.navigationController?.popViewController(animated: true)
        }
    
    @IBOutlet weak var reminderRemoveButton: UIBarButtonItem!
    
    @IBAction func willRemoveReminder(_ sender: Any) {
        let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogsReminderManagerViewController.reminderAction.text ?? targetReminder!.displayTypeName)?", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), removedReminderUUID: self.targetReminder!.uuid)
            //self.performSegue(withIdentifier: "unwindToAddDogReminderTableView", sender: self)
            self.navigationController?.popViewController(animated: true)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeReminderConfirmation.addAction(alertActionRemove)
        removeReminderConfirmation.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueAlertForPresentation(removeReminderConfirmation)
    }
    
    //Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder back to table view.
        @IBAction private func willSave(_ sender: Any) {
            
            dogsReminderManagerViewController.willSaveReminder()
          
        }
        
    //MARK: - Properties
    
    var delegate: DogsNestedReminderViewControllerDelegate! = nil
    
    var dogsReminderManagerViewController = DogsReminderManagerViewController()
    
    var targetReminder: Reminder?
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetReminder != nil {
            reminderRemoveButton.isEnabled = true
            saveButton.title = "Save"
            pageNavigationBar.title = "Edit Reminder"
        }
        else {
            reminderRemoveButton.isEnabled = false
            saveButton.title = "Add"
            pageNavigationBar.title = "Create Reminder"
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsNestedReminderManagerViewController"{
            dogsReminderManagerViewController = segue.destination as! DogsReminderManagerViewController
            dogsReminderManagerViewController.delegate = self
            dogsReminderManagerViewController.targetReminder = targetReminder
        }
    }
    
    
}
