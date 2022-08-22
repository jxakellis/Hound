//
//  Timing.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol TimingManagerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class TimingManager {
    
    // MARK: - Properties
    
    static var delegate: TimingManagerDelegate! = nil
    
    /// If a timeOfDay alarm is being skipped, this array stores all the timers that are responsible for unskipping the alarm when it goes from 1 Day -> 23 Hours 59 Minutes
    private static var isSkippingDisablingTimers: [Timer] = []
    
    // MARK: - Main
    
    /// Initalizes all timers according to the dogManager passed, assumes no timers currently active and if transitioning from Paused to Unpaused (didUnpuase = true) handles logic differently
    static func willInitalize(forDogManager dogManager: DogManager) {
        
        /// Takes a DogManager and potentially a Bool of if all timers were unpaused, goes through the dog manager and finds all enabled reminders under all enabled dogs and sets a timer to fire.
        
        // goes through all dogs
        for dog in dogManager.dogs {
            // makes sure current dog is enabled, as if it isn't then all of its timers arent either
            
            // goes through all reminders in a dog
            for reminder in dog.dogReminders.reminders {
                
                /*
                 TO DO NOW if there are multiple reminders with the SAME parent dog and reminder action (or are .Custom with same custom reminder action), don't show queue muliple of the same pop ups.
                 
                 For example: Penny Potty at 5:00 pm and every 30 minutes. If reminder A goes off then some amount of time later reminder B goes off, this will present the user with two back to back alerts. These alerts will be IDENTICAl.
                 Therefore, keep both alerts in the queue (as they go off at different times) BUT if they both get presented at once only show one.
                 Then, make the action tapped, e.g. Log 'Potty: Pee', apply to all identical reminders.
                 Therefore, instead of having the user click Log 'Potty: Pee' 2+ times for Penny, they click it once and 'Potty: Pee' is logged for all reminders (e.g. reminders A, B, C...) that have gone off and queued an alert.
                 This reduces the number of taps that the user has to do and makes it less annoying as a lot of pop ups are obnoxious
                 */
                
                // makes sure a reminder is enabled and its presentation is not being handled
                guard reminder.reminderIsEnabled == true && reminder.hasAlarmPresentationHandled == false
                else {
                    continue
                }
                
                // Sets a timer that executes when the timer should go from isSkipping true -> false, e.g. 1 Day left on a timer that is skipping and when it hits 23 hours and 59 minutes it turns into a regular nonskipping timer
                let unskipDate = reminder.unskipDate()
                
                // if the a date to unskip exists, then creates a timer to do so when it is time
                if let unskipDate = unskipDate {
                    let isSkippingDisabler = Timer(fireAt: unskipDate,
                                                   interval: -1,
                                                   target: self,
                                                   selector: #selector(willUpdateIsSkipping(sender:)),
                                                   userInfo: [ServerDefaultKeys.dogId.rawValue: dog.dogId, ServerDefaultKeys.reminderId.rawValue: reminder.reminderId],
                                                   repeats: false)
                    
                    isSkippingDisablingTimers.append(isSkippingDisabler)
                    
                    RunLoop.main.add(isSkippingDisabler, forMode: .common)
                }
                
                let timer = Timer(fireAt: reminder.reminderExecutionDate!,
                                  interval: -1,
                                  target: self,
                                  selector: #selector(self.didExecuteTimer(sender:)),
                                  userInfo: [
                                    ServerDefaultKeys.dogManager.rawValue: dogManager,
                                    ServerDefaultKeys.dogId.rawValue: dog.dogId,
                                    ServerDefaultKeys.reminderId.rawValue: reminder.reminderId],
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .common)
                
                reminder.timer?.invalidate()
                reminder.timer = timer
            }
        }
    }
    
    /// invalidateAll timers for the oldDogManager
    static func willReinitalize(forOldDogManager oldDogManager: DogManager, forNewDogManager newDogManager: DogManager) {
        self.invalidateAll(forDogManager: oldDogManager)
        self.willInitalize(forDogManager: newDogManager)
    }
    
    /// Invalidates all timers so it's fresh when time to reinitalize
    static func invalidateAll(forDogManager dogManager: DogManager) {
        for dog in dogManager.dogs {
            for reminder in dog.dogReminders.reminders {
                reminder.timer?.invalidate()
                reminder.timer = nil
            }
        }
        
        for timer in isSkippingDisablingTimers {
            timer.invalidate()
        }
        
        isSkippingDisablingTimers.removeAll()
    }
    
    // MARK: - Timer Actions
    
    /// Used as a selector when constructing timer in willInitalize, when called at an unknown point in time by the timer it triggers helper functions to create both in app notifications and iOS notifications
    @objc private static func didExecuteTimer(sender: Timer) {
        
        // Parses the sender info needed to figure out which reminder's timer fired
        guard let parsedDictionary = sender.userInfo as? [String: Any] else {
            return
        }
        
        let dogManager = parsedDictionary[ServerDefaultKeys.dogManager.rawValue] as? DogManager
        let dogId = parsedDictionary[ServerDefaultKeys.dogId.rawValue] as? Int
        let reminderId = parsedDictionary[ServerDefaultKeys.reminderId.rawValue] as? Int
        
        guard let dogManager = dogManager, let dogId = dogId, let reminderId = reminderId else {
            return
        }
        
        AlarmManager.willShowAlarm(forDogManager: dogManager, forDogId: dogId, forReminderId: reminderId)
    }
    
    /// If a reminder is skipping the next time of day alarm, at some point it will go from 1+ day away to 23 hours and 59 minutes. When that happens then the timer should be changed from isSkipping to normal mode because it just skipped that alarm that should have happened
    @objc private static func willUpdateIsSkipping(sender: Timer) {
        guard let dictionary = sender.userInfo as? [String: Any],
              let dogId: Int = dictionary[ServerDefaultKeys.dogId.rawValue] as? Int,
              let passedReminderId: Int = dictionary[ServerDefaultKeys.reminderId.rawValue] as? Int else {
            return
        }
        
        let dogManager = MainTabBarViewController.staticDogManager
        
        let dog = dogManager.findDog(forDogId: dogId)
        let reminder = dog?.dogReminders.findReminder(forReminderId: passedReminderId)
        
        guard let reminder = reminder else {
            return
        }
        
        if reminder.reminderType == .weekly {
            reminder.weeklyComponents.isSkipping = false
            reminder.weeklyComponents.isSkippingDate = nil
        }
        else if reminder.reminderType == .monthly {
            reminder.monthlyComponents.isSkipping = false
            reminder.monthlyComponents.isSkippingDate = nil
        }
        reminder.reminderExecutionBasis = Date()
        
        delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        
    }
    
}
