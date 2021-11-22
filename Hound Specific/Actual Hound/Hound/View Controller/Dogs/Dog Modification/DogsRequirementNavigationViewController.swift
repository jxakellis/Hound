//
//  DogsReminderNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderNavigationViewControllerDelegate {
    func didAddReminder(newReminder: Reminder)
    func didUpdateReminder(updatedReminder: Reminder)
    func didRemoveReminder(removedReminderUUID: String)
}

class DogsReminderNavigationViewController: UINavigationController, DogsReminderTableViewControllerDelegate {
    
    
    //MARK: - DogsReminderTableViewControllerDelegate
    
    func didAddReminder(newReminder: Reminder) {
        passThroughDelegate.didAddReminder(newReminder: newReminder)
    }
    
    func didUpdateReminder(updatedReminder: Reminder) {
        passThroughDelegate.didUpdateReminder(updatedReminder: updatedReminder)
    }
    
    func didRemoveReminder(removedReminderUUID: String) {
        passThroughDelegate.didRemoveReminder(removedReminderUUID: removedReminderUUID)
    }
    
   // func didUpdateReminders(newReminderList: [Reminder]) {
   //     passThroughDelegate.didUpdateReminders(newReminderList: newReminderList)
   // }
    
    //MARK: - Properties
    
    //This delegate is used in order to connect the delegate from the sub table view to the master embedded view, i.e. connect DogsReminderTableViewController delegate to DogsAddDogViewController
    var passThroughDelegate: DogsReminderNavigationViewControllerDelegate! = nil
    
    var dogsReminderTableViewController: DogsReminderTableViewController! = nil
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets DogsReminderTableViewController delegate to self, this is required to pass through the data to DogsAddDogViewController as this navigation controller is in the way.
        dogsReminderTableViewController = self.viewControllers[self.viewControllers.count-1] as? DogsReminderTableViewController
        dogsReminderTableViewController.delegate = self
    }
    
    //MARK: - DogsAddDogViewController
    
    //Called by superview to pass down new reminders to subview, used when editting a dog
    func didPassReminders(sender: Sender, passedReminders: ReminderManager){
        dogsReminderTableViewController.setReminderManager(sender: Sender(origin: sender, localized: self), newReminderManager: passedReminders)
    }
}
