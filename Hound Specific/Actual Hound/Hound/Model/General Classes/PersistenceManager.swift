//
//  PersistenceManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/16/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class PersistenceManager{
    ///Called by App or Scene Delegate when setting up in didFinishLaunchingWithOptions, can be either the first time setup or a recurring setup (i.e. not the app isnt being opened for the first time)
    static func willSetup(isRecurringSetup: Bool = false){
        
        if isRecurringSetup == true{
            //not first time setup
            TimingConstant.isPaused = UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as! Bool
            TimingConstant.lastPause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastPause.rawValue) as? Date
            TimingConstant.lastUnpause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastUnpause.rawValue) as? Date
            
            TimingConstant.defaultSnoozeLength = UserDefaults.standard.value(forKey: UserDefaultsKeys.defaultSnoozeLength.rawValue) as! TimeInterval
            
            NotificationConstant.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool
            NotificationConstant.isNotificationEnabled = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool
            NotificationConstant.shouldLoudNotification = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldLoudNotification.rawValue) as! Bool
            NotificationConstant.shouldShowTerminationAlert = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldShowTerminationAlert.rawValue) as? Bool ?? NotificationConstant.shouldShowTerminationAlert
            NotificationConstant.shouldFollowUp = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldFollowUp.rawValue) as! Bool
            NotificationConstant.followUpDelay = UserDefaults.standard.value(forKey: UserDefaultsKeys.followUpDelay.rawValue) as! TimeInterval
            NotificationConstant.notificationSound = NotificationSound(rawValue: UserDefaults.standard.value(forKey: UserDefaultsKeys.notificationSound.rawValue) as? String ?? NotificationSound.radar.rawValue)!
            
            
            DogsNavigationViewController.hasBeenLoadedBefore = UserDefaults.standard.value(forKey: UserDefaultsKeys.hasBeenLoadedBefore.rawValue) as! Bool
            AppearanceConstant.isCompactView = UserDefaults.standard.value(forKey: UserDefaultsKeys.isCompactView.rawValue) as! Bool
            
            AppearanceConstant.darkModeStyle = UIUserInterfaceStyle(rawValue: UserDefaults.standard.value(forKey: UserDefaultsKeys.darkModeStyle.rawValue) as? Int ?? UIUserInterfaceStyle.unspecified.rawValue)!
            
            
            //termination checker
            if NotificationConstant.shouldShowTerminationAlert == true && UIApplication.previousAppBuild == UIApplication.appBuild{
                NSLog("App has not updated")
                
                let decoded = UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as! Data
                let decodedDogManager = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! DogManager
                
                //correct conditions
                if AudioPlayer.sharedPlayer == nil && NotificationConstant.isNotificationEnabled && NotificationConstant.shouldLoudNotification && decodedDogManager.hasEnabledReminder && !TimingConstant.isPaused {
                    let terminationAlertController = GeneralUIAlertController(title: "Oops, you may have terminated Hound", message: "Your notifications won't ring properly if the app isn't running.", preferredStyle: .alert)
                    let acceptAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    let understandAlertAction = UIAlertAction(title: "Don't Show Again", style: .default) { _ in
                        NotificationConstant.shouldShowTerminationAlert = false
                    }
                    
                    terminationAlertController.addAction(acceptAlertAction)
                    terminationAlertController.addAction(understandAlertAction)
                    AlertPresenter.shared.enqueueAlertForPresentation(terminationAlertController)
                }
            }
            
            
        }
        
        else {
            //first time setup
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
            UserDefaults.standard.setValue(NotificationConstant.shouldFollowUp, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.followUpDelay, forKey: UserDefaultsKeys.followUpDelay.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.notificationSound.rawValue, forKey: UserDefaultsKeys.notificationSound.rawValue)
            
            UserDefaults.standard.setValue(DogsNavigationViewController.hasBeenLoadedBefore, forKey: UserDefaultsKeys.hasBeenLoadedBefore.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.isCompactView, forKey: UserDefaultsKeys.isCompactView.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.darkModeStyle.rawValue, forKey: UserDefaultsKeys.darkModeStyle.rawValue)
            
            MainTabBarViewController.firstTimeSetup = true
        }
    }
    
    ///Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func willEnterBackground(isTerminating: Bool = false){
        
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
        
        //background silence player for loud alarm that bypasses ringer and if phone locked
        func handleBackgroundSilence(){
            NSLog("handleBackgroundSilence")
            AudioPlayer.stopAudio()
            
            guard NotificationConstant.isNotificationEnabled && NotificationConstant.shouldLoudNotification && MainTabBarViewController.staticDogManager.hasEnabledReminder && !TimingConstant.isPaused else{
                return
            }
            
            AudioPlayer.playSilenceAudio()

        }
        
        //saves to user defaults
        func handleUserDefaults(){
            NSLog("handleUserDefaults")
            //dogManager
            //DogManagerEfficencyImprovement OK, Changes are being made that might not apply to the rest of the system, might be invalid, or might affect finding something
            var dataDogManager = MainTabBarViewController.staticDogManager.copy() as! DogManager
            dataDogManager.clearAllPresentationHandled()
            
            let encodedDataDogManager = try! NSKeyedArchiver.archivedData(withRootObject: dataDogManager, requiringSecureCoding: false)
            UserDefaults.standard.setValue(encodedDataDogManager, forKey: UserDefaultsKeys.dogManager.rawValue)
                        
            //Pause State
            UserDefaults.standard.setValue(TimingConstant.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
            UserDefaults.standard.setValue(TimingConstant.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(TimingConstant.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
            
            //Snooze interval
            
            UserDefaults.standard.setValue(TimingConstant.defaultSnoozeLength, forKey: UserDefaultsKeys.defaultSnoozeLength.rawValue)
            
            //Notifications
            UserDefaults.standard.setValue(NotificationConstant.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldLoudNotification, forKey: UserDefaultsKeys.shouldLoudNotification.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldShowTerminationAlert, forKey: UserDefaultsKeys.shouldShowTerminationAlert.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.shouldFollowUp, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.followUpDelay, forKey: UserDefaultsKeys.followUpDelay.rawValue)
            UserDefaults.standard.setValue(NotificationConstant.notificationSound.rawValue, forKey: UserDefaultsKeys.notificationSound.rawValue)
            
            UserDefaults.standard.setValue(DogsNavigationViewController.hasBeenLoadedBefore, forKey: UserDefaultsKeys.hasBeenLoadedBefore.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.isCompactView, forKey: UserDefaultsKeys.isCompactView.rawValue)
            UserDefaults.standard.setValue(AppearanceConstant.darkModeStyle.rawValue, forKey: UserDefaultsKeys.darkModeStyle.rawValue)
        }
        
        //ios notifications
        func handleNotifications(){
            NSLog("handleNotifications")
            guard NotificationConstant.isNotificationAuthorized && NotificationConstant.isNotificationEnabled && !TimingConstant.isPaused else {
                return
            }
            NSLog("handleNotifications passed guard statement")
            
            //remove duplicate notifications if app is backgrounded then terminated
            
               UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
            for dog in MainTabBarViewController.staticDogManager.dogs{
                for reminder in dog.dogReminders.reminders{
                    guard reminder.timer?.isValid == true else{
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
        
        if isTerminating == true  {
            //this is only called if the app is DIRECTlY terminated (not background then terminated). If this happens then we can just skips background silence (termination kills it anyways)
            handleUserDefaults()
            
            handleNotifications()
        }
        
        else {
            handleBackgroundSilence()
            
            handleUserDefaults()
            
            handleNotifications()
            
            /*
             // Checks for disconnects between what is displayed in the switches, what is stored in static variables and what is stored in user defaults
             NSLog("shouldFollowUp \(NotificationConstant.shouldFollowUp) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldFollowUp.rawValue) as! Bool)")
             NSLog("isAuthorized \(NotificationConstant.isNotificationAuthorized) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool)")
             NSLog("isEnabled \(NotificationConstant.isNotificationEnabled) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool)")
             NSLog("isPaused \(TimingConstant.isPaused) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as! Bool)")
             */
        }
        
    }
    
    static func willEnterForeground(){
        
        synchronizeNotificationAuthorization()
        
        if NotificationConstant.isNotificationAuthorized && NotificationConstant.isNotificationEnabled == true{
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    ///Checks to see if a change in notification permissions has occured, if it has then update to reflect
    static private func synchronizeNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                
                //going from off to on, meaning the user has gone into the settings app and turned notifications from disabled to enabled
                if UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool == false {
                    //originally set notifications enabled for the user but decided against. let the user do it themself
                    
                    //UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                    //UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
                    //NotificationConstant.isNotificationEnabled = true
                    //NotificationConstant.shouldFollowUp = true
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
                //Updates switch to reflect change, if the last view open was the settings page then the app is exitted and property changed in the settings app then this app is reopened, VWL will not be called as the settings page was already opened, weird edge case.
                DispatchQueue.main.async {
                    let settingsVC: SettingsViewController? = MainTabBarViewController.mainTabBarViewController.settingsViewController
                    if settingsVC != nil && settingsVC!.isViewLoaded {
                        settingsVC?.synchronizeAllNotificationSwitches(animated: false)
                    }
                }
            case .notDetermined:
                NSLog(".notDetermined")
            case .provisional:
                NSLog(".provisional")
            case .ephemeral:
                NSLog(".ephemeral")
            @unknown default:
                NSLog("unknown auth status")
            }
        }
        
        
    }
}


