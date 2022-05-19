//
//  AppDelegate.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit
import UserNotifications
import os.log
import CryptoKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    static var generalLogger = Logger(subsystem: "com.example.Pupotty", category: "General")
    static var lifeCycleLogger = Logger(subsystem: "com.example.Pupotty", category: "Life Cycle")
    static var APIRequestLogger = Logger(subsystem: "com.example.Pupotty", category: "API Request")
    static var APIResponseLogger = Logger(subsystem: "com.example.Pupotty", category: "API Response")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppDelegate.lifeCycleLogger.notice("Application Did Finish Launching with Options")
        
        PersistenceManager.setup()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        AppDelegate.lifeCycleLogger.notice("Application Will Terminate")
        PersistenceManager.willEnterBackground(isTerminating: true)

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        AppDelegate.generalLogger.notice("Successfully registered for remote notifications for token: \(token)")
        
        if token != UserInformation.userNotificationToken {
            
            // don't sent the user an alert if this request fails as there is no point
            UserRequest.update(invokeErrorManager: false, body: [ServerDefaultKeys.userNotificationToken.rawValue: token]) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    UserInformation.userNotificationToken = token
                }
            }
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AppDelegate.generalLogger.warning("Failed to register for remote notifications with error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppDelegate.generalLogger.notice("Received \(userInfo)")
        
        // look for the aps body
        guard let aps = userInfo["aps"] as? [String: Any] else {
            completionHandler(.noData)
            return
        }
        
        guard let category = aps["category"] as? String else {
            completionHandler(.noData)
            return
        }

        // if the notification is a reminder, then check to see if loud notification can be played
        guard category == "reminder" else {
            completionHandler(.noData)
            return
        }
        
        // BUG if a reminder is created by another user and this user hasn't refreshed. Then when the notification comes through nothing will display. this is because this local device doesn't know that reminder exists.
        // solution: attach a reminderId/reminderLastModified and use that to determine if we need to refresh that reminder.
        
        // BUG (similar to above problem)if a reminder is updated to an earlier time by another user, then our user will be out of date. This means they could get a notification for a reminder, but when they open up the app it will show the reminder at the original (incorrect) time. This bug however, when the original reminder is supposed to go off, will fix itself as it checks to see if the reminder is updated before showing an alert
        // solution: a potential rememdy to this bug, is when the notification for a reminder alarm comes through verify that we have an updated reminder that matches. if we don't have the reminder or the reminder is incorrect, then have the user query the server to retrieve the updated reminder
        AudioManager.playLoudNotification()
        
        completionHandler(.newData)
    }
    
}
