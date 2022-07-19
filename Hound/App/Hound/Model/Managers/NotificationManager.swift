//
//  NotificationManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/31/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum NotificationManager {
    
    /**
     DOES update local UserConfiguration. Requests permission to send notifications to the user then invokes updateServerUserNotificationConfiguration. If the server returned a 200 status and is successful, then return. Otherwise, if the user didn't grant permission or there was a problem with the  query, then return and (if needed) ErrorManager is automatically invoked
     */
    static func requestNotificationAuthorization(completionHandler: @escaping () -> Void) {
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        let beforeUpdateIsFollowUpEnabled = UserConfiguration.isFollowUpEnabled
        if LocalConfiguration.isNotificationAuthorized == false {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, _) in
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
            // A user could potentially be isNotificationAuthorized == true but unregistered for remoteNotications. Therefore
            UIApplication.shared.registerForRemoteNotifications()
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
            UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
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
    
    /// Checks to see if a change in notification permissions has occured, if it has then update to reflect
    static func synchronizeNotificationAuthorization() {
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        let beforeUpdateIsFollowUpEnabled = UserConfiguration.isFollowUpEnabled
        
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                
                // going from off to on, meaning the user has gone into the settings app and turned notifications from disabled to enabled
                LocalConfiguration.isNotificationAuthorized = true
                // The user isn't registered for remote notifications but should be
                if UserInformation.userNotificationToken == nil {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                
            case .denied:
                
                LocalConfiguration.isNotificationAuthorized = false
                UserConfiguration.isNotificationEnabled = false
                UserConfiguration.isLoudNotification = false
                UserConfiguration.isFollowUpEnabled = false
                // Updates switch to reflect change, if the last view open was the settings page then the app is exitted and property changed in the settings app then this app is reopened, VWL will not be called as the settings page was already opened, weird edge case.
                // keep .main as UNUserNotificationCenter.current().getNotificationSettings is on seperate thread
                DispatchQueue.main.async {
                    let settingsVC: SettingsViewController? = MainTabBarViewController.mainTabBarViewController?.settingsViewController
                    settingsVC?.settingsNotificationsViewController?.synchronizeAllNotificationSwitches(animated: false)
                }
                updateServerUserConfiguration()
                
            case .notDetermined:
                AppDelegate.generalLogger.notice(".notDetermined")
            case .provisional:
                AppDelegate.generalLogger.notice(".provisional")
            case .ephemeral:
                AppDelegate.generalLogger.notice(".ephemeral")
            @unknown default:
                AppDelegate.generalLogger.notice("\(VisualConstant.TextConstant.unknownText) notification authorization status")
            }
        }
        
        /// Contact the server about the updated values and, if there is no response or a bad response, revert the values to their previous values. isNotificationAuthorized purposefully excluded as server doesn't need to know that and its value cant exactly just be flipped (as tied to apple notif auth status)
        func updateServerUserConfiguration() {
            var body: [String: Any] = [:]
            // check for if values were changed, if there were then tell the server
            if UserConfiguration.isNotificationEnabled != beforeUpdateIsNotificationEnabled {
                body[ServerDefaultKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
            }
            if UserConfiguration.isLoudNotification != beforeUpdateIsLoudNotification {
                body[ServerDefaultKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
            }
            if UserConfiguration.isFollowUpEnabled != beforeUpdateIsFollowUpEnabled {
                body[ServerDefaultKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
            }
            if body.keys.isEmpty == false {
                UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
                    if requestWasSuccessful == false {
                        // error, revert to previous
                        UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                        UserConfiguration.isLoudNotification = beforeUpdateIsLoudNotification
                        UserConfiguration.isFollowUpEnabled = beforeUpdateIsFollowUpEnabled
                        
                        let settingsVC: SettingsViewController? = MainTabBarViewController.mainTabBarViewController?.settingsViewController
                        settingsVC?.settingsNotificationsViewController?.synchronizeAllNotificationSwitches(animated: false)
                    }
                }
            }
            
        }
    }
    
}
