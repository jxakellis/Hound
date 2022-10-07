//
//  DogsReminderNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsReminderNavigationViewController: UINavigationController {
    
    // MARK: - Properties
    
    var dogsReminderTableViewController: DogsReminderTableViewController?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets DogsReminderTableViewController delegate to self, this is required to pass through the data to DogsAddDogViewController as this navigation controller is in the way.
        dogsReminderTableViewController = self.viewControllers.first as? DogsReminderTableViewController
    }
    
    // MARK: - DogsAddDogViewController
    
    // Called by superview to pass down new reminders to subview, used when editting a dog
    func didPassReminders(sender: Sender, passedReminders: ReminderManager) {
        dogsReminderTableViewController?.setReminderManager(sender: Sender(origin: sender, localized: self), newReminderManager: passedReminders)
    }
}
