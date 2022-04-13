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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    static var generalLogger = Logger(subsystem: "com.example.Pupotty", category: "General")
    static var lifeCycleLogger = Logger(subsystem: "com.example.Pupotty", category: "Life Cycle")
    static var APIRequestLogger = Logger(subsystem: "com.example.Pupotty", category: "API Request")
    static var APIResponseLogger = Logger(subsystem: "com.example.Pupotty", category: "API Response")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        AppDelegate.lifeCycleLogger.notice("Application Did Finish Launching with Options")

        // retrieve value from local store, if value doesn't exist then false is returned
        let hasSetup = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasDoneFirstTimeSetup.rawValue)

        if hasSetup {
            AppDelegate.generalLogger.notice("Recurring setup for app data")
            PersistenceManager.setup(isRecurringSetup: true)
        }
        else {
            AppDelegate.generalLogger.notice("First time setup for app data")
            PersistenceManager.setup()
        }
        
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
        AppDelegate.generalLogger.warning("Successfully registered for remote notifications for token: \(token)")
        
        if token != UserInformation.userNotificationToken {
            UserInformation.userNotificationToken = token
            UserRequest.update(body: [ServerDefaultKeys.userNotificationToken.rawValue: UserInformation.userNotificationToken!]) { _ in
                // do nothing
            }
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AppDelegate.generalLogger.warning("Failed to register for remote notifications with error: \(error.localizedDescription)")
    }

}
