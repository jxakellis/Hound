//
//  Reminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ReminderManagerProtocol {
    
    // array of reminders, a dog should contain one of these to specify all of its reminders
    var reminders: [Reminder] { get }
    
    /// Checks to see if a reminder is already present. If its reminderId is, then is removes the old one and replaces it with the new. If the reminder has a placeholder reminderId and a reminder with the same reminderId already exists, then the placeholder id is shifted and the reminder is added
    mutating func addReminder(newReminder: Reminder) throws
    
    /// Invokes addReminder(newReminder: Reminder) for newReminder.count times
    mutating func addReminder(newReminders: [Reminder]) throws
    
    /// Checks to see if a reminder is already present. If its reminderId is, then is removes the old one and replaces it with the new. If the reminder has a placeholder reminderId and a reminder with the same reminderId already exists, then the existing reminder is overridden
    mutating func updateReminder(updatedReminder: Reminder) throws
    
    /// Invokes updateReminder(updatedReminder: Reminder) for updatedReminder.count times
    mutating func updateReminder(updatedReminders: [Reminder]) throws
    
    /// Tries to find a reminder with the matching reminderId, if found then it removes the reminder, if not found then throws error
    mutating func removeReminder(forReminderId reminderId: Int) throws
    mutating func removeReminder(forIndex index: Int)
    
    /// Removed as addReminer can serve this purpose (replaces old one if already present)
    // mutating func changeReminder(forReminderId reminderId: String, newReminder: Reminder) throws
    
    /// finds and returns the reference of a reminder matching the given reminderId
    func findReminder(forReminderId reminderId: Int) throws -> Reminder
    
    /// finds and returns the index of a reminder with a reminderId in terms of the reminder: [Reminder] array
    func findIndex(forReminderId reminderId: Int) throws -> Int
    
}

extension ReminderManagerProtocol {
    
    func findReminder(forReminderId reminderId: Int) throws -> Reminder {
        
        for r in 0..<reminders.count where reminders[r].reminderId == reminderId {
            return reminders[r]
        }
        throw ReminderManagerError.reminderIdNotPresent
    }
    
    func findIndex(forReminderId reminderId: Int) throws -> Int {
        for r in 0..<reminders.count where reminders[r].reminderId == reminderId {
            return r
        }
        throw ReminderManagerError.reminderIdNotPresent
    }
    
}

