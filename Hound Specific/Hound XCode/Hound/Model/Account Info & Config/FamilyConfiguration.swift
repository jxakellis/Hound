//
//  FamilyConfiguration.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Configuration that is local to the app only. If the app is reinstalled then this data should be pulled down from the cloud
enum FamilyConfiguration {
    
    // MARK: - Ordered List
    // familyCode
    // isLocked
    //
    
    // MARK: - Main
    
    /// Sets the FamilyConfiguration values equal to all the values found in the body. The key for the each body value must match the name of the FamilyConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: Any]) {
        if let isLocked = body[ServerDefaultKeys.isLocked.rawValue] as? Bool {
            self.isLocked = isLocked
        }
        if let familyCode = body[ServerDefaultKeys.familyCode.rawValue] as? String {
            self.familyCode = familyCode
        }
        if let isPaused = body[ServerDefaultKeys.isPaused.rawValue] as? Bool {
            self.isPaused = isPaused
        }
        if let lastPause = body[ServerDefaultKeys.lastPause.rawValue] as? String {
            self.lastPause = ResponseUtils.dateFormatter(fromISO8601String: lastPause)
        }
        if let lastUnpause = body[ServerDefaultKeys.lastPause.rawValue] as? String {
            self.lastUnpause = ResponseUtils.dateFormatter(fromISO8601String: lastUnpause)
        }
    }
    
    // MARK: - Main
    
    /// The code used by new users to join the family
    static var familyCode: String = ""
    
    /// If a family is locked, then no new members can join. Only the family head can lock and unlock the family.
    static var isLocked: Bool = false
    
    /// Saves state isPaused, self.isPaused can be modified by SettingsViewController but this is only when there are no active timers and pause is automatically set to unpaused
    static var isPaused: Bool = false
    
    /// Saves date of last pause (if there was one). App needs this to perform calculations for pausing / unpausing reminders as it can be exited and lose track of time.
    static var lastPause: Date?
    
    /// Saves date of last unpause (if there was one). App needs this to perform calculations for pausing / unpausing reminders as it can be exited and lose track of time.
    static var lastUnpause: Date?
}
