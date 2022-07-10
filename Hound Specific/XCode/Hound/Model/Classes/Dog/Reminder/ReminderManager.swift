//
//  Reminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ReminderManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ReminderManager()
        for reminder in reminders {
            copy.addReminder(newReminder: reminder.copy() as! Reminder)
        }
        return copy
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        reminders = aDecoder.decodeObject(forKey: "reminders") as? [Reminder] ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(reminders, forKey: "reminders")
    }
    
    // MARK: - Main
    
    init(initReminders: [Reminder] = []) {
        super.init()
        addReminders(newReminders: initReminders)
    }
    
    convenience init(fromBody reminderBodies: [[String: Any]]) {
        self.init()
        
        for reminderBody in reminderBodies {
            let reminder = Reminder(fromBody: reminderBody)
            addReminder(newReminder: reminder)
        }
    }
    
    // MARK: Properties
    
    /// Array of reminders
    private(set) var reminders: [Reminder] = []
    
    // MARK: Add Reminders
    
    /// Helper function allows us to use the same logic for addReminder and addReminders and allows us to only sort at the end. Without this function, addReminders would invoke addReminder repeadly and sortReminders() with each call.
    private func addReminderWithoutSorting(newReminder: Reminder) {
        
        // removes any existing reminders that have the same reminderId as they would cause problems. Placeholder Ids aren't real so they can be shifted .reversed() is needed to make it work, without it there will be an index of out bounds error.
        for (reminderIndex, reminder) in reminders.enumerated().reversed() where reminder.reminderId == newReminder.reminderId && reminder.reminderId >= 0 {
            
            // instead of crashing, replace the reminder.
            reminder.timer?.invalidate()
            // there shouldn't be a matching reminder with an alarm presented, but if there is, we don't want to duplicate. therefore we should copy the presentation handled
            newReminder.hasAlarmPresentationHandled = reminder.hasAlarmPresentationHandled
            reminders.remove(at: reminderIndex)
            break
        }
        
        // check to see if we are dealing with a placeholder id reminder
        if newReminder.reminderId < 0 {
            // If there are multiple reminders with placeholder ids, set the new reminder's placeholder id to the lowest possible, therefore no overlap.
            var lowestReminderId = Int.max
            reminders.forEach { reminder in
                if reminder.reminderId < lowestReminderId {
                    lowestReminderId = reminder.reminderId
                }
            }
            
            // the lowest reminder is is <0 so there are other placeholder reminders, that means we should set our new reminder to a placeholder id that is 1 below the lowest (making this reminder the new lowest)
            if lowestReminderId < 0 {
                newReminder.reminderId = lowestReminderId - 1
            }
           
        }
        
        reminders.append(newReminder)
    }
    
    /// Checks to see if a reminder is already present. If its reminderId is, then is removes the old one and replaces it with the new. If the reminder has a placeholder reminderId and a reminder with the same reminderId already exists, then the placeholder id is shifted and the reminder is added
    func addReminder(newReminder: Reminder) {
        
        addReminderWithoutSorting(newReminder: newReminder)
        
        sortReminders()
    }
    
    /// Invokes addReminder(newReminder: Reminder) for newReminder.count times (but only sorts once at the end to be more efficent)
    func addReminders(newReminders: [Reminder]) {
        for newReminder in newReminders {
            addReminderWithoutSorting(newReminder: newReminder)
        }
        
        sortReminders()
    }
    
    private func sortReminders() {
        // Returns true if reminderId1 should come before reminderId2, taking into account placeholderIds.
        func compareReminderIds(reminderId1: Int, reminderId2: Int) -> Bool {
            
            // both real id from the server, make the one that is lower (aka older) come first
            if reminderId1 > 0 && reminderId2 > 0 {
                return reminderId1 < reminderId2
            }
            // both placeholder ids until there is server contact to create the reminders
            else if reminderId1 < 0 && reminderId2 < 0 {
                // the placeholder that is close to 0 / is a larger value (the older one) should come first
                return reminderId1 > reminderId2
            }
            // one of them is a placeholder id
            else {
                // if reminderId1 is >0 then it is the real id and should come first, otherwise reminderId2 is the real id and should come first
                return reminderId1 > 0
            }
        }
        reminders.sort { (reminder1, reminder2) -> Bool in
            // both countdown
            if reminder1.reminderType == .countdown && reminder2.reminderType == .countdown {
                let reminder1ExecutionInterval = reminder1.countdownComponents.executionInterval
                let reminder2ExecutionInterval = reminder2.countdownComponents.executionInterval
                
                guard reminder1ExecutionInterval != reminder2ExecutionInterval else {
                    // if equal, then smaller reminderId comes first
                    return compareReminderIds(reminderId1: reminder1.reminderId, reminderId2: reminder2.reminderId)
                }
                // shorter executionInterval comes first
                return reminder1ExecutionInterval < reminder2ExecutionInterval
            }
            // both weekly
            else if reminder1.reminderType == .weekly && reminder2.reminderType == .weekly {
                // earlier in the day is listed first
                let reminder1Hour = reminder1.weeklyComponents.hour
                let reminder2Hour = reminder2.weeklyComponents.hour
                
                guard reminder1Hour != reminder2Hour else {
                    // hours are equal
                    let reminder1Minute = reminder1.weeklyComponents.minute
                    let reminder2Minute = reminder2.weeklyComponents.minute
                    
                    guard reminder1Minute != reminder2Minute else {
                        // if equal, then smaller reminderId comes first
                        return compareReminderIds(reminderId1: reminder1.reminderId, reminderId2: reminder2.reminderId)
                    }
                    
                    // smaller minute comes first
                    return reminder1Minute < reminder2Minute
                }
                
                // smaller hour comes first
                return reminder1Hour < reminder2Hour
            }
            // both monthly
            else if reminder1.reminderType == .monthly && reminder2.reminderType == .monthly {
                let reminder1Day = reminder1.monthlyComponents.day
                let reminder2Day = reminder2.monthlyComponents.day
                
                guard reminder1Day != reminder2Day else {
                    // earliest in day comes first if same days
                    let reminder1Hour = reminder1.monthlyComponents.hour
                    let reminder2Hour = reminder2.monthlyComponents.hour
                    
                    guard reminder1Hour != reminder2Hour else {
                        // earliest in hour comes first if same hour
                        let reminder1Minute = reminder1.monthlyComponents.minute
                        let reminder2Minute = reminder2.monthlyComponents.minute
                        
                        guard reminder1Minute != reminder2Minute else {
                            // smaller remidnerId comes first
                            return compareReminderIds(reminderId1: reminder1.reminderId, reminderId2: reminder2.reminderId)
                        }
                        // smaller minute comes first
                        return reminder1Minute < reminder2Minute
                    }
                    
                    // smaller hour comes first
                    return reminder1Hour < reminder2Hour
                }
                // smaller day comes first
                return reminder1Day < reminder2Day
            }
            else if reminder1.reminderType == .oneTime && reminder2.reminderType == .oneTime {
                let reminder1DistanceToPast = Date().distance(to: reminder1.oneTimeComponents.oneTimeDate)
                let reminder2DistanceToPast = Date().distance(to: reminder2.oneTimeComponents.oneTimeDate)
                
                guard reminder1DistanceToPast != reminder2DistanceToPast else {
                    // if equal, then smaller reminderId comes first
                    return compareReminderIds(reminderId1: reminder1.reminderId, reminderId2: reminder2.reminderId)
                }
                // not equal, the oldest one comes first
                return reminder1DistanceToPast < reminder2DistanceToPast
            }
            // different timing styles
            else {
                // reminder1 and reminder2 are known to be different styles
                switch reminder1.reminderType {
                case .countdown:
                    // reminder2 can't be .countdown and .countdown always comes first, so reminder1 comes first
                    return true
                case .weekly:
                    // reminder2 can't be weekly. Therefore, the only way it can come before is if its .countdown
                    return (reminder2.reminderType == .countdown) ? false : true
                case .monthly:
                    // reminder2 can't be weekly. Therefore, the only way it can come before is if its .countdown or .weekly
                    return (reminder2.reminderType == .countdown || reminder2.reminderType == .weekly) ? false : true
                case .oneTime:
                    // reminder2 can't be oneTime. Therefore, it will come before as it has to be one of the other types
                    return false
                }
                
            }
        }
    }
    
    // MARK: Update Reminders
    
    /// Helper function allows us to use the same logic for updateReminder and updateReminders and allows us to only sort at the end. Without this function, updateReminders would invoke updateReminder repeadly and sortReminders() with each call.
    private func updateReminderWithoutSorting(updatedReminder: Reminder) {
        // Removes any existing reminders that have the same reminderId as they would cause problems.
        for (reminderIndex, reminder) in reminders.enumerated().reversed() where reminder.reminderId == updatedReminder.reminderId {
            
            // remove the old reminder
            reminder.timer?.invalidate()
            reminders.remove(at: reminderIndex)
        }
        
        reminders.append(updatedReminder)
    }
    
    /// Checks to see if a reminder is already present. If its reminderId is, then is removes the old one and replaces it with the new. If the reminder has a placeholder reminderId and a reminder with the same reminderId already exists, then the existing reminder is overridden
    func updateReminder(updatedReminder: Reminder) {
        
        updateReminderWithoutSorting(updatedReminder: updatedReminder)
        
        sortReminders()
    }
    
    /// Invokes updateReminder(updatedReminder: Reminder) for updatedReminder.count times  (but only sorts once at the end to be more efficent)
    func updateReminder(updatedReminders: [Reminder]) {
        for updatedReminder in updatedReminders {
            updateReminderWithoutSorting(updatedReminder: updatedReminder)
        }
        
        sortReminders()
    }
    
    // MARK: Remove Reminders
    
    /// Tries to find a reminder with the matching reminderId, if found then it removes the reminder, if not found then throws error
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
            
            reminders[indexOfRemovalTarget ?? ReminderConstant.defaultReminderId].timer?.invalidate()
            reminders.remove(at: indexOfRemovalTarget ?? -1)
        }
    }
    
    func removeReminder(forIndex index: Int) {
        reminders[index].timer?.invalidate()
        reminders.remove(at: index)
    }
    
}

