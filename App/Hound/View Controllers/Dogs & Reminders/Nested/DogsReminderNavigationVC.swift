//
//  DogsReminderNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderNavigationViewControllerDelegate: AnyObject {
    func didAddReminder(forReminder: Reminder)
    func didUpdateReminder(forReminder: Reminder)
    func didRemoveReminder(reminderId: Int)
}

final class DogsReminderNavigationViewController: UINavigationController, DogsReminderTableViewControllerDelegate {
    
    // MARK: - DogsReminderTableViewControllerDelegate
    
    func didAddReminder(forReminder reminder: Reminder) {
        passThroughDelegate.didAddReminder(forReminder: reminder)
    }
    
    func didUpdateReminder(forReminder reminder: Reminder) {
        passThroughDelegate.didUpdateReminder(forReminder: reminder)
    }
    
    func didRemoveReminder(reminderId: Int) {
        passThroughDelegate.didRemoveReminder(reminderId: reminderId)
    }
    
    // MARK: - Properties
    
    // This delegate is used in order to connect the delegate from the sub table view to the parent embedded view, i.e. connect DogsReminderTableViewController delegate to DogsAddDogViewController
    weak var passThroughDelegate: DogsReminderNavigationViewControllerDelegate! = nil
    
    var dogsReminderTableViewController: DogsReminderTableViewController! = nil
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets DogsReminderTableViewController delegate to self, this is required to pass through the data to DogsAddDogViewController as this navigation controller is in the way.
        dogsReminderTableViewController = self.viewControllers[self.viewControllers.count - 1] as? DogsReminderTableViewController
        dogsReminderTableViewController.delegate = self
    }
    
    // MARK: - DogsAddDogViewController
    
    // Called by superview to pass down new reminders to subview, used when editting a dog
    func didPassReminders(sender: Sender, passedReminders: ReminderManager) {
        dogsReminderTableViewController.setReminderManager(sender: Sender(origin: sender, localized: self), newReminderManager: passedReminders)
    }
}
