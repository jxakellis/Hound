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
            TimingConstant.isPaused = UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as? Bool ?? TimingConstant.isPaused
            TimingConstant.lastPause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastPause.rawValue) as? Date
            TimingConstant.lastUnpause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastUnpause.rawValue) as? Date

            TimingConstant.defaultSnoozeLength = UserDefaults.standard.value(forKey: UserDefaultsKeys.defaultSnoozeLength.rawValue) as? TimeInterval ?? TimingConstant.defaultSnoozeLength

            NotificationConstant.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as? Bool ?? NotificationConstant.isNotificationAuthorized
            NotificationConstant.isNotificationEnabled = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as? Bool ?? NotificationConstant.isNotificationEnabled
            NotificationConstant.shouldLoudNotification = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldLoudNotification.rawValue) as? Bool ?? NotificationConstant.shouldLoudNotification
            NotificationConstant.shouldShowTerminationAlert = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldShowTerminationAlert.rawValue) as? Bool ?? NotificationConstant.shouldShowTerminationAlert
            NotificationConstant.shouldShowReleaseNotes = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldShowReleaseNotes.rawValue) as? Bool ?? NotificationConstant.shouldShowReleaseNotes
            NotificationConstant.shouldFollowUp = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldFollowUp.rawValue) as? Bool ?? NotificationConstant.shouldFollowUp
            NotificationConstant.followUpDelay = UserDefaults.standard.value(forKey: UserDefaultsKeys.followUpDelay.rawValue) as? TimeInterval ?? NotificationConstant.followUpDelay
            NotificationConstant.notificationSound = NotificationSound(rawValue: UserDefaults.standard.value(forKey: UserDefaultsKeys.notificationSound.rawValue) as? String ?? NotificationSound.radar.rawValue)!

            DogsNavigationViewController.hasBeenLoadedBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasBeenLoadedBefore.rawValue) as? Bool ?? DogsNavigationViewController.hasBeenLoadedBefore
            AppearanceConstant.isCompactView = UserDefaults.standard.value(forKey: UserDefaultsKeys.isCompactView.rawValue) as? Bool ?? AppearanceConstant.isCompactView

            AppearanceConstant.darkModeStyle = UIUserInterfaceStyle(rawValue: UserDefaults.standard.value(forKey: UserDefaultsKeys.darkModeStyle.rawValue) as? Int ?? UIUserInterfaceStyle.unspecified.rawValue)!
            AppearanceConstant.reviewRequestDates = UserDefaults.standard.value(forKey: UserDefaultsKeys.reviewRequestDates.rawValue) as? [Date] ?? AppearanceConstant.reviewRequestDates

            // termination checker
            if NotificationConstant.shouldShowTerminationAlert == true && UIApplication.previousAppBuild == UIApplication.appBuild {

                AppDelegate.generalLogger.notice("App has not updated")

                do {
                    if let decoded: Data = UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as? Data {
                        AppDelegate.generalLogger.notice("Decoded dogManager for termination checker")

                        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: decoded)
                        unarchiver.requiresSecureCoding = false
                        let decodedDogManager: DogManager = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! DogManager

                        // NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded!) as! DogManager

                        if AudioManager.sharedPlayer == nil && NotificationConstant.isNotificationEnabled && NotificationConstant.shouldLoudNotification && decodedDogManager.hasEnabledReminder && !TimingConstant.isPaused {
                            AppDelegate.generalLogger.notice("Showing Termionation Alert")
                            let terminationAlertController = GeneralUIAlertController(title: "Oops, you may have terminated Hound", message: "Your notifications won't ring properly if the app isn't running.", preferredStyle: .alert)
                            let understandAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            let stopAlertAction = UIAlertAction(title: "Don't Show Again", style: .default) { _ in
                                NotificationConstant.shouldShowTerminationAlert = false
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
            if UIApplication.previousAppBuild != UIApplication.appBuild && NotificationConstant.shouldShowReleaseNotes == true {
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
                    NotificationConstant.shouldShowReleaseNotes = false
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

            UserDefaults.standard.setValue(TimingConstant.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
            UserDefaults.standard.setValue(TimingConstant.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(TimingConstant.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)

            UserDefaults.standard.setValue(TimingConstant.defaultSnoozeLength, forKey: UserDefaultsKeys.defaultSnoozeLength.rawValue)

            UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

            UserDefaults.standard.setValue(NotificationConstant.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldLoudNotification, forKey: UserDefaultsKeys.shouldLoudNotification.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldShowTerminationAlert, forKey: UserDefaultsKeys.shouldShowTerminationAlert.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldShowReleaseNotes, forKey: UserDefaultsKeys.shouldShowReleaseNotes.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldFollowUp, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.followUpDelay, forKey: UserDefaultsKeys.followUpDelay.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.notificationSound.rawValue, forKey: UserDefaultsKeys.notificationSound.rawValue)

            UserDefaults.standard.setValue(DogsNavigationViewController.hasBeenLoadedBefore, forKey: UserDefaultsKeys.hasBeenLoadedBefore.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.isCompactView, forKey: UserDefaultsKeys.isCompactView.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.darkModeStyle.rawValue, forKey: UserDefaultsKeys.darkModeStyle.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)

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

            guard NotificationConstant.isNotificationEnabled && NotificationConstant.shouldLoudNotification && MainTabBarViewController.staticDogManager.hasEnabledReminder && !TimingConstant.isPaused else {
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
            UserDefaults.standard.setValue(TimingConstant.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
            UserDefaults.standard.setValue(TimingConstant.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(TimingConstant.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)

            // Snooze interval

            UserDefaults.standard.setValue(TimingConstant.defaultSnoozeLength, forKey: UserDefaultsKeys.defaultSnoozeLength.rawValue)

            // Notifications
            UserDefaults.standard.setValue(NotificationConstant.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldLoudNotification, forKey: UserDefaultsKeys.shouldLoudNotification.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldShowTerminationAlert, forKey: UserDefaultsKeys.shouldShowTerminationAlert.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldShowReleaseNotes, forKey: UserDefaultsKeys.shouldShowReleaseNotes.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldFollowUp, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.followUpDelay, forKey: UserDefaultsKeys.followUpDelay.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.notificationSound.rawValue, forKey: UserDefaultsKeys.notificationSound.rawValue)

            UserDefaults.standard.setValue(DogsNavigationViewController.hasBeenLoadedBefore, forKey: UserDefaultsKeys.hasBeenLoadedBefore.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.isCompactView, forKey: UserDefaultsKeys.isCompactView.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.darkModeStyle.rawValue, forKey: UserDefaultsKeys.darkModeStyle.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.reviewRequestDates, forKeyPath: UserDefaultsKeys.reviewRequestDates.rawValue)
        }

        // ios notifications
        func handleNotifications() {
            AppDelegate.generalLogger.notice("handleNotifications")
            guard NotificationConstant.isNotificationAuthorized && NotificationConstant.isNotificationEnabled && !TimingConstant.isPaused else {
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

                    if NotificationConstant.shouldFollowUp == true {
                        Utils.willCreateFollowUpUNUserNotification(dogName: dog.dogTraits.dogName, reminder: reminder)
                    }
                }
            }
            /*
             for dogKey in TimingManager.timerDictionary.keys{
             
             for reminderUUID in TimingManager.timerDictionary[dogKey]!.keys{
             guard TimingManager.timerDictionary[dogKey]![reminderUUID]!.isValid else{
             continue
             }
             Utils.willCreateUNUserNotification(dogName: dogKey, reminderUUID: reminderUUID, executionDate: TimingManager.timerDictionary[dogKey]![reminderUUID]!.fireDate)
             
             if NotificationConstant.shouldFollowUp == true {
             Utils.willCreateFollowUpUNUserNotification(dogName: dogKey, reminderUUID: reminderUUID, executionDate: TimingManager.timerDictionary[dogKey]![reminderUUID]!.fireDate + NotificationConstant.followUpDelay)
             }
             
             }
             }
             */
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

            /*
             // Checks for disconnects between what is displayed in the switches, what is stored in static variables and what is stored in user defaults
             AppDelegate.generalLogger.notice("shouldFollowUp \(NotificationConstant.shouldFollowUp) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldFollowUp.rawValue) as! Bool)")
             AppDelegate.generalLogger.notice("isAuthorized \(NotificationConstant.isNotificationAuthorized) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool)")
             AppDelegate.generalLogger.notice("isEnabled \(NotificationConstant.isNotificationEnabled) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool)")
             AppDelegate.generalLogger.notice("isPaused \(TimingConstant.isPaused) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as! Bool)")
             */
        }

    }

    static func willEnterForeground() {

        synchronizeNotificationAuthorization()

        if NotificationConstant.isNotificationAuthorized && NotificationConstant.isNotificationEnabled == true {
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
                if UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool == false {
                    // originally set notifications enabled for the user but decided against. let the user do it themself

                    // UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                    // UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
                    // NotificationConstant.isNotificationEnabled = true
                    // NotificationConstant.shouldFollowUp = true
                }

                UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
                NotificationConstant.isNotificationAuthorized = true

            case .denied:
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
                NotificationConstant.isNotificationAuthorized = false
                NotificationConstant.isNotificationEnabled = false
                NotificationConstant.shouldFollowUp = false
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