extension ReminderManager {
    
    // MARK: Locate
    
    /// finds and returns the reference of a reminder matching the given reminderId
    func findReminder(forReminderId reminderId: Int) throws -> Reminder {
        
        for r in 0..<reminders.count where reminders[r].reminderId == reminderId {
            return reminders[r]
        }
        throw ReminderManagerError.reminderIdNotPresent
    }
    
    /// finds and returns the index of a reminder with a reminderId in terms of the reminder: [Reminder] array
    func findIndex(forReminderId reminderId: Int) throws -> Int {
        for r in 0..<reminders.count where reminders[r].reminderId == reminderId {
            return r
        }
        throw ReminderManagerError.reminderIdNotPresent
    }
    
    // MARK: Information
    
    /// returns true if has created a reminder and has at least one enabled
    var hasEnabledReminder: Bool {
        for reminder in reminders where reminder.reminderIsEnabled == true {
            return true
        }
        return false
    }
    
    /// Returns the reminderExecutionDate that is closest to the present but still in the future.
    var soonestReminderExecutionDate: Date? {
        var closestExecutionDate: Date?
        // no point to interate through reminders with a nil reminderExecutionDate
        for reminder in reminders where reminder.reminderExecutionDate != nil {
            if closestExecutionDate == nil {
                closestExecutionDate = reminder.reminderExecutionDate!
            }
            else if Date().distance(to: reminder.reminderExecutionDate!) < Date().distance(to: closestExecutionDate!) {
                closestExecutionDate = reminder.reminderExecutionDate!
            }
        }
        return closestExecutionDate
    }
    
    // MARK: Compare
    
    /// Combines the reminders of an old reminder manager with the new reminder manager, forming a union with their reminders arrays. In the event that the newReminderManager (this object) has a reminder with the same id as the oldReminderManager, the reminder from the newReminderManager will override that reminder
    func combine(withOldReminderManager oldReminderManager: ReminderManager) {
        // the addReminders function overwrites reminders if it finds them, so we must add the reminders to the old reminders (allowing the newReminderManager to overwrite the oldReminderManager reminders if there is an overlap)
        oldReminderManager.addReminders(newReminders: self.reminders)
        // now that the oldReminderManager contains its original reminders, our new reminders, and has had its old reminders overwritten (in the case old & new both had a reminder with same reminderId), we have an updated array.
        self.reminders = oldReminderManager.reminders
    }
    
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