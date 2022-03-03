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
    static func willSetup(isRecurringSetup: Bool = false) {

        if isRecurringSetup == true {
            // not first time setup

            // MARK: User Configuration

            UserConfiguration.isPaused = UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as? Bool ?? UserConfiguration.isPaused

            UserConfiguration.snoozeLength = UserDefaults.standard.value(forKey: UserDefaultsKeys.snoozeLength.rawValue) as? TimeInterval ?? UserConfiguration.snoozeLength

            UserConfiguration.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as? Bool ?? UserConfiguration.isNotificationAuthorized

            UserConfiguration.isNotificationEnabled = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isNotificationEnabled

            UserConfiguration.isLoudNotification = UserDefaults.standard.value(forKey: UserDefaultsKeys.isLoudNotification.rawValue) as? Bool ?? UserConfiguration.isLoudNotification

            UserConfiguration.isFollowUpEnabled = UserDefaults.standard.value(forKey: UserDefaultsKeys.isFollowUpEnabled.rawValue) as? Bool ?? UserConfiguration.isFollowUpEnabled

            UserConfiguration.followUpDelay = UserDefaults.standard.value(forKey: UserDefaultsKeys.followUpDelay.rawValue) as? TimeInterval ?? UserConfiguration.followUpDelay

            UserConfiguration.notificationSound = NotificationSound(rawValue: UserDefaults.standard.value(forKey: UserDefaultsKeys.notificationSound.rawValue) as? String ?? NotificationSound.radar.rawValue)!

            UserConfiguration.isCompactView = UserDefaults.standard.value(forKey: UserDefaultsKeys.isCompactView.rawValue) as? Bool ?? UserConfiguration.isCompactView

            UserConfiguration.darkModeStyle = UIUserInterfaceStyle(rawValue: UserDefaults.standard.value(forKey: UserDefaultsKeys.darkModeStyle.rawValue) as? Int ?? UIUserInterfaceStyle.unspecified.rawValue)!

            // MARK: Local Configuration

            LocalConfiguration.lastPause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastPause.rawValue) as? Date

            LocalConfiguration.lastUnpause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastUnpause.rawValue) as? Date

            LocalConfiguration.hasLoadedIntroductionViewControllerBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasLoadedIntroductionViewControllerBefore.rawValue) as? Bool ?? LocalConfiguration.hasLoadedIntroductionViewControllerBefore

            LocalConfiguration.reviewRequestDates = UserDefaults.standard.value(forKey: UserDefaultsKeys.reviewRequestDates.rawValue) as? [Date] ?? LocalConfiguration.reviewRequestDates

            LocalConfiguration.isShowTerminationAlert = UserDefaults.standard.value(forKey: UserDefaultsKeys.isShowTerminationAlert.rawValue) as? Bool ?? LocalConfiguration.isShowTerminationAlert

            LocalConfiguration.isShowReleaseNotes = UserDefaults.standard.value(forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue) as? Bool ?? LocalConfiguration.isShowReleaseNotes

            // termination checker
            if LocalConfiguration.isShowTerminationAlert == true && UIApplication.previousAppBuild == UIApplication.appBuild {

                AppDelegate.generalLogger.notice("App has not updated")

                do {
                    if let decoded: Data = UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as? Data {
                        AppDelegate.generalLogger.notice("Decoded dogManager for termination checker")

                        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: decoded)
                        unarchiver.requiresSecureCoding = false
                        let decodedDogManager: DogManager = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! DogManager

                        // sharedPlayer nil indicates the background silence is absent
                        // From there we perform checks to make sure the background silence should have been there
                        // If those check pass, it means the background silence's absense is due to the app terminating
                        if AudioManager.sharedPlayer == nil && UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotification && decodedDogManager.hasEnabledReminder && !UserConfiguration.isPaused {

                            AppDelegate.generalLogger.notice("Showing Termionation Alert")
                            let terminationAlertController = GeneralUIAlertController(title: "Oops, you may have terminated Hound", message: "Your notifications won't ring properly if the app isn't running.", preferredStyle: .alert)
                            let understandAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            let stopAlertAction = UIAlertAction(title: "Don't Show Again", style: .default) { _ in
                                LocalConfiguration.isShowTerminationAlert = false
                            }

                            terminationAlertController.addAction(understandAlertAction)
                            terminationAlertController.addAction(stopAlertAction)
                            AlertManager.shared.enqueueAlertForPresentation(terminationAlertController)
                        }
                        // }

                    }
                    else {
                        AppDelegate.generalLogger.error("Failed to decode dogManager for termination checker")
                    }
                }
                catch {
                    AppDelegate.generalLogger.error("Failed to unarchive dogManager for termination checker \(error.localizedDescription)")
                }

            }

            // new update, mutally exclusive from termnating alert
            if UIApplication.previousAppBuild != UIApplication.appBuild && LocalConfiguration.isShowReleaseNotes == true {
                AppDelegate.generalLogger.notice("Showing Release Notes")
                var message: String?

                switch UIApplication.appBuild {
                case 3048:
                    message = "--Added in-app, update release notes\n--Revised notification sound options (28->23). If your sound was removed then your sound choice was reset to the default\n--In the event of an app crash during the launch process, app data no longer resets\n--Expanded Settings page logic\n--Improved performance"
                case 3163:
                    message = "--If corrupted data is discovered while loading Hound, Hound now recovers itself instead of crashing\n--Improved crashes, Hound now displays error messages where previous crashes existed\n--Clarified certain error messages\n--Fixed certain spelling errors\n--Added this message!"
                case 3193:
                    message = "--Fixed days of week menu bug\n--Further improved crashes, converting them into error messages instead. No crashes have been detected as of version 1.3.2"
                case 3451:
                    message = "--Revised unarchiving of stored data, hopefully reducing corruption, data resets, and crashes.\n--Added intermittent pop-up to review Hound.\n--Integrated event logs to provide insight into crashes reports."
                case 3810:
                    message = "--Improved redundancy when unarchiving data"
                default:
                    message = nil
                }

                guard message != nil else {
                    return
                }

                let updateAlertController = GeneralUIAlertController(title: "Release Notes For Hound \(UIApplication.appVersion ?? String(UIApplication.appBuild))", message: message, preferredStyle: .alert)
                let understandAlertAction = UIAlertAction(title: "Ok, sounds great!", style: .default, handler: nil)
                let stopAlertAction = UIAlertAction(title: "Don't show release notes again", style: .default) { _ in
                    LocalConfiguration.isShowReleaseNotes = false
                }

                updateAlertController.addAction(understandAlertAction)
                updateAlertController.addAction(stopAlertAction)
                AlertManager.shared.enqueueAlertForPresentation(updateAlertController)
            }

        }
        else {
            // first time setup
            let data = DogManagerConstant.defaultDogManager
            let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            UserDefaults.standard.setValue(encodedData, forKey: UserDefaultsKeys.dogManager.rawValue)

            MainTabBarViewController.selectedEntryIndex = 0

            UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

            // MARK: User Configuration

            UserDefaults.standard.setValue(UserConfiguration.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)

            UserDefaults.standard.setValue(UserConfiguration.snoozeLength, forKey: UserDefaultsKeys.snoozeLength.rawValue)

            UserDefaults.standard.setValue(UserConfiguration.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.isLoudNotification, forKey: UserDefaultsKeys.isLoudNotification.rawValue)

            UserDefaults.standard.setValue(UserConfiguration.isFollowUpEnabled, forKey: UserDefaultsKeys.isFollowUpEnabled.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.followUpDelay, forKey: UserDefaultsKeys.followUpDelay.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.notificationSound.rawValue, forKey: UserDefaultsKeys.notificationSound.rawValue)

            UserDefaults.standard.setValue(UserConfiguration.isCompactView, forKey: UserDefaultsKeys.isCompactView.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.darkModeStyle.rawValue, forKey: UserDefaultsKeys.darkModeStyle.rawValue)

            // MARK: Local Configuration
            UserDefaults.standard.setValue(LocalConfiguration.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.hasLoadedIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedIntroductionViewControllerBefore.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.isShowTerminationAlert, forKey: UserDefaultsKeys.isShowTerminationAlert.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.isShowReleaseNotes, forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)

            MainTabBarViewController.firstTimeSetup = true
        }
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
            // dogManager
            // DogManagerEfficencyImprovement OK, Changes are being made that might not apply to the rest of the system, might be invalid, or might affect finding something
            var dataDogManager = MainTabBarViewController.staticDogManager.copy() as! DogManager
            dataDogManager.clearAllPresentationHandled()

            let encodedDataDogManager = try! NSKeyedArchiver.archivedData(withRootObject: dataDogManager, requiringSecureCoding: false)
            UserDefaults.standard.setValue(encodedDataDogManager, forKey: UserDefaultsKeys.dogManager.rawValue)

            // Pause State
            UserDefaults.standard.setValue(UserConfiguration.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)

            // Snooze interval

            UserDefaults.standard.setValue(UserConfiguration.snoozeLength, forKey: UserDefaultsKeys.snoozeLength.rawValue)

            // Notifications
            UserDefaults.standard.setValue(UserConfiguration.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.isLoudNotification, forKey: UserDefaultsKeys.isLoudNotification.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.isFollowUpEnabled, forKey: UserDefaultsKeys.isFollowUpEnabled.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.followUpDelay, forKey: UserDefaultsKeys.followUpDelay.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.notificationSound.rawValue, forKey: UserDefaultsKeys.notificationSound.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.isCompactView, forKey: UserDefaultsKeys.isCompactView.rawValue)
            UserDefaults.standard.setValue(UserConfiguration.darkModeStyle.rawValue, forKey: UserDefaultsKeys.darkModeStyle.rawValue)

            // Local
            UserDefaults.standard.setValue(LocalConfiguration.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.isShowTerminationAlert, forKey: UserDefaultsKeys.isShowTerminationAlert.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.isShowReleaseNotes, forKey: UserDefaultsKeys.isShowReleaseNotes.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.hasLoadedIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedIntroductionViewControllerBefore.rawValue)
            UserDefaults.standard.setValue(LocalConfiguration.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)
        }

        // ios notifications
        func handleNotifications() {
            AppDelegate.generalLogger.notice("handleNotifications")
            guard UserConfiguration.isNotificationAuthorized && UserConfiguration.isNotificationEnabled && !UserConfiguration.isPaused else {
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
                    Utils.willCreateUNUserNotification(dogName: dog.dogTraits.dogName, reminder: reminder)

                    if UserConfiguration.isFollowUpEnabled == true {
                        Utils.willCreateFollowUpUNUserNotification(dogName: dog.dogTraits.dogName, reminder: reminder)
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

        if UserConfiguration.isNotificationAuthorized && UserConfiguration.isNotificationEnabled == true {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }

    /// Checks to see if a change in notification permissions has occured, if it has then update to reflect
    static private func synchronizeNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:

                // going from off to on, meaning the user has gone into the settings app and turned notifications from disabled to enabled
                UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
                UserConfiguration.isNotificationAuthorized = true

            case .denied:
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isFollowUpEnabled.rawValue)
                UserConfiguration.isNotificationAuthorized = false
                UserConfiguration.isNotificationEnabled = false
                UserConfiguration.isFollowUpEnabled = false
                // Updates switch to reflect change, if the last view open was the settings page then the app is exitted and property changed in the settings app then this app is reopened, VWL will not be called as the settings page was already opened, weird edge case.
                DispatchQueue.main.async {
                    let settingsVC: SettingsViewController? = MainTabBarViewController.mainTabBarViewController.settingsViewController
                    if settingsVC != nil && settingsVC!.isViewLoaded {
                        settingsVC?.synchronizeAllNotificationSwitches(animated: false)
                    }
                }
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

    }
}
