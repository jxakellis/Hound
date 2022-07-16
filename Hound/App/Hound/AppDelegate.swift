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
final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    /*
     TO DO NOW add handling for consent of subscription price increase
     When you increase the price of a subscription, the system asks your delegate’s function paymentQueueShouldShowPriceConsent(_:) whether to immediately display the price consent sheet, or to delay displaying the sheet until later. For example, you may want to delay showing the sheet if it would interrupt a multistep user interaction, such as setting up a user account. Return false in paymentQueueShouldShowPriceConsent(_:) to prevent the dialog from displaying immediately.
     To show the price consent sheet after a delay, call showPriceConsentIfNeeded(), which shows the sheet only if the user hasn’t responded to the price increase notifications.
     */

    static var generalLogger = Logger(subsystem: "com.example.Pupotty", category: "General")
    static var lifeCycleLogger = Logger(subsystem: "com.example.Pupotty", category: "Life Cycle")
    static var APIRequestLogger = Logger(subsystem: "com.example.Pupotty", category: "API Request")
    static var APIResponseLogger = Logger(subsystem: "com.example.Pupotty", category: "API Response")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppDelegate.lifeCycleLogger.notice("Application Did Finish Launching with Options")
        
        NetworkManager.shared.startMonitoring()
        
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
        AppDelegate.generalLogger.error("Failed to register for remote notifications with error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
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
        
        // check to see if we have a reminderLastModified available to us
        if let reminderLastModifiedString = userInfo["reminderLastModified"] as? String, let reminderLastModified = ResponseUtils.dateFormatter(fromISO8601String: reminderLastModifiedString), LocalConfiguration.lastDogManagerSynchronization.distance(to: reminderLastModified) > 0 {
            // If the reminder was modified after the last time we synced our whole dogManager, then that means our local reminder is out of date.
            // This makes our local reminder untrustworthy. The server reminder could have been deleted (and we don't know), the server reminder could have been created (and we don't have it locally), or the server reminder could have had its timing changes (and our locally timing will be inaccurate).
            // Therefore, we should refresh the dogManager to make sure we are up to date on important features of the reminder's state: create, delete, timing.
            // Once everything is synced again, the alarm will be shown as expected.
            
            // Note: we also individually fetch a reminder before immediately constructing its alertController for its alarm. This ensure, even if the user has notifications turned off (meaning this piece of code right here won't be executed), that the reminder they are being show is up to date.
            DogsRequest.get(invokeErrorManager: false, dogManager: MainTabBarViewController.staticDogManager) { newDogManager, _ in
                guard newDogManager != nil else {
                    return
                }
                MainTabBarViewController.mainTabBarViewController?.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: newDogManager!)
            }
        }
        
        AudioManager.playLoudNotification()
        
        completionHandler(.newData)
    }
    
}
