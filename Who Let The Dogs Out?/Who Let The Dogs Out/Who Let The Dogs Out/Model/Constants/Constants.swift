//
//  Constants.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 12/1/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogConstant {
    private static let nameTuple: (String, String) = ("name", "Bella")
    private static let descriptionTuple: (String, String) = ("description", "Friendly")
    static let defaultEnable: Bool = true
    static let defaultDogSpecificationKeys: [(String, String)] = [nameTuple, descriptionTuple]
}

enum RequirementConstant {
    static let defaultName = "Potty"
    static let defaultDescription = "Take dog outside"
    static let defaultTimeInterval = (3600*2.0)
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
    
        let testingRequirementOne = Requirement()
        try! testingRequirementOne.changeRequirementName(newRequirementName: "Potty")
        try! testingRequirementOne.changeRequirementDescription(newRequirementDescription: "Take Dog Outside")
        testingRequirementOne.countDownComponents.changeExecutionInterval(newExecutionInterval: TimeInterval(25))
        //defaultRequirementOne.countDownComponents.changeExecutionInterval(newExecutionInterval: TimeInterval(50))
        testingRequirementOne.setEnable(newEnableStatus: true)
        try! testingDog.dogRequirments.addRequirement(newRequirement: testingRequirementOne)
 
        
        let testingRequirementTwo = Requirement()
        try! testingRequirementTwo.changeRequirementName(newRequirementName: "Food")
        try! testingRequirementTwo.changeRequirementDescription(newRequirementDescription: "Feed The Dog")
        testingRequirementTwo.countDownComponents.changeExecutionInterval(newExecutionInterval: TimeInterval(15))
        testingRequirementTwo.setEnable(newEnableStatus: true)
        try! testingDog.dogRequirments.addRequirement(newRequirement: testingRequirementTwo)
        
        let testingRequirementThree = Requirement()
        try! testingRequirementThree.changeRequirementName(newRequirementName: "Brush")
        try! testingRequirementThree.changeRequirementDescription(newRequirementDescription: "Brush His Fur Out")
        //testingRequirementThree.interval = TimeInterval((3600*7)+(3600*0.75))
        testingRequirementThree.countDownComponents.changeExecutionInterval(newExecutionInterval: TimeInterval(3600))
        testingRequirementThree.setEnable(newEnableStatus: false)
        try! testingDog.dogRequirments.addRequirement(newRequirement: testingRequirementThree)
        
        for i in 0..<DogConstant.defaultDogSpecificationKeys.count{
        try! testingDog.dogSpecifications.changeDogSpecifications(key: DogConstant.defaultDogSpecificationKeys[i].0, newValue: DogConstant.defaultDogSpecificationKeys[i].1)
        }
        
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
        
        for i in 0..<DogConstant.defaultDogSpecificationKeys.count{
        try! userDefaultDog.dogSpecifications.changeDogSpecifications(key: DogConstant.defaultDogSpecificationKeys[i].0, newValue: DogConstant.defaultDogSpecificationKeys[i].1)
        }
        
        userDefaultDog.setEnable(newEnableStatus: DogConstant.defaultEnable)
    
        return userDefaultDog
    }
    
    static var defaultDogManager: DogManager {
        var sudoDogManager = DogManager()
        try! sudoDogManager.addDog(dogAdded: DogManagerConstant.userDefaultDog.copy() as! Dog)
        return sudoDogManager.copy() as! DogManager
    }
}

enum TimerConstant {
    static var defaultSnooze: TimeInterval = TimeInterval(60*30)
    static var defaultTimeOfDay: DateComponents = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: 8, minute: 30, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    static var defaultSkipStatus: Bool = false
}

enum NotificationConstant {
    static var shouldFollowUp: Bool = true
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
    
    
}
