//
//  AppDelegate.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var hasSetup: Bool!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //retrieve value from local store, if value doesn't exist then false is returned
        hasSetup = UserDefaults.standard.bool(forKey: UserDefaultsKeys.didFirstTimeSetup.rawValue)
        
        if hasSetup{
            print("recurringSetup")
            Persistence.willSetup(isRecurringSetup: true)
            
            hasSetup = true
        }
        else {
            print("firstTimeSetup")
            Persistence.willSetup()
            
            UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.didFirstTimeSetup.rawValue)
        }
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
        print("willTerminate")
        Persistence.willEnterBackground(isTerminating: true)
    }

}

