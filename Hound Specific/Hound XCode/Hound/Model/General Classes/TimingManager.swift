//
//  Timing.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum TimingManagerError: Error{
    case parseSenderInfoFailed
    case invalidateFailed
}

protocol TimingManagerDelegate {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class TimingManager{
    
    //MARK: - Properties
    
    static var delegate: TimingManagerDelegate! = nil
    
    ///Returns number of active timers, returns nil if paused
    static var currentlyActiveTimersCount: Int? {
        guard TimingConstant.isPaused == false else {
            return nil
        }
        
        var count = 0
        for d in 0..<MainTabBarViewController.staticDogManager.dogs.count {
            
            for r in 0..<MainTabBarViewController.staticDogManager.dogs[d].dogReminders.reminders.count {
                guard MainTabBarViewController.staticDogManager.dogs[d].dogReminders.reminders[r].getEnable() == true else{
                    continue
                }
                
                count = count + 1
            }
        }
        return count
    }
    
    ///Corrolates to dogManager: "
    ///Dictionary<dogName: String, Dictionary<reminderName: String, associatedTimer: Timer>>"
    
    /// IMPORTANT NOTE: DO NOT COPY, WILL MAKE MULTIPLE TIMERS WHICH WILL FIRE SIMULTANIOUSLY. This is depreciated as of 11/19/2021, added a timer variable to the remidners to simplify the process
   // static var timerDictionary: Dictionary<String,Dictionary<String,Timer>> = Dictionary<String,Dictionary<String,Timer>>()
    
    ///If a timeOfDay alarm is being skipped, this array stores all the timers that are responsible for unskipping the alarm when it goes from 1 Day -> 23 Hours 59 Minutes
    private static var isSkippingDisablers: [Timer] = []
    //MARK: - Main
    
    ///Initalizes all timers according to the dogManager passed, assumes no timers currently active and if transitioning from Paused to Unpaused (didUnpuase = true) handles logic differently
    static func willInitalize(dogManager: DogManager){
        
        ///Takes a DogManager and potentially a Bool of if all timers were unpaused, goes through the dog manager and finds all enabled reminders under all enabled dogs and sets a timer to fire.
        
        //Makes sure isPaused is false, don't want to instantiate timers when they should be paused
        guard TimingConstant.isPaused == false else {
            return
        }
        
        let sudoDogManager = dogManager
        //goes through all dogs
        for d in 0..<sudoDogManager.dogs.count{
            //makes sure current dog is enabled, as if it isn't then all of its timers arent either
            
            //goes through all reminders in a dog
            for r in 0..<sudoDogManager.dogs[d].dogReminders.reminders.count{
                
                let reminder = sudoDogManager.dogs[d].dogReminders.reminders[r]
                
                
                
                //makes sure a reminder is enabled and its presentation is not being handled
                guard reminder.getEnable() == true && reminder.isPresentationHandled == false
                else{
                    continue
                }
                
                //Sets a timer that executes when the timer should go from isSkipping true -> false, e.g. 1 Day left on a timer that is skipping and when it hits 23 hours and 59 minutes it turns into a regular nonskipping timer
                let unskipDate = reminder.timeOfDayComponents.unskipDate(timerMode: reminder.timerMode, reminderExecutionBasis: reminder.executionBasis)
                if unskipDate != nil {
                    let isSkippingDisabler = Timer(fireAt: unskipDate!,
                                                 interval: -1,
                                                 target: self,
                                                 selector: #selector(self.willUpdateIsSkipping(sender:)),
                                                 userInfo: ["dogName": dogManager.dogs[d].dogTraits.dogName, "reminder": reminder, "dogManager": dogManager],
                                                 repeats: false)
                    
                    isSkippingDisablers.append(isSkippingDisabler)
                    
                    RunLoop.main.add(isSkippingDisabler, forMode: .common)
                }
                
                let timer = Timer(fireAt: reminder.executionDate!,
                                          interval: -1,
                                          target: self,
                                          selector: #selector(self.didExecuteTimer(sender:)),
                                          userInfo: ["dogName": dogManager.dogs[d].dogTraits.dogName, "reminder": reminder],
                                          repeats: false)
                    RunLoop.main.add(timer, forMode: .common)
                
                reminder.timer?.invalidate()
                reminder.timer = timer
                
                /*
                 //Updates timerDictionary to reflect new timer added, this is so a reference to the created timer can be referenced later and invalidated if needed.
                 var nestedtimerDictionary: Dictionary<String, Timer> = timerDictionary[dogManager.dogs[d].dogTraits.dogName] ?? Dictionary<String,Timer>()
                 
                 nestedtimerDictionary[reminder.uuid] = timer
                 
                 timerDictionary[dogManager.dogs[d].dogTraits.dogName] = nestedtimerDictionary
                 */
                
            }
        }
    }
    
