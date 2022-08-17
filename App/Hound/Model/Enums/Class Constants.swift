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
        static let defaultDogIcon: UIImage = UIImage.init(named: "whitePawWithHands")!
        static let defaultDogId: Int = -1
        static let chooseImageForDog: UIImage = UIImage.init(named: "chooseImageForDog")!
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
            try? reminder.weeklyComponents.changeHour(forHour: 7)
            try? reminder.weeklyComponents.changeMinute(forMinute: 0)
            return reminder
        }
        private static var defaultReminderThree: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .feed
            reminder.reminderType = .weekly
            try? reminder.weeklyComponents.changeHour(forHour: 5 + 12)
            try? reminder.weeklyComponents.changeMinute(forMinute: 0)
            return reminder
        }
        private static var defaultReminderFour: Reminder {
            let reminder = Reminder()
            reminder.reminderAction = .medicine
            reminder.reminderType = .monthly
            try? reminder.monthlyComponents.changeDay(forDay: 1)
            try? reminder.monthlyComponents.changeHour(forHour: 9)
            try? reminder.monthlyComponents.changeMinute(forMinute: 0)
            return reminder
        }
    }
    
    enum ReminderComponentConstant {
        static let defaultCountdownExecutionInterval: TimeInterval = 1800
    }
}
