//
//  Constants.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 12/1/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogConstant {
    private static let nameTuple: (String, String) = ("name", "Fido")
    private static let descriptionTuple: (String, String) = ("description", "Friendly")
    static let defaultEnable: Bool = true
    static let defaultDogSpecificationKeys: [(String, String)] = [nameTuple, descriptionTuple]
}

enum RequirementConstant {
    static let defaultName = "Potty"
    static let defaultDescription = "Take Dog Out"
    static let defaultTimeInterval = (3600*2.5)
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
    
    static var defaultDog: Dog {
        let defaultDog = Dog()
    
        let defaultRequirementOne = Requirement()
        try! defaultRequirementOne.changeRequirementName(newRequirementName: "Potty")
        try! defaultRequirementOne.changeRequirementDescription(newRequirementDescription: "Take The Dog Out")
        defaultRequirementOne.countDownComponents.changeExecutionInterval(newExecutionInterval: TimeInterval((3600*3)+(3600*(1/3))))
        //defaultRequirementOne.countDownComponents.changeExecutionInterval(newExecutionInterval: TimeInterval(50))
        defaultRequirementOne.setEnable(newEnableStatus: false)
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementOne)
 
        
        let defaultRequirementTwo = Requirement()
        try! defaultRequirementTwo.changeRequirementName(newRequirementName: "Food")
        try! defaultRequirementTwo.changeRequirementDescription(newRequirementDescription: "Feed The Dog")
        //defaultRequirementTwo.executionInterval = TimeInterval((3600*7)+(3600*0.75))
        defaultRequirementTwo.countDownComponents.changeExecutionInterval(newExecutionInterval: TimeInterval(180))
        defaultRequirementTwo.setEnable(newEnableStatus: false)
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementTwo)
        
        let defaultRequirementThree = Requirement()
        try! defaultRequirementThree.changeRequirementName(newRequirementName: "Brush")
        try! defaultRequirementThree.changeRequirementDescription(newRequirementDescription: "Brush His Fur Out")
        //defaultRequirementThree.interval = TimeInterval((3600*7)+(3600*0.75))
        defaultRequirementThree.countDownComponents.changeExecutionInterval(newExecutionInterval: TimeInterval(3600))
        defaultRequirementThree.setEnable(newEnableStatus: false)
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementThree)
        
        for i in 0..<DogConstant.defaultDogSpecificationKeys.count{
        try! defaultDog.dogSpecifications.changeDogSpecifications(key: DogConstant.defaultDogSpecificationKeys[i].0, newValue: DogConstant.defaultDogSpecificationKeys[i].1)
        }
        
        defaultDog.setEnable(newEnableStatus: DogConstant.defaultEnable)
    
        return defaultDog
    }
    
    static var defaultDogManager: DogManager {
        var sudoDogManager = DogManager()
        try! sudoDogManager.addDog(dogAdded: DogManagerConstant.defaultDog.copy() as! Dog)
        return sudoDogManager.copy() as! DogManager
    }
}

enum TimerConstant {
    static var defaultSnooze: TimeInterval = TimeInterval(60*30)
    static var defaultTimeOfDay: DateComponents = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: 8, minute: 30, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
}

enum UserDefaultsKeys: String{
    case didFirstTimeSetup = "didFirstTimeSetup"
    case dogManager = "dogManager"
    case defaultSnooze = "defaultSnooze"
    case isPaused = "isPaused"
    case lastPause = "lastPause"
    case lastUnpause = "lastUnpause"
    case isRequestAuthorizationGranted = "isRequestAuthorizationGranted"
    case isNotificationEnabled = "isNotificationEnabled"
    case alertPresenter = "alertPresenter"
}

enum AnimationConstant: Double{
    
    case HomeLogStateAnimate = 0.42
    case HomeLogStateDisappearDelay = 0.15
}