class ReminderManager: NSObject, NSCoding, NSCopying, ReminderManagerProtocol {
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ReminderManager(initReminders: self.reminders)
        return copy
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        storedReminders = aDecoder.decodeObject(forKey: "reminders") as? [Reminder] ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedReminders, forKey: "reminders")
    }
    
    // MARK: - Main
    
    init(initReminders: [Reminder] = []) {
        super.init()
        addReminder(newReminders: initReminders)
    }
    
    // MARK: Properties
    
    /// Array of reminders
    private var storedReminders: [Reminder] = []
    var reminders: [Reminder] { return storedReminders }
    
    // MARK: Add Reminders
    
    func addReminder(newReminder: Reminder) {
        
        var lowestReminderId = Int.max
        for reminder in reminders where reminder.reminderId < lowestReminderId {
            // find the lowest placeholder id
            lowestReminderId = reminder.reminderId
        }
        
        // removes any existing reminders that have the same reminderId as they would cause problems. Placeholder Ids aren't real so they can be shifted .reversed() is needed to make it work, without it there will be an index of out bounds error.
        for (reminderIndex, reminder) in reminders.enumerated().reversed() where reminder.reminderId == newReminder.reminderId && reminder.reminderId >= 0 {
            
            // instead of crashing, replace the reminder.
            reminder.timer?.invalidate()
            storedReminders.remove(at: reminderIndex)
        }
        
        // If there are multiple reminders with placeholder ids, set the new reminder's placeholder id to the lowest possible, therefore no overlap.
        if newReminder.reminderId < 0 && lowestReminderId < 0 {
            newReminder.reminderId = lowestReminderId - 1
        }
        
        storedReminders.append(newReminder)
        
        sortReminders()
    }
    
    func addReminder(newReminders: [Reminder]) {
        for reminder in newReminders {
            addReminder(newReminder: reminder)
        }
        sortReminders()
    }
    
    // MARK: Update Reminders
    
    func updateReminder(updatedReminder: Reminder) {
        
       // Removes any existing reminders that have the same reminderId as they would cause problems.
        for (reminderIndex, reminder) in reminders.enumerated().reversed() where reminder.reminderId == updatedReminder.reminderId {
            
            // remove the old reminder
            reminder.timer?.invalidate()
            storedReminders.remove(at: reminderIndex)
        }
        
        storedReminders.append(updatedReminder)
        
        sortReminders()
    }
    
    func updateReminder(updatedReminders: [Reminder]) {
        for reminder in updatedReminders {
            updateReminder(updatedReminder: reminder)
        }
        sortReminders()
    }
    
    // MARK: Remove Reminders
    
    func removeReminder(forReminderId reminderId: Int) throws {
        var reminderNotPresent = true
        
        // goes through reminders to see if the given reminder name (aka reminder name) is in the array of reminders
        for reminder in reminders where reminder.reminderId == reminderId {
            reminderNotPresent = false
            break
        }
        
        // if provided reminder is not present, throws error
        
        if reminderNotPresent == true {
            throw ReminderManagerError.reminderIdNotPresent
        }
        // if provided reminder is present, proceeds
        else {
            // finds index of given reminder (through reminder name), returns nil if not found but it should be if code is written correctly, code should not be not be able to reach this point if reminder name was not present
            var indexOfRemovalTarget: Int? {
                for index in 0...Int(reminders.count) where reminders[index].reminderId == reminderId {
                    return index
                }
                return nil
            }
            
            storedReminders[indexOfRemovalTarget ?? ReminderConstant.defaultReminderId].timer?.invalidate()
            storedReminders.remove(at: indexOfRemovalTarget ?? -1)
        }
    }
    
    func removeReminder(forIndex index: Int) {
        storedReminders[index].timer?.invalidate()
        storedReminders.remove(at: index)
    }
    
    // MARK: Manipulate Reminders
    
    /// returns true if has created a reminder and has at least one enabled
    var hasEnabledReminder: Bool {
        for reminder in reminders where reminder.isEnabled == true {
            return true
        }
        return false
    }
    
    private func sortReminders() {
        storedReminders.sort { (reminder1, reminder2) -> Bool in
            if reminder1.reminderType == .oneTime && reminder2.reminderType == .oneTime {
                if Date().distance(to: reminder1.oneTimeComponents.oneTimeDate) < Date().distance(to: reminder2.oneTimeComponents.oneTimeDate) {
                    return true
                }
                else {
                    return false
                }
            }
            // both countdown
            else if reminder1.reminderType == .countdown && reminder2.reminderType == .countdown {
                // shorter is listed first
                if reminder1.countdownComponents.executionInterval <= reminder2.countdownComponents.executionInterval {
                    return true
                }
                else {
                    return false
                }
            }
            // both weekly
            else if reminder1.reminderType == .weekly && reminder2.reminderType == .weekly {
                // earlier in the day is listed first
                let reminder1Hour = reminder1.weeklyComponents.dateComponents.hour!
                let reminder2Hour = reminder2.weeklyComponents.dateComponents.hour!
                if reminder1Hour == reminder2Hour {
                    let reminder1Minute = reminder1.weeklyComponents.dateComponents.minute!
                    let reminder2Minute = reminder2.weeklyComponents.dateComponents.minute!
                    if reminder1Minute <= reminder2Minute {
                        return true
                    }
                    else {
                        return false
                    }
                }
                else if reminder1Hour <= reminder2Hour {
                    return true
                }
                else {
                    return false
                }
            }
            // both monthly
            else if reminder1.reminderType == .monthly && reminder2.reminderType == .monthly {
                let reminder1Day: Int! = reminder1.monthlyComponents.dayOfMonth
                let reminder2Day: Int! = reminder2.monthlyComponents.dayOfMonth
                // first day of the month comes first
                if reminder1Day == reminder2Day {
                    // earliest in day comes first if same days
                    let reminder1Hour = reminder1.monthlyComponents.dateComponents.hour!
                    let reminder2Hour = reminder2.monthlyComponents.dateComponents.hour!
                    if reminder1Hour == reminder2Hour {
                        // earliest in hour comes first if same hour
                        let reminder1Minute = reminder1.monthlyComponents.dateComponents.minute!
                        let reminder2Minute = reminder2.monthlyComponents.dateComponents.minute!
                        if reminder1Minute <= reminder2Minute {
                            return true
                        }
                        else {
                            return false
                        }
                    }
                    else if reminder1Hour <= reminder2Hour {
                        return true
                    }
                    else {
                        return false
                    }
                }
                else if reminder1Day < reminder2Day {
                    return true
                }
                else {
                    return false
                }
            }
            // different timing styles
            else {
                
                // reminder1 and reminder2 are known to be different styles
                switch reminder1.reminderType {
                case .countdown:
                    // can assume is comes first as countdown always first and different
                    return true
                case .weekly:
                    if reminder2.reminderType == .countdown {
                        return false
                    }
                    else {
                        return true
                    }
                case .monthly:
                    if reminder2.reminderType == .oneTime {
                        return true
                    }
                    else {
                        return false
                    }
                case .oneTime:
                    return false
                }
                
            }
        }
    }
    
    // MARK: Compare
    
    /// Compares newReminders against the reminders stored in this reminders manager. The first array is reminders that haven't changed, therefore they are in sync with the server. The second array is reminders that have been created and must be communicated to the server. The third array is reminders that have been updated so the server must be notified of their changes. The fourth array is reminders that have been deleted so the server must be notified of their deletion (this function also invalidates the timers of the reminders in the deleted array).
    func groupReminders(newReminders: [Reminder]) -> ([Reminder], [Reminder], [Reminder], [Reminder]) {
        var sameReminders: [Reminder] = []
        var createdReminders: [Reminder] = []
        var updatedReminders: [Reminder] = []
        var deletedReminders: [Reminder] = []
        
        // first we loop through our inital reminders array. We can find same, updated, and deleted reminders this way.
        // Since we don't deal with created reminders in this loop, all reminderIds will be real Ids from the server
        for reminder in self.reminders {
            var containsReminder = false
            for newReminder in newReminders where newReminder.reminderId == reminder.reminderId && newReminder.reminderId >= 0 {
                containsReminder = true
                if reminder.isSame(asReminder: newReminder) {
                    // nothing was changed about the reminder
                    sameReminders.append(newReminder)
                }
                else {
                    // some property of the reminder was updated
                    updatedReminders.append(newReminder)
                }
                break
            }
            if containsReminder == false {
                // new reminder array doesn't contain the old reminder, therefore it was deleted
                deletedReminders.append(reminder)
                // make sure to invalidate the old reminder, no need to do any same/updated reminder as (even if they are a .copy()) their timers are just references to the original timers. This means there are no duplicated timers and TimingManager will handle them
                reminder.timer?.invalidate()
                reminder.timer = nil
            }
        }
        
        // look for reminders that have the default reminder id, meaning they were just created and couldn't be in the old array
        for newReminder in newReminders where newReminder.reminderId < 0 {
            createdReminders.append(newReminder)
        }
        
        return (sameReminders, createdReminders, updatedReminders, deletedReminders)
    }
    
}

protocol ReminderManagerControlFlowProtocol {
    
    /// Returns a copy of ReminderManager used to avoid accidental changes (due to reference type) by classes which get their dog manager from here
    func getReminderManager() -> ReminderManager
    
    /// Sets reminderManager equal to newReminderManager, depending on sender will also call methods to propogate change.
    func setReminderManager(sender: Sender, newReminderManager: ReminderManager)
    
    // Updates things dependent on reminderManager
    func updateReminderManagerDependents()
    
}