    ///Dummy selector sent to an inactive timer, an inactive timer (due to the way the infrastructure is built) still needs to be added to the timer dictionary so dependent components can display information properly
    @objc static private func sudoSelector(){
    }
    
    ///Invalidates all current timers then calls willInitalize, makes it a clean slate then re sets everything up
    static func willReinitalize(dogManager: DogManager) {
        ///Reinitalizes all timers when a new dogManager is sent
        self.invalidateAll(dogManager: dogManager)
        self.willInitalize(dogManager: dogManager)
    }
    
    
    ///If a reminder is skipping the next time of day alarm, at some point it will go from 1+ day away to 23 hours and 59 minutes. When that happens then the timer should be changed from isSkipping to normal mode because it just skipped that alarm that should have happened
    @objc private static func willUpdateIsSkipping(sender: Timer){
        guard let parsedDictionary = sender.userInfo as? [String: Any]
        else{
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: TimingManagerError.parseSenderInfoFailed)
            return
        }
        
        let dogName: String = parsedDictionary["dogName"]! as! String
        let pastReminder: Reminder = parsedDictionary["reminder"]! as! Reminder
        let dogManager = MainTabBarViewController.staticDogManager
        
        do {
            let dog = try dogManager.findDog(forName: dogName)
            let reminder = try dog.dogReminders.findReminder(forUUID: pastReminder.uuid)
            
            reminder.timeOfDayComponents.changeIsSkipping(newSkipStatus: false, shouldRemoveLogDuringPossibleUnskip: false)
            reminder.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
            
            delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
            
        } catch {
            AppDelegate.generalLogger.notice("willUpdateIsSkipping failure in finding dog or reminder")
            ErrorProcessor.alertForError(message: "Something went wrong trying to unskip your reminder's timing. If your reminder appears stuck, try: disabling it then re-enabling it, deleting it, or restarting the app.")
        }
        
        
        
    }
    
    //MARK: - Pause Control
    
    ///Toggles pause for a given dogManager to a specifided newPauseState
    static func willTogglePause(dogManager: DogManager, newPauseStatus: Bool) {
        
        //self.isPaused can be modified by SettingsViewController but this is only when there are no active timers and pause is automatically set to unpaused
        
        guard newPauseStatus != TimingConstant.isPaused else {
            return
        }
        
        ///Toggles pause status of timers, called when pauseAllTimers in settings is switched to a new state
        if newPauseStatus == true {
            TimingConstant.lastPause = Date()
            TimingConstant.isPaused = true
            
            willPause(dogManager: dogManager)
            
            invalidateAll(dogManager: dogManager)
            
        }
        else {
            TimingConstant.lastUnpause = Date()
            TimingConstant.isPaused = false
            willUnpause(dogManager: dogManager)
        }
    }
    
    
    
     ///Invalidates the isSkippingDisablers so it's fresh when time to reinitalize
    private static func invalidateAll(dogManager: DogManager) {
         /*
          ///Invalidates all timers
          for dogKey in timerDictionary.keys{
              for reminderKey in timerDictionary[dogKey]!.keys {
                      timerDictionary[dogKey]![reminderKey]!.invalidate()
              }
              timerDictionary[dogKey]!.removeAll()
          }
          timerDictionary.removeAll()
          */
        
        for dog in dogManager.dogs{
            for reminder in dog.dogReminders.reminders{
                reminder.timer?.invalidate()
                reminder.timer = nil
            }
        }
         
         
         for timerIndex in 0..<isSkippingDisablers.count {
             isSkippingDisablers[timerIndex].invalidate()
         }
         
         isSkippingDisablers.removeAll()
         
     }
     
    
    
