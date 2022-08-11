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
    
    /// Creates AlarmUIAlertController to show the user about their alarm going off. We query the server with the information provided first to make sure it is up to date. 
    static func willShowAlarm(forDogManager dogManager: DogManager, forDogId dogId: Int, forReminderId reminderId: Int) {
        
        // See if we can find a corresponding dog for the dogId. If we can't, then no point to go any further
        guard let dog = try? dogManager.findDog(forDogId: dogId) else {
            return
        }
        
        // before presenting alarm, make sure we are up to date locally
        RemindersRequest.get(invokeErrorManager: false, forDogId: dogId, forReminderId: reminderId) { reminder, responseStatus in
            
            // If we got no response, then halt here as we were unable to retrieve the updated reminder
            guard responseStatus != .noResponse else {
                return
            }
            
            guard let reminder = reminder else {
                // We weren't able to retrieve the reminder. The reminder might have been deleted, the dog might have been deleted, or some other error with the query
                // We can attempt to refresh the dog manager. If the reminder or dog were deleted, then this will update our local storage to remove them. If the query failed for other reasons, then this dogManager query will fail as well
                RequestUtils.getFamilyGetDog(invokeErrorManager: false, dogManager: dogManager) { newDogManager, _ in
                    guard let newDogManager = newDogManager else {
                        return
                    }
                    
                    delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
                }
                return
            }
            
            // If reminder.reminderExecutionDate is nil, then something potentially was disabled / paused or the reminder's timing components are broken.
            // If distance from present to executionDate is positive, then executionDate in future. If distance is negative, then executionDate in past
            guard reminder.reminderExecutionDate != nil && Date().distance(to: reminder.reminderExecutionDate!) < 0 else {
                // We were able to retrieve the reminder and something was wrong with it. Something was disabled/paused, the reminder was pushed back to the future, or it simply just has invalid timing components
                // MARK: IMPORTANT - Do not try to refresh DogManager as that can (and does) cause an infinite loop. The reminder can exist but for some reason have invalid data leading to a nil executionDate. If we refresh the DogManager, we could retrieve the same invalid reminder data which leads back to this statement (and thus starts the infinite loop)
                
                self.delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
                return
            }
            
            // the reminder exists, its executionDate exists, and its executionDate is in the past (meaning it should be valid).
        
                // the dogId and reminderId exist if we got a reminder back
            let title = "\(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)) - \(dog.dogName)"
                
                let alertController = GeneralUIAlertController(
                    title: title,
                    message: nil,
                    preferredStyle: .alert)
                
                let alertActionDismiss = UIAlertAction(
                    title: "Dismiss",
                    style: .cancel,
                    handler: { (_: UIAlertAction!)  in
                        // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                        AlarmManager.willDismissAlarm(forDogId: dogId, forReminder: reminder)
                        CheckManager.checkForReview()
                    })
                
                var alertActionsForLog: [UIAlertAction] = []
                
                switch reminder.reminderAction {
                case .potty:
                    let pottyKnownTypes: [LogAction] = [.pee, .poo, .both, .neither, .accident]
                    for pottyKnownType in pottyKnownTypes {
                        let alertActionLog = UIAlertAction(
                            title: "Log \(pottyKnownType.displayActionName(logCustomActionName: nil, isShowingAbreviatedCustomActionName: true))",
                            style: .default,
                            handler: { (_)  in
                                // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                                AlarmManager.willLogAlarm(forDogId: dogId, forReminder: reminder, forLogAction: pottyKnownType)
                                CheckManager.checkForReview()
                            })
                        alertActionsForLog.append(alertActionLog)
                    }
                default:
                    let alertActionLog = UIAlertAction(
                        title: "Log \(reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true))",
                        style: .default,
                        handler: { (_)  in
                            // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                            AlarmManager.willLogAlarm(forDogId: dogId, forReminder: reminder, forLogAction: LogAction(rawValue: reminder.reminderAction.rawValue)!)
                            CheckManager.checkForReview()
                        })
                    alertActionsForLog.append(alertActionLog)
                }
                
                let alertActionSnooze = UIAlertAction(
                    title: "Snooze",
                    style: .default,
                    handler: { (_: UIAlertAction!)  in
                        // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                        AlarmManager.willSnoozeAlarm(forDogId: dogId, forReminder: reminder)
                        CheckManager.checkForReview()
                    })
                
                for alertActionLog in alertActionsForLog {
                    alertController.addAction(alertActionLog)
                }
                alertController.addAction(alertActionSnooze)
                alertController.addAction(alertActionDismiss)
                
                // we have successfully constructed our alert
                reminder.hasAlarmPresentationHandled = true
            delegate.didUpdateReminder(sender: Sender(origin: self, localized: self), forDogId: dogId, forReminder: reminder)
            
                AlertManager.enqueueAlertForPresentation(alertController)
            
        }
    }
    
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Snooze' the reminder. Therefore we modify the timing data so the reminder turns into .snooze mode, alerting them again soon. We don't add a log
    private static func willSnoozeAlarm(forDogId dogId: Int, forReminder reminder: Reminder) {
        // update information
        reminder.prepareForNextAlarm()
        
        reminder.snoozeComponents.changeSnoozeIsEnabled(forSnoozeIsEnabled: true)
        
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
        
        var isSkippingLogDate: Date {
            if reminder.reminderType == .weekly {
                return reminder.weeklyComponents.isSkippingDate!
            }
            else {
                return reminder.monthlyComponents.isSkippingDate!
            }
        }
        
        // this is the time that the reminder's next alarm was skipped. at this same moment, a log was added. If this log is still there, with it's date unmodified by the user, then we remove it.
        let dateOfLogToRemove = isSkippingLogDate
        
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
