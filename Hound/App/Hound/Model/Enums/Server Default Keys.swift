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
    
    case familyMembers
    case isFamilyHead
    
    case dogManager
    
    case familyCode
    case isLocked
    case isPaused
    case kickUserId
    case activeSubscription
    
    // MARK: User Information
    
    case familyId
    case userIdentifier
    case userNotificationToken
    case userId
    case userEmail
    case userFirstName
    case userLastName
    
    // MARK: User Configuration
    
    case logsInterfaceScale
    case remindersInterfaceScale
    case interfaceStyle
    case snoozeLength
    case isNotificationAuthorized
    case isNotificationEnabled
    case isLoudNotification
    case isFollowUpEnabled
    case followUpDelay
    case notificationSound
    
    // MARK: Purchase
    case base64EncodedAppStoreReceiptURL
    
    case transactionId
    case productId
    case subscriptionPurchaseDate
    case subscriptionExpiration
    case subscriptionNumberOfFamilyMembers
    case subscriptionNumberOfDogs
    case subscriptionIsActive
    
    // MARK: - Special Local Configuration
    
    case lastDogManagerSynchronization
    
    // MARK: Dog
    
    case dogId
    case dogName
    case dogIsDeleted
    
    // MARK: Logs
    
    case logs
    
    // MARK: Log
    
    case logId
    case logAction
    case logCustomActionName
    case logDate
    case logNote
    case logIsDeleted
    
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
    case reminderIsDeleted
    
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
    case weeklySunday
    case weeklyMonday
    case weeklyTuesday
    case weeklyWednesday
    case weeklyThursday
    case weeklyFriday
    case weeklySaturday
    case weeklyIsSkipping
    case weeklyIsSkippingDate
    
    // MARK: Monthly Components
    
    case monthlyDay
    case monthlyHour
    case monthlyMinute
    case monthlyIsSkipping
    case monthlyIsSkippingDate
    
    // MARK: One Time Components
    
    case oneTimeDate
}
