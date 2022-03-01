//
//  DogsReminderTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderTableViewControllerDelegate: AnyObject {
    func didAddReminder(newReminder: Reminder)
    func didUpdateReminder(updatedReminder: Reminder)
    func didRemoveReminder(removedReminderUUID: String)
}

class DogsReminderTableViewController: UITableViewController, ReminderManagerControlFlowProtocol, DogsNestedReminderViewControllerDelegate, DogsReminderTableViewCellDelegate {

    // MARK: - Dogs Reminder Table View Cell

    func didToggleEnable(sender: Sender, reminderUUID: String, newEnableStatus: Bool) {
        let sudoReminderManager = getReminderManager()
        do {
            let reminder = try sudoReminderManager.findReminder(forUUID: reminderUUID)
            reminder.setEnable(newEnableStatus: newEnableStatus)
            setReminderManager(sender: sender, newReminderManager: sudoReminderManager)

            delegate.didUpdateReminder(updatedReminder: reminder)
        }
        catch {
            fatalError("DogsReminderTableViewController func didToggleEnable(reminderName: String, newEnableStatus: Bool) error")
        }

    }

    // MARK: - Dogs Nested Reminder

    var dogsNestedReminderViewController = DogsNestedReminderViewController()

    /// When this function is called through a delegate, it adds the information to the list of reminders and updates the cells to display it
    func didAddReminder(sender: Sender, newReminder: Reminder) throws {
        let sudoReminderManager = getReminderManager()
        try sudoReminderManager.addReminder(newReminder: newReminder)
        setReminderManager(sender: sender, newReminderManager: sudoReminderManager)

        delegate.didAddReminder(newReminder: newReminder)
    }

    func didUpdateReminder(sender: Sender, updatedReminder: Reminder) throws {
        let sudoReminderManager = getReminderManager()
        try sudoReminderManager.addReminder(newReminder: updatedReminder)
        setReminderManager(sender: sender, newReminderManager: sudoReminderManager)

        delegate.didUpdateReminder(updatedReminder: updatedReminder)
    }

    func didRemoveReminder(sender: Sender, removedReminderUUID: String) {
        let sudoReminderManager = getReminderManager()
        try! sudoReminderManager.removeReminder(forUUID: removedReminderUUID)
        setReminderManager(sender: sender, newReminderManager: sudoReminderManager)

        delegate.didRemoveReminder(removedReminderUUID: removedReminderUUID)
    }

    // MARK: - Reminder Manager Control Flow Protocol

    private var reminderManager = ReminderManager(masterDog: nil)

    func getReminderManager() -> ReminderManager {
        return reminderManager
    }

    func setReminderManager(sender: Sender, newReminderManager: ReminderManager) {
        reminderManager = newReminderManager

        if !(sender.localized is DogsReminderNavigationViewController) {
           // delegate.didUpdateReminders(newReminderList: getReminderManager().reminders)
        }

        if !(sender.origin is DogsReminderTableViewCell) && !(sender.origin is DogsReminderTableViewController) {
            updateReminderManagerDependents()
        }

        reloadTableConstraints()

    }

    private func reloadTableConstraints() {
        if getReminderManager().reminders.count > 0 {
            self.tableView.rowHeight = -1
        }
        else {
            self.tableView.rowHeight = 65.5
        }
    }

    func updateReminderManagerDependents() {
        self.reloadTable()
    }

    // MARK: - Properties

    /// Used for when a reminder is selected (aka clicked) on the table view in order to pass information to open the editing page for the reminder
    private var selectedReminder: Reminder?

    weak var delegate: DogsReminderTableViewControllerDelegate! = nil

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = UIEdgeInsets.zero
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.getReminderManager().reminders.count == 0 {
            self.tableView.allowsSelection = false
        }
        else {
            self.tableView.allowsSelection = true
        }

        MainTabBarViewController.mainTabBarViewController.dogsViewController.dogsAddDogViewController.willHideButtons(isHidden: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MainTabBarViewController.mainTabBarViewController.dogsViewController.dogsAddDogViewController.willHideButtons(isHidden: true)
    }
    // MARK: Table View Management

    // Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    /// Returns the number of cells present in section (currently only 1 section)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // if getReminderManager().reminders.count == 0{
        //    return 1
        // }
        return getReminderManager().reminders.count
    }

    /// Configures cells at the given index path, pulls from reminder manager reminders to get configuration parameters for each cell, corrosponding cell goes to corrosponding index of reminder manager reminder e.g. cell 1 at [0]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "dogsReminderTableViewCell", for: indexPath)

        let castCell = cell as! DogsReminderTableViewCell
        castCell.delegate = self
        castCell.setup(reminder: getReminderManager().reminders[indexPath.row])

        return cell
    }

    /// Reloads table data when it is updated, if you change the data w/o calling this, the data display to the user will not be updated
    private func reloadTable() {

        if self.getReminderManager().reminders.count == 0 {
            self.tableView.allowsSelection = false
        }
        else {
            self.tableView.allowsSelection = true
        }

        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedReminder = getReminderManager().reminders[indexPath.row]
        self.performSegue(withIdentifier: "dogsNestedReminderViewController", sender: self)

    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let sudoReminderManager = getReminderManager()
        if editingStyle == .delete && sudoReminderManager.reminders.count > 0 {
            let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(sudoReminderManager.reminders[indexPath.row].displayTypeName)?", message: nil, preferredStyle: .alert)

            let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in

                let reminderUUID = self.getReminderManager().reminders[indexPath.row].uuid
                let sudoReminderManager = self.getReminderManager()
                sudoReminderManager.removeReminder(forIndex: indexPath.row)
                self.setReminderManager(sender: Sender(origin: self, localized: self), newReminderManager: sudoReminderManager)

                self.delegate.didRemoveReminder(removedReminderUUID: reminderUUID)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeReminderConfirmation.addAction(alertActionRemove)
            removeReminderConfirmation.addAction(alertActionCancel)
            AlertManager.shared.enqueueAlertForPresentation(removeReminderConfirmation)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.getReminderManager().reminders.count == 0 {
            return false
        }
        else {
            return true
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Links delegate to NestedReminder
        if segue.identifier == "dogsNestedReminderViewController" {
            dogsNestedReminderViewController = segue.destination as! DogsNestedReminderViewController
            dogsNestedReminderViewController.delegate = self

            if selectedReminder != nil {
                dogsNestedReminderViewController.targetReminder = selectedReminder!
                selectedReminder = nil
            }

        }
    }

}
