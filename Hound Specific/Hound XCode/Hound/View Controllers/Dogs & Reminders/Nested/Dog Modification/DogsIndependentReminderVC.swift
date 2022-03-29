//
//  DogsIndependentReminderViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsIndependentReminderViewControllerDelegate: AnyObject {
    func didApplyReminderSettings(sender: Sender, parentDogId: Int, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, parentDogId: Int, reminderId: Int)
    /// Reinitalizes timers that were possibly destroyed
    func didCancel(sender: Sender)
}

class DogsIndependentReminderViewController: UIViewController {

    // MARK: - IB

    // Buttons to manage the information fate, whether to update or to cancel

    @IBOutlet weak var pageNavigationBar: UINavigationItem!
    @IBOutlet private weak var saveReminderButton: UIButton!
    @IBOutlet private weak var saveReminderButtonBackground: UIButton!

    @IBOutlet private weak var cancelUpdateReminderButton: UIButton!

    @IBOutlet private weak var cancelUpdateReminderButtonBackground: UIButton!

    /// Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured reminder to DogsViewController
    @IBAction private func willSave(_ sender: Any) {
        
        // Since this is the independent reminders view controller, meaning its not nested in a larger Add Dog VC, we perform the server queries then exit.
        
        let updatedReminder = dogsReminderManagerViewController.applyReminderSettings()
        
        if updatedReminder != nil {
            // reminder settings were valid
            if isUpdating == true {
                // updating
                RemindersRequest.update(forDogId: parentDogId, forReminder: updatedReminder!) { requestWasSuccessful in
                    if requestWasSuccessful == true {
                        // successful so we can persist the data locally
                        self.delegate.didApplyReminderSettings(sender: Sender(origin: self, localized: self), parentDogId: self.parentDogId, forReminder: updatedReminder!)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            else {
                RemindersRequest.create(forDogId: parentDogId, forReminder: updatedReminder!) { reminderId in
                    // query complete
                    if reminderId != nil {
                        // successful and able to get reminderId, persist locally
                        updatedReminder!.reminderId = reminderId!
                        self.delegate.didApplyReminderSettings(sender: Sender(origin: self, localized: self), parentDogId: self.parentDogId, forReminder: updatedReminder!)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }

    }

    @IBOutlet weak var reminderRemoveButton: UIBarButtonItem!

    @IBAction func willRemoveReminder(_ sender: Any) {
        
        // Since this is the independent reminders view controller, meaning its not nested in a larger Add Dog VC, we perform the server queries then exit.
        
        guard targetReminder != nil else {
            return
        }
        let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogsReminderManagerViewController.reminderAction.text ?? targetReminder!.displayTypeName)?", message: nil, preferredStyle: .alert)

        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in

            RemindersRequest.delete(forDogId: self.parentDogId, forReminderId: self.targetReminder!.reminderId) { requestWasSuccessful in
                if requestWasSuccessful == true {
                        // persist data locally
                        self.delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), parentDogId: self.parentDogId, reminderId: self.targetReminder!.reminderId)
                        self.navigationController?.popViewController(animated: true)
                    }
            }

        }

        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        removeReminderConfirmation.addAction(alertActionRemove)
        removeReminderConfirmation.addAction(alertActionCancel)

        AlertManager.enqueueAlertForPresentation(removeReminderConfirmation)
    }

    /// The cancel / exit button was pressed, dismisses view to complete intended action
    @IBAction private func willCancel(_ sender: Any) {

        // "Any changes you have made won't be saved"
        if dogsReminderManagerViewController.initalValuesChanged == true {
            let unsavedInformationConfirmation = GeneralUIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)

            let alertActionExit = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
                self.delegate.didCancel(sender: Sender(origin: self, localized: self))
                self.navigationController?.popViewController(animated: true)
            }

            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            unsavedInformationConfirmation.addAction(alertActionExit)
            unsavedInformationConfirmation.addAction(alertActionCancel)

            AlertManager.enqueueAlertForPresentation(unsavedInformationConfirmation)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }

    }

    // MARK: - Properties

    weak var delegate: DogsIndependentReminderViewControllerDelegate! = nil

    var dogsReminderManagerViewController: DogsReminderManagerViewController = DogsReminderManagerViewController()

    var targetReminder: Reminder?
    var isUpdating: Bool {
        if targetReminder == nil {
            return false
        }
        else {
            return true
    }}

    var parentDogId: Int! = nil

    // MARK: - Main

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
        AlertManager.globalPresenter = self
    }

    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsUpdateReminderManagerViewController"{
            dogsReminderManagerViewController = segue.destination as! DogsReminderManagerViewController
            dogsReminderManagerViewController.targetReminder = self.targetReminder
            // dogsReminderManagerViewController.delegate = self
        }
    }

}
