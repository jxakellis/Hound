//
//  Requirement.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from RequirementManager
enum RequirementManagerError: Error {
   case requirementAlreadyPresent
    case requirementNotPresent
    case requirementInvalid
    case requirementUUIDNotPresent
}

protocol RequirementManagerProtocol {
    
    //array of requirments, a dog should contain one of these to specify all of its requirements
    var requirements: [Requirement] { get set }
    
    init(initRequirements: [Requirement])
    
    ///checks to see if a requirement with the same name is present, if not then adds new requirement, if one is then throws error
    mutating func addRequirement(newRequirement: Requirement) throws
    
    mutating func addRequirement(newRequirements: [Requirement]) throws
    
    ///removes trys to find a requirement whos name (capitals don't matter) matches requirement name given, if found removes requirement, if not found throws error
    mutating func removeRequirement(forUUID uuid: String) throws
    mutating func changeRequirement(forUUID uuid: String, newRequirement: Requirement) throws
    
    ///finds and returns the reference of a requirement matching the given uuid
    func findRequirement(forUUID uuid: String) throws -> Requirement
    
    ///finds and returns the index of a requirement with a uuid in terms of the requirement: [Requirement] array
    func findIndex(forUUID uuid: String) throws -> Int
    
}

extension RequirementManagerProtocol {
    
    
    mutating func addRequirement(newRequirement: Requirement) throws {
        var requirementAlreadyPresent = false
        
        requirements.forEach { (req) in
            if (req.uuid == newRequirement.uuid){
                requirementAlreadyPresent = true
            }
        }
        
        if requirementAlreadyPresent == true{
            throw RequirementManagerError.requirementAlreadyPresent
        }
        else {
            //RequirementEfficencyImprovements requirements.append(newRequirement.copy() as! Requirement)
            requirements.append(newRequirement)
        }
        sortRequirements()
    }
    
    mutating func addRequirement(newRequirements: [Requirement]) throws {
        for requirement in newRequirements {
            try addRequirement(newRequirement: requirement)
        }
        sortRequirements()
    }
    
    
    mutating func removeRequirement(forUUID uuid: String) throws{
        var requirementNotPresent = true
        
        //goes through requirements to see if the given requirement name (aka requirement name) is in the array of requirments
        requirements.forEach { (req) in
            if req.uuid == uuid{
                requirementNotPresent = false
            }
        }
        
        //if provided requirement is not present, throws error
        
        if requirementNotPresent == true{
            throw RequirementManagerError.requirementNotPresent
        }
        //if provided requirement is present, proceeds
        else {
            //finds index of given requirement (through requirement name), returns nil if not found but it should be if code is written correctly, code should not be not be able to reach this point if requirement name was not present
            var indexOfRemovalTarget: Int?{
                for index in 0...Int(requirements.count){
                    if requirements[index].uuid == uuid{
                        return index
                    }
                }
                return nil
            }
            
        requirements.remove(at: indexOfRemovalTarget ?? -1)
        }
    }
    
    mutating func changeRequirement(forUUID uuid: String, newRequirement: Requirement) throws {
        
        //check to find the index of targetted requirement
        var newRequirementIndex: Int?
        
        for i in 0..<requirements.count {
            if requirements[i].uuid == uuid {
                newRequirementIndex = i
            }
        }
        
        if newRequirementIndex == nil {
            throw RequirementManagerError.requirementUUIDNotPresent
        }
        
        else {
            //RequirementEfficencyImprovements requirements[newRequirementIndex!] = newRequirement.copy() as! Requirement
            requirements[newRequirementIndex!] = newRequirement
        }
        sortRequirements()
    }
    
    
    func findRequirement(forUUID uuid: String) throws -> Requirement {
        for r in 0..<requirements.count{
            if requirements[r].uuid == uuid {
                return requirements[r]
            }
        }
        throw RequirementManagerError.requirementNotPresent
    }
    
    
    func findIndex(forUUID uuid: String) throws -> Int {
        for r in 0..<requirements.count{
            if requirements[r].uuid == uuid {
                return r
            }
        }
        throw RequirementManagerError.requirementNotPresent
    }
    
