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
        
        // MARK: Log Launch
        
        AppDelegate.generalLogger.notice("\n-----Device Info-----\n Model: \(UIDevice.current.model) \n Name: \(UIDevice.current.name) \n System Name: \(UIDevice.current.systemName) \n System Version: \(UIDevice.current.systemVersion)")
        
        // MARK: Save Certain Values
        
        UIApplication.previousAppBuild = UserDefaults.standard.object(forKey: UserDefaultsKeys.appBuild.rawValue) as? Int
        
        UserDefaults.standard.setValue(UIApplication.appBuild, forKey: UserDefaultsKeys.appBuild.rawValue)
        
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // MARK: Load Stored Keychain
        
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier = keychain.get(ServerDefaultKeys.userIdentifier.rawValue)
        UserInformation.userEmail = keychain.get(ServerDefaultKeys.userEmail.rawValue) ?? UserInformation.userEmail
        UserInformation.userFirstName = keychain.get(ServerDefaultKeys.userFirstName.rawValue) ?? UserInformation.userFirstName
        UserInformation.userLastName = keychain.get(ServerDefaultKeys.userLastName.rawValue) ?? UserInformation.userLastName
        
        // MARK: Load Stored User Information
        
        UserInformation.userId = UserDefaults.standard.value(forKey: ServerDefaultKeys.userId.rawValue) as? String ?? UserInformation.userId
        UserInformation.familyId = UserDefaults.standard.value(forKey: ServerDefaultKeys.familyId.rawValue) as? String ?? UserInformation.familyId
        
        // MARK: Load Stored User Configuration
        
        // Data is retrieved from the server, so no need to store/persist locally
        
        // MARK: Load Stored Local Configuration
        
        LocalConfiguration.lastDogManagerSynchronization = UserDefaults.standard.value(forKey: ServerDefaultKeys.lastDogManagerSynchronization.rawValue) as? Date ?? LocalConfiguration.lastDogManagerSynchronization
        
        if let dataDogIcons: Data = UserDefaults.standard.data(forKey: UserDefaultsKeys.dogIcons.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataDogIcons) {
            unarchiver.requiresSecureCoding = false
            LocalConfiguration.dogIcons = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [LocalDogIcon] ?? LocalConfiguration.dogIcons
        }
        
        // if the user had a dogManager from pre Hound 2.0 (build 4000), then we must clear it. It will be incompatible and cause issues. Must start from scratch.
        if UIApplication.previousAppBuild ?? 4000 < 4000 {
            UserDefaults.standard.removeObject(forKey: ServerDefaultKeys.dogManager.rawValue)
        }
        
        if let dataDogManager: Data = UserDefaults.standard.data(forKey: ServerDefaultKeys.dogManager.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataDogManager) {
            unarchiver.requiresSecureCoding = false
            
            if let dogManager = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? DogManager {
                ServerSyncViewController.dogManager = dogManager
            }
            else {
                // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refetch from the server
                AppDelegate.generalLogger.error("Failed to decode dogManager with unarchiver")
                ServerSyncViewController.dogManager = DogManager()
                LocalConfiguration.lastDogManagerSynchronization = LocalConfiguration.defaultLastDogManagerSynchronization
            }
        }
        else {
            // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refetch from the server
            AppDelegate.generalLogger.error("Failed to construct dataDogManager or construct unarchiver for dogManager")
            ServerSyncViewController.dogManager = DogManager()
            LocalConfiguration.lastDogManagerSynchronization = LocalConfiguration.defaultLastDogManagerSynchronization
        }
        
        LocalConfiguration.logCustomActionNames = UserDefaults.standard.value(forKey: UserDefaultsKeys.logCustomActionNames.rawValue) as? [String] ?? LocalConfiguration.logCustomActionNames
        LocalConfiguration.reminderCustomActionNames = UserDefaults.standard.value(forKey: UserDefaultsKeys.reminderCustomActionNames.rawValue) as? [String] ?? LocalConfiguration.reminderCustomActionNames
        
        LocalConfiguration.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as? Bool ?? LocalConfiguration.isNotificationAuthorized
        
        LocalConfiguration.reviewRequestDates = UserDefaults.standard.value(forKey: UserDefaultsKeys.reviewRequestDates.rawValue) as? [Date] ?? LocalConfiguration.reviewRequestDates
        LocalConfiguration.shouldShowReleaseNotes = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldShowReleaseNotes.rawValue) as? Bool ?? LocalConfiguration.shouldShowReleaseNotes
        LocalConfiguration.appBuildsWithReleaseNotesShown = UserDefaults.standard.value(forKey: UserDefaultsKeys.appBuildsWithReleaseNotesShown.rawValue) as? [Int] ?? LocalConfiguration.appBuildsWithReleaseNotesShown
        
        LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore
        LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore
        LocalConfiguration.hasLoadedSettingsFamilyIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedSettingsFamilyIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedSettingsFamilyIntroductionViewControllerBefore
        
        // MARK: Configure Other
        
        // If the user hasn't completed the dogs and reminders introduction page, then we put them on the logs page (index 0). Otherwise, if they have configured their first dog and reminder, then they get put on the dogs page (index 1)
        MainTabBarViewController.selectedEntryIndex = (LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore && LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore) ? 1 : 0
    
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
                // TO DO BUG if the user directly termiantes the app, without letting it go to background first, then the API request doesn't get sent off and the user doesn't get their notification warning them
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
        
        UserDefaults.standard.set(LocalConfiguration.lastDogManagerSynchronization, forKey: ServerDefaultKeys.lastDogManagerSynchronization.rawValue)
        
        if let dataDogIcons = try? NSKeyedArchiver.archivedData(withRootObject: LocalConfiguration.dogIcons, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogIcons, forKey: UserDefaultsKeys.dogIcons.rawValue)
        }
        if let dataDogManager = try? NSKeyedArchiver.archivedData(withRootObject: MainTabBarViewController.staticDogManager, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogManager, forKey: ServerDefaultKeys.dogManager.rawValue)
        }
        
        UserDefaults.standard.set(LocalConfiguration.logCustomActionNames, forKey: UserDefaultsKeys.logCustomActionNames.rawValue)
        UserDefaults.standard.set(LocalConfiguration.reminderCustomActionNames, forKey: UserDefaultsKeys.reminderCustomActionNames.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.shouldShowReleaseNotes, forKey: UserDefaultsKeys.shouldShowReleaseNotes.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.appBuildsWithReleaseNotesShown, forKey: UserDefaultsKeys.appBuildsWithReleaseNotesShown.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedSettingsFamilyIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedSettingsFamilyIntroductionViewControllerBefore.rawValue)
    }
    
    static func willEnterForeground() {
        
        NotificationManager.synchronizeNotificationAuthorization()
        
        // stop any loud notifications that may have occured
        AudioManager.stopLoudNotification()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
    }
    
}
