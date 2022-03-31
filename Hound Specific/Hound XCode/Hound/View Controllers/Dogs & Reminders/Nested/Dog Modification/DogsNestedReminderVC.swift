//
//  DogsNestedReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

// Delegate to pass setup reminder back to table view
protocol DogsNestedReminderViewControllerDelegate: AnyObject {
    func didApplyReminderSettings(sender: Sender, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, reminderId: Int)
}

class DogsNestedReminderViewController: UIViewController {

    // MARK: - IB

    @IBOutlet weak var pageNavigationBar: UINavigationItem!

    @IBOutlet private weak var saveButton: UIBarButtonItem!
    
    // Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder back to table view.
    @IBAction private func willSave(_ sender: Any) {
        
        // Since this is the nested reminders view controller, meaning its nested in the larger Add Dog VC, we only perform the server queries when the user decides to create / update the greater dog.
        
        let updatedReminder = dogsReminderManagerViewController.applyReminderSettings()
        if updatedReminder != nil {
            delegate.didApplyReminderSettings(sender: Sender(origin: self, localized: self), forReminder: updatedReminder!)
            navigationController?.popViewController(animated: true)
        }
        
    }

    @IBAction private func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        }

    @IBOutlet weak var reminderRemoveButton: UIBarButtonItem!
    
    @IBAction func willRemoveReminder(_ sender: Any) {
        
        // Since this is the nested reminders view controller, meaning its nested in the larger Add Dog VC, we only perform the server queries when the user decides to create / update the greater dog.
        
        let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogsReminderManagerViewController.reminderAction.text ?? targetReminder!.displayActionName)?", message: nil, preferredStyle: .alert)

        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), reminderId: self.targetReminder!.reminderId)
            self.navigationController?.popViewController(animated: true)
        }

        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        removeReminderConfirmation.addAction(alertActionRemove)
        removeReminderConfirmation.addAction(alertActionCancel)

        AlertManager.enqueueAlertForPresentation(removeReminderConfirmation)
    }

    // MARK: - Properties

    weak var delegate: DogsNestedReminderViewControllerDelegate! = nil

    var dogsReminderManagerViewController = DogsReminderManagerViewController()

    var targetReminder: Reminder?
    var isUpdating: Bool {
        if targetReminder == nil {
            return false
        }
        else {
            return true
    }}

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        if isUpdating == true {
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
            dogsReminderManagerViewController.targetReminder = targetReminder
        }
    }

}
