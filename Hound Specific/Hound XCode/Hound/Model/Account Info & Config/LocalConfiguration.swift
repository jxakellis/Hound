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
    
    // TO DO import certain variables from Hound 1.3.5 that are immutable to me (e.g. notificationAuthorized and reviewRequestDates) as Apple doesn't care that the app reset so the original values need to be tracked
    // open up Hound 1.3.5 and find their original names to import
    
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
    
    /// Used to track when the user was last asked to review the app
    static var reviewRequestDates: [Date] = [Date()]
    
    /// Determines where or not the app should display an message when the app is first opened after an update
    static var isShowReleaseNotes: Bool = true
    
    /// Keeps track of if the user has viewed AND completed the family introduction view controller (which helps the user setup their first dog)
    static var hasLoadedFamilyIntroductionViewControllerBefore: Bool = false
    
    /// Keeps track of if the user has viewed AND completed the reminders introduction view controller (which helps the user setup their first reminders)
    static var hasLoadedRemindersIntroductionViewControllerBefore: Bool = false
    
}
