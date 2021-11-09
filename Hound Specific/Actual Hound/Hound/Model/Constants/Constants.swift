//
//  Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 12/1/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogConstant {
    static let defaultEnable: Bool = true
    static let defaultName: String = "Bella"
    static let defaultIcon: UIImage = UIImage.init(named: "pawFullResolutionWhite")!
    static let chooseIcon: UIImage = UIImage.init(named: "chooseIcon")!
}

enum ReminderConstant {
    static let defaultType = ScheduledLogType.allCases[0]
    static let defaultTimeInterval = (3600*0.5)
    static let defaultEnable: Bool = true
    static var defaultReminderOne: Reminder {
        let reminder = Reminder()
        reminder.reminderType = ScheduledLogType.potty
        reminder.countDownComponents.changeExecutionInterval(newExecutionInterval: defaultTimeInterval)
        return reminder
    }
    static var defaultReminderTwo: Reminder {
        let reminder = Reminder()
        reminder.reminderType = .feed
        reminder.changeTimingStyle(newTimingStyle: .weekly)
        try! reminder.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 7)
        try! reminder.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
        return reminder
    }
    static var defaultReminderThree: Reminder {
        let reminder = Reminder()
        reminder.reminderType = .feed
        reminder.changeTimingStyle(newTimingStyle: .weekly)
        try! reminder.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 5+12)
        try! reminder.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
        return reminder
    }
    static var defaultReminderFour: Reminder {
        let reminder = Reminder()
        reminder.reminderType = .medicine
        reminder.changeTimingStyle(newTimingStyle: .monthly)
        try! reminder.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 9)
        try! reminder.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
        try! reminder.timeOfDayComponents.changeDayOfMonth(newDayOfMonth: 1)
        return reminder
    }
}

enum DogManagerConstant {
    
    static var userDefaultDog: Dog {
        let userDefaultDog = Dog()
        
        /*
         let reminder = Reminder()
         reminder.reminderType = .trainingSession
         reminder.changeTimingStyle(newTimingStyle: .countDown)
         reminder.countDownComponents.changeExecutionInterval(newExecutionInterval: 30.0)
         try! userDefaultDog.dogReminders.addReminder(newReminder: reminder)
         */
        
    
        return userDefaultDog
    }
    
    static var defaultDogManager: DogManager {
        let dogManager = DogManager()
        
        try! dogManager.addDog(newDog: DogManagerConstant.userDefaultDog)
        
        return dogManager
    }
}

enum TimerConstant {
    static var defaultSnoozeLength: TimeInterval = TimeInterval(60*5)
    static var defaultTimeOfDay: DateComponents = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: 8, minute: 30, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    static var defaultSkipStatus: Bool = false
}

enum NotificationConstant {
    static var isNotificationAuthorized: Bool = false
    static var isNotificationEnabled: Bool = false
    static var shouldLoudNotification: Bool = false
    static var shouldShowTerminationAlert: Bool = true
    static var shouldFollowUp: Bool = false
    static var followUpDelay: TimeInterval = 5.0 * 60.0
}

enum AppearanceConstant {
    static var isCompactView: Bool = true
    static var darkModeStyle: UIUserInterfaceStyle = .unspecified
}

enum UserDefaultsKeys: String{
    case didFirstTimeSetup = "didFirstTimeSetup"
    case dogManager = "dogManager"
    case alertPresenter = "alertPresenter"
    case shouldPerformCleanInstall = "shouldPerformCleanInstall"
    case appBuild = "appBuild"
    
    //DogsViewController
    case hasBeenLoadedBefore = "hasBeenLoadedBefore"
    
    //Timing
    case isPaused = "isPaused"
    case lastPause = "lastPause"
    case lastUnpause = "lastUnpause"
    case defaultSnoozeLength = "defaultSnooze"
    
    //Notifications
    case isNotificationAuthorized = "isNotificationAuthorized"
    case isNotificationEnabled = "isNotificationEnabled"
    case shouldLoudNotification = "shouldLoudNotification"
    case shouldShowTerminationAlert = "shouldShowTerminationAlert"
    case shouldFollowUp = "shouldFollowUp"
    case followUpDelay = "followUpDelay"
    
    //Appearance
    case isCompactView = "isCompactView"
    case darkModeStyle = "darkModeStyle"
}

enum AnimationConstant: Double{
    
    case largeButtonShow = 0.30
    case largeButtonHide = 0.1500000001
    
    case toolTipShow = 0.1000000002
    case toolTipHide = 0.1000000003
    
    case switchButton = 0.1200000001
}
