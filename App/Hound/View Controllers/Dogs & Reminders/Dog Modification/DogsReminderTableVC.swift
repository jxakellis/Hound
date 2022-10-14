//
//  DogsReminderTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsReminderTableViewController: UITableViewController, DogsReminderTableViewCellDelegate, DogsNestedReminderViewControllerDelegate {
    
    // MARK: DogsNestedReminderViewControllerDelegate
    
    func willAddReminder(sender: Sender, forReminder: Reminder) {
        
        reminders.removeAll { reminder in
            guard reminder.reminderId >= 0 else {
                return false
            }
            
            return reminder.reminderId == forReminder.reminderId
        }
         
        // find the reminder with the lowest reminderId of all the existing reminderIds
        let lowestReminderId = reminders.min { reminderOne, reminderTwo in
            return reminderOne.reminderId <= reminderTwo.reminderId
        }
        
        // if the reminder we want to add has a placeholderId and another reminder in the array already has a placeholderId, then shift the new reminder's placeholderId
        if let lowestReminderId = lowestReminderId, forReminder.reminderId <= -1 && lowestReminderId.reminderId <= -1 {
            forReminder.reminderId = lowestReminderId.reminderId - 1
        }
        reminders.append(forReminder)
        reloadTable()
    }
    
    func willUpdateReminder(sender: Sender, forReminder: Reminder) {
        reminders.removeAll { reminder in
            return reminder.reminderId == forReminder.reminderId
        }
        reminders.append(forReminder)
        reloadTable()
    }
    
    func willRemoveReminder(sender: Sender, forReminder: Reminder) {
        reminders.removeAll { reminder in
            return reminder.reminderId == forReminder.reminderId
        }
        reloadTable()
    }
    
    // MARK: - DogsReminderTableViewCell
    
    func didUpdateReminderIsEnabled(sender: Sender, forReminderId: Int, forReminderIsEnabled: Bool) {
        reminders.first(where: { $0.reminderId == forReminderId })?.reminderIsEnabled = forReminderIsEnabled
    }
    
    // MARK: - Reminder Manager
    
    /// Use a reminders array instead of a ReminderManager. We will be performing changes on the reminderManager that can potentially be discarded by hitting the cancel button, therefore we can't use ReminderManager as it can invalidate timers
    var reminders: [Reminder] = []
    
    // MARK: - Properties
    
    /// Used for when a reminder is selected (aka clicked) on the table view in order to pass information to open the editing page for the reminder
    private var selectedReminder: Reminder?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadTable()
        
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
        return reminders.count
    }
    
    /// Configures cells at the given index path, pulls from reminder manager reminders to get configuration parameters for each cell, corrosponding cell goes to corrosponding index of reminder manager reminder e.g. cell 1 at [0]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DogsReminderTableViewCell", for: indexPath)
        
        if let castCell = cell as? DogsReminderTableViewCell {
            castCell.delegate = self
            castCell.setup(forReminder: reminders[indexPath.row])
        }
        
        return cell
    }
    
    /// Reloads table data when it is updated, if you change the data w/o calling this, the data display to the user will not be updated
    private func reloadTable() {
        
        tableView.rowHeight = reminders.count > 0 ? -1 : 65.5
        
        if reminders.count == 0 {
            tableView.allowsSelection = false
        }
        else {
            tableView.allowsSelection = true
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReminder = reminders[indexPath.row]
        
        performSegueOnceInWindowHierarchy(segueIdentifier: "DogsNestedReminderViewController")
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && reminders.count > 0 {
            let reminder = reminders[indexPath.row]
            
            let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))?", message: nil, preferredStyle: .alert)
            
            let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.reminders.removeAll { currentReminder in
                    return currentReminder.reminderId == reminder.reminderId
                }
                
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeReminderConfirmation.addAction(alertActionRemove)
            removeReminderConfirmation.addAction(alertActionCancel)
            AlertManager.enqueueAlertForPresentation(removeReminderConfirmation)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if reminders.count == 0 {
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
