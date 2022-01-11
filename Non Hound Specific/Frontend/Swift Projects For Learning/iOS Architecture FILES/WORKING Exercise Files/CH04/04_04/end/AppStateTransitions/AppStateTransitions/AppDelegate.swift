//
//  AppDelegate.swift
//  AppStateTransitions
//
//  Created by Karoly Nyisztor on 6/6/18.
//  Copyright © 2018 Karoly Nyisztor. All rights reserved.
//

import UIKit

enum AppState {
    case notrunning
    case launching
    case initialized
    case active
    case inactive
    case wakingup
    case background
    case terminating
}

extension AppState: CustomStringConvertible {
    var description: String {
        switch self {
        case .notrunning: return "NotRunning"
        case .launching: return "Launching"
        case .initialized: return "Initialized"
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .wakingup: return "WakingUp"
        case .background: return "Background"
        case .terminating: return "Terminating"
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var state = AppState.notrunning

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        print("\(#function) called.\n\t \(state) -> \(AppState.launching)")
        state = .launching
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("\(#function) called.\n\t \(state) -> \(AppState.initialized)")
        state = .initialized
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("\(#function) called.\n\t \(state) -> \(AppState.inactive)")
        state = .inactive
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("\(#function) called.\n\t \(state) -> \(AppState.background)")
        state = .background
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("\(#function) called.\n\t \(state) -> \(AppState.wakingup)")
        state = .wakingup
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("\(#function) called.\n\t \(state) -> \(AppState.active)")
        state = .active
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("\(#function) called.\n\t \(state) -> \(AppState.terminating)")
        state = .terminating
    }


}

