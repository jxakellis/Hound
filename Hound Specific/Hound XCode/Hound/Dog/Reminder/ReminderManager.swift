//
//  Reminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Enum full of cases of possible errors from ReminderManager
enum ReminderManagerError: Error {
    case reminderIdAlreadyPresent
    case reminderIdNotPresent
}

protocol ReminderManagerProtocol {

    // dog that holds the reminders
    var parentDog: Dog? { get set }

    // array of reminders, a dog should contain one of these to specify all of its reminders
    var reminders: [Reminder] { get }

    /// Checks to see if a reminder is already present. If its reminderId is, then is removes the old one and replaces it with the new
    mutating func addReminder(newReminder: Reminder) throws

    /// Invokes addReminder(newReminder: Reminder) for newReminder.count times
    mutating func addReminder(newReminders: [Reminder]) throws

    /// removes trys to find a reminder whos name (capitals don't matter) matches reminder name given, if found removes reminder, if not found throws error
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
        let copy = ReminderManager(parentDog: parentDog, initReminders: self.reminders)
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

    init(parentDog: Dog?, initReminders: [Reminder] = []) {
        self.storedParentDog = parentDog
        super.init()
        for reminder in initReminders {
            appendReminder(newReminder: reminder)
        }
    }

    // MARK: Properties

    /// Array of reminders
    private var storedReminders: [Reminder] = []
    var reminders: [Reminder] { return storedReminders }

    private var storedParentDog: Dog?
    var parentDog: Dog? {
        get {
            return storedParentDog
        }
        set (newParentDog) {
            self.storedParentDog = newParentDog
            for reminder in storedReminders {
                reminder.parentDog = storedParentDog
            }
        }
    }

    // MARK: Add Reminders

    /// This handles the proper appending of a reminder. This function assumes an already checked reminder and its purpose is to bypass the add reminder endpoint
    private func appendReminder(newReminder: Reminder) {
        let newReminderCopy = newReminder.copy() as! Reminder
        newReminderCopy.parentDog = self.parentDog
       storedReminders.append(newReminderCopy)
    }

    func addReminder(newReminder: Reminder) {

        // removes any existing reminders that have the same reminderId as they would cause problems. .reversed() is needed to make it work, without it there will be an index of out bounds error.
        for (reminderIndex, reminder) in reminders.enumerated().reversed() where reminder.reminderId == newReminder.reminderId {
            // instead of crashing, replace the reminder.
            reminder.timer?.invalidate()
            storedReminders.remove(at: reminderIndex)
            storedReminders.append(newReminder)
            AppDelegate.endpointLogger.notice("ENDPOINT Update Reminder")

            sortReminders()
            return
        }

        appendReminder(newReminder: newReminder)
        AppDelegate.endpointLogger.notice("ENDPOINT Add Reminder")

        sortReminders()
    }

    func addReminder(newReminders: [Reminder]) {
        for reminder in newReminders {
            addReminder(newReminder: reminder)
        }
        sortReminders()
    }

    /// adds default set of reminders
    func addDefaultReminders() {
        addReminder(newReminder: ReminderConstant.defaultReminderOne)
        addReminder(newReminder: ReminderConstant.defaultReminderTwo)
        addReminder(newReminder: ReminderConstant.defaultReminderThree)
        addReminder(newReminder: ReminderConstant.defaultReminderFour)
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

        storedReminders[indexOfRemovalTarget ?? -1].timer?.invalidate()
        storedReminders.remove(at: indexOfRemovalTarget ?? -1)
        AppDelegate.endpointLogger.notice("ENDPOINT Remove Reminder (via reminderId)")
        }
    }

    func removeReminder(forIndex index: Int) {
        storedReminders[index].timer?.invalidate()
        storedReminders.remove(at: index)
        AppDelegate.endpointLogger.notice("ENDPOINT Remove Reminder (via index)")
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
            if Date().distance(to: reminder1.oneTimeComponents.executionDate) < Date().distance(to: reminder2.oneTimeComponents.executionDate) {
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

}

protocol ReminderManagerControlFlowProtocol {

    /// Returns a copy of ReminderManager used to avoid accidental changes (due to reference type) by classes which get their dog manager from here
    func getReminderManager() -> ReminderManager

    /// Sets reminderManager equal to newReminderManager, depending on sender will also call methods to propogate change.
    func setReminderManager(sender: Sender, newReminderManager: ReminderManager)

    // Updates things dependent on reminderManager
    func updateReminderManagerDependents()

}
