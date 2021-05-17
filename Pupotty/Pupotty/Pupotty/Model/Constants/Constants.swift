//
//  Constants.swift
//  Pupotty
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

enum RequirementConstant {
    static let defaultType = ScheduledLogType.allCases[0]
    static let defaultTimeInterval = (3600*0.5)
    static let defaultEnable: Bool = true
    static var defaultRequirementOne: Requirement {
        let req = Requirement()
        req.requirementType = ScheduledLogType.potty
        req.countDownComponents.changeExecutionInterval(newExecutionInterval: defaultTimeInterval)
        req.setEnable(newEnableStatus: defaultEnable)
        return req
    }
    static var defaultRequirementTwo: Requirement {
        let req = Requirement()
        req.requirementType = .feed
        req.changeTimingStyle(newTimingStyle: .weekly)
        try! req.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 7)
        try! req.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
        return req
    }
    static var defaultRequirementThree: Requirement {
        let req = Requirement()
        req.requirementType = .feed
        req.changeTimingStyle(newTimingStyle: .weekly)
        try! req.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 5+12)
        try! req.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
        return req
    }
    static var defaultRequirementFour: Requirement {
        let req = Requirement()
        req.requirementType = .medicine
        req.changeTimingStyle(newTimingStyle: .monthly)
        try! req.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 9)
        try! req.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
        try! req.timeOfDayComponents.changeDayOfMonth(newDayOfMonth: 1)
        return req
    }
}

enum DogManagerConstant {
    
    static var userDefaultDog: Dog {
        let userDefaultDog = Dog()
        
        userDefaultDog.setEnable(newEnableStatus: DogConstant.defaultEnable)
        
        /*
         let req = Requirement()
         req.requirementType = .trainingSession
         req.changeTimingStyle(newTimingStyle: .countDown)
         req.countDownComponents.changeExecutionInterval(newExecutionInterval: 30.0)
         try! userDefaultDog.dogRequirments.addRequirement(newRequirement: req)
         */
        
    
        return userDefaultDog
    }
    
    static var defaultDogManager: DogManager {
        var dogManager = DogManager()
        
        try! dogManager.addDog(dogAdded: DogManagerConstant.userDefaultDog)
        
        return dogManager
    }
}

enum TimerConstant {
    static var defaultSnooze: TimeInterval = TimeInterval(60*5)
    static var defaultTimeOfDay: DateComponents = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: 8, minute: 30, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    static var defaultSkipStatus: Bool = false
}

enum NotificationConstant {
    static var isNotificationAuthorized: Bool = false
    static var isNotificationEnabled: Bool = false
    static var shouldLoudNotification: Bool = false
    static var shouldFollowUp: Bool = false
    static var followUpDelay: TimeInterval = 5.0 * 60.0
}

enum UserDefaultsKeys: String{
    case didFirstTimeSetup = "didFirstTimeSetup"
    case dogManager = "dogManager"
    case alertPresenter = "alertPresenter"
    case shouldPerformCleanInstall = "shouldPerformCleanInstall"
    
    //DogsViewController
    case hasBeenLoadedBefore = "hasBeenLoadedBefore"
    
    //LogsMainScreenTableViewController
    case isCompactView = "isCompactView"
    
    //Timing
    case isPaused = "isPaused"
    case lastPause = "lastPause"
    case lastUnpause = "lastUnpause"
    case defaultSnooze = "defaultSnooze"
    
    
    //Notifications
    case isNotificationAuthorized = "isNotificationAuthorized"
    case isNotificationEnabled = "isNotificationEnabled"
    case shouldLoudNotification = "shouldLoudNotification"
    case shouldFollowUp = "shouldFollowUp"
    case followUpDelay = "followUpDelay"
}

enum AnimationConstant: Double{
    
    case largeButtonShow = 0.30
    case largeButtonHide = 0.1500000001
    
    case toolTipShow = 0.1000000002
    case toolTipHide = 0.1000000003
    
    case switchButton = 0.1200000001
}

 
 
enum ColorConstant {
    case gray
}

extension ColorConstant: RawRepresentable {
    typealias RawValue = UIColor
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case UIColor.systemGray.withAlphaComponent(0.30):
            self = .gray
        default:
            print("ColorConstant nil while init")
            return nil
        }
    }
    
    var rawValue: RawValue {
        switch self {
        case .gray:
            return UIColor.systemGray.withAlphaComponent(0.30)
        }
    }
}
