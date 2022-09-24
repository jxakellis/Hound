//
//  PersistenceManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/16/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
import KeychainSwift
import StoreKit

enum PersistenceManager {
    /// Called by App or Scene Delegate when setting up in didFinishLaunchingWithOptions, can be either the first time setup or a recurring setup (i.e. not the app isnt being opened for the first time)
    static func setup() {
        
        // MARK: Log Launch
        
        AppDelegate.generalLogger.notice("\n-----Device Info-----\n Model: \(UIDevice.current.model) \n Name: \(UIDevice.current.name) \n System Name: \(UIDevice.current.systemName) \n System Version: \(UIDevice.current.systemVersion)")
        
        // MARK: Save Certain Values
        
        // <= build 8000 appVersion
        UIApplication.previousAppVersion = UserDefaults.standard.object(forKey: KeyConstant.localAppVersion.rawValue) as? String ?? UserDefaults.standard.object(forKey: "appVersion") as? String
        // <= build 8000 appBuild
        UIApplication.previousAppBuild = UserDefaults.standard.object(forKey: KeyConstant.localAppBuild.rawValue) as? Int ?? UserDefaults.standard.object(forKey: "appBuild") as? Int
        
        UserDefaults.standard.setValue(UIApplication.appVersion, forKey: KeyConstant.localAppVersion.rawValue)
        UserDefaults.standard.setValue(UIApplication.appBuild, forKey: KeyConstant.localAppBuild.rawValue)
        
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // MARK: Load Stored Keychain
        
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier = keychain.get(KeyConstant.userIdentifier.rawValue)
        
        if EnumConstant.DevelopmentConstant.isProductionDatabase == false {
            UserInformation.userIdentifier = "18a324da0aea90d36451962667b664aeb168c8cee5033a5ff9e806342cdc54d0"
        }
        
        UserInformation.userEmail = keychain.get(KeyConstant.userEmail.rawValue) ?? UserInformation.userEmail
        UserInformation.userFirstName = keychain.get(KeyConstant.userFirstName.rawValue) ?? UserInformation.userFirstName
        UserInformation.userLastName = keychain.get(KeyConstant.userLastName.rawValue) ?? UserInformation.userLastName
        
        // MARK: Load Stored User Information
        
        UserInformation.userId = UserDefaults.standard.value(forKey: KeyConstant.userId.rawValue) as? String ?? UserInformation.userId
        
        if EnumConstant.DevelopmentConstant.isProductionDatabase == false {
            UserInformation.userId = "c461dda5297129dfcd92a69b47ba850fd573a656800930fd3e7fe0c940eeca1b"
        }
       
        UserInformation.familyId = UserDefaults.standard.value(forKey: KeyConstant.familyId.rawValue) as? String ?? UserInformation.familyId
        
        // MARK: Load Stored User Configuration
        
        // Data is retrieved from the server, so no need to store/persist locally
        
        // MARK: Load Stored Local Configuration
        
        LocalConfiguration.lastDogManagerSynchronization = UserDefaults.standard.value(forKey: KeyConstant.userConfigurationPreviousDogManagerSynchronization.rawValue) as? Date ?? LocalConfiguration.lastDogManagerSynchronization
        
        // TO DO NOW can't store dogIcons in user defaults. causes issues beause it uses too much storage
        // <= build 8000 dogIcons
        if let dataDogIcons: Data = UserDefaults.standard.data(forKey: KeyConstant.localDogIcons.rawValue) ?? UserDefaults.standard.data(forKey: "dogIcons"), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataDogIcons) {
            unarchiver.requiresSecureCoding = false
            LocalConfiguration.dogIcons = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [LocalDogIcon] ?? LocalConfiguration.dogIcons
        }
        
        // if the user had a dogManager from pre Hound 2.0.0, then we must clear it. It will be incompatible and cause issues. Must start from scratch.
        if UIApplication.previousAppBuild ?? 3810 <= 3810 {
            UserDefaults.standard.removeObject(forKey: KeyConstant.dogManager.rawValue)
        }
        
