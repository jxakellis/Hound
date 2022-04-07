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
    
    // store userId and familyId locally so it makes it easier for the user to login
    case userId
    case familyId
    
    // the rest are exclusively server, so no user defaults
    
    // MARK: User Configuration
    
    // all stored in server, so no user defaults
    
    // MARK: Local Configuration
    
    case dogIcons
    case isNotificationAuthorized
    case lastPause
    case lastUnpause
    case reviewRequestDates
    case isShowTerminationAlert
    case isShowReleaseNotes
    case hasLoadedIntroductionViewControllerBefore
    case hasLoadedRemindersIntroductionViewControllerBefore
    
    // MARK: Other
    case hasDoneFirstTimeSetup
    case appBuild
}
