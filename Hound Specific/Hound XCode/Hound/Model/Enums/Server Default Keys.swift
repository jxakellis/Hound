//
//  Server Default Keys.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ServerDefaultKeys: String {
    
    // MARK: Response Body
    
    case result
    case message
    case code
    case name
    
    // MARK: Family Information & Members
    
    case familyIsLocked
    case familyCode
    case familyMembers
    case isFamilyHead
    
    // MARK: User Information
    
    case familyId
    case userIdentifier
    case userNotificationToken
    case userId
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
    
    case dogId
    case dogName
    
    // MARK: Logs
    
    case logs
    
    // MARK: Log
    
    case logId
    case logAction
    case logCustomActionName
    case logDate
    case logNote
    
    // MARK: Reminders
    
    case reminders
    
    // MARK: Reminder
    
    case reminderId
    case reminderAction
    case reminderCustomActionName
    case reminderType
    case reminderExecutionBasis
    case reminderExecutionDate
    case reminderIsEnabled
    
    // MARK: Snooze Components
    
    case snoozeIsEnabled
    case snoozeExecutionInterval
    case snoozeIntervalElapsed
    
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
    case monthlyDay
    
    // MARK: One Time Components
    
    case oneTimeDate
}
