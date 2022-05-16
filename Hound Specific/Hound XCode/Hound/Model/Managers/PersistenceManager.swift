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
    static func setup() {
        
        AppDelegate.generalLogger.notice("\n-----Device Info-----\n Model: \(UIDevice.current.model) \n Name: \(UIDevice.current.name) \n System Name: \(UIDevice.current.systemName) \n System Version: \(UIDevice.current.systemVersion)")
        
        UIApplication.previousAppBuild = UserDefaults.standard.object(forKey: UserDefaultsKeys.appBuild.rawValue) as? Int
        
        UserDefaults.standard.setValue(UIApplication.appBuild, forKey: UserDefaultsKeys.appBuild.rawValue)
        
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier = keychain.get(ServerDefaultKeys.userIdentifier.rawValue)
        UserInformation.userEmail = keychain.get(ServerDefaultKeys.userEmail.rawValue) ?? UserInformation.userEmail
        UserInformation.userFirstName = keychain.get(ServerDefaultKeys.userFirstName.rawValue) ?? UserInformation.userFirstName
        UserInformation.userLastName = keychain.get(ServerDefaultKeys.userLastName.rawValue) ?? UserInformation.userLastName
        
        // If the user hasn't completed the dogs and reminders introduction page, then we put them on the logs page (index 0). Otherwise, if they have configured their first dog and reminder, then they get put on the dogs page (index 1)
        MainTabBarViewController.selectedEntryIndex = (LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore && LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore) ? 1 : 0
        
        // MARK: User Information
        
        UserInformation.userId = UserDefaults.standard.value(forKey: ServerDefaultKeys.userId.rawValue) as? Int ?? UserInformation.userId
        UserInformation.familyId = UserDefaults.standard.value(forKey: ServerDefaultKeys.familyId.rawValue) as? Int ?? UserInformation.familyId
        
        // MARK: User Configuration
        
        // Data is retrieved from the server, so no need to store/persist locally
        
        // MARK: Local Configuration
        
        LocalConfiguration.lastDogManagerSync = UserDefaults.standard.value(forKey: ServerDefaultKeys.lastDogManagerSync.rawValue) as? Date ?? LocalConfiguration.lastDogManagerSync
        
        if let dataDogIcons: Data = UserDefaults.standard.data(forKey: UserDefaultsKeys.dogIcons.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataDogIcons) {
            unarchiver.requiresSecureCoding = false
            LocalConfiguration.dogIcons = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [LocalDogIcon] ?? LocalConfiguration.dogIcons
        }
        
        LocalConfiguration.logCustomActionNames = UserDefaults.standard.value(forKey: UserDefaultsKeys.logCustomActionNames.rawValue) as? [String] ?? LocalConfiguration.logCustomActionNames
        LocalConfiguration.reminderCustomActionNames = UserDefaults.standard.value(forKey: UserDefaultsKeys.reminderCustomActionNames.rawValue) as? [String] ?? LocalConfiguration.reminderCustomActionNames
        
        LocalConfiguration.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as? Bool ?? LocalConfiguration.isNotificationAuthorized
        
        LocalConfiguration.reviewRequestDates = UserDefaults.standard.value(forKey: UserDefaultsKeys.reviewRequestDates.rawValue) as? [Date] ?? LocalConfiguration.reviewRequestDates
        LocalConfiguration.isShowReleaseNotes = UserDefaults.standard.value(forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue) as? Bool ?? LocalConfiguration.isShowReleaseNotes
        
        LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore
        LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore
        
    }
    
    /// Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func willEnterBackground(isTerminating: Bool = false) {
        
        // MARK: Loud Notifications and Silent Audio
        
        // Check to see if the user is eligible for loud notifications
        // don't check for if there are enabled reminders/ isPaused, as client could be out of sync with server which has a reminder/ different pause status
        if UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotification {
            // the user can have loud notifications
            if isTerminating == true {
                // send the user an alert since their loud notifications won't work
                // BUG, if the app is directly terminated and doesn't enter the background, then the user wont get a notifiation (api request doesn't go through)
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
        
        // other user info from ASAuthorization is saved immediately to the keychain
        
        // User Configuration
        
        // Data below is retrieved from the server, so no need to store/persist locally
        
        // Local Configuration
        
        UserDefaults.standard.set(LocalConfiguration.lastDogManagerSync, forKey: ServerDefaultKeys.lastDogManagerSync.rawValue)
        
        if let dataDogIcons = try? NSKeyedArchiver.archivedData(withRootObject: LocalConfiguration.dogIcons, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogIcons, forKey: UserDefaultsKeys.dogIcons.rawValue)
        }
        
        UserDefaults.standard.set(LocalConfiguration.logCustomActionNames, forKey: UserDefaultsKeys.logCustomActionNames.rawValue)
        UserDefaults.standard.set(LocalConfiguration.reminderCustomActionNames, forKey: UserDefaultsKeys.reminderCustomActionNames.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.isShowReleaseNotes, forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue)
    }
    
    static func willEnterForeground() {
        
        NotificationManager.synchronizeNotificationAuthorization()
        
        // stop any loud notifications that may have occured
        AudioManager.stopLoudNotification()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
    }
    
}
