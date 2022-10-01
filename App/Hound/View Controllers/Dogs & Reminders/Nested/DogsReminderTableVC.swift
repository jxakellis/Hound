//
//  DogsReminderTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderTableViewControllerDelegate: AnyObject {
    func didAddReminder(forReminder: Reminder)
    func didUpdateReminder(forReminder: Reminder)
    func didRemoveReminder(forReminder: Reminder)
}

final class DogsReminderTableViewController: UITableViewController, DogsNestedReminderViewControllerDelegate, DogsReminderTableViewCellDelegate {
    
    // MARK: - Dogs Reminder Table View Cell
    
    func didUpdateReminderIsEnabled(sender: Sender, reminderId: Int, reminderIsEnabled: Bool) {
        guard let reminder = reminderManager.findReminder(forReminderId: reminderId) else {
            return
        }
        
        reminder.reminderIsEnabled = reminderIsEnabled
        setReminderManager(sender: sender, newReminderManager: reminderManager)
        delegate.didUpdateReminder(forReminder: reminder)
    }
    
    // MARK: - Dogs Nested Reminder
    
    /// When this function is called through a delegate, it adds the information to the list of reminders and updates the cells to display it
    func didAddReminder(sender: Sender, forReminder reminder: Reminder) {
        reminderManager.addReminder(forReminder: reminder)
        
        setReminderManager(sender: sender, newReminderManager: reminderManager)
        
        delegate.didAddReminder(forReminder: reminder)
    }
    
    /// When this function is called through a delegate, it adds the information to the list of reminders and updates the cells to display it
    func didUpdateReminder(sender: Sender, forReminder reminder: Reminder) {
        reminderManager.updateReminder(forReminder: reminder)
        
        setReminderManager(sender: sender, newReminderManager: reminderManager)
        
        delegate.didUpdateReminder(forReminder: reminder)
    }
    
    func didRemoveReminder(sender: Sender, forReminder reminder: Reminder) {
        reminderManager.removeReminder(forReminderId: reminder.reminderId)
        
        setReminderManager(sender: sender, newReminderManager: reminderManager)
        
        delegate.didRemoveReminder(forReminder: reminder)
    }
    
    // MARK: - Reminder Manager
    
    private var reminderManager = ReminderManager()
    
    func setReminderManager(sender: Sender, newReminderManager: ReminderManager) {
        reminderManager = newReminderManager
        
        if !(sender.origin is DogsReminderTableViewCell) && !(sender.origin is DogsReminderTableViewController) {
            reloadTable()
        }
        
        tableView.rowHeight = reminderManager.reminders.count > 0 ? -1 : 65.5
    }
    
    // MARK: - Properties
    
    /// Used for when a reminder is selected (aka clicked) on the table view in order to pass information to open the editing page for the reminder
    private var selectedReminder: Reminder?
    
    weak var delegate: DogsReminderTableViewControllerDelegate! = nil
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.reminderManager.reminders.count == 0 {
            self.tableView.allowsSelection = false
        }
        else {
            self.tableView.allowsSelection = true
        }
        
        MainTabBarViewController.mainTabBarViewController?.dogsViewController?.dogsAddDogViewController.willHideButtons(isHidden: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MainTabBarViewController.mainTabBarViewController?.dogsViewController?.dogsAddDogViewController.willHideButtons(isHidden: true)
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
        // if reminderManager.reminders.count == 0{
        //    return 1
        // }
        return reminderManager.reminders.count
    }
    
    /// Configures cells at the given index path, pulls from reminder manager reminders to get configuration parameters for each cell, corrosponding cell goes to corrosponding index of reminder manager reminder e.g. cell 1 at [0]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DogsReminderTableViewCell", for: indexPath)
        
        if let castCell = cell as? DogsReminderTableViewCell {
            castCell.delegate = self
            castCell.setup(forReminder: reminderManager.reminders[indexPath.row])
        }
        
        return cell
    }
    
    /// Reloads table data when it is updated, if you change the data w/o calling this, the data display to the user will not be updated
    private func reloadTable() {
        
        if self.reminderManager.reminders.count == 0 {
            self.tableView.allowsSelection = false
        }
        else {
            self.tableView.allowsSelection = true
        }
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedReminder = reminderManager.reminders[indexPath.row]
        self.performSegueOnceInWindowHierarchy(segueIdentifier: "DogsNestedReminderViewController")
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && reminderManager.reminders.count > 0 {
            let reminder = reminderManager.reminders[indexPath.row]
            
            let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
            
            let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                
                self.reminderManager.removeReminder(forReminderId: reminder.reminderId)
                self.setReminderManager(sender: Sender(origin: self, localized: self), newReminderManager: self.reminderManager)
                
                self.delegate.didRemoveReminder(forReminder: reminder)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeReminderConfirmation.addAction(alertActionRemove)
            removeReminderConfirmation.addAction(alertActionCancel)
            AlertManager.enqueueAlertForPresentation(removeReminderConfirmation)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.reminderManager.reminders.count == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Links delegate to NestedReminder
        if let dogsNestedReminderViewController = segue.destination as? DogsNestedReminderViewController {
            dogsNestedReminderViewController.delegate = self
            
            dogsNestedReminderViewController.targetReminder = selectedReminder
            selectedReminder = nil
        }
    }
    
}
