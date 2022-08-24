//
//  Dog Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ClassConstant {
    
    enum SubscriptionConstant {
        static var defaultSubscription: Subscription { return Subscription(transactionId: nil, product: defaultSubscriptionProduct, purchaseDate: nil, expirationDate: nil, numberOfFamilyMembers: defaultSubscriptionNumberOfFamilyMembers, numberOfDogs: defaultSubscriptionNumberOfDogs, isActive: true, isAutoRenewing: true) }
        static let defaultSubscriptionProduct = InAppPurchaseProduct.default
        static let defaultUnknownProduct = InAppPurchaseProduct.unknown
        static let defaultSubscriptionNumberOfFamilyMembers = 1
        static let defaultSubscriptionSpelledOutNumberOfFamilyMembers = "one"
        static let defaultSubscriptionNumberOfDogs = 2
        static let defaultSubscriptionSpelledOutNumberOfDogs = "two"
    }
    
    enum DogConstant {
        static let defaultDogName: String = "Bella"
        static let defaultDogIcon: UIImage = UIImage.init(named: "whitePawWithHands") ?? UIImage()
        static let defaultDogId: Int = -1
        static let chooseImageForDog: UIImage = UIImage.init(named: "chooseImageForDog") ?? UIImage()
        static let dogNameCharacterLimit: Int = 32
    }
    
    enum LogConstant {
        static let defaultLogId: Int = -1
        static var defaultUserId: String {
            return UserInformation.userId ?? EnumConstant.HashConstant.defaultSHA256Hash
        }
        static let defaultLogAction = LogAction.feed
        static let defaultLogCustomActionName: String? = nil
        static let defaultLogNote: String = ""
        static var defaultLogDate: Date { return Date() }
        /// when looking to unskip a reminder, we look for a log that has its time unmodified. if its logDate within a certain percision of the skipdate, then we assume that log is from that reminder skipping.
        static let logRemovalPrecision: Double = 0.025
        static let logCustomActionNameCharacterLimit: Int = 32
        static let logNoteCharacterLimit: Int = 500
    }
    
    enum ReminderConstant {
        static let defaultReminderId: Int = -1
        static let defaultReminderAction = ReminderAction.feed
        static let defaultReminderCustomActionName: String? = nil
        static let defaultReminderType = ReminderType.countdown
        static var defaultReminderExecutionBasis: Date { return Date() }
        static let defaultReminderIsEnabled = true
        static let reminderCustomActionNameCharacterLimit: Int = 32
        static var defaultReminders: [Reminder] {
            return [ defaultReminderOne, defaultReminderTwo, defaultReminderThree, defaultReminderFour ]
        }
        private static var defaultReminderOne: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .potty
            reminder.reminderType = .countdown
            reminder.countdownComponents.executionInterval = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
            return reminder
        }
        private static var defaultReminderTwo: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .feed
            reminder.reminderType = .weekly
            var date = Date()
            // 7:00 AM local time
            date = Calendar.current.date(bySettingHour: ReminderComponentConstant.defaultLocalizedUTCHour, minute: ReminderComponentConstant.defaultLocalizedUTCMinute, second: 0, of: date) ?? DateConstant.default1970Date
            // Change reminder to noon UTC
            reminder.weeklyComponents.changeUTCHour(forDate: date)
            reminder.weeklyComponents.changeUTCMinute(forDate: date)
            return reminder
        }
        private static var defaultReminderThree: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .feed
            reminder.reminderType = .weekly
            var date = Date()
            // 5:00 PM local time
            date = Calendar.current.date(bySettingHour: (ReminderComponentConstant.defaultLocalizedUTCHour + 10) % 24, minute: ReminderComponentConstant.defaultLocalizedUTCMinute, second: 0, of: date) ?? DateConstant.default1970Date
            return reminder
        }
        private static var defaultReminderFour: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .medicine
            reminder.reminderType = .monthly
            var date = Date()
            date = Calendar.current.date(bySetting: .month, value: ReminderComponentConstant.defaultLocalizedUTCDay, of: date) ?? DateConstant.default1970Date
            date = Calendar.current.date(bySettingHour: (ReminderComponentConstant.defaultLocalizedUTCHour + 2) % 24, minute: ReminderComponentConstant.defaultLocalizedUTCMinute, second: 0, of: date) ?? DateConstant.default1970Date
            reminder.monthlyComponents.changeUTCDay(forDate: date)
            reminder.monthlyComponents.changeUTCHour(forDate: date)
            reminder.monthlyComponents.changeUTCMinute(forDate: date)
            return reminder
        }
    }
    
    enum ReminderComponentConstant {
        static let defaultCountdownExecutionInterval: TimeInterval = 1800
        static var defaultLocalizedUTCDay: Int {
            return 1
        }
        /// We want the default reminder to be 7:00 am in the user's time zone. However, we go off UTC time. Therefore, adjust the UTCHour so it represents 7:00 am in their local time.
        static var defaultLocalizedUTCHour: Int {
            // Want the default UTC Hour to be
            let defaultUTCHour = 7
            
            let hoursFromUTC = Int(Calendar.current.timeZone.secondsFromGMT() / 3600)
            
            var defaultLocalizedUTCHour = defaultUTCHour + hoursFromUTC
            // Verify defaultLocalizedUTCHour >= 0
            if defaultLocalizedUTCHour < 0 {
                defaultLocalizedUTCHour += 24
            }
            
            // Verify defaultLocalizedUTCHour <= 23
            if defaultLocalizedUTCHour > 23 {
                defaultLocalizedUTCHour = defaultLocalizedUTCHour % 24
            }
            
            return defaultLocalizedUTCHour
        }
        
        /// We want the default reminder to be 7:00 am in the user's time zone. However, we go off UTC time. Therefore, adjust the UTCMinute so it represents 7:00 am in their local time.
        static var defaultLocalizedUTCMinute: Int {
            // Want the default UTC Hour to be
            let defaultUTCMinute = 0
            
            let minutesFromUTC = Int((Calendar.current.timeZone.secondsFromGMT() % 3600) / 60 )
            
            var defaultLocalizedUTCMinute = defaultUTCMinute + minutesFromUTC
            // Verify defaultLocalizedUTCMinute >= 0
            if defaultLocalizedUTCMinute < 0 {
                defaultLocalizedUTCMinute += 60
            }
            
            // Verify defaultLocalizedUTCMinute <= 59
            if defaultLocalizedUTCMinute > 59 {
                defaultLocalizedUTCMinute = defaultLocalizedUTCMinute % 60
            }
            
            return defaultLocalizedUTCMinute
        }
    }
    
    enum DateConstant {
        static let default1970Date = Date(timeIntervalSince1970: 0.0)
    }
}
