//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogError: Error {
    case noRequirementsPresent
}

class Dog: NSObject, NSCoding, NSCopying, EnableProtocol {
    
    //MARK: - NSCoding
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
    
    //MARK: - Conformation EnableProtocol
    
    ///Whether or not the dog is enabled, if disabled all requirements under this will not fire (but have their own independent isEnabled state)
    private var isEnabled: Bool = DogConstant.defaultEnable
    
    func setEnable(newEnableStatus: Bool) {
        if isEnabled == false && newEnableStatus == true {
            for r in dogRequirments.requirements {
                guard r.getEnable() == true else {
                    continue
                }
                r.timerReset(shouldLogExecution: false)
            }
        }
        
        if newEnableStatus == false{
            for r in dogRequirments.requirements{
                r.setEnable(newEnableStatus: false)
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
    
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Dog()
        copy.dogRequirments = self.dogRequirments.copy() as! RequirementManager
        copy.dogTraits = self.dogTraits.copy() as! DogTraitManager
        copy.isEnabled = self.isEnabled
        return copy
    }
    
    //MARK: - Properties
    
    ///Traint"
    var dogTraits: DogTraitManager = DogTraitManager()
    
    ///RequirmentManager that handles all specified requirements for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogRequirments: RequirementManager = RequirementManager()
    
    var catagorizedLogTypes: [(KnownLogType, [(Requirement?, KnownLog)])] {
        var catagorizedLogTypes: [(KnownLogType, [(Requirement?, KnownLog)])] = []
        
        //handles all dog logs and adds to catagorized log types
        for dogLog in dogTraits.logs{
            //already contains that dog log type, needs to append
            if catagorizedLogTypes.contains(where: { (arg1) -> Bool in
                let knownLogType = arg1.0
                if dogLog.logType == knownLogType{
                    return true
                }
                else {
                    return false
                }
            }) == true {
                //since knownLogType is already present, append on dogLog that is of that same type to the arry of logs with the given knownLogType
                let targetIndex: Int! = catagorizedLogTypes.firstIndex(where: { (arg1) -> Bool in
                    let knownLogType = arg1.0
                    if knownLogType == dogLog.logType{
                        return true
                    }
                    else {
                        return false
                    }
                })
                
                catagorizedLogTypes[targetIndex].1.append((nil, dogLog))
            }
            //does not contain that dog Log's Type
            else {
                catagorizedLogTypes.append((dogLog.logType, [(nil, dogLog)]))
            }
        }
        
        //go through all requirements
        for requirement in dogRequirments.requirements{
            //go through all requirement logs
            for requirementLog in requirement.logs{
                //already contains that requirementLog type, needs to append
                if catagorizedLogTypes.contains(where: { (arg1) -> Bool in
                    let knownLogType = arg1.0
                    if requirementLog.logType == knownLogType{
                        return true
                    }
                    else {
                        return false
                    }
                }) == true {
                    //since knownLogType is already present, append on requirementLog that is of that same type to the arry of logs with the given knownLogType
                    let targetIndex: Int! = catagorizedLogTypes.firstIndex(where: { (arg1) -> Bool in
                        let knownLogType = arg1.0
                        if knownLogType == requirementLog.logType{
                            return true
                        }
                        else {
                            return false
                        }
                    })
                    
                    catagorizedLogTypes[targetIndex].1.append((requirement, requirementLog))
                }
                //does not contain that dog Log's Type
                else {
                    catagorizedLogTypes.append((requirementLog.logType, [(requirement, requirementLog)]))
                }
            }
        }
        
        //sorts by the order defined by the enum, so whatever case is first in the code of the enum that is the order of the catagorizedLogTypes
        catagorizedLogTypes.sort { arg1, arg2 in
            let (knownLogType1, _) = arg1
            let (knownLogType2, _) = arg2
            
            //finds corrosponding index
            let knownLogType1Index: Int! = KnownLogType.allCases.firstIndex { arg1 in
                if knownLogType1.rawValue == arg1.rawValue{
                    return true
                }
                else {
                    return false
                }
            }
            //finds corrosponding index
            let knownLogType2Index: Int! = KnownLogType.allCases.firstIndex { arg1 in
                if knownLogType2.rawValue == arg1.rawValue{
                    return true
                }
                else {
                    return false
                }
            }
            
            if knownLogType1Index <= knownLogType2Index{
                return true
            }
            else {
                return false
            }
            
            
        }
        
        return catagorizedLogTypes
    }
    
    override init() {
        super.init()
    }
}


