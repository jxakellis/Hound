//
//  Persistence.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 4/16/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Persistence{
    ///Called by App or Scene Delegate when setting up in didFinishLaunchingWithOptions, can be either the first time setup or a recurring setup (i.e. not the app isnt being opened for the first time)
    static func willSetup(isRecurringSetup: Bool = false){
        if isRecurringSetup == true{
            //not first time setup
            TimingManager.isPaused = UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as! Bool
            TimingManager.lastPause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastPause.rawValue) as? Date
            TimingManager.lastUnpause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastUnpause.rawValue) as? Date
            
           TimerConstant.defaultSnooze = UserDefaults.standard.value(forKey: UserDefaultsKeys.defaultSnooze.rawValue) as! TimeInterval
            
            NotificationConstant.shouldFollowUp = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldFollowUp.rawValue) as! Bool
            NotificationConstant.followUpDelay = UserDefaults.standard.value(forKey: UserDefaultsKeys.followUpDelay.rawValue) as! TimeInterval
            NotificationConstant.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool
            NotificationConstant.isNotificationEnabled = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool
        }
        
        else {
            //first time setup
            let data = DogManagerConstant.defaultDogManager
            let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            UserDefaults.standard.setValue(encodedData, forKey: UserDefaultsKeys.dogManager.rawValue)
            
            MainTabBarViewController.selectedEntryIndex = 2
            
            UserDefaults.standard.setValue(TimingManager.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
            UserDefaults.standard.setValue(TimingManager.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(TimingManager.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
            
            UserDefaults.standard.setValue(TimerConstant.defaultSnooze, forKey: UserDefaultsKeys.defaultSnooze.rawValue)
            
            UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            
            
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, error) in
                UserDefaults.standard.setValue(isGranted, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
                UserDefaults.standard.setValue(isGranted, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                UserDefaults.standard.setValue(isGranted, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
                NotificationConstant.isNotificationAuthorized = isGranted
                NotificationConstant.isNotificationEnabled = isGranted
                NotificationConstant.shouldFollowUp = isGranted
            }
            
            UserDefaults.standard.setValue(NotificationConstant.followUpDelay, forKey: "followUpDelay")
            
        }
    }
    
    ///Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func willEnterBackground(isTerminating: Bool = false){
        
        //dogManager
        //DogManagerEfficencyImprovement OK, Changes are being made that might not apply to the rest of the system, might be invalid, or might affect finding something
        var dataDogManager = MainTabBarViewController.staticDogManager.copy() as! DogManager
        dataDogManager.clearAllPresentationHandled()
        
        let encodedDataDogManager = try! NSKeyedArchiver.archivedData(withRootObject: dataDogManager, requiringSecureCoding: false)
         UserDefaults.standard.setValue(encodedDataDogManager, forKey: UserDefaultsKeys.dogManager.rawValue)
        
        //Pause State
        UserDefaults.standard.setValue(TimingManager.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
        UserDefaults.standard.setValue(TimingManager.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
        UserDefaults.standard.setValue(TimingManager.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
        
        //Snooze interval
        
        UserDefaults.standard.setValue(TimerConstant.defaultSnooze, forKey: UserDefaultsKeys.defaultSnooze.rawValue)
        
        //Notifications
        
        UserDefaults.standard.setValue(NotificationConstant.shouldFollowUp, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
        UserDefaults.standard.setValue(NotificationConstant.followUpDelay, forKey: UserDefaultsKeys.followUpDelay.rawValue)
        UserDefaults.standard.setValue(NotificationConstant.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
        UserDefaults.standard.setValue(NotificationConstant.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
        
        //notification on off and authorization
        //SettingsVC.ISN and .ISA are both calculated properties so no need to update.
       // UserDefaults.standard.setValue(SettingsViewController.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
        //UserDefaults.standard.setValue(SettingsViewController.isNotificationAuthorized, forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue)
        
        if isTerminating == true  {
            
        }
        
        else {
            
            
            /*
            // Checks for disconnects between what is displayed in the switches, what is stored in static variables and what is stored in user defaults
            print("shouldFollowUp \(NotificationConstant.shouldFollowUp) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldFollowUp.rawValue) as! Bool)")
            print("isAuthorized \(NotificationConstant.isNotificationAuthorized) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool)")
            print("isEnabled \(NotificationConstant.isNotificationEnabled) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool)")
            print("isPaused \(TimingManager.isPaused) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as! Bool)")
             */
             
            
            if NotificationConstant.isNotificationAuthorized && NotificationConstant.isNotificationEnabled && !TimingManager.isPaused {
                for dogKey in TimingManager.timerDictionary.keys{
                    
                    for requirementKey in TimingManager.timerDictionary[dogKey]!.keys{
                        guard TimingManager.timerDictionary[dogKey]![requirementKey]!.isValid else{
                            continue
                        }
                        
                        Utils.willCreateUNUserNotification(dogName: dogKey, requirementName: requirementKey, executionDate: TimingManager.timerDictionary[dogKey]![requirementKey]!.fireDate)
                        if NotificationConstant.shouldFollowUp == true {
                            Utils.willCreateFollowUpUNUserNotification(dogName: dogKey, requirementName: requirementKey, executionDate: TimingManager.timerDictionary[dogKey]![requirementKey]!.fireDate + NotificationConstant.followUpDelay)
                        }
                        
                     }
                }
            }
            /*
             pending notif checker
            print("current date \(Date())")
             UNUserNotificationCenter.current().getPendingNotificationRequests { (notifs) in
                for notif in notifs{
                    print("\(notif.content.title)  \(notif.content.body)   \(notif.trigger?.description)")
                }
            }
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
                    UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                    UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
                    NotificationConstant.isNotificationEnabled = true
                    NotificationConstant.shouldFollowUp = true
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
                        settingsVC?.refreshNotificationSwitches(animated: false)
                    }
                }
            case .notDetermined:
                print(".notDetermined")
            case .provisional:
                print(".provisional")
            case .ephemeral:
                print(".ephemeral")
            @unknown default:
                print("unknown auth status")
            }
        }
        
       
    }
}
