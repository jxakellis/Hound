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
    private static let descriptionTuple: (String, String) = ("description", "Fiesty")
    static let defaultEnable: Bool = true
    static let defaultDogSpecificationKeys: [(String, String)] = [nameTuple, descriptionTuple]
}

enum RequirementConstant {
    static let defaultName = "Potty"
    static let defaultDescription = "Take Dog Out"
    static let defaultTimeInterval = (3600*2.5)
    static let defaultEnable: Bool = true
}

enum DogManagerConstant {
    
    static var defaultDog: Dog {
        let defaultDog = Dog()
        
        let defaultRequirementOne = Requirement()
        defaultRequirementOne.name = "Potty"
        defaultRequirementOne.requirementDescription = "Take The Dog Out"
        //defaultRequirementOne.interval = TimeInterval((3600*3)+(3600*(1/3)))
        try! defaultRequirementOne.changeInterval(newInterval: TimeInterval(25))
        defaultRequirementOne.setEnable(newEnableStatus: false)
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementOne)
        
        let defaultRequirementTwo = Requirement()
        defaultRequirementTwo.name = "Food"
        defaultRequirementTwo.requirementDescription = "Feed The Dog"
        //defaultRequirementTwo.executionInterval = TimeInterval((3600*7)+(3600*0.75))
        try! defaultRequirementTwo.changeInterval(newInterval: TimeInterval(17))
        defaultRequirementTwo.setEnable(newEnableStatus: false)
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementTwo)
        
        let defaultRequirementThree = Requirement()
        defaultRequirementThree.name = "Brush"
        defaultRequirementThree.requirementDescription = "Brush His Fur Out"
        //defaultRequirementThree.interval = TimeInterval((3600*7)+(3600*0.75))
        try! defaultRequirementThree.changeInterval(newInterval: TimeInterval(10))
        defaultRequirementThree.setEnable(newEnableStatus: true)
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementThree)
        
        for i in 0..<DogConstant.defaultDogSpecificationKeys.count{
        try! defaultDog.dogSpecifications.changeDogSpecifications(key: DogConstant.defaultDogSpecificationKeys[i].0, newValue: DogConstant.defaultDogSpecificationKeys[i].1)
        }
        
        defaultDog.setEnable(newEnableStatus: true)
    
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
