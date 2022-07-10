//
//  Dog Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogManagerConstant {
    
    static var userDefaultDog: Dog {
        let userDefaultDog = try! Dog(dogName: DogConstant.defaultDogName)
        
        return userDefaultDog
    }
    
    static var defaultDogManager: DogManager {
        let dogManager = DogManager()
        
        dogManager.addDog(newDog: DogManagerConstant.userDefaultDog)
        
        return dogManager
    }
}

enum DogConstant {
    static let defaultDogName: String = "Bella"
    static let defaultDogIcon: UIImage = UIImage.init(named: "pawFullResolutionWhite")!
    static let defaultDogId: Int = -1
    static let chooseIconForDog: UIImage = UIImage.init(named: "chooseIconForDog")!
}

enum LogConstant {
    static let defaultLogId: Int = -1
    static var defaultUserId: String {
        return UserInformation.userId ?? Hash.defaultSHA256Hash
    }
    static let defaultLogAction = LogAction.allCases[0]
    static let defaultLogCustomActionName: String? = nil
    static let defaultLogNote: String = ""
    static var defaultLogDate: Date { return Date() }
    /// when looking to unskip a reminder, we look for a log that has its time unmodified. if its logDate within a certain percision of the skipdate, then we assume that log is from that reminder skipping.
    static let logRemovalPrecision: Double = 0.025
}

enum ReminderConstant {
    static let defaultReminderId: Int = -1
    static let defaultReminderAction = ReminderAction.feed
    static let defaultReminderCustomActionName: String? = nil
    static let defaultReminderType = ReminderType.countdown
    static var defaultReminderExecutionBasis: Date { return Date() }
    static let defaultReminderIsEnabled = true
    static var defaultReminders: [Reminder] {
        return [ defaultReminderOne, defaultReminderTwo, defaultReminderThree, defaultReminderFour ]
    }
    private static var defaultReminderOne: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .potty
        reminder.reminderType = .countdown
        reminder.countdownComponents.executionInterval = ReminderComponentConstant.defaultCountdownExecutionInterval
        return reminder
    }
    private static var defaultReminderTwo: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .feed
        reminder.reminderType = .weekly
        try! reminder.weeklyComponents.changeHour(newHour: 7)
        try! reminder.weeklyComponents.changeMinute(newMinute: 0)
        return reminder
    }
    private static var defaultReminderThree: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .feed
        reminder.reminderType = .weekly
        try! reminder.weeklyComponents.changeHour(newHour: 5+12)
        try! reminder.weeklyComponents.changeMinute(newMinute: 0)
        return reminder
    }
    private static var defaultReminderFour: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .medicine
        reminder.reminderType = .monthly
        try! reminder.monthlyComponents.changeDay(newDay: 1)
        try! reminder.monthlyComponents.changeHour(newHour: 9)
        try! reminder.monthlyComponents.changeMinute(newMinute: 0)
        return reminder
    }
}

enum ReminderComponentConstant {
    static let defaultCountdownExecutionInterval: TimeInterval = 1800
}