    ///Updates dogManager to reflect the changes in intervalElapsed as if everything is paused the amount of time elapsed by each timer must to saved so when unpaused the new timers can be properly calculated
    private static func willPause(dogManager: DogManager){
        /*
        for dogKey in timerDictionary.keys{
            for reminderUUID in timerDictionary[dogKey]!.keys {
                
                //checks to make sure the enabled timer found is still valid (invalid ones are just ones from the past, left in the data)
                guard timerDictionary[dogKey]![reminderUUID]!.isValid else {
                    continue
                }
                
                let reminder = try! dogManager.findDog(forName: dogKey).dogReminders.findReminder(forUUID: reminderUUID)
         */
        for dog in dogManager.dogs{
            for reminder in dog.dogReminders.reminders {
                
                //checks to make sure the enabled timer found is still valid (invalid ones are just ones from the past, left in the data)
                guard reminder.timer?.isValid == true else {
                    continue
                }
                
                //one time reminder
                if reminder.timerMode == .oneTime{
                    //nothing
                }
                //If reminder is counting down
                else if reminder.timerMode == .countDown {
                    //If intervalElapsed has not been added to before
                    if reminder.countDownComponents.intervalElapsed <= 0.0001 {
                        reminder.countDownComponents.changeIntervalElapsed(newIntervalElapsed: reminder.executionBasis.distance(to: TimingConstant.lastPause!))
                    }
                    //If intervalElapsed has been added to before
                    else{
                        
                        reminder.countDownComponents.changeIntervalElapsed(newIntervalElapsed: (reminder.countDownComponents.intervalElapsed + TimingConstant.lastUnpause!.distance(to: (TimingConstant.lastPause!))))
                    }
                }
                //If reminder is snoozed
                else if reminder.timerMode == .snooze {
                    //If intervalElapsed has not been added to before
                    if reminder.snoozeComponents.intervalElapsed <= 0.0001 {
                        reminder.snoozeComponents.changeIntervalElapsed(newIntervalElapsed: reminder.executionBasis.distance(to: TimingConstant.lastPause!))
                    }
                    //If intervalElapsed has been added to before
                    else{
                        reminder.snoozeComponents.changeIntervalElapsed(newIntervalElapsed: (reminder.snoozeComponents.intervalElapsed + TimingConstant.lastUnpause!.distance(to: (TimingConstant.lastPause!))))
                    }
                }
                //If reminder is time of day
                else if reminder.timerMode == .weekly || reminder.timerMode == .monthly{
                    //nothing as time of day does not utilize interval elapsed
                }
                else {
                    fatalError("Not Implemented reminder.timerMode type, willPause(dogManager: DogManager)")
                }
                
                
                
            }
        }
        
        delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
    }
    
    ///Updates dogManager to reflect needed changes to the executionBasis, without this change the interval remaining would be based off an incorrect start date and fire at the wrong time. Can't use just Date() as it would be inaccurate if reinitalized but executionBasis + intervalRemaining will yield the same executionDate everytime.
    private static func willUnpause(dogManager: DogManager){
        
        //Goes through all enabled dogs and all their enabled reminders
        for dog in dogManager.dogs{
            for reminder in dog.dogReminders.reminders {
                //Changes the execution basis to the current time of unpause, if the execution basis is not changed then the interval remaining will go off a earlier point in time and have an overall earlier execution date, making the timer fire too early
                reminder.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: false)
                
                
            }
        }
        
        delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
    }

    //MARK: - Timer Actions
    
    ///Used as a selector when constructing timer in willInitalize, when called at an unknown point in time by the timer it triggers helper functions to create both in app notifcations and iOS notifcations
    @objc private static func didExecuteTimer(sender: Timer){
        
        //Parses the sender info needed to figure out which reminder's timer fired
        guard let parsedDictionary = sender.userInfo as? [String: Any]
        else{
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: TimingManagerError.parseSenderInfoFailed)
            return
        }
        
        let dogName: String = parsedDictionary["dogName"]! as! String
        let reminder: Reminder = parsedDictionary["reminder"]! as! Reminder
        
        TimingManager.willShowTimer(dogName: dogName, reminder: reminder)
    }
    
    ///Creates alertController to queue for presentation along with information passed along with it to reinitalize the timer once an option is selected (e.g. disable or snooze)
    static func willShowTimer(dogName: String, reminder: Reminder){
        
        let title = "\(reminder.displayTypeName) - \(dogName)"
        //let message = "\(reminder.reminderDescription)"
        
        let alertController = AlarmUIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert)
        
        let alertActionDismiss = UIAlertAction(
            title:"Dismiss",
            style: .cancel,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                    //TimingManager.willInactivateTimer(sender: Sender(origin: self, localized: self), dogName: dogName, reminderUUID: reminder.uuid)
                    TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: dogName, reminderUUID: reminder.uuid, knownLogType: nil)
                    Utils.checkForReview()
                })
        
        var alertActionsForLog: [UIAlertAction] = []
        
        switch reminder.reminderType {
        case .potty:
            let pottyKnownTypes: [KnownLogType] = [.pee, .poo, .both, .neither, .accident]
            for pottyKnownType in pottyKnownTypes {
                let alertActionLog = UIAlertAction(
                    title:"Log \(pottyKnownType.rawValue)",
                    style: .default,
                    handler:
                        {
                            (_)  in
                            //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                            TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: dogName, reminderUUID: reminder.uuid, knownLogType: pottyKnownType)
                            Utils.checkForReview()
                        })
                alertActionsForLog.append(alertActionLog)
            }
        default:
            let alertActionLog = UIAlertAction(
                title:"Log \(reminder.displayTypeName)",
                style: .default,
                handler:
                    {
                        (_)  in
                        //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                        TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: dogName, reminderUUID: reminder.uuid, knownLogType: KnownLogType(rawValue: reminder.reminderType.rawValue)!)
                        Utils.checkForReview()
                    })
            alertActionsForLog.append(alertActionLog)
        }
        
        let alertActionSnooze = UIAlertAction(
            title:"Snooze",
            style: .default,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                    TimingManager.willSnoozeTimer(sender: Sender(origin: self, localized: self), dogName: dogName, reminderUUID: reminder.uuid)
                    Utils.checkForReview()
                })
        
        for alertActionLog in alertActionsForLog {
            alertController.addAction(alertActionLog)
        }
        alertController.addAction(alertActionSnooze)
        alertController.addAction(alertActionDismiss)
        
    
        let dogManager = MainTabBarViewController.staticDogManager
        do {
            let dog = try dogManager.findDog(forName: dogName)
            //AppDelegate.generalLogger.notice("willShowTimer success in finding dog")
            let reminder = try dog.dogReminders.findReminder(forUUID: reminder.uuid)
            //AppDelegate.generalLogger.notice("willShowTimer success in finding reminder")
            
            if reminder.isPresentationHandled == false {
                reminder.isPresentationHandled = true
                delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
            }
            
            AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        } catch {
            AppDelegate.generalLogger.error("willShowTimer failure in finding dog or reminder")
            ErrorProcessor.alertForError(message: "Something went wrong trying to present your reminder's alarm. If your reminder appears stuck, disable it then re-enable it to fix.")
        }
        
        
    }
    
    ///Finishes executing timer and then sets its isSnoozed to true, note passed reminder should be a reference to a reminder in passed dogManager
    static func willSnoozeTimer(sender: Sender, dogName targetDogName: String, reminderUUID: String){
        let dogManager = MainTabBarViewController.staticDogManager
        
        let reminder = try! dogManager.findDog(forName: targetDogName).dogReminders.findReminder(forUUID: reminderUUID)
        
        reminder.timerReset(shouldLogExecution: false)
        
        reminder.snoozeComponents.changeSnooze(newSnoozeStatus: true)
        
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
    }
    
    ///Finishs executing timer then just resets it to countdown again
    static func willResetTimer(sender: Sender, dogName targetDogName: String, reminderUUID: String, knownLogType: KnownLogType?){
        
        let sudoDogManager = MainTabBarViewController.staticDogManager
        
        let dog = try! sudoDogManager.findDog(forName: targetDogName)
        
        let reminder = try! dog.dogReminders.findReminder(forUUID: reminderUUID)
        
        if reminder.timingStyle == .oneTime{
            if knownLogType != nil {
                try! dog.dogTraits.addLog(newLog: KnownLog(date: Date(), logType: knownLogType!, customTypeName: reminder.customTypeName))
            }
            try! dog.dogReminders.removeReminder(forUUID: reminderUUID)
            delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
            return
        }
        //Skips next TOD
        else if (reminder.timerMode == .weekly || reminder.timerMode == .monthly) && reminder.timeOfDayComponents.isSkipping == false && Date().distance(to: reminder.executionDate!) > 0{
            let executionBasisBackup = reminder.executionBasis
            reminder.timerReset(shouldLogExecution: true, knownLogType: knownLogType, customTypeName: reminder.customTypeName)
            reminder.timeOfDayComponents.changeIsSkipping(newSkipStatus: true, shouldRemoveLogDuringPossibleUnskip: nil)
            reminder.changeExecutionBasis(newExecutionBasis: executionBasisBackup, shouldResetIntervalsElapsed: false)
        }
        //Unskips next TOD
        else if (reminder.timerMode == .weekly || reminder.timerMode == .monthly) && reminder.timeOfDayComponents.isSkipping == true{
            reminder.timeOfDayComponents.changeIsSkipping(newSkipStatus: false, shouldRemoveLogDuringPossibleUnskip: true)
        }
        //Regular reset
        else {
            if knownLogType != nil {
                reminder.timerReset(shouldLogExecution: true, knownLogType: knownLogType, customTypeName: reminder.customTypeName)
            }
            else {
                reminder.timerReset(shouldLogExecution: false, knownLogType: nil, customTypeName: reminder.customTypeName)
            }
            
        }
        
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: sudoDogManager)
    }
    
    
}
