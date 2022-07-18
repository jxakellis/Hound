//
//  LocalConfiguration.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Configuration that is local to the app only. If the app is reinstalled then this data should be fresh
enum LocalConfiguration {
    
    // MARK: Sync Related
    
    // For our first every dogManager sync, we want to retrieve ever dog, reminder, and log (which can be a LOT of data as accounts accumlate logs over the years). To get everything the family has ever added, we set our last sync as far back in time as it will go. This will retrieve everything
    static var lastDogManagerSynchronization: Date = LocalConfiguration.defaultLastDogManagerSynchronization
    
    static var defaultLastDogManagerSynchronization: Date {
        return Date(timeIntervalSince1970: 1234567890)
    }
    
    // MARK: Dog Related
    
    /// This stores the icons for the dogs locally. If a dog is succesfully POST, PUT, or DELETE then we update this dictionary, otherwise it remains untouched.
    static var dogIcons: [LocalDogIcon] = []
    
    // MARK: Log Related
    
    /// An array storing the logCustomActionName input by the user. If the user selects a log as 'Custom' then puts in a custom name, it will be tracked here.
    static var logCustomActionNames: [String] = []
    
    /// Add the custom log action name to the stored array of logCustomActionNames. If it is already present, then nothing changes, otherwise override the oldest one
    static func addLogCustomAction(forName name: String) {
        
        // make sure the name actually contains something
        guard name.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            return
        }
        
        if logCustomActionNames.contains(name) == true {
            // logCustomActionNames contains the name
            // We should remove the name then re add it, making it as new as possible
            
            logCustomActionNames.removeAll { string in
                // if string == true, then return true to indicate that we want to remove it
                return string == name
            }
            // now re add the string so its fresh
            logCustomActionNames.insert(name, at: 0)
        }
        else {
            // logCustomActionNames does not contain the name
            
            // insert the new name
            logCustomActionNames.insert(name, at: 0)
            
            // check to see if we are over capacity, if we are then remove the last item
            if logCustomActionNames.count > 3 {
                logCustomActionNames.removeLast()
            }
        }
    }
    
    // MARK: Reminder Related
    
    /// An array storing the reminderCustomActionNames input by the user. If the user selects a reminder as 'Custom' then puts in a custom name, it will be tracked here.
    static var reminderCustomActionNames: [String] = []
    
    /// Add the custom reminder action name to the stored array of reminderCustomActionNames. If it is already present, then nothing changes, otherwise override the oldest one
    static func addReminderCustomAction(forName name: String) {
        
        // make sure the name actually contains something
        guard name.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            return
        }
        
        if reminderCustomActionNames.contains(name) == true {
            // reminderCustomActionNames contains the name
            // We should remove the name then re add it, making it as new as possible
            
            reminderCustomActionNames.removeAll { string in
                // if string == true, then return true to indicate that we want to remove it
                return string == name
            }
            // now re add the string so its fresh
            reminderCustomActionNames.insert(name, at: 0)
        }
        else {
            // reminderCustomActionNames does not contain the name
            
            // insert the new name
            reminderCustomActionNames.insert(name, at: 0)
            
            // check to see if we are over capacity, if we are then remove the last item
            if reminderCustomActionNames.count > 3 {
                reminderCustomActionNames.removeLast()
            }
        }
    }
    
    // MARK: iOS Notification Related
    
    static var isNotificationAuthorized: Bool = false
    
    // MARK: Alert Related
    
    /// Used to track when the user was last asked to review the app. We add a Date() to the array by default to signify when the app was installed (or the update for this feature was installed)
    static var userAskedToReviewHoundDates: [Date] = [Date()]
    
   /// Used to track when the user was shown Apple's request review pop-up that allows the user to one to five star Hound
    static var rateReviewRequestedDates: [Date] = []
    
    /// Used to track when the user was shown a URL page pop-up  that allows the user to write a review on HoundHound
    static var writeReviewRequestedDates: [Date] = []
    
    /// Determines where or not the app should display an message when the app is first opened after an update
    static var shouldShowReleaseNotes: Bool = true
    
    /// Keeps track of what Hound versions the release notes have been shown for. For example, if we show the release notes for Hound 2.0.0 Build 4000, then we will store 4000 in the array. This makes sure the release notes are only shown once for a given update
    static var appBuildsWithReleaseNotesShown: [Int] = []
    
    /// Keeps track of if the user has viewed AND completed the family introduction view controller (which helps the user setup their first dog)
    static var hasLoadedFamilyIntroductionViewControllerBefore: Bool = false
    
    /// Keeps track of if the user has viewed AND completed the reminders introduction view controller (which helps the user setup their first reminders)
    static var hasLoadedRemindersIntroductionViewControllerBefore: Bool = false
    
    /// Keeps track of if the user has viewed AND completed the settings family introduction view controller (which helps notify the user of their family limits)
    static var hasLoadedSettingsFamilyIntroductionViewControllerBefore: Bool = false
}

extension LocalConfiguration {
    // MARK: Functions
    
    /// Resets the values of certain LocalConfiguration variables for when a user is joining a new family. These are certain local configurations that just control some basic user experience things, so can be modified.
    static func resetForNewFamily() {
        // We write these changes to storage immediately. If not, could cause funky issues if not persisted. For example: the dogs from user's old family would combine client side with dogs of new family, but this would only be client-side. Those dogs wouldn't actually exist on the server and would be bugged.
        
        // MARK: User Inforamtion
        
        UserInformation.familyId = nil
        UserDefaults.standard.setValue(UserInformation.familyId, forKey: ServerDefaultKeys.familyId.rawValue)
        
        // MARK: Local Configuration
        
        LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = false
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedFamilyIntroductionViewControllerBefore.rawValue)
        
        LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = false
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedRemindersIntroductionViewControllerBefore.rawValue)
        
        LocalConfiguration.hasLoadedSettingsFamilyIntroductionViewControllerBefore = false
        UserDefaults.standard.setValue(LocalConfiguration.hasLoadedSettingsFamilyIntroductionViewControllerBefore, forKey: UserDefaultsKeys.hasLoadedSettingsFamilyIntroductionViewControllerBefore.rawValue)
        
        LocalConfiguration.lastDogManagerSynchronization = LocalConfiguration.defaultLastDogManagerSynchronization
        UserDefaults.standard.set(LocalConfiguration.lastDogManagerSynchronization, forKey: ServerDefaultKeys.lastDogManagerSynchronization.rawValue)
        
        LocalConfiguration.dogIcons = []
        if let dataDogIcons = try? NSKeyedArchiver.archivedData(withRootObject: LocalConfiguration.dogIcons, requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogIcons, forKey: UserDefaultsKeys.dogIcons.rawValue)
        }
        
        // reset local dogManager to blank to clear what was saved from the last
        if let dataDogManager = try? NSKeyedArchiver.archivedData(withRootObject: DogManager(), requiringSecureCoding: false) {
            UserDefaults.standard.set(dataDogManager, forKey: ServerDefaultKeys.dogManager.rawValue)
        }
    }
}