     mutating private func sortRequirements(){
         requirements.sort { (req1, req2) -> Bool in
            if req1.timingStyle == .oneTime && req2.timingStyle == .oneTime{
                if Date().distance(to: req1.oneTimeComponents.executionDate!) < Date().distance(to: req2.oneTimeComponents.executionDate!){
                    return true
                }
                else {
                    return false
                }
            }
            //both countdown
             else if req1.timingStyle == .countDown && req2.timingStyle == .countDown{
                 //shorter is listed first
                 if req1.countDownComponents.executionInterval <= req2.countDownComponents.executionInterval{
                     return true
                 }
                 else {
                     return false
                 }
             }
             //both weekly
             else if req1.timingStyle == .weekly && req2.timingStyle == .weekly{
                 //earlier in the day is listed first
                 let req1Hour = req1.timeOfDayComponents.timeOfDayComponent.hour!
                 let req2Hour = req2.timeOfDayComponents.timeOfDayComponent.hour!
                if req1Hour == req2Hour{
                    let req1Minute = req1.timeOfDayComponents.timeOfDayComponent.minute!
                    let req2Minute = req2.timeOfDayComponents.timeOfDayComponent.minute!
                    if req1Minute <= req2Minute{
                        return true
                    }
                    else {
                        return false
                    }
                }
                else if req1Hour <= req2Hour {
                     return true
                 }
                 else {
                     return false
                 }
             }
             //both monthly
             else if req1.timingStyle == .monthly && req2.timingStyle == .monthly{
                let req1Day: Int! = req1.timeOfDayComponents.dayOfMonth
                let req2Day: Int! = req2.timeOfDayComponents.dayOfMonth
                //first day of the month comes first
                if req1Day == req2Day{
                    //earliest in day comes first if same days
                    let req1Hour = req1.timeOfDayComponents.timeOfDayComponent.hour!
                    let req2Hour = req2.timeOfDayComponents.timeOfDayComponent.hour!
                   if req1Hour == req2Hour{
                    //earliest in hour comes first if same hour
                       let req1Minute = req1.timeOfDayComponents.timeOfDayComponent.minute!
                       let req2Minute = req2.timeOfDayComponents.timeOfDayComponent.minute!
                       if req1Minute <= req2Minute{
                           return true
                       }
                       else {
                           return false
                       }
                   }
                   else if req1Hour <= req2Hour {
                        return true
                    }
                    else {
                        return false
                    }
                }
                else if req1Day < req2Day{
                    return true
                }
                else {
                    return false
                }
             }
             //different timing styles
             else {
                 
                //req1 and req2 are known to be different styles
                switch req1.timingStyle {
                case .countDown:
                    //can assume is comes first as countdown always first and different
                    return true
                case .weekly:
                    if req2.timingStyle == .countDown{
                        return false
                    }
                    else {
                        return true
                    }
                case .monthly:
                    if req2.timingStyle == .oneTime{
                        return true
                    }
                    else {
                        return false
                    }
                case .oneTime:
                    return false
                }
              
             }
         }
     }
    
}

class RequirementManager: NSObject, NSCoding, NSCopying, RequirementManagerProtocol {
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        requirements = aDecoder.decodeObject(forKey: "requirements") as! [Requirement]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(requirements, forKey: "requirements")
    }
    
    //MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RequirementManager()
        for i in 0..<self.requirements.count {
            copy.requirements.append(self.requirements[i].copy() as! Requirement)
        }
        return copy
    }
    
    ///Array of requirements
    var requirements: [Requirement]
    
    ///if the array should be set to something by default, can be done so with init
    required init(initRequirements: [Requirement] = []) {
        requirements = initRequirements
    }
    
}

protocol RequirementManagerControlFlowProtocol {
    
    ///Returns a copy of RequirementManager used to avoid accidental changes (due to reference type) by classes which get their dog manager from here
    func getRequirementManager() -> RequirementManager
    
    ///Sets requirementManager equal to newRequirementManager, depending on sender will also call methods to propogate change.
    func setRequirementManager(sender: Sender, newRequirementManager: RequirementManager)
    
    //Updates things dependent on requirementManager
    func updateRequirementManagerDependents()
    
}
