//
//  DogRequirementManager.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogRequirementError: Error {
    case labelInvalid
    case descriptionInvalid
    case intervalInvalid
}

protocol DogRequirementProtocol {
    //name of requirement, can't be repeated, will throw error if try to add two requirments to same requirement manager with same label
    var label: String { get set }
    
    //descripton of reqirement
    var description: String { get set }
    
    //time at which requirement was initalized
    var initalizationDate: Date { get set }
    
    //last time the requirement was fired
    var lastDate: Date { get set }
    
    //interval at which a timer should be triggered for requirement
    var interval: TimeInterval { get set }
    
    init(initDate: Date) throws
    
    mutating func changeLabel(newLabel: String?) throws
    
    mutating func changeDescription(newDescription: String?) throws
    
    mutating func changeInterval(newInterval: TimeInterval?) throws
    
    
    //TEMPORARILY DISABLED DUE TO CONFLICT OF MATCHING NAMES WITH DIFFERENT DOG OBJECT
    // mutating func resetLabel()
    
    mutating func resetDescription()
    
    mutating func resetInterval()
}

extension DogRequirementProtocol {
    
    //MARK: DogRequirmentProtocol Function Extension Implementation
    
    //if newLabel passes all tests, changes value, if not throws error
    mutating func changeLabel(newLabel: String?) throws{
        if newLabel == nil || newLabel == "" {
            throw DogRequirementError.labelInvalid
        }
        label = newLabel!
    }
    
    //if newDescription passes all tests, changes value, if not throws error
    mutating func changeDescription(newDescription: String?) throws{
        if newDescription == nil {
            throw DogRequirementError.descriptionInvalid
        }
        
        description = newDescription!
    }
      
    //if newInterval passes all tests, changes value, if not throws error
    mutating func changeInterval(newInterval: TimeInterval?) throws{
        if newInterval == nil || newInterval! < TimeInterval(60.0){
            throw DogRequirementError.intervalInvalid
        }
        interval = newInterval!
    }
    
    /*
     TEMPORARILY DISABLED DUE TO CONFLICT OF MATCHING NAMES WITH DIFFERENT DOG OBJECT
     //resets value of label to constant/default value
    mutating func resetLabel(){
        label = DogConstant.defaultRequirementLabel
    }
     */
    
    //resets value of description to constant/default value
    mutating func resetDescription(){
        description = RequirementConstant.defaultDescription
    }
    
    //resets value of time interval to constant/default value
    mutating func resetInterval(){
        interval = TimeInterval(RequirementConstant.defaultTimeInterval)
    }
      
}

enum DogRequirementManagerError: Error {
    case requirementAlreadyPresent
    case requirementNotPresent
    case requirementInvalid
    case error
}

protocol DogRequirementManagerProtocol {
    
    //array of requirments, a dog should contain one of these to specify all of its requirements
    var requirements: [Requirement] { get set }
    
    init(initRequirements: [Requirement])
    
    mutating func addRequirement(newRequirement: Requirement) throws
    
    mutating func removeRequirement(requirementName: String) throws
    
    mutating func clearRequirements()
}

extension DogRequirementManagerProtocol {
    
    //checks to see if a requirement with the same label is present, if not then adds new requirement, if one is then throws error
    mutating func addRequirement(newRequirement: Requirement) throws {
        var requirementAlreadyPresent = false
        
        requirements.forEach { (req) in
            if (req.label.lowercased()) == (newRequirement.label.lowercased()){
                requirementAlreadyPresent = true
            }
        }
        
        if requirementAlreadyPresent == true{
            throw DogRequirementManagerError.requirementAlreadyPresent
        }
        else {
            requirements.append(newRequirement)
        }
        
    }
    
    //removes trys to find a requirement whos label (capitals don't matter) matches requirement name given, if found removes requirement, if not found throws error
    mutating func removeRequirement(requirementName: String) throws{
        var requirementNotPresent = true
        
        //goes through requirements to see if the given requirement name (aka requirement label) is in the array of requirments
        requirements.forEach { (req) in
            if (req.label.lowercased()) == (requirementName.lowercased()){
                requirementNotPresent = false
                
            }
        }
        
        //if provided requirement is not present, throws error
        
        if requirementNotPresent == true{
            throw DogRequirementManagerError.requirementNotPresent
        }
        //if provided requirement is present, proceeds
        else {
            //finds index of given requirement (through requirement label), returns nil if not found but it should be if code is written correctly, code should not be not be able to reach this point if requirement name was not present
            var indexOfRemovalTarget: Int?{
                for index in 0...Int(requirements.count){
                    if (requirements[index].label.lowercased()) == requirementName.lowercased(){
                        return index
                    }
                }
                return nil
            }
            
        requirements.remove(at: indexOfRemovalTarget ?? -1)
        }
    }
    
        //clears all requirements, should make requirements an empty array
    mutating func clearRequirements() {
        requirements.removeAll()
    }
}
