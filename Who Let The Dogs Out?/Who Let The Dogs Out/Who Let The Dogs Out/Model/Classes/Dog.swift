//
//  Dog.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogError: Error {
    case noRequirementsPresent
}

class Dog: NSCopying, EnableProtocol {
    
    
    
    //MARK: Conformation EnableProtocol
    
    ///Whether or not the dog is enabled, if disabled all requirements under this will not fire (but have their own independent isEnabled state)
    private var isEnabled: Bool = DogConstant.defaultEnable
    
    func setEnable(newEnableStatus: Bool) {
        isEnabled = newEnableStatus
    }
    
    func willToggle() {
        isEnabled.toggle()
    }
    
    func getEnable() -> Bool{
        return isEnabled
    }
    
    
    //MARK: Conformation NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Dog()
        copy.dogRequirments = self.dogRequirments.copy() as! RequirementManager
        copy.dogSpecifications = self.dogSpecifications.copy() as! SpecificationManager
        copy.isEnabled = self.isEnabled
        return copy
    }
    
    //MARK: Properties
    
    ///dictionary of specifications for a dog, e.g. "name", "description"
    var dogSpecifications: SpecificationManager = SpecificationManager()
    
    ///RequirmentManager that handles all specified requirements for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogRequirments: RequirementManager = RequirementManager()
}

class DogManager: DogManagerProtocol, NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogManager()
        for i in 0..<dogs.count{
            copy.dogs.append(dogs[i].copy() as! Dog)
        }
        return copy
    }
    
    ///Array of dogs
    var dogs: [Dog]
    
    ///initalizes, sets dogs to []
    init(){
        dogs = []
    }
    
}
