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

class Dog: NSObject, NSCoding, NSCopying, EnableProtocol {
    
    //MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        dogSpecifications = aDecoder.decodeObject(forKey: "dogSpecifications") as! SpecificationManager
        dogRequirments = aDecoder.decodeObject(forKey: "dogRequirments") as! RequirementManager
        isEnabled = aDecoder.decodeBool(forKey: "isEnabled")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogSpecifications, forKey: "dogSpecifications")
        aCoder.encode(dogRequirments, forKey: "dogRequirments")
        aCoder.encode(isEnabled, forKey: "isEnabled")
    }
    
    //MARK: Conformation EnableProtocol
    
    ///Whether or not the dog is enabled, if disabled all requirements under this will not fire (but have their own independent isEnabled state)
    private var isEnabled: Bool = DogConstant.defaultEnable
    
    func setEnable(newEnableStatus: Bool) {
        isEnabled = newEnableStatus
        for r in dogRequirments.requirements {
            r.snoozeComponents.changeSnooze(newSnoozeStatus: false)
        }
    }
    
    func willToggle() {
        isEnabled.toggle()
    }
    
    func getEnable() -> Bool{
        return isEnabled
    }
    
    
    //MARK: NSCopying
    
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
    
    override init() {
        super.init()
    }
}


