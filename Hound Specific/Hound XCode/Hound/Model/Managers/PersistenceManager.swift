//
//  PersistenceManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/16/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class PersistenceManager {
    /// Called by App or Scene Delegate when setting up in didFinishLaunchingWithOptions, can be either the first time setup or a recurring setup (i.e. not the app isnt being opened for the first time)
    static func setup(isRecurringSetup: Bool = false) {
        
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
        
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        MainTabBarViewController.selectedEntryIndex = 0
        
        // Data below is retrieved from the server, so no need to store/persist locally
        /*
         
         let data = DogManagerConstant.defaultDogManager
         let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
         UserDefaults.standard.setValue(encodedData, forKey: UserDefaultsKeys.dogManager.rawValue)
         
         // MARK: User Configuration
         
         
         UserDefaults.standard.setValue(UserConfiguration.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
         
         UserDefaults.standard.setValue(UserConfiguration.snoozeLength, forKey: UserDefaultsKeys.snoozeLength.rawValue)
         
         
         UserDefaults.standard.setValue(UserConfiguration.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
         UserDefaults.standard.setValue(UserConfiguration.isLoudNotification, forKey: UserDefaultsKeys.isLoudNotification.rawValue)
         
         UserDefaults.standard.setValue(UserConfiguration.isFollowUpEnabled, forKey: UserDefaultsKeys.isFollowUpEnabled.rawValue)
         UserDefaults.standard.setValue(UserConfiguration.followUpDelay, forKey: UserDefaultsKeys.followUpDelay.rawValue)
         UserDefaults.standard.setValue(UserConfiguration.notificationSound.rawValue, forKey: UserDefaultsKeys.notificationSound.rawValue)
         
         UserDefaults.standard.setValue(UserConfiguration.isCompactView, forKey: UserDefaultsKeys.isCompactView.rawValue)
         UserDefaults.standard.setValue(UserConfiguration.interfaceStyle.rawValue, forKey: UserDefaultsKeys.interfaceStyle.rawValue)
         
         */
        
        // MARK: Local Configuration
        UserDefaults.standard.setValue(LocalConfiguration.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedIntroductionViewControllerBefore.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.isShowTerminationAlert, forKey: UserDefaultsKeys.isShowTerminationAlert.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.isShowReleaseNotes, forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue)
        UserDefaults.standard.setValue(LocalConfiguration.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)
        
        // indicate to local save that the app has sucessfully set itself up
        UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.hasDoneFirstTimeSetup.rawValue)
    }
    
    /// Sets the data to its saved values as if the app is reopening again
    static private func recurringSetup() {
        
        // Data below is retrieved from the server, so no need to store/persist locally
        /*
         // MARK: User Configuration
         
         UserConfiguration.isPaused = UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as? Bool ?? UserConfiguration.isPaused
         
         UserConfiguration.snoozeLength = UserDefaults.standard.value(forKey: UserDefaultsKeys.snoozeLength.rawValue) as? TimeInterval ?? UserConfiguration.snoozeLength
         
         
         
         UserConfiguration.isNotificationEnabled = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isNotificationEnabled
         
         UserConfiguration.isLoudNotification = UserDefaults.standard.value(forKey: UserDefaultsKeys.isLoudNotification.rawValue) as? Bool ?? UserConfiguration.isLoudNotification
         
         UserConfiguration.isFollowUpEnabled = UserDefaults.standard.value(forKey: UserDefaultsKeys.isFollowUpEnabled.rawValue) as? Bool ?? UserConfiguration.isFollowUpEnabled
         
         UserConfiguration.followUpDelay = UserDefaults.standard.value(forKey: UserDefaultsKeys.followUpDelay.rawValue) as? TimeInterval ?? UserConfiguration.followUpDelay
         
         UserConfiguration.notificationSound = NotificationSound(rawValue: UserDefaults.standard.value(forKey: UserDefaultsKeys.notificationSound.rawValue) as? String ?? NotificationSound.radar.rawValue)!
         
         UserConfiguration.isCompactView = UserDefaults.standard.value(forKey: UserDefaultsKeys.isCompactView.rawValue) as? Bool ?? UserConfiguration.isCompactView
         
         UserConfiguration.interfaceStyle = UIUserInterfaceStyle(rawValue: UserDefaults.standard.value(forKey: UserDefaultsKeys.interfaceStyle.rawValue) as? Int ?? UIUserInterfaceStyle.unspecified.rawValue)!
         
         */
        // MARK: Local Configuration
        
        LocalConfiguration.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as? Bool ?? LocalConfiguration.isNotificationAuthorized
        
        LocalConfiguration.lastPause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastPause.rawValue) as? Date
        
        LocalConfiguration.lastUnpause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastUnpause.rawValue) as? Date
        
        LocalConfiguration.hasLoadedIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedIntroductionViewControllerBefore
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
            
            // Data below is retrieved from the server, so no need to store/persist locally
            /*
             // dogManager
             // DogManagerEfficencyImprovement OK, Changes are being made that might not apply to the rest of the system, might be invalid, or might affect finding something
             var dataDogManager = MainTabBarViewController.staticDogManager.copy() as! DogManager
             dataDogManager.clearAllPresentationHandled()
             
             let encodedDataDogManager = try! NSKeyedArchiver.archivedData(withRootObject: dataDogManager, requiringSecureCoding: false)
             UserDefaults.standard.setValue(encodedDataDogManager, forKey: UserDefaultsKeys.dogManager.rawValue)
             
             // MARK: User Configuration
             
             // Pause State
             UserDefaults.standard.setValue(UserConfiguration.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
             
             // Snooze interval
             
             UserDefaults.standard.setValue(UserConfiguration.snoozeLength, forKey: UserDefaultsKeys.snoozeLength.rawValue)
             
             // Notifications
             
             UserDefaults.standard.setValue(UserConfiguration.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
             UserDefaults.standard.setValue(UserConfiguration.isLoudNotification, forKey: UserDefaultsKeys.isLoudNotification.rawValue)
             UserDefaults.standard.setValue(UserConfiguration.isFollowUpEnabled, forKey: UserDefaultsKeys.isFollowUpEnabled.rawValue)
             UserDefaults.standard.setValue(UserConfiguration.followUpDelay, forKey: UserDefaultsKeys.followUpDelay.rawValue)
             UserDefaults.standard.setValue(UserConfiguration.notificationSound.rawValue, forKey: UserDefaultsKeys.notificationSound.rawValue)
             UserDefaults.standard.setValue(UserConfiguration.isCompactView, forKey: UserDefaultsKeys.isCompactView.rawValue)
             UserDefaults.standard.setValue(UserConfiguration.interfaceStyle.rawValue, forKey: UserDefaultsKeys.interfaceStyle.rawValue)
             
             */
            // MARK: Local Configuration
            UserDefaults.standard.setValue(LocalConfiguration.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.isShowTerminationAlert, forKey: UserDefaultsKeys.isShowTerminationAlert.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.isShowReleaseNotes, forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.hasLoadedIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedIntroductionViewControllerBefore.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)
        }
        
        // ios notifications
        func handleNotifications() {
            AppDelegate.generalLogger.notice("handleNotifications")
            guard LocalConfiguration.isNotificationAuthorized && UserConfiguration.isNotificationEnabled && !UserConfiguration.isPaused else {
                return
            }
            AppDelegate.generalLogger.notice("handleNotifications passed guard statement")
            
            // remove duplicate notifications if app is backgrounded then terminated
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
            for dog in MainTabBarViewController.staticDogManager.dogs {
                for reminder in dog.dogReminders.reminders {
                    guard reminder.timer?.isValid == true else {
                        continue
                    }
                    Utils.willCreateUNUserNotification(dogName: dog.dogName, reminder: reminder)
                    
                    if UserConfiguration.isFollowUpEnabled == true {
                        Utils.willCreateFollowUpUNUserNotification(dogName: dog.dogName, reminder: reminder)
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
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
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
                body[UserDefaultsKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
            }
            if UserConfiguration.isLoudNotification != beforeUpdateIsLoudNotification {
                body[UserDefaultsKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
            }
            if UserConfiguration.isFollowUpEnabled != beforeUpdateIsFollowUpEnabled {
                body[UserDefaultsKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
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
