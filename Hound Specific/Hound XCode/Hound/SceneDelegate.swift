//
//  SceneDelegate.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        //AppDelegate.lifeCycleLogger.notice("scene \(UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as? Data)")
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        AppDelegate.lifeCycleLogger.notice("Scene did disconnect")
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        //AppDelegate.lifeCycleLogger.notice("sceneDidDisconnect \(UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as? Data)")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        AppDelegate.lifeCycleLogger.notice("Scene did become active")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        //AppDelegate.lifeCycleLogger.notice("scene did become active")
        //AppDelegate.lifeCycleLogger.notice("sceneDidBecomeActive \(UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as? Data)")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        AppDelegate.lifeCycleLogger.notice("Scene will resign active")
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        AppDelegate.lifeCycleLogger.notice("Scene will enter foreground")
        PersistenceManager.willEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        AppDelegate.lifeCycleLogger.notice("Scene did enter background")
        PersistenceManager.willEnterBackground()
        
    }


}

