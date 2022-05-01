//
//  Timing.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol TimingManagerDelegate {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class TimingManager {
    
    // MARK: - Properties
    
    static var delegate: TimingManagerDelegate! = nil
    
    /// If a timeOfDay alarm is being skipped, this array stores all the timers that are responsible for unskipping the alarm when it goes from 1 Day -> 23 Hours 59 Minutes
    private static var isSkippingDisablers: [Timer] = []
    // MARK: - Main
    
    /// Initalizes all timers according to the dogManager passed, assumes no timers currently active and if transitioning from Paused to Unpaused (didUnpuase = true) handles logic differently
    static func willInitalize(dogManager: DogManager) {
        
        /// Takes a DogManager and potentially a Bool of if all timers were unpaused, goes through the dog manager and finds all enabled reminders under all enabled dogs and sets a timer to fire.
        
        // Makes sure isPaused is false, don't want to instantiate timers when they should be paused
        guard FamilyConfiguration.isPaused == false else {
            return
        }
        
        let sudoDogManager = dogManager
        // goes through all dogs
        for d in 0..<sudoDogManager.dogs.count {
            // makes sure current dog is enabled, as if it isn't then all of its timers arent either
            
            // goes through all reminders in a dog
            for r in 0..<sudoDogManager.dogs[d].dogReminders.reminders.count {
                
                let reminder = sudoDogManager.dogs[d].dogReminders.reminders[r]
                
                // makes sure a reminder is enabled and its presentation is not being handled
                guard reminder.reminderIsEnabled == true && reminder.isPresentationHandled == false
                else {
                    continue
                }
                
                // Sets a timer that executes when the timer should go from isSkipping true -> false, e.g. 1 Day left on a timer that is skipping and when it hits 23 hours and 59 minutes it turns into a regular nonskipping timer
                let unskipDate = reminder.unskipDate()
                
                // if the a date to unskip exists, then creates a timer to do so when it is time
                if unskipDate != nil {
                    let isSkippingDisabler = Timer(fireAt: unskipDate!,
                                                   interval: -1,
                                                   target: self,
                                                   selector: #selector(willUpdateIsSkipping(sender:)),
                                                   userInfo: [ServerDefaultKeys.dogId.rawValue: dogManager.dogs[d].dogId, ServerDefaultKeys.reminderId.rawValue: reminder.reminderId],
                                                   repeats: false)
                    
                    isSkippingDisablers.append(isSkippingDisabler)
                    
                    RunLoop.main.add(isSkippingDisabler, forMode: .common)
                }
                
                let timer = Timer(fireAt: reminder.reminderExecutionDate!,
                                  interval: -1,
                                  target: self,
                                  selector: #selector(self.didExecuteTimer(sender:)),
                                  userInfo: [
                                    ServerDefaultKeys.dogId.rawValue: dogManager.dogs[d].dogId,
                                    ServerDefaultKeys.dogName.rawValue: dogManager.dogs[d].dogName,
                                    ServerDefaultKeys.reminderId.rawValue: reminder.reminderId],
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .common)
                
                reminder.timer?.invalidate()
                reminder.timer = timer
            }
        }
    }
    
    /// Invalidates all current timers then calls willInitalize, makes it a clean slate then re sets everything up
    static func willReinitalize(dogManager: DogManager) {
        /// Reinitalizes all timers when a new dogManager is sent
        self.invalidateAll(dogManager: dogManager)
        self.willInitalize(dogManager: dogManager)
    }
    
    /// If a reminder is skipping the next time of day alarm, at some point it will go from 1+ day away to 23 hours and 59 minutes. When that happens then the timer should be changed from isSkipping to normal mode because it just skipped that alarm that should have happened
    @objc private static func willUpdateIsSkipping(sender: Timer) {
        guard let parsedDictionary = sender.userInfo as? [String: Any]
        else {
            ErrorManager.alert(forError: TimingManagerError.parseSenderInfoFailed)
            return
        }
        
        let dogId: Int = parsedDictionary[ServerDefaultKeys.dogId.rawValue]! as! Int
        let passedReminderId: Int = parsedDictionary[ServerDefaultKeys.reminderId.rawValue]! as! Int
        let dogManager = MainTabBarViewController.staticDogManager
        
        do {
            let dog = try dogManager.findDog(forDogId: dogId)
            let reminder = try dog.dogReminders.findReminder(forReminderId: passedReminderId)
            
            if reminder.reminderType == .weekly {
                reminder.weeklyComponents.isSkipping = false
                reminder.weeklyComponents.isSkippingDate = nil
            }
            else if reminder.reminderType == .monthly {
                reminder.monthlyComponents.isSkipping = false
                reminder.monthlyComponents.isSkippingDate = nil
                
            }
            reminder.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
            
            delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
            
        }
        catch {
            AppDelegate.generalLogger.notice("willUpdateIsSkipping failure in finding dog or reminder")
        }
        
    }
    
    // MARK: - Pause Control
    
    /// Toggles pause for a given dogManager to a specifided newPauseState
    static func willToggleIsPaused(forDogManager dogManager: DogManager, newIsPaused isPaused: Bool) {
        
        guard isPaused != FamilyConfiguration.isPaused else {
            return
        }
        
        let body: [String: Any] = [
            ServerDefaultKeys.isPaused.rawValue: isPaused
        ]
        
        FamilyRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == true {
                // update the local information to reflect the server change
                FamilyConfiguration.isPaused = isPaused
                if isPaused == false {
                    // TO DO have server calculate reminderExecutionDates itself
                    // reminders are now unpaused, we must update the server with the new executionDates (can't calculate them itself)
                    RequestUtils.getDogManager(invokeErrorManager: true) { dogManager, _ in
                        // Goes through all enabled dogs and all their reminders
                        if dogManager != nil {
                            for dog in dogManager!.dogs {
                                // update the Hound server with
                                let remindersToUpdate = dog.dogReminders.reminders.filter({ reminder in
                                    // create an array of reminders with non-nil executionDates, as we are providing the Hound server with a list of reminders with the newly calculated executionDates
                                    return (reminder.reminderExecutionDate == nil) == false
                                })
                                RemindersRequest.update(invokeErrorManager: true, forDogId: dog.dogId, forReminders: remindersToUpdate) { requestWasSuccessful, _ in
                                    if requestWasSuccessful == true {
                                        // the call to update the server on the reminder unpause was successful, now send to delegate
                                        delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager!)
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    // reminders are now paused, so remove the timers
                    self.invalidateAll(dogManager: dogManager)
                }
            }
        }
    }
    
    /// Invalidates the isSkippingDisablers so it's fresh when time to reinitalize
    private static func invalidateAll(dogManager: DogManager) {
        
        for dog in dogManager.dogs {
            for reminder in dog.dogReminders.reminders {
                reminder.timer?.invalidate()
                reminder.timer = nil
            }
        }
        
        for timerIndex in 0..<isSkippingDisablers.count {
            isSkippingDisablers[timerIndex].invalidate()
        }
        
        isSkippingDisablers.removeAll()
        
    }
    
    /// Updates dogManager to reflect the changes in intervalElapsed as if everything is paused the amount of time elapsed by each timer must to saved so when unpaused the new timers can be properly calculated
    private static func willPause(forDogManager dogManager: DogManager) {
        
        for dog in dogManager.dogs {
            for reminder in dog.dogReminders.reminders {
                
                // checks to make sure the enabled timer found is still valid (invalid ones are just ones from the past, left in the data)
                guard reminder.timer?.isValid == true else {
                    continue
                }
                
                switch reminder.currentReminderMode {
                case .countdown:
                    // If intervalElapsed has not been added to before
                    if reminder.countdownComponents.intervalElapsed == 0.0 {
                        reminder.countdownComponents.changeIntervalElapsed(newIntervalElapsed: reminder.reminderExecutionBasis.distance(to: FamilyConfiguration.lastPause!))
                    }
                    // If intervalElapsed has been added to before, so not first time it has been paused and lastUnpause shouldn't be nil
                    else {
                        
                        reminder.countdownComponents.changeIntervalElapsed(newIntervalElapsed: (reminder.countdownComponents.intervalElapsed + FamilyConfiguration.lastUnpause!.distance(to: (FamilyConfiguration.lastPause!))))
                    }
                case .snooze:
                    // If intervalElapsed has not been added to before, so not first time it has been paused and lastUnpause shouldn't be nil
                    if reminder.snoozeComponents.intervalElapsed == 0.0 {
                        reminder.snoozeComponents.changeIntervalElapsed(newIntervalElapsed: reminder.reminderExecutionBasis.distance(to: FamilyConfiguration.lastPause!))
                    }
                    // If intervalElapsed has been added to before
                    else {
                        reminder.snoozeComponents.changeIntervalElapsed(newIntervalElapsed: (reminder.snoozeComponents.intervalElapsed + FamilyConfiguration.lastUnpause!.distance(to: (FamilyConfiguration.lastPause!))))
                    }
                default:
                    continue
                    // nothing as weekly, monthly, and oneTime do not utilize interval elapsed
                }
                
            }
            
            // since all of the reminders will have their executionDates set to nil, we need to update them all
            RemindersRequest.update(invokeErrorManager: true, forDogId: dog.dogId, forReminders: dog.dogReminders.reminders) { requestWasSuccessful, _ in
                // TO DO there is a more efficent way to do this. Lots of delegate calls.
                if requestWasSuccessful == true {
                    delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
                }
            }
            
        }
    }
    
    /// Updates dogManager to reflect needed changes to the reminderExecutionBasis, without this change the interval remaining would be based off an incorrect start date and fire at the wrong time. Can't use just Date() as it would be inaccurate if reinitalized but reminderExecutionBasis + intervalRemaining will yield the same reminderExecutionDate everytime.
    private static func willUnpause(forDogManager dogManager: DogManager) {
        
        // Goes through all enabled dogs and all their reminders
        for dog in dogManager.dogs {
            for reminder in dog.dogReminders.reminders {
                // Changes the execution basis to the current time of unpause, if the execution basis is not changed then the interval remaining will go off a earlier point in time and have an overall earlier execution date, making the timer fire too early
                reminder.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: false)
                
            }
            // since we update the execution basis of all the reminders, we should update the server on them all
            RemindersRequest.update(invokeErrorManager: true, forDogId: dog.dogId, forReminders: dog.dogReminders.reminders) { requestWasSuccessful, _ in
                // TO DO there is a more efficent way to do this. Lots of delegate calls.
                if requestWasSuccessful == true {
                    // the call to update the server on the reminder unpause was successful, now send to delegate
                    delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
                }
            }
        }
    }
    
    // MARK: - Timer Actions
    
    /// Used as a selector when constructing timer in willInitalize, when called at an unknown point in time by the timer it triggers helper functions to create both in app notifcations and iOS notifcations
    @objc private static func didExecuteTimer(sender: Timer) {
        
        // Parses the sender info needed to figure out which reminder's timer fired
        guard let parsedDictionary = sender.userInfo as? [String: Any]
        else {
            ErrorManager.alert(forError: TimingManagerError.parseSenderInfoFailed)
            return
        }
        
        let dogName: String = parsedDictionary[ServerDefaultKeys.dogName.rawValue]! as! String
        let dogId: Int = parsedDictionary[ServerDefaultKeys.dogId.rawValue]! as! Int
        let reminderId: Int = parsedDictionary[ServerDefaultKeys.reminderId.rawValue]! as! Int
        
        AlarmManager.willShowAlarm(forDogName: dogName, forDogId: dogId, forReminderId: reminderId)
    }
    
}
