//
//  Dog.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Dog: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Dog()
        copy.dogRequirments = self.dogRequirments.copy() as! RequirementManager
        copy.dogSpecifications = self.dogSpecifications.copy() as! SpecificationManager
        copy.isEnabled = self.isEnabled
        return copy
    }
    
    //dictionary of specifications for a dog, e.g. "name", "breed", "description"
    var dogSpecifications: SpecificationManager = SpecificationManager()
    
    var isEnabled = DogConstant.enabledTuple.1
    
    //RequirmentManager that handles all specified requirements for a dog, e.g. being taken to the outside every time interval or being fed.
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
    
    var dogs: [Dog]
    
    init(){
        dogs = []
    }
    
}