        if let dataDogManager: Data = UserDefaults.standard.data(forKey: KeyConstant.dogManager.rawValue), let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: dataDogManager) {
            unarchiver.requiresSecureCoding = false
            
            if let dogManager = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? DogManager {
                ServerSyncViewController.dogManager = dogManager
            }
            else {
                // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refetch from the server
                AppDelegate.generalLogger.error("Failed to decode dogManager with unarchiver")
                ServerSyncViewController.dogManager = DogManager()
                LocalConfiguration.lastDogManagerSynchronization = ClassConstant.DateConstant.default1970Date
            }
        }
        else {
            // if nil, then decode failed or there was an issue. therefore, set the interval back to past so we can refetch from the server
            AppDelegate.generalLogger.error("Failed to construct dataDogManager or construct unarchiver for dogManager")
            ServerSyncViewController.dogManager = DogManager()
            LocalConfiguration.lastDogManagerSynchronization = ClassConstant.DateConstant.default1970Date
        }
        
        // <= build 8000 logCustomActionNames
        LocalConfiguration.localPreviousLogCustomActionNames =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousLogCustomActionNames.rawValue) as? [String]
        ?? UserDefaults.standard.value(forKey: "logCustomActionNames") as? [String]
        ?? LocalConfiguration.localPreviousLogCustomActionNames
        
        // <= build 8000 reminderCustomActionNames
        LocalConfiguration.localPreviousReminderCustomActionNames =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousReminderCustomActionNames.rawValue) as? [String]
        ?? UserDefaults.standard.value(forKey: "reminderCustomActionNames") as? [String]
        ?? LocalConfiguration.localPreviousReminderCustomActionNames
        
        // <= build 8000 isNotificationAuthorized
        LocalConfiguration.localIsNotificationAuthorized =
        UserDefaults.standard.value(forKey: KeyConstant.localIsNotificationAuthorized.rawValue) as? Bool
        ?? UserDefaults.standard.value(forKey: "isNotificationAuthorized") as? Bool
        ?? LocalConfiguration.localIsNotificationAuthorized
        
        // <= build 6500 userAskedToReviewHoundDates
        // <= build 8000 datesUserShownBannerToReviewHound
        LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousDatesUserShownBannerToReviewHound.rawValue) as? [Date]
        ?? UserDefaults.standard.value(forKey: "datesUserShownBannerToReviewHound") as? [Date]
        ?? UserDefaults.standard.value(forKey: "userAskedToReviewHoundDates") as? [Date]
        ?? LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound
        
        // reviewRequestDates depreciated >= build 6000; rateReviewRequestedDates depreciated >= build 6500
        // <= build 6000 reviewRequestDates
        // <= build 6500 rateReviewRequestedDates
        // <= build 8000 datesUserReviewRequested
        LocalConfiguration.localPreviousDatesUserReviewRequested =
        UserDefaults.standard.value(forKey: KeyConstant.localPreviousDatesUserReviewRequested.rawValue) as? [Date]
        ?? UserDefaults.standard.value(forKey: "datesUserReviewRequested") as? [Date]
        ?? UserDefaults.standard.value(forKey: "reviewRequestDates") as? [Date]
        ?? UserDefaults.standard.value(forKey: "rateReviewRequestedDates") as? [Date] ?? LocalConfiguration.localPreviousDatesUserReviewRequested
        
        // <= build 8000 appVersionsWithReleaseNotesShown
        LocalConfiguration.localAppVersionsWithReleaseNotesShown =
        UserDefaults.standard.value(forKey: KeyConstant.localAppVersionsWithReleaseNotesShown.rawValue) as? [String]
        ?? UserDefaults.standard.value(forKey: "appVersionsWithReleaseNotesShown") as? [String]
        ?? LocalConfiguration.localAppVersionsWithReleaseNotesShown
        
        // <= build 8000 appBuildsWithReleaseNotesShown
        LocalConfiguration.localAppBuildsWithReleaseNotesShown =
        UserDefaults.standard.value(forKey: KeyConstant.localAppBuildsWithReleaseNotesShown.rawValue) as? [Int]
        ?? UserDefaults.standard.value(forKey: "appBuildsWithReleaseNotesShown") as? [Int]
        ?? LocalConfiguration.localAppBuildsWithReleaseNotesShown
        
        // <= build 8000 hasLoadedHoundIntroductionViewControllerBefore
        LocalConfiguration.localHasCompletedHoundIntroductionViewController =
        UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedHoundIntroductionViewController.rawValue) as? Bool
        ?? UserDefaults.standard.value(forKey: "hasLoadedHoundIntroductionViewControllerBefore") as? Bool
        ?? LocalConfiguration.localHasCompletedHoundIntroductionViewController
        
        // <= build 8000 hasLoadedRemindersIntroductionViewControllerBefore
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController =
        UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedRemindersIntroductionViewController.rawValue) as? Bool
        ?? UserDefaults.standard.value(forKey: "hasLoadedRemindersIntroductionViewControllerBefore") as? Bool
        ?? LocalConfiguration.localHasCompletedRemindersIntroductionViewController
        
        // <= build 8000 hasLoadedSettingsFamilyIntroductionViewControllerBefore
        LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController =
        UserDefaults.standard.value(forKey: KeyConstant.localHasCompletedSettingsFamilyIntroductionViewController.rawValue) as? Bool
        ?? UserDefaults.standard.value(forKey: "hasLoadedSettingsFamilyIntroductionViewControllerBefore") as? Bool
        ?? LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController
        
        // MARK: Configure Other
        
        // For family Hound, always put the user on the logs of care page first. This is most likely the most pertinant information. There isn't much reason to visit the dogs/reminders page unless updating a dog/reminder (or logging a reminder early).
        MainTabBarViewController.selectedEntryIndex = 0
        
    }
    
    /// Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func didEnterBackground(isTerminating: Bool = false) {
        
        // MARK: Loud Notifications and Silent Audio
        
        // Check to see if the user is eligible for loud notifications
        // Don't check for enabled reminders, as client could be out of sync with server
        if UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotification {
            if isTerminating == true {
                // Send notification to user that their loud notifications won't work
                AlertRequest.create(invokeErrorManager: false, completionHandler: { _, _ in
                    //
                })
            }
            else {
                // app isn't terminating so add background silence
                AudioManager.stopAudio()
                AudioManager.playSilenceAudio()
            }
        }
        
        // MARK: - User Defaults
        
        // User Information
        
        UserDefaults.standard.setValue(UserInformation.userId, forKey: KeyConstant.userId.rawValue)
        UserDefaults.standard.setValue(UserInformation.familyId, forKey: KeyConstant.familyId.rawValue)
        
        // other user info from ASAuthorization is saved immediately to the keychain
        
        // User Configuration
        
        // Data below is retrieved from the server, so no need to store/persist locally
        
        // Local Configuration
        
        UserDefaults.standard.set(LocalConfiguration.lastDogManagerSynchronization, forKey: KeyConstant.userConfigurationPreviousDogManagerSynchronization.rawValue)
        
        if let dataDogIcons = try? NSKeyedArchiver.archivedData(withRootObject: LocalConfiguration.dogIcons, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogIcons, forKey: KeyConstant.localDogIcons.rawValue)
        }
        if let dataDogManager = try? NSKeyedArchiver.archivedData(withRootObject: MainTabBarViewController.staticDogManager, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogManager, forKey: KeyConstant.dogManager.rawValue)
        }
        
        UserDefaults.standard.set(LocalConfiguration.localPreviousLogCustomActionNames, forKey: KeyConstant.localPreviousLogCustomActionNames.rawValue)
        UserDefaults.standard.set(LocalConfiguration.localPreviousReminderCustomActionNames, forKey: KeyConstant.localPreviousReminderCustomActionNames.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.localIsNotificationAuthorized, forKey: KeyConstant.localIsNotificationAuthorized.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.localPreviousDatesUserShownBannerToReviewHound, forKeyPath: KeyConstant.localPreviousDatesUserShownBannerToReviewHound.rawValue)
        PersistenceManager.persistRateReviewRequestedDates()
    
        UserDefaults.standard.setValue(LocalConfiguration.localAppVersionsWithReleaseNotesShown, forKey: KeyConstant.localAppVersionsWithReleaseNotesShown.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.localAppBuildsWithReleaseNotesShown, forKey: KeyConstant.localAppBuildsWithReleaseNotesShown.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedHoundIntroductionViewController, forKey: KeyConstant.localHasCompletedHoundIntroductionViewController.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedRemindersIntroductionViewController, forKey: KeyConstant.localHasCompletedRemindersIntroductionViewController.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.localHasCompletedSettingsFamilyIntroductionViewController, forKey: KeyConstant.localHasCompletedSettingsFamilyIntroductionViewController.rawValue)
    }
    
    static func willEnterForeground() {
        
        // Invocation of synchronizeNotificationAuthorization from willEnterForeground will only be accurate in conjuction with invocation of synchronizeNotificationAuthorization in viewDidAppear of MainTabBarViewController. This makes it so every time Hound is opened, either from the background or from terminated, notifications are properly synced.
        // 1. Hound entering foreground from being terminated. willEnterForeground called upon inital launch of Hound although UserConfiguration (and notification settings) aren't loaded from the server, but viewDidAppear MainTabBarViewController will catch as it's invoked once ServerSyncViewController is done loading (and notification settings are loaded
        // 2. Hound entering foreground after entering background. viewDidAppear MainTabBarViewController won't catch as MainTabBarViewController's view isn't appearing anymore but willEnterForeground will catch any imbalance as it's called once app is loaded to foreground
        NotificationManager.synchronizeNotificationAuthorization()
        
        // stop any loud notifications that may have occured
        AudioManager.stopLoudNotification()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
    }
    
    /// It is important to persist this value to memory immediately. Apple keeps track of when we ask the user for a rate review and we must keep accurate track. But, if Hound crashes before we can save an updated value of localPreviousDatesUserReviewRequested, then our value and Apple's true value is mismatched.
    static func persistRateReviewRequestedDates() {
        UserDefaults.standard.setValue(LocalConfiguration.localPreviousDatesUserReviewRequested, forKeyPath: KeyConstant.localPreviousDatesUserReviewRequested.rawValue)
    }
    
}
