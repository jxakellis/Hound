//
//  UserDefaultKeys.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/31/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum UserDefaultsKeys: String {
    
    // MARK: User Information
    
    case userId
    case userIdentifier
    case userEmail
    case userFirstName
    case userLastName
    
    // MARK: User Configuration
    
    // Appearance
    case isCompactView
    case interfaceStyle
    
    // Timing
    case isPaused
    case snoozeLength
    
    // Notifications
    case isNotificationAuthorized
    case isNotificationEnabled
    case isLoudNotification
    case isFollowUpEnabled
    case followUpDelay
    case notificationSound
    
    // MARK: Local Configuration
    
    case lastPause
    case lastUnpause
    case reviewRequestDates
    case isShowTerminationAlert
    case isShowReleaseNotes
    case hasLoadedIntroductionViewControllerBefore
    case hasLoadedRemindersIntroductionViewControllerBefore
    
    // MARK: Other
    case hasDoneFirstTimeSetup
    case dogManager
    case appBuild
}
