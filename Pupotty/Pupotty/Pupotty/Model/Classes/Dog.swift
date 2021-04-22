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
        dogTraits = aDecoder.decodeObject(forKey: "dogTraits") as! DogTraitManager
        dogRequirments = aDecoder.decodeObject(forKey: "dogRequirments") as! RequirementManager
        isEnabled = aDecoder.decodeBool(forKey: "isEnabled")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogTraits, forKey: "dogTraits")
        aCoder.encode(dogRequirments, forKey: "dogRequirments")
        aCoder.encode(isEnabled, forKey: "isEnabled")
    }
    
    //MARK: Conformation EnableProtocol
    
    ///Whether or not the dog is enabled, if disabled all requirements under this will not fire (but have their own independent isEnabled state)
    private var isEnabled: Bool = DogConstant.defaultEnable
    
    func setEnable(newEnableStatus: Bool) {
        if isEnabled == false && newEnableStatus == true {
            for r in dogRequirments.requirements {
                guard r.getEnable() == true else {
                    continue
                }
                r.timerReset(didExecuteToUser: false)
            }
        }
        
        isEnabled = newEnableStatus
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
        copy.dogTraits = self.dogTraits.copy() as! DogTraitManager
        copy.isEnabled = self.isEnabled
        return copy
    }
    
    //MARK: Properties
    
    ///Traint"
    var dogTraits: DogTraitManager = DogTraitManager()
    
    ///RequirmentManager that handles all specified requirements for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogRequirments: RequirementManager = RequirementManager()
    
    override init() {
        super.init()
    }
}


