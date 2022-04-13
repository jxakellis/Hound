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
    static func setup(isRecurringSetup: Bool = false) {
        
        AppDelegate.generalLogger.notice("\n-----Device Info-----\n Model: \(UIDevice.current.model) \n Name: \(UIDevice.current.name) \n System Name: \(UIDevice.current.systemName) \n System Version: \(UIDevice.current.systemVersion)")
        
        UIApplication.previousAppBuild = UserDefaults.standard.object(forKey: UserDefaultsKeys.appBuild.rawValue) as? Int
        
        UserDefaults.standard.setValue(UIApplication.appBuild, forKey: UserDefaultsKeys.appBuild.rawValue)

        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        if isRecurringSetup == true {
            // not first time setup
            
            recurringSetup()
            
        }
        else {
            // first time setup
            
            firstTimeSetup()
        }
    }
    
    /// Sets the data to default values as if the user is opening the app for the first time
    static private func firstTimeSetup() {
        
        MainTabBarViewController.selectedEntryIndex = 0
        
        // MARK: User Information
        
        UserDefaults.standard.setValue(UserInformation.userId, forKey: ServerDefaultKeys.userId.rawValue)
        UserDefaults.standard.setValue(UserInformation.familyId, forKey: ServerDefaultKeys.familyId.rawValue)
        
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier = keychain.get(ServerDefaultKeys.userIdentifier.rawValue)
        UserInformation.userEmail = keychain.get(ServerDefaultKeys.userEmail.rawValue) ?? UserInformation.userEmail
        UserInformation.userFirstName = keychain.get(ServerDefaultKeys.userFirstName.rawValue) ?? UserInformation.userFirstName
        UserInformation.userLastName = keychain.get(ServerDefaultKeys.userLastName.rawValue) ?? UserInformation.userLastName
         
         // MARK: User Configuration
         
        // Data is retrieved from the server, so no need to store/persist locally
        
        // MARK: Local Configuration
        
        let dataDogIcons = LocalConfiguration.dogIcons
        let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: dataDogIcons, requiringSecureCoding: false)
        UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.dogIcons.rawValue)
        
        UserDefaults.standard.setValue(LocalConfiguration.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.isShowTerminationAlert, forKey: UserDefaultsKeys.isShowTerminationAlert.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.isShowReleaseNotes, forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)
        
        // indicate to local save that the app has sucessfully set itself up
        UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.hasDoneFirstTimeSetup.rawValue)
    }
    
    /// Sets the data to its saved values as if the app is reopening again
    static private func recurringSetup() {
        
        // MARK: User Information
        
        UserInformation.userId = UserDefaults.standard.value(forKey: ServerDefaultKeys.userId.rawValue) as? Int
        UserInformation.familyId = UserDefaults.standard.value(forKey: ServerDefaultKeys.familyId.rawValue) as? Int
        
        // These values are retrieved from Sign In With Apple so therefore need to be persisted specially. All other values can be retrieved using these values.
        let keychain = KeychainSwift()
        
        UserInformation.userIdentifier = keychain.get(ServerDefaultKeys.userIdentifier.rawValue)
        UserInformation.userEmail = keychain.get(ServerDefaultKeys.userEmail.rawValue) ?? UserInformation.userEmail
        UserInformation.userFirstName = keychain.get(ServerDefaultKeys.userFirstName.rawValue) ?? UserInformation.userFirstName
        UserInformation.userLastName = keychain.get(ServerDefaultKeys.userLastName.rawValue) ?? UserInformation.userLastName
        
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
                // TO DO add error message to alert user
                AppDelegate.generalLogger.error("Unable to unarchive localDogIcons")
            }
        }
        
        LocalConfiguration.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as? Bool ?? LocalConfiguration.isNotificationAuthorized
        
        LocalConfiguration.lastPause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastPause.rawValue) as? Date
        
        LocalConfiguration.lastUnpause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastUnpause.rawValue) as? Date
        
        LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore
        LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore
        
        LocalConfiguration.reviewRequestDates = UserDefaults.standard.value(forKey: UserDefaultsKeys.reviewRequestDates.rawValue) as? [Date] ?? LocalConfiguration.reviewRequestDates
        
        LocalConfiguration.isShowTerminationAlert = UserDefaults.standard.value(forKey: UserDefaultsKeys.isShowTerminationAlert.rawValue) as? Bool ?? LocalConfiguration.isShowTerminationAlert
        
        LocalConfiguration.isShowReleaseNotes = UserDefaults.standard.value(forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue) as? Bool ?? LocalConfiguration.isShowReleaseNotes
        
    }
    
    /// Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func willEnterBackground(isTerminating: Bool = false) {
        
        func getSizeOfUserDefaults() -> Int? {
            guard let libraryDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
                return nil
            }
            
            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                return nil
            }
            
            let filepath = "\(libraryDir)/Preferences/\(bundleIdentifier).plist"
            let filesize = try? FileManager.default.attributesOfItem(atPath: filepath)
            let retVal = filesize?[FileAttributeKey.size]
            return retVal as? Int
        }
        
        // background silence player for loud alarm that bypasses ringer and if phone locked
        func handleBackgroundSilence() {
            AppDelegate.generalLogger.notice("handleBackgroundSilence")
            AudioManager.stopAudio()
            
            guard UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotification && MainTabBarViewController.staticDogManager.hasEnabledReminder && !UserConfiguration.isPaused else {
                return
            }
            
            AudioManager.playSilenceAudio()
            
        }
        
        // saves to user defaults
        func handleUserDefaults() {
            AppDelegate.generalLogger.notice("handleUserDefaults")
            
            // MARK: User Information
            
            UserDefaults.standard.setValue(UserInformation.userId, forKey: ServerDefaultKeys.userId.rawValue)
            UserDefaults.standard.setValue(UserInformation.familyId, forKey: ServerDefaultKeys.familyId.rawValue)
            
            // other user info from ASAuthorization is saved immediately to the keychain
             
             // MARK: User Configuration
             
             // Data below is retrieved from the server, so no need to store/persist locally
            
            // MARK: Local Configuration
            
            let dataDogIcons = LocalConfiguration.dogIcons
            let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: dataDogIcons, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.dogIcons.rawValue)
            
            UserDefaults.standard.setValue(LocalConfiguration.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.isShowTerminationAlert, forKey: UserDefaultsKeys.isShowTerminationAlert.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.isShowReleaseNotes, forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)
        }
        
        // ios notifications
        func handleNotifications() {
            AppDelegate.generalLogger.notice("handleNotifications")
            guard LocalConfiguration.isNotificationAuthorized && UserConfiguration.isNotificationEnabled && !UserConfiguration.isPaused else {
                return
            }
            AppDelegate.generalLogger.notice("handleNotifications enabled by user settings, will create notifications")
            
            // remove duplicate notifications if app is backgrounded then terminated
            
            NotificationManager.removeAllNotifications()
            
            for dog in MainTabBarViewController.staticDogManager.dogs {
                for reminder in dog.dogReminders.reminders {
                    guard reminder.timer?.isValid == true else {
                        continue
                    }
                    NotificationManager.willCreateUNUserNotification(dogName: dog.dogName, reminder: reminder)
                    
                    if UserConfiguration.isFollowUpEnabled == true {
                        NotificationManager.willCreateFollowUpUNUserNotification(dogName: dog.dogName, reminder: reminder)
                    }
                }
            }
        }
        
        if isTerminating == true {
            // this is only called if the app is DIRECTlY terminated (not background then terminated). If this happens then we can just skips background silence (termination kills it anyways)
            handleUserDefaults()
            
            handleNotifications()
        }
        else {
            handleBackgroundSilence()
            
            handleUserDefaults()
            
            handleNotifications()
        }
        
    }
    
    static func willEnterForeground() {
        
        synchronizeNotificationAuthorization()
        
        if LocalConfiguration.isNotificationAuthorized && UserConfiguration.isNotificationEnabled == true {
            NotificationManager.removeAllNotifications()
        }
    }
    
    /// Checks to see if a change in notification permissions has occured, if it has then update to reflect
    static private func synchronizeNotificationAuthorization() {
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        let beforeUpdateIsFollowUpEnabled = UserConfiguration.isFollowUpEnabled
        
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                
                // going from off to on, meaning the user has gone into the settings app and turned notifications from disabled to enabled
                LocalConfiguration.isNotificationAuthorized = true
                
            case .denied:
                
                    LocalConfiguration.isNotificationAuthorized = false
                    UserConfiguration.isNotificationEnabled = false
                    UserConfiguration.isLoudNotification = false
                    UserConfiguration.isFollowUpEnabled = false
                    // Updates switch to reflect change, if the last view open was the settings page then the app is exitted and property changed in the settings app then this app is reopened, VWL will not be called as the settings page was already opened, weird edge case.
                // keep .main as UNUserNotificationCenter.current().getNotificationSettings is on seperate thread
                DispatchQueue.main.async {
                    let settingsVC: SettingsViewController? = MainTabBarViewController.mainTabBarViewController?.settingsViewController
                    settingsVC?.settingsNotificationsViewController?.synchronizeAllNotificationSwitches(animated: false)
                }
                    updateServerUserConfiguration()
               
            case .notDetermined:
                AppDelegate.generalLogger.notice(".notDetermined")
            case .provisional:
                AppDelegate.generalLogger.notice(".provisional")
            case .ephemeral:
                AppDelegate.generalLogger.notice(".ephemeral")
            @unknown default:
                AppDelegate.generalLogger.notice("unknown auth status")
            }
        }
        
        /// Contact the server about the updated values and, if there is no response or a bad response, revert the values to their previous values. isNotificationAuthorized purposefully excluded as server doesn't need to know that and its value cant exactly just be flipped (as tied to apple notif auth status)
        func updateServerUserConfiguration() {
            var body: [String: Any] = [:]
            // check for if values were changed, if there were then tell the server
            if UserConfiguration.isNotificationEnabled != beforeUpdateIsNotificationEnabled {
                body[ServerDefaultKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
            }
            if UserConfiguration.isLoudNotification != beforeUpdateIsLoudNotification {
                body[ServerDefaultKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
            }
            if UserConfiguration.isFollowUpEnabled != beforeUpdateIsFollowUpEnabled {
                body[ServerDefaultKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
            }
            if body.keys.isEmpty == false {
                UserRequest.update(body: body) { requestWasSuccessful in
                    if requestWasSuccessful == false {
                        // error, revert to previous
                        UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                        UserConfiguration.isLoudNotification = beforeUpdateIsLoudNotification
                        UserConfiguration.isFollowUpEnabled = beforeUpdateIsFollowUpEnabled
                        
                        let settingsVC: SettingsViewController? = MainTabBarViewController.mainTabBarViewController?.settingsViewController
                        settingsVC?.settingsNotificationsViewController?.synchronizeAllNotificationSwitches(animated: false)
                    }
                }
            }
            
        }
    }
    
}
