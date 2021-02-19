//
//  Constants.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 12/1/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogConstant {
    
    //convert to tuple so the defaults for the keys are directly linked.
    //static let defaultLabel = ""
    //static let defaultDescription = ""
    private static let nameTuple: (String, String) = ("name", "Fido")
    private static let descriptionTuple: (String, String) = ("description", "Fiesty")
    static let defaultEnable: Bool = true
    static let defaultDogSpecificationKeys: [(String, String)] = [nameTuple, descriptionTuple]
}

enum RequirementConstant {
    static let defaultLabel = "Potty"
    static let defaultDescription = "Take Dog Out"
    static let defaultTimeInterval = (3600*2.5)
    static let defaultEnable: Bool = true
}

enum DogManagerConstant {
    
    static var defaultDog: Dog {
        let defaultDog = Dog()
        
        let defaultRequirementOne = Requirement()
        defaultRequirementOne.label = "Potty"
        defaultRequirementOne.description = "Take The Dog Out"
        defaultRequirementOne.interval = TimeInterval((3600*3)+(3600*(1/3)))
        //defaultRequirementOne.interval = TimeInterval(50)
        defaultRequirementOne.setEnable(newEnableStatus: false)
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementOne)
        
        let defaultRequirementTwo = Requirement()
        defaultRequirementTwo.label = "Food"
        defaultRequirementTwo.description = "Feed The Dog"
        defaultRequirementTwo.interval = TimeInterval((3600*7)+(3600*0.75))
        //defaultRequirementTwo.interval = TimeInterval(20)
        defaultRequirementTwo.setEnable(newEnableStatus: true)
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementTwo)
        
        let defaultRequirementThree = Requirement()
        defaultRequirementThree.label = "Brush"
        defaultRequirementThree.description = "Brush His Fur Out"
        //defaultRequirementThree.interval = TimeInterval((3600*7)+(3600*0.75))
        defaultRequirementThree.interval = TimeInterval(15)
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
