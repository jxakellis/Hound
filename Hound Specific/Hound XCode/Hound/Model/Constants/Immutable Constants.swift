//
//  Immutable Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
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

enum UserDefaultsKeys: String {

    // MARK: User Information

    case userEmail
    case userFirstName
    case userLastName

    // MARK: User Configuration

    // Appearance
    case isCompactView
    case darkModeStyle

    // Timing
    case isPaused
    case snoozeLength

    // Notifications
    case isNotificationAuthorized
    case isNotificationEnabled
    case isLoudNotification
    case isFollowUpEnabled
    case followUpDelay
    case notificationSound

    // MARK: Local Configuration

    case lastPause
    case lastUnpause
    case reviewRequestDates
    case isShowTerminationAlert
    case isShowReleaseNotes
    case hasLoadedIntroductionViewControllerBefore

    // MARK: Other
    case didFirstTimeSetup
    case dogManager
    case appBuild
}

enum AnimationConstant: Double {

    case largeButtonShow = 0.30
    case largeButtonHide = 0.1500000001

    case toolTipShow = 0.1000000002
    case toolTipHide = 0.1000000003

    case switchButton = 0.1200000001
}

enum NotificationSound: String, CaseIterable {
    // ENUM('Radar','Apex','Beacon','Bulletin','By The Seaside','Chimes','Circuit','Constellation','Cosmic','Crystals','Hillside','Illuminate','Night Owl','Opening','Presto','Reflection','Ripplies','Sencha','Signal','Silk','Stargaze','Twinkle','Waves')
    init?(rawValue: String) {
        for sound in NotificationSound.allCases where sound.rawValue == rawValue {
            self = sound
            return
        }

        AppDelegate.generalLogger.fault("Depreciated NotificationSound \(rawValue), resetting value to default")
        self = .radar
        return

        // case playtime = "Playtime"
        // case radiate = "Radiate"
        // case slowRise = "Slow Rise"
        // case summit = "Summit"
        // case uplift = "Uplift"
    }
    case radar = "Radar"
    case apex = "Apex"
    case beacon = "Beacon"
    case bulletin  = "Bulletin"
    case byTheSeaside = "By The Seaside"
    case chimes  = "Chimes"
    case circuit = "Circuit"
    case constellation = "Constellation"
    case cosmic = "Cosmic"
    case crystals = "Crystals"
    case hillside = "Hillside"
    case illuminate = "Illuminate"
    case nightOwl = "Night Owl"
    case opening = "Opening"
    // case playtime = "Playtime"
    case presto = "Presto"
    // case radiate = "Radiate"
    case reflection = "Reflection"
    case ripples = "Ripples"
    case sencha = "Sencha"
    case signal = "Signal"
    case silk = "Silk"
    // case slowRise = "Slow Rise"
    case stargaze = "Stargaze"
    // case summit = "Summit"
    case twinkle = "Twinkle"
    // case uplift = "Uplift"
    case waves = "Waves"
}
