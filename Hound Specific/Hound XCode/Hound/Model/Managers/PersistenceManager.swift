//
//  PersistenceManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/16/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
import KeychainSwift

enum PersistenceManager {
    /// Called by App or Scene Delegate when setting up in didFinishLaunchingWithOptions, can be either the first time setup or a recurring setup (i.e. not the app isnt being opened for the first time)
    static func setup(isFirstTime: Bool) {
        
        AppDelegate.generalLogger.notice("\n-----Device Info-----\n Model: \(UIDevice.current.model) \n Name: \(UIDevice.current.name) \n System Name: \(UIDevice.current.systemName) \n System Version: \(UIDevice.current.systemVersion)")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        UIApplication.previousAppBuild = UserDefaults.standard.object(forKey: UserDefaultsKeys.appBuild.rawValue) as? Int
        
        UserDefaults.standard.setValue(UIApplication.appBuild, forKey: UserDefaultsKeys.appBuild.rawValue)
        
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier = keychain.get(ServerDefaultKeys.userIdentifier.rawValue)
        UserInformation.userEmail = keychain.get(ServerDefaultKeys.userEmail.rawValue) ?? UserInformation.userEmail
        UserInformation.userFirstName = keychain.get(ServerDefaultKeys.userFirstName.rawValue) ?? UserInformation.userFirstName
        UserInformation.userLastName = keychain.get(ServerDefaultKeys.userLastName.rawValue) ?? UserInformation.userLastName
        
        if isFirstTime == true {
            // first time the user is opening the app
            MainTabBarViewController.selectedEntryIndex = 0
            // indicate to local save that the app has sucessfully set itself up
            UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.hasDoneFirstTimeSetup.rawValue)
        }
        else {
            // not first time setup
            
            // MARK: User Information
            
            UserInformation.userId = UserDefaults.standard.value(forKey: ServerDefaultKeys.userId.rawValue) as? Int
            UserInformation.familyId = UserDefaults.standard.value(forKey: ServerDefaultKeys.familyId.rawValue) as? Int
            UserInformation.userNotificationToken = UserDefaults.standard.value(forKey: ServerDefaultKeys.userNotificationToken.rawValue) as? String
            
            // MARK: User Configuration
            
            // Data is retrieved from the server, so no need to store/persist locally
            
            // MARK: Local Configuration
            
            // checks to see if data decoded sucessfully
            
            if let dataDogIcons: Data = UserDefaults.standard.data(forKey: UserDefaultsKeys.dogIcons.rawValue) {
                do {
                    let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: dataDogIcons)
                    unarchiver.requiresSecureCoding = false
                    LocalConfiguration.dogIcons = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [LocalDogIcon] ?? []
                }
                catch {
                    AppDelegate.generalLogger.error("Unable to unarchive localDogIcons")
                }
            }
            
            LocalConfiguration.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as? Bool ?? LocalConfiguration.isNotificationAuthorized
            
            LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore
            LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore
            
            LocalConfiguration.reviewRequestDates = UserDefaults.standard.value(forKey: UserDefaultsKeys.reviewRequestDates.rawValue) as? [Date] ?? LocalConfiguration.reviewRequestDates
            
            LocalConfiguration.isShowReleaseNotes = UserDefaults.standard.value(forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue) as? Bool ?? LocalConfiguration.isShowReleaseNotes
            
        }
    }
    
    /// Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func willEnterBackground(isTerminating: Bool = false) {
        
        // MARK: Loud Notifications and Silent Audio
        
        // Check to see if the user is eligible for loud notifications
        if UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotification && MainTabBarViewController.staticDogManager.hasEnabledReminder && FamilyConfiguration.isPaused == false {
            // the user can have loud notifications
            if isTerminating == true {
                // send the user an alert since their loud notifications won't work
                // TO DO, if the app is directly terminated and doesn't enter the background, then the user wont get a notifiation (api request doesn't go through)
                RequestUtils.createTerminationNotification()
            }
            else {
                // app isn't terminating so add background silence
                AudioManager.stopAudio()
                AudioManager.playSilenceAudio()
            }
        }
        
        // MARK: - User Defaults
        
        // User Information
        
        UserDefaults.standard.setValue(UserInformation.userId, forKey: ServerDefaultKeys.userId.rawValue)
        UserDefaults.standard.setValue(UserInformation.familyId, forKey: ServerDefaultKeys.familyId.rawValue)
        UserDefaults.standard.setValue(UserInformation.userNotificationToken, forKey: ServerDefaultKeys.userNotificationToken.rawValue)
        
        // other user info from ASAuthorization is saved immediately to the keychain
        
        // User Configuration
        
        // Data below is retrieved from the server, so no need to store/persist locally
        
        // Local Configuration
        
        let dataDogIcons = LocalConfiguration.dogIcons
        let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: dataDogIcons, requiringSecureCoding: false)
        UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.dogIcons.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.isShowReleaseNotes, forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)
        
    }
    
    static func willEnterForeground() {
        
        NotificationManager.synchronizeNotificationAuthorization()
        
        // stop any loud notifications that may have occured
        AudioManager.stopLoudNotification()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
    }
    
}
