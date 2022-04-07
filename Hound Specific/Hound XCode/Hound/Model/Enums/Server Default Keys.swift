//
//  Server Default Keys.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ServerDefaultsKeys: String {
    
    // MARK: User Information
    
    case userIdentifier
    case userEmail
    case userFirstName
    case userLastName
    
    // MARK: User Configuration
    
    case isCompactView
    case interfaceStyle
    case snoozeLength
    case isPaused
    case isNotificationAuthorized
    case isNotificationEnabled
    case isLoudNotification
    case isFollowUpEnabled
    case followUpDelay
    case notificationSound
    
    // MARK: Dog
    
    case dogName
    
    // MARK: Logs
    
    case logs
    
    // MARK: Log
    
    case logAction
    // TO DO differentiate between log and reminder customActionName
    case customActionName
    case logDate
    case logNote
    
    // MARK: Reminders
    
    case reminders
    
    // MARK: Reminder
    
    case reminderId
    case reminderAction
    // case customActionName
    case executionBasis
    case isEnabled
    case reminderType
    
    // MARK: Countdown Components
    
    case countdownExecutionInterval
    case countdownIntervalElapsed
    
    // MARK: Weekly Components
    
    case weeklyHour
    case weeklyMinute
    case weeklyIsSkipping
    case weeklyIsSkippingDate
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    // MARK: Monthly Components
    
    case monthlyHour
    case monthlyMinute
    case monthlyIsSkipping
    case monthlyIsSkippingDate
    case dayOfMonth
    
    // MARK: One Time Components
    
    case oneTimeDate
}
