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
    // isCompactView
    // interfaceStyle
    // snoozeLength
    // isPaused
    // isNotificationAuthorized
    // isNotificationEnabled
    // isLoudNotification
    // isFollowUpEnabled
    // followUpDelay
    // notificationSound
    
    // MARK: - Main
    
    /// Sets the FamilyConfiguration values equal to all the values found in the body. The key for the each body value must match the name of the FamilyConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: Any]) {
        if let isLocked = body[ServerDefaultKeys.familyIsLocked.rawValue] as? Bool {
            storedIsLocked = isLocked
        }
        if let familyCode = body[ServerDefaultKeys.familyCode.rawValue] as? String {
            storedFamilyCode = familyCode
        }
    }
    
    // MARK: - Main
    
    static private var storedFamilyCode: String = ""
    /// The code used by new users to join the family
    static var familyCode: String {
        get {
            return storedFamilyCode
        }
        set (newFamilyCode) {
            guard newFamilyCode != storedFamilyCode else {
                return
            }
            storedFamilyCode = newFamilyCode
        }
    }
    
    static private var storedIsLocked: Bool = true
    /// If a family is locked, then no new members can join. Only the family head can lock and unlock the family.
    static var isLocked: Bool {
        get {
            return storedIsLocked
        }
        set (newIsLocked) {
            guard newIsLocked != storedIsLocked else {
                return
            }
            storedIsLocked = newIsLocked
        }
    }
    
}
