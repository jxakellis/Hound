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
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var generalLogger = Logger(subsystem: "com.example.Pupotty", category: "General")
    static var endpointLogger = Logger(subsystem: "com.example.Pupotty", category: "Endpoints")
    static var APIResponseLogger = Logger(subsystem: "com.example.Pupotty", category: "API Response")
    static var lifeCycleLogger = Logger(subsystem: "com.example.Pupotty", category: "Life Cycle")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        AppDelegate.lifeCycleLogger.notice("Application did finish launching with options")
        AppDelegate.generalLogger.notice("\n-----Device Info-----\n Model: \(UIDevice.current.model) \n Name: \(UIDevice.current.name) \n System Name: \(UIDevice.current.systemName) \n System Version: \(UIDevice.current.systemVersion)")

        let decodedPreviousAppBuild: Int? = UserDefaults.standard.object(forKey: UserDefaultsKeys.appBuild.rawValue) as? Int ?? nil
        var previousAppBuild: Int {
            return decodedPreviousAppBuild ?? 1228
        }
        UIApplication.previousAppBuild = previousAppBuild
        UserDefaults.standard.setValue(UIApplication.appBuild, forKey: UserDefaultsKeys.appBuild.rawValue)

        // see if last time setup crashed
        var didCrashDuringLastSetup = UserDefaults.standard.bool(forKey: "didCrashDuringSetup")
        // will be set to false if successfully setup
        UserDefaults.standard.setValue(true, forKey: "didCrashDuringSetup")

        // let shouldPerformCleanInstall = UserDefaults.standard.bool(forKey: UserDefaultsKeys.shouldPerformCleanInstall.rawValue)

        // MARK: DISABLING OF didCrashDuringLastSetup
        if didCrashDuringLastSetup == true {
            AppDelegate.generalLogger.notice("Override didCrashDuringLastSetup, not wiping data and recovering")

            didCrashDuringLastSetup = false
            UserDefaults.standard.setValue(false, forKey: "didCrashDuringSetup")

            // UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.shouldPerformCleanInstall.rawValue)
        }

       if didCrashDuringLastSetup == true {
            AppDelegate.generalLogger.fault("Recovery setup for app data, crashed during last setup")
            PersistenceManager.willSetup()

           UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.hasDoneFirstTimeSetup.rawValue)
            // UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.shouldPerformCleanInstall.rawValue)

            AlertManager.willShowAlert(title: "🚨Crashed detected🚨", message: "Hound crashed during its last launch and had to reset itself to default in order to recover. I am sorry for the inconvenience😢")

        }
        else {
            // retrieve value from local store, if value doesn't exist then false is returned
            let hasSetup = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasDoneFirstTimeSetup.rawValue)
        
            if hasSetup {
                AppDelegate.generalLogger.notice("Recurring setup for app data")
                PersistenceManager.willSetup(isRecurringSetup: true)
            }
            else {
                AppDelegate.generalLogger.notice("First time setup for app data")
                PersistenceManager.willSetup()
// hasDoneFirstTimeSetup to true in PersistanceManager after everything completed
            }
        }

        // AppDelegate.generalLogger.notice("application end \(UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as? Data)")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        AppDelegate.lifeCycleLogger.notice("Application will terminate")
        PersistenceManager.willEnterBackground(isTerminating: true)

    }

}
