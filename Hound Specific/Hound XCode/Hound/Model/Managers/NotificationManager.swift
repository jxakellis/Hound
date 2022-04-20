//
//  NotificationManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/31/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum NotificationManager {
    
    static func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
     /*
    
    static func willCreateFollowUpUNUserNotification(dogName: String, reminder: Reminder) {
        
        guard reminder.reminderExecutionDate != nil else {
            AppDelegate.generalLogger.fault("willCreateFollowUpUNUserNotification reminderExecutionDate is nil")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.interruptionLevel = .timeSensitive
        
        content.title = "Follow up notification for \(dogName)!"
        
        content.body = "It's been \(String.convertToReadable(fromTimeInterval: UserConfiguration.followUpDelay, capitalizeLetters: false)), give your dog a helping hand with \(reminder.displayActionName)!"
        
        if UserConfiguration.isLoudNotification == false {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(UserConfiguration.notificationSound.rawValue.lowercased())30.wav"))
        }
        
        let reminderExecutionDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.reminderExecutionDate! + UserConfiguration.followUpDelay)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: reminderExecutionDateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                AppDelegate.generalLogger.error("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }
    
    static func willCreateUNUserNotification(dogName: String, reminder: Reminder) {
        
        guard reminder.reminderExecutionDate != nil else {
            AppDelegate.generalLogger.fault("willCreateUNUserNotification reminderExecutionDate is nil")
            return
        }
        // let reminder = try! MainTabBarViewController.staticDogManager.findDog(forDogId: dogName).dogReminders.findReminder(forReminderId: reminderUUID)
        let content = UNMutableNotificationContent()
        content.interruptionLevel = .timeSensitive
        
        content.title = "Reminder for \(dogName)!"
        
        content.body = reminder.displayActionName
        
        if UserConfiguration.isLoudNotification == false {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(UserConfiguration.notificationSound.rawValue.lowercased())30.wav"))
        }
        
        let reminderExecutionDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.reminderExecutionDate!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: reminderExecutionDateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                AppDelegate.generalLogger.error("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }
     */
    
    /**
     DOES update local UserConfiguration. Requests permission to send notifications to the user then invokes updateServerUserNotificationConfiguration. If the server returned a 200 status and is successful, then return. Otherwise, if the user didn't grant permission or there was a problem with the  query, then return and (if needed) ErrorManager is automatically invoked
     */
    static func requestNotificationAuthorization(completionHandler: @escaping () -> Void) {
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        let beforeUpdateIsFollowUpEnabled = UserConfiguration.isFollowUpEnabled
        
        if LocalConfiguration.isNotificationAuthorized == false {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, _) in
                LocalConfiguration.isNotificationAuthorized = isGranted
                UserConfiguration.isNotificationEnabled = isGranted
                UserConfiguration.isLoudNotification = isGranted
                UserConfiguration.isFollowUpEnabled = isGranted
                
                if LocalConfiguration.isNotificationAuthorized == true {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                
                NotificationManager.updateServerUserNotificationConfiguration(
                    updatedIsNotificationEnabled: UserConfiguration.isNotificationEnabled, updatedIsLoudNotification: UserConfiguration.isLoudNotification, updatedIsFollowUpEnabled: UserConfiguration.isFollowUpEnabled) { requestWasSuccessful in
                        if requestWasSuccessful == false {
                            UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                            UserConfiguration.isLoudNotification = beforeUpdateIsLoudNotification
                            UserConfiguration.isFollowUpEnabled = beforeUpdateIsFollowUpEnabled
                        }
                        completionHandler()
                    }
            }
            
        }
        else {
            completionHandler()
        }
    }
    
    /**
     DOES NOT update local UserConfiguration. Updates the server based on the new status of the parameters provided.  If the server returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem with the query, false is returned and ErrorManager is automatically invoked.
     */
    private static func updateServerUserNotificationConfiguration(updatedIsNotificationEnabled: Bool? = nil, updatedIsLoudNotification: Bool? = nil, updatedIsFollowUpEnabled: Bool? = nil, completionHandler: @escaping (Bool) -> Void) {
        // Contact the server about the updated values and, if there is no response or a bad response, revert the values to their previous values. isNotificationAuthorized purposefully excluded as server doesn't need to know that and its value cant exactly just be flipped (as tied to apple notif auth status)
        var body: [String: Any] = [:]
        // check for if values were changed, if there were then tell the server
        if updatedIsNotificationEnabled != nil {
            body[ServerDefaultKeys.isNotificationEnabled.rawValue] = updatedIsNotificationEnabled!
        }
        if updatedIsLoudNotification != nil {
            body[ServerDefaultKeys.isLoudNotification.rawValue] = updatedIsLoudNotification!
        }
        if updatedIsFollowUpEnabled != nil {
            body[ServerDefaultKeys.isFollowUpEnabled.rawValue] = updatedIsFollowUpEnabled
        }
        if body.keys.isEmpty == false {
            // something to update
            UserRequest.update(body: body) { requestWasSuccessful in
                completionHandler(requestWasSuccessful)
            }
        }
        // body is empty so there was nothing to query, return completion handler
        else {
            // DONT REMOVE THIS .main, UNUserNotificationCenter.current().requestAuthorization invokes this function inside is compeltionHandler and that is not on the main thread. Will cause issues since UserRequest part is main thread but this isn't
            DispatchQueue.main.async {
                completionHandler(true)
            }
        }
    }
    
}