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
    static let defaultIcon: UIImage = UIImage.init(named: "pawFullResolutionWhite")!
    static let defaultDogId: Int = -1
    static let chooseIcon: UIImage = UIImage.init(named: "chooseIcon")!
}

enum LogConstant {
    static let defaultAction = LogAction.allCases[0]
    static let defaultLogId: Int = -1
    static let defaultNote: String = ""
}

enum ReminderConstant {
    static let defaultAction = ReminderAction.allCases[0]
    static let defaultType = ReminderType.allCases[0]
    static let defaultTimeInterval = (3600*0.5)
    static let defaultEnable: Bool = true
    static let defaultReminderId: Int = -1
    static var defaultReminderOne: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = ReminderAction.potty
        reminder.countdownComponents.changeExecutionInterval(newExecutionInterval: defaultTimeInterval)
        return reminder
    }
    static var defaultReminderTwo: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .feed
        reminder.changeReminderType(newReminderType: .weekly)
        reminder.weeklyComponents.changeDateComponents(newDateComponent: .hour, newValue: 7)
        reminder.weeklyComponents.changeDateComponents(newDateComponent: .minute, newValue: 0)
        return reminder
    }
    static var defaultReminderThree: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .feed
        reminder.changeReminderType(newReminderType: .weekly)
        reminder.weeklyComponents.changeDateComponents(newDateComponent: .hour, newValue: 5+12)
        reminder.weeklyComponents.changeDateComponents(newDateComponent: .minute, newValue: 0)
        return reminder
    }
    static var defaultReminderFour: Reminder {
        let reminder = Reminder()
        reminder.reminderAction = .medicine
        reminder.changeReminderType(newReminderType: .monthly)
        reminder.monthlyComponents.changeDateComponents(newDateComponent: .hour, newValue: 9)
        reminder.monthlyComponents.changeDateComponents(newDateComponent: .minute, newValue: 0)
        try! reminder.monthlyComponents.changeDayOfMonth(newDayOfMonth: 1)
        return reminder
    }
}
