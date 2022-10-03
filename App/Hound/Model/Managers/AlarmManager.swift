//
//  AlarmManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/20/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol AlarmManagerDelegate: AnyObject {
    func didAddLog(sender: Sender, forDogId: Int, forLog: Log)
    func didRemoveLog(sender: Sender, forDogId: Int, forLogId: Int)
    func didUpdateReminder(sender: Sender, forDogId: Int, forReminder: Reminder)
    func didRemoveReminder(sender: Sender, forDogId: Int, forReminderId: Int)
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class AlarmManager {
    static var delegate: AlarmManagerDelegate! = nil
    
    /// If the globalPresenter is not loaded, indicating that the app is in the background, we store all willShowAlarm calls in this alarmQueue. This ensures that once the app is opened, the alarm queue is executed so that it fetches the most current information from the server.
    static private var alarmQueue: [(DogManager, Int, Int)] = []
    
    /// Creates AlarmUIAlertController to show the user about their alarm going off. We query the server with the information provided first to make sure it is up to date. 
    static func willShowAlarm(forDogManager dogManager: DogManager, forDogId dogId: Int, forReminderId reminderId: Int) {
        // If the app is in the background, add the willShowAlarm to the queue. Once the app is brought to the foreground, executes synchronizeAlarmQueue to attempt to reshow all of these alarms. This ensures that when the alarms are presented, the app is open. Otherwise, we could fetch the information for an alarm and present it, only for it to sit in the background for an hour while the app is closed, making the alarm outdated.
        guard UIApplication.shared.applicationState != .background else {
            alarmQueue.append((dogManager, dogId, reminderId))
            return
        }
        
        // See if we can find a corresponding dog for the dogId. If we can't, then no point to go any further
        guard let dog = dogManager.findDog(forDogId: dogId) else {
            return
        }
        
        // Add temporary and informal hasAlarmPresentationHandled to the reminder. We do this so willShowAlarm isn't invoked again for a reminder while a fraction of a second earlier call is still waiting for a result from RemindersRequest.get
        dog.dogReminders.findReminder(forReminderId: reminderId)?.hasAlarmPresentationHandled = true
        
        // before presenting alarm, make sure we are up to date locally
        RemindersRequest.get(invokeErrorManager: false, forDogId: dogId, forReminderId: reminderId) { reminder, responseStatus in
            
            // Remove temporary and informal presentation handled indicator. The formal hasAlarmPresentationHandled marker will be adjusted below
            dog.dogReminders.findReminder(forReminderId: reminderId)?.hasAlarmPresentationHandled = false
            
            // If we got no response, then halt here as we were unable to retrieve the updated reminder
            guard responseStatus != .noResponse else {
                return
            }
            
            guard let reminder = reminder else {
                if responseStatus == .successResponse {
                    // If the response was successful but no reminder was returned, that means the reminder was deleted. Therefore, update the dogManager to indicate as such.
                    dogManager.findDog(forDogId: dogId)?.dogReminders.removeReminder(forReminderId: reminderId)
                    delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
                }
                return
            }
            
            // If reminder.reminderExecutionDate is nil, then something potentially was disabled / paused or the reminder's timing components are broken.
            // If distance from present to executionDate is positive, then executionDate in future. If distance is negative, then executionDate in past
            guard let reminderExecutionDate = reminder.reminderExecutionDate, Date().distance(to: reminderExecutionDate) < 0 else {
                // We were able to retrieve the reminder and something was wrong with it. Something was disabled/paused, the reminder was pushed back to the future, or it simply just has invalid timing components
                // MARK: IMPORTANT - Do not try to refresh DogManager as that can (and does) cause an infinite loop. The reminder can exist but for some reason have invalid data leading to a nil executionDate. If we refresh the DogManager, we could retrieve the same invalid reminder data which leads back to this statement (and thus starts the infinite loop)
                
                self.delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
                return
            }
            
            // the reminder exists, its executionDate exists, and its executionDate is in the past (meaning it should be valid).
            
            // the dogId and reminderId exist if we got a reminder back
            let title = "\(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)) - \(dog.dogName)"
            
            let alarmAlertController = AlarmUIAlertController(
                title: title,
                message: nil,
                preferredStyle: .alert)
            alarmAlertController.setup(forDogId: dogId, forReminder: reminder)
            
            let alertActionDismiss = UIAlertAction(
                title: "Dismiss",
                style: .cancel,
                handler: { (_: UIAlertAction!)  in
                    // Make sure to use alarmAlertController.referenceAlarmAlertController as at the time of execution, original alarmAlertController could have been combined with something else
                    guard let referenceAlarmAlertController = alarmAlertController.referenceAlarmAlertController else {
                        return
                    }
                    
                    for alarmReminder in referenceAlarmAlertController.reminders {
                        AlarmManager.willDismissAlarm(forDogId: dogId, forReminder: alarmReminder)
                    }
                    CheckManager.checkForReview()
                })
            
            var alertActionsForLog: [UIAlertAction] = []
            
            // Cant convert a reminderAction of potty directly to logAction, as it has serveral possible outcomes. Otherwise, logAction and reminderAction 1:1
            let logActions: [LogAction] = reminder.reminderAction == .potty ? [.pee, .poo, .both, .neither, .accident] : [LogAction(rawValue: reminder.reminderAction.rawValue) ?? ClassConstant.LogConstant.defaultLogAction]
        
            for logAction in logActions {
                let alertActionLog = UIAlertAction(
                    title: "Log \(logAction.displayActionName(logCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))",
                    style: .default,
                    handler: { (_)  in
                        // Make sure to use alarmAlertController.referenceAlarmAlertController as at the time of execution, original alarmAlertController could have been combined with something else
                        guard let referenceAlarmAlertController = alarmAlertController.referenceAlarmAlertController else {
                            return
                        }
                        
                        for alarmReminder in referenceAlarmAlertController.reminders {
                            AlarmManager.willLogAlarm(forDogId: dogId, forReminder: alarmReminder, forLogAction: logAction)
                        }
                        CheckManager.checkForReview()
                    })
                alertActionsForLog.append(alertActionLog)
            }
            
            let alertActionSnooze = UIAlertAction(
                title: "Snooze",
                style: .default,
                handler: { (_: UIAlertAction!)  in
                    // Make sure to use alarmAlertController.referenceAlarmAlertController as at the time of execution, original alarmAlertController could have been combined with something else
                    guard let referenceAlarmAlertController = alarmAlertController.referenceAlarmAlertController else {
                        return
                    }
                    
                    for alarmReminder in referenceAlarmAlertController.reminders {
                        AlarmManager.willSnoozeAlarm(forDogId: dogId, forReminder: alarmReminder)
                    }
                    CheckManager.checkForReview()
                })
            
            for alertActionLog in alertActionsForLog {
                alarmAlertController.addAction(alertActionLog)
            }
            alarmAlertController.addAction(alertActionSnooze)
            alarmAlertController.addAction(alertActionDismiss)
            
            // we have successfully constructed our alert
            reminder.hasAlarmPresentationHandled = true
            delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
            
            AlertManager.enqueueAlertForPresentation(alarmAlertController)
            
        }
    }
    
    /// Once the app is brought back into the foreground, meaning the alarms in the alarm queue can be presented, call this function to iterate through and present any alarms in the alarm queue
    static func synchronizeAlarmQueue() {
        
        // Only attempt to show the alarms if the app isn't in the background
        guard UIApplication.shared.applicationState != .background else {
            return
        }
        
        let copiedAlarmQueue = alarmQueue
        alarmQueue = []
        
        // We can't iterate over alarmQueue as willShowAlarm could potentially add items to alarmQueue. That means we need to empty alarmQueue before iterating over to avoid mixing.
        for (index, alarm) in copiedAlarmQueue.enumerated() {
            // First alarm (at front of queue... should come first): execute queries right now
            // Second alarm: execute queries after 25 ms to help ensure it comes second
            // Thirds alarm: execute queries after 50 ms to help ensure it comes third
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.025 * Double(index)), execute: {
                willShowAlarm(forDogManager: alarm.0, forDogId: alarm.1, forReminderId: alarm.2)
            })
        }
    }
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Snooze' the reminder. Therefore we modify the timing data so the reminder turns into .snooze mode, alerting them again soon. We don't add a log
    private static func willSnoozeAlarm(forDogId dogId: Int, forReminder reminder: Reminder) {
        // update information
        reminder.prepareForNextAlarm()
        
        reminder.snoozeComponents.executionInterval = UserConfiguration.snoozeLength
        
        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _ in
            if requestWasSuccessful == true {
                // no log or anything created, so we can just proceed to updating locally
                delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
            }
        }
        
    }
    
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Dismiss' the reminder. Therefore we reset the timing data and don't add a log.
    private static func willDismissAlarm(forDogId dogId: Int, forReminder reminder: Reminder) {
        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // just make request to delete reminder for oneTime remidner
            RemindersRequest.delete(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminderId: reminder.reminderId)
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            reminder.prepareForNextAlarm()
            
            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _ in
                // we dont need to persist a log
                if requestWasSuccessful == true {
                    delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
                }
            }
        }
        
    }
    
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Log' the reminder. Therefore we reset the timing data and add a log.
    private static func willLogAlarm(forDogId dogId: Int, forReminder reminder: Reminder, forLogAction logAction: LogAction) {
        
        let log = Log(logAction: logAction, logCustomActionName: reminder.reminderCustomActionName, logDate: Date())
        
        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder
            
            // delete the reminder on the server
            RemindersRequest.delete(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminderId: reminder.reminderId)
                    // create log on the server and then assign it the logId and then add it to the dog
                    LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: log) { logId, _ in
                        guard let logId = logId else {
                            return
                        }
                        
                        // persist log successful, therefore we can save the info locally
                        log.logId = logId
                        delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogId: dogId, forLog: log)
                    }
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            reminder.prepareForNextAlarm()
            
            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
                    // we need to persist a log as well
                    LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: log) { logId, _ in
                        guard let logId = logId else {
                            return
                        }
                        // persist log successful, therefore we can save the info locally
                        log.logId = logId
                        delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogId: dogId, forLog: log)
                    }
                }
            }
        }
        
    }
    
    /// The user went to log/skip a reminder on the reminders page. Must updating skipping data and add a log. Only provide a UIViewController if you wish the spinning checkmark animation to happen.
    static func willSkipReminder(forDogId dogId: Int, forReminder reminder: Reminder, forLogAction logAction: LogAction) {
        let log = Log(logAction: logAction, logCustomActionName: reminder.reminderCustomActionName, logDate: Date())
        
        // special case. Once a oneTime reminder executes/ is skipped, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder
            
            // delete the reminder on the server
            RemindersRequest.delete(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    delegate.didRemoveReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminderId: reminder.reminderId)
                    // create log on the server and then assign it the logId and then add it to the dog
                    LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: log) { logId, _ in
                        guard let logId = logId else {
                            return
                        }
                        // persist log successful, therefore we can save the info locally
                        log.logId = logId
                        delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogId: dogId, forLog: log)
                    }
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            
            reminder.changeIsSkipping(forIsSkipping: true)
            
            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
                    // we need to persist a log as well
                    LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: log) { logId, _ in
                        guard let logId = logId else {
                            return
                        }
                        // persist log successful, therefore we can save the info locally
                        log.logId = logId
                        delegate.didAddLog(sender: Sender(origin: self, localized: self), forDogId: dogId, forLog: log)
                    }
                }
            }
        }
    }
    
    /// The user went to unlog/unskip a reminder on the reminders page. Must update skipping information. Note: only weekly/monthly reminders can be skipped therefore only they can be unskipped.
    static func willUnskipReminder(forDog dog: Dog, forReminder reminder: Reminder) {
        
        // we can only unskip a weekly/monthly reminder that is currently isSkipping == true
        guard (reminder.reminderType == .weekly && reminder.weeklyComponents.isSkipping == true) || (reminder.reminderType == .monthly && reminder.monthlyComponents.isSkipping == true) else {
            return
        }
        
        // this is the time that the reminder's next alarm was skipped. at this same moment, a log was added. If this log is still there, with it's date unmodified by the user, then we remove it.
        let dateOfLogToRemove: Date = {
            if reminder.reminderType == .weekly {
                return reminder.weeklyComponents.skippedDate ?? ClassConstant.DateConstant.default1970Date
            }
            else if reminder.reminderType == .monthly {
                return reminder.monthlyComponents.skippedDate ?? ClassConstant.DateConstant.default1970Date
            }
            else {
                return ClassConstant.DateConstant.default1970Date
            }
        }()
        
        reminder.changeIsSkipping(forIsSkipping: false)
        
        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(invokeErrorManager: true, forDogId: dog.dogId, forReminder: reminder) { requestWasSuccessful1, _ in
            if requestWasSuccessful1 == true {
                delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: dog.dogId, forReminder: reminder)
                
                // find log that is incredibly close the time where the reminder was skipped, once found, then we delete it.
                var logToRemove: Log?
                for log in dog.dogLogs.logs where dateOfLogToRemove.distance(to: log.logDate) < ClassConstant.LogConstant.logRemovalPrecision && dateOfLogToRemove.distance(to: log.logDate) > -ClassConstant.LogConstant.logRemovalPrecision {
                    logToRemove = log
                    break
                }
                
                guard let logToRemove = logToRemove else {
                    return
                }
                
                // log to remove from unlog event. Attempt to delete the log server side
                LogsRequest.delete(invokeErrorManager: true, forDogId: dog.dogId, forLogId: logToRemove.logId) { requestWasSuccessful2, _ in
                    if requestWasSuccessful2 == true {
                        delegate.didRemoveLog(sender: Sender(origin: self, localized: self), forDogId: dog.dogId, forLogId: logToRemove.logId)
                    }
                }
            }
            
        }
    }
}
