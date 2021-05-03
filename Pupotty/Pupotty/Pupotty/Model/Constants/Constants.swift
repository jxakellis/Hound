//
//  Constants.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 12/1/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit
import AudioToolbox

enum DogConstant {
    static let defaultEnable: Bool = true
    static let defaultName: String = "Bella"
    static let defaultDescription: String = "Friendly"
}

enum RequirementConstant {
    static let defaultName = "Potty"
    static let defaultDescription = "Take dog outside"
    static let defaultTimeInterval = (3600*0.5)
    static let defaultEnable: Bool = true
    static var defaultRequirement: Requirement { let req = Requirement()
        try! req.changeRequirementName(newRequirementName: defaultName)
        req.countDownComponents.changeExecutionInterval(newExecutionInterval: defaultTimeInterval)
        try! req.changeRequirementDescription(newRequirementDescription: defaultDescription)
        req.setEnable(newEnableStatus: defaultEnable)
        return req
    }
}

enum DogManagerConstant {
    
    static var testingDog: Dog {
        let testingDog = Dog()
        
        try! testingDog.dogRequirments.addRequirement(newRequirement: RequirementConstant.defaultRequirement)
        testingDog.dogRequirments.requirements[0].countDownComponents.changeExecutionInterval(newExecutionInterval: 30.0)
        
        testingDog.setEnable(newEnableStatus: DogConstant.defaultEnable)
    
        return testingDog
    }
    
    static var userDefaultDog: Dog {
        let userDefaultDog = Dog()
        
        try! userDefaultDog.dogRequirments.addRequirement(newRequirement: RequirementConstant.defaultRequirement)
        
        let userDefaultRequirementTwo = Requirement()
        try! userDefaultRequirementTwo.changeRequirementName(newRequirementName: "Breakfast")
        try! userDefaultRequirementTwo.changeRequirementDescription(newRequirementDescription: "Feed the dog")
        userDefaultRequirementTwo.changeTimingStyle(newTimingStyle: .timeOfDay)
        try! userDefaultRequirementTwo.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 7)
        try! userDefaultRequirementTwo.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
        try! userDefaultDog.dogRequirments.addRequirement(newRequirement: userDefaultRequirementTwo)
        
        let userDefaultRequirementThree = Requirement()
        try! userDefaultRequirementThree.changeRequirementName(newRequirementName: "Dinner")
        try! userDefaultRequirementThree.changeRequirementDescription(newRequirementDescription: "Feed the dog")
        userDefaultRequirementThree.changeTimingStyle(newTimingStyle: .timeOfDay)
        try! userDefaultRequirementThree.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 5+12)
        try! userDefaultRequirementThree.timeOfDayComponents.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
        try! userDefaultDog.dogRequirments.addRequirement(newRequirement: userDefaultRequirementThree)
        
        userDefaultDog.setEnable(newEnableStatus: DogConstant.defaultEnable)
    
        return userDefaultDog
    }
    
    static var defaultDogManager: DogManager {
        var dogManager = DogManager()
        try! dogManager.addDog(dogAdded: DogManagerConstant.userDefaultDog)
        return dogManager
    }
}

enum TimerConstant {
    static var defaultSnooze: TimeInterval = TimeInterval(60*30)
    static var defaultTimeOfDay: DateComponents = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: 8, minute: 30, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    static var defaultSkipStatus: Bool = false
    static var defaultSystemSound: SystemSoundID = SystemSoundID(1007)
}

enum NotificationConstant {
    static var shouldFollowUp: Bool = false
    static var followUpDelay: TimeInterval = 5.0 * 60.0
    static var isNotificationEnabled: Bool = false
    static var isNotificationAuthorized: Bool = false
}

enum UserDefaultsKeys: String{
    case didFirstTimeSetup = "didFirstTimeSetup"
    case dogManager = "dogManager"
    case alertPresenter = "alertPresenter"
    case shouldPerformCleanInstall = "shouldPerformCleanInstall"
    
    //Timing
    case isPaused = "isPaused"
    case lastPause = "lastPause"
    case lastUnpause = "lastUnpause"
    case defaultSnooze = "defaultSnooze"
    
    
    //Notifications
    case shouldFollowUp = "shouldFollowUp"
    case followUpDelay = "followUpDelay"
    case isNotificationEnabled = "isNotificationEnabled"
    case isNotificationAuthorized = "isNotificationAuthorized"
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
