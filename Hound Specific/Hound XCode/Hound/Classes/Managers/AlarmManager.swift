//
//  AlarmManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/20/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol AlarmManagerDelegate {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class AlarmManager {
    static var delegate: AlarmManagerDelegate! = nil
    /// Creates alertController to queue for presentation along with information passed along with it to reinitalize the timer once an option is selected (e.g. disable or snooze)
    static func willShowAlarm(dogName: String, dogId: Int, reminder: Reminder) {
        
        let title = "\(reminder.displayActionName) - \(dogName)"
        
        let alertController = AlarmUIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert)
        
        let alertActionDismiss = UIAlertAction(
            title: "Dismiss",
            style: .cancel,
            handler: { (_: UIAlertAction!)  in
                // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                AlarmManager.willDismissAlarm(sender: Sender(origin: self, localized: self), dogId: dogId, reminderId: reminder.reminderId)
                Utils.checkForReview()
            })
        
        var alertActionsForLog: [UIAlertAction] = []
        
        switch reminder.reminderAction {
        case .potty:
            let pottyKnownTypes: [LogAction] = [.pee, .poo, .both, .neither, .accident]
            for pottyKnownType in pottyKnownTypes {
                let alertActionLog = UIAlertAction(
                    title: "Log \(pottyKnownType.rawValue)",
                    style: .default,
                    handler: { (_)  in
                        // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                        AlarmManager.willLogAlarm(sender: Sender(origin: self, localized: self), dogId: dogId, reminderId: reminder.reminderId, logAction: pottyKnownType)
                        Utils.checkForReview()
                    })
                alertActionsForLog.append(alertActionLog)
            }
        default:
            let alertActionLog = UIAlertAction(
                title: "Log \(reminder.displayActionName)",
                style: .default,
                handler: { (_)  in
                    // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                    AlarmManager.willLogAlarm(sender: Sender(origin: self, localized: self), dogId: dogId, reminderId: reminder.reminderId, logAction: LogAction(rawValue: reminder.reminderAction.rawValue)!)
                    Utils.checkForReview()
                })
            alertActionsForLog.append(alertActionLog)
        }
        
        let alertActionSnooze = UIAlertAction(
            title: "Snooze",
            style: .default,
            handler: { (_: UIAlertAction!)  in
                // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                AlarmManager.willSnoozeAlarm(sender: Sender(origin: self, localized: self), dogId: dogId, reminderId: reminder.reminderId)
                Utils.checkForReview()
            })
        
        for alertActionLog in alertActionsForLog {
            alertController.addAction(alertActionLog)
        }
        alertController.addAction(alertActionSnooze)
        alertController.addAction(alertActionDismiss)
        
        let dogManager = MainTabBarViewController.staticDogManager
        
        do {
            let dog = try dogManager.findDog(forDogId: dogId)
            // AppDelegate.generalLogger.notice("willShowAlarm success in finding dog")
            let reminder = try dog.dogReminders.findReminder(forReminderId: reminder.reminderId)
            // AppDelegate.generalLogger.notice("willShowAlarm success in finding reminder")
            
            if reminder.isPresentationHandled == false {
                reminder.isPresentationHandled = true
                // the server doesn't care about isPresentationHandled so we do not send a request to it. That is completely local.
                delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
            }
            
            AlertManager.enqueueAlertForPresentation(alertController)
        }
        catch {
            AppDelegate.generalLogger.error("willShowAlarm failure in finding dog or reminder")
        }
        
    }
    
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Snooze' the reminder. Therefore we modify the timing data so the reminder turns into .snooze mode, alerting them again soon. We don't add a log
    static func willSnoozeAlarm(sender: Sender, dogId: Int, reminderId: Int) {
        let dogManager = MainTabBarViewController.staticDogManager
        
        let reminder = try! dogManager.findDog(forDogId: dogId).dogReminders.findReminder(forReminderId: reminderId)
        
        reminder.prepareForNextAlarm()
        
        reminder.snoozeComponents.changeSnooze(newSnoozeStatus: true)
        
        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(forDogId: dogId, forReminder: reminder) { requestWasSuccessful in
            if requestWasSuccessful == true {
                // no log or anything created, so we can just proceed to updating locally
                delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            }
        }
        
    }
    
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Dismiss' the reminder. Therefore we reset the timing data and don't add a log.
    static func willDismissAlarm(sender: Sender, dogId: Int, reminderId: Int) {
        let sudoDogManager = MainTabBarViewController.staticDogManager
        
        let dog = try! sudoDogManager.findDog(forDogId: dogId)
        
        let reminder = try! dog.dogReminders.findReminder(forReminderId: reminderId)
        
        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // just make request to delete reminder for oneTime remidner
            RemindersRequest.delete(forDogId: dogId, forReminderId: reminderId) { requestWasSuccessful in
                if requestWasSuccessful == true {
                    try! dog.dogReminders.removeReminder(forReminderId: reminderId)
                    delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            reminder.prepareForNextAlarm()
            
            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(forDogId: dogId, forReminder: reminder) { _ in
                // we dont need to persist a log
                delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: sudoDogManager)
            }
        }
        
    }
    
    /// User responded to the reminder's alarm that popped up on their screen. They selected to 'Log' the reminder. Therefore we reset the timing data and add a log.
    static func willLogAlarm(sender: Sender, dogId: Int, reminderId: Int, logAction: LogAction) {
        
        let sudoDogManager = MainTabBarViewController.staticDogManager
        
        let dog = try! sudoDogManager.findDog(forDogId: dogId)
        
        let reminder = try! dog.dogReminders.findReminder(forReminderId: reminderId)
        
        let log = Log(date: Date(), logAction: logAction, customActionName: reminder.customActionName)
        
        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder
            
            // delete the reminder on the server
            RemindersRequest.delete(forDogId: dogId, forReminderId: reminderId) { requestWasSuccessful in
                if requestWasSuccessful == true {
                    try! dog.dogReminders.removeReminder(forReminderId: reminderId)
                    // create log on the server and then assign it the logId and then add it to the dog
                    LogsRequest.create(forDogId: dogId, forLog: log) { logId in
                        if logId != nil {
                            log.logId = logId!
                            dog.dogLogs.addLog(newLog: log)
                            // creating the log succeeded. we can persist the changes locally.
                            delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                        }
                    }
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            // the reminder just executed an alarm/alert, so we want to reset its stuff
            reminder.prepareForNextAlarm()
            
            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(forDogId: dogId, forReminder: reminder) { _ in
                // we need to persist a log as well
                LogsRequest.create(forDogId: dog.dogId, forLog: log) { logId in
                    // persist log successful, therefore we can save the info locally
                    if logId != nil {
                        log.logId = logId!
                        dog.dogLogs.addLog(newLog: log)
                        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: sudoDogManager)
                    }
                }
            }
        }
        
    }
    
    /// The user went to log/skip a reminder on the reminders page. Must updating skipping data and add a log
    static func willSkipReminder(sender: Sender, dogId: Int, reminderId: Int, logAction: LogAction) {
        let sudoDogManager = MainTabBarViewController.staticDogManager
        
        let dog = try! sudoDogManager.findDog(forDogId: dogId)
        
        let reminder = try! dog.dogReminders.findReminder(forReminderId: reminderId)
        
        let log = Log(date: Date(), logAction: logAction, customActionName: reminder.customActionName)
        
        // special case. Once a oneTime reminder executes, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder
            
            // delete the reminder on the server
            RemindersRequest.delete(forDogId: dogId, forReminderId: reminderId) { requestWasSuccessful in
                if requestWasSuccessful == true {
                    try! dog.dogReminders.removeReminder(forReminderId: reminderId)
                    // create log on the server and then assign it the logId and then add it to the dog
                    LogsRequest.create(forDogId: dogId, forLog: log) { logId in
                        if logId != nil {
                            log.logId = logId!
                            dog.dogLogs.addLog(newLog: log)
                            // creating the log succeeded. we can persist the changes locally.
                            delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                        }
                    }
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            
            reminder.skipNextAlarm()
            
            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(forDogId: dogId, forReminder: reminder) { _ in
                // we need to persist a log as well
                LogsRequest.create(forDogId: dog.dogId, forLog: log) { logId in
                    // persist log successful, therefore we can save the info locally
                    if logId != nil {
                        log.logId = logId!
                        dog.dogLogs.addLog(newLog: log)
                        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: sudoDogManager)
                    }
                }
            }
        }
    }
    
    /// The user went to unlog/unskip a reminder on the reminders page. Must update skipping information. Note: only weekly/monthly reminders can be skipped therefore only they can be unskipped.
    static func willUnskipReminder(sender: Sender, dogId: Int, reminderId: Int) {
        
        let sudoDogManager = MainTabBarViewController.staticDogManager
        
        let dog = try! sudoDogManager.findDog(forDogId: dogId)
        
        let reminder = try! dog.dogReminders.findReminder(forReminderId: reminderId)
        
        guard reminder.reminderType == .weekly || reminder.reminderType == .monthly else {
            return
        }
        
        reminder.unskipNextAlarm()
        
        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(forDogId: dogId, forReminder: reminder) { _ in
            // we dont need to persist a log, so just update dogManager
            self.delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: sudoDogManager)
            
        }
    }
}
