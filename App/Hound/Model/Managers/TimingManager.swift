//
//  Timing.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol TimingManagerDelegate: AnyObject {
    func didAddReminder(sender: Sender, forDogId: Int, forReminder: Reminder)
}

final class TimingManager {
    
    // MARK: - Properties
    
    static var delegate: TimingManagerDelegate! = nil
    
    // MARK: - Main
    
    /// Initalizes all reminder timers
    static func initalizeReminderTimers(forDogManager dogManager: DogManager) {
        for dog in dogManager.dogs {
            for reminder in dog.dogReminders.reminders {
                // if the reminder has a execution date, then create its timers
                guard reminder.reminderIsEnabled == true, let reminderExecutionDate = reminder.reminderExecutionDate else {
                    // the reminder is disabled and can't have any timers, make sure that its timers are cleared as such
                    reminder.clearTimers()
                    continue
                }
                
                // if the reminder doesn't have a reminderAlarmTimer or the reminderAlarmTimer hasn't fired yet, assign the reminder a new reminderAlarmTimer
                if reminder.reminderAlarmTimer == nil || reminder.reminderAlarmTimer?.fireDate ?? Date(timeIntervalSince1970: 0.0) > Date() {
                    let reminderAlarmTimer = Timer(fireAt: reminderExecutionDate,
                                      interval: -1,
                                      target: self,
                                      selector: #selector(self.didExecuteReminderAlarmTimer(sender:)),
                                      userInfo: [
                                        KeyConstant.dogName.rawValue: dog.dogName,
                                        KeyConstant.dogId.rawValue: dog.dogId,
                                        KeyConstant.reminder.rawValue: reminder
                                      ],
                                      repeats: false)
                    reminder.reminderAlarmTimer = reminderAlarmTimer
                    RunLoop.main.add(reminderAlarmTimer, forMode: .common)
                }
                
                // Sets a timer that executes when the timer should go from isSkipping true -> false.
                // If the reminder doesn't have a reminderDisableIsSkippingTimer or the reminderDisableIsSkippingTimer hasn't fired yet, assign the reminder a new reminderDisableIsSkippingTimer
                if reminder.reminderDisableIsSkippingTimer == nil || reminder.reminderDisableIsSkippingTimer?.fireDate ?? Date(timeIntervalSince1970: 0.0) > Date(), let disableIsSkippingDate = reminder.disableIsSkippingDate {
                    let reminderDisableIsSkippingTimer = Timer(fireAt: disableIsSkippingDate,
                                                   interval: -1,
                                                   target: self,
                                                   selector: #selector(didExecuteReminderDisableIsSkippingTimer(sender:)),
                                                   userInfo: [
                                                        KeyConstant.dogId.rawValue: dog.dogId,
                                                        KeyConstant.reminder.rawValue: reminder],
                                                   repeats: false)
                    reminder.reminderDisableIsSkippingTimer = reminderDisableIsSkippingTimer
                    RunLoop.main.add(reminderDisableIsSkippingTimer, forMode: .common)
                }
            }
        }
    }
    
    // MARK: - Timer Actions
    
    /// Used as a selector when constructing timer in initalizeReminderTimers. Invoke AlarmManager to show alart controller for reminder alarm
    @objc private static func didExecuteReminderAlarmTimer(sender: Timer) {
        // Parses the sender info needed to figure out which reminder's timer fired
        guard let userInfo = sender.userInfo as? [String: Any] else {
            return
        }
        
        let dogName: String? = userInfo[KeyConstant.dogName.rawValue] as? String
        let dogId: Int? = userInfo[KeyConstant.dogId.rawValue] as? Int
        let reminder: Reminder? = userInfo[KeyConstant.reminder.rawValue] as? Reminder
        
        guard let dogName = dogName, let dogId = dogId, let reminder = reminder else {
            return
        }
        
        AlarmManager.willShowAlarm(forDogName: dogName, forDogId: dogId, forReminder: reminder)
    }
    
    /// Used as a selector when constructing timer in initalizeReminderTimers. It triggers when the current date passes the original reminderExecutionDate that was skipped, indicating the reminder should go back into regular, non-skipping mode. If assigning new timer, invalidates the current timer then assigns reminderDisableIsSkippingTimer to new timer.
    @objc private static func didExecuteReminderDisableIsSkippingTimer(sender: Timer) {
        guard let userInfo = sender.userInfo as? [String: Any] else {
            return
        }
        
        let dogId: Int? = userInfo[KeyConstant.dogId.rawValue] as? Int
        let reminder: Reminder? = userInfo[KeyConstant.reminder.rawValue] as? Reminder
        
        guard let dogId = dogId, let reminder = reminder else {
            return
        }
        
        reminder.resetForNextAlarm()
        
        RemindersRequest.update(invokeErrorManager: false, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _ in
            guard requestWasSuccessful == true else {
                return
            }
            
            delegate.didAddReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
        }
    }
    
}
