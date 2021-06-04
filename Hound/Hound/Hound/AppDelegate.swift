//
//  AppDelegate.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let decodedPreviousAppBuild: Int? = UserDefaults.standard.object(forKey: UserDefaultsKeys.appBuild.rawValue) as? Int ?? nil
        var previousAppBuild: Int {
            return decodedPreviousAppBuild ?? 1228
        }
        UIApplication.previousAppBuild = previousAppBuild
        UserDefaults.standard.setValue(UIApplication.appBuild, forKey: UserDefaultsKeys.appBuild.rawValue)
        
        //see if last time setup crashed
        let didCrashDuringLastSetup = UserDefaults.standard.bool(forKey: "didCrashDuringSetup")
        //will be set to false if successfully setup
        UserDefaults.standard.setValue(true, forKey: "didCrashDuringSetup")
        
        let shouldPerformCleanInstall = UserDefaults.standard.bool(forKey: UserDefaultsKeys.shouldPerformCleanInstall.rawValue)
        
        if didCrashDuringLastSetup == true {
            print("crashedDuringLastSetup")
            Persistence.willSetup()
            
            UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.didFirstTimeSetup.rawValue)
            UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.shouldPerformCleanInstall.rawValue)
            
            Utils.willShowAlert(title: "🚨Crashed detected🚨", message: "Hound crashed during its last launch and had to reset itself to default in order to recover. I am sorry for the inconvenience😢")
           
        }
        else if shouldPerformCleanInstall == true {
            print("cleanInstall (used for when the user wants to reset the app)")
            Persistence.willSetup()
            
            UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.didFirstTimeSetup.rawValue)
            UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.shouldPerformCleanInstall.rawValue)
        }
        else {
            //retrieve value from local store, if value doesn't exist then false is returned
            var hasSetup = UserDefaults.standard.bool(forKey: UserDefaultsKeys.didFirstTimeSetup.rawValue)
            
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
        //Persistence.willEnterBackground(isTerminating: true)
        
    }

}


