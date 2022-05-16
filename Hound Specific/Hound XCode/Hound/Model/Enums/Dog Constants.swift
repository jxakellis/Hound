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
    static let defaultAction = LogAction.allCases[0]
    static let defaultLogId: Int = -1
    static let defaultLogNote: String = ""
    /// when looking to unskip a reminder, we look for a log that has its time unmodified. if its logDate within a certain percision of the skipdate, then we assume that log is from that reminder skipping.
    static let logRemovalPrecision: Double = 0.025
}

enum ReminderConstant {
    static let defaultAction = ReminderAction.allCases[0]
    static let defaultType = ReminderType.allCases[0]
    static let defaultTimeInterval = (3600*0.5)
    static let defaultEnable: Bool = true
    static let defaultReminderId: Int = -1
    static var defaultReminders: [Reminder] {
        return [ defaultReminderOne, defaultReminderTwo, defaultReminderThree, defaultReminderFour ]
    }
    private static var defaultReminderOne: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = ReminderAction.potty
        reminder.countdownComponents.changeExecutionInterval(newExecutionInterval: defaultTimeInterval)
        return reminder
    }
    private static var defaultReminderTwo: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .feed
        reminder.changeReminderType(newReminderType: .weekly)
        try! reminder.weeklyComponents.changeHour(newHour: 7)
        try! reminder.weeklyComponents.changeMinute(newMinute: 0)
        return reminder
    }
    private static var defaultReminderThree: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .feed
        reminder.changeReminderType(newReminderType: .weekly)
        try! reminder.weeklyComponents.changeHour(newHour: 5+12)
        try! reminder.weeklyComponents.changeMinute(newMinute: 0)
        return reminder
    }
    private static var defaultReminderFour: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .medicine
        reminder.changeReminderType(newReminderType: .monthly)
        try! reminder.monthlyComponents.changeDay(newDay: 1)
        try! reminder.monthlyComponents.changeHour(newHour: 9)
        try! reminder.monthlyComponents.changeMinute(newMinute: 0)
        return reminder
    }
}
