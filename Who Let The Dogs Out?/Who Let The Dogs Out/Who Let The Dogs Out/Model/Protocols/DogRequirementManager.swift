//
//  DogRequirementManager.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogRequirementError: Error {
    case LabelInvalid
    case DescriptionInvalid
    case IntervalInvalid
}

protocol DogRequirementProtocol {
    
    var label: String { get set }
    
    var description: String { get set }
    
    var initalizationDate: Date { get set }
    
    var interval: TimeInterval { get set }
    
    init(initDate: Date, initInterval: TimeInterval) throws
    
    mutating func changeLabel(newLabel: String) throws
    
    mutating func changeDescription(newDescription: String) throws
    
    mutating func changeInterval(newInterval: TimeInterval) throws
    
    mutating func resetLabel()
    
    mutating func resetDescription()
    
    mutating func resetInterval()
}

extension DogRequirementProtocol {
    
    //MARK: DogRequirmentProtocol Function Extension Implementation
    
    //if newLabel passes all tests, changes value, if not throws error
    mutating func changeLabel(newLabel: String) throws{
        label = newLabel
    }
    
    //if newDescription passes all tests, changes value, if not throws error
    mutating func changeDescription(newDescription: String) throws{
        description = newDescription
    }
      
    //if newInterval passes all tests, changes value, if not throws error
    mutating func changeInterval(newInterval: TimeInterval) throws{
        interval = newInterval
    }
    
    //resets value of label to constant/default value
    mutating func resetLabel(){
        //replace with constant eventually
        label = ""
    }
    
    //resets value of description to constant/default value
    mutating func resetDescription(){
        //replace with constant eventually
        description = ""
    }
    
    //resets value of time interval to constant/default value
    mutating func resetInterval(){
        //replace with constant eventually
        interval = TimeInterval(3600)
    }
      
}

enum DogRequirementManagerError: Error {
    case RequirementAlreadyPresent
    case RequirementNotPresent
    case RequirementInvalid
    case Error
}

protocol DogRequirementManagerProtocol {
    
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
        
        //ADD MORE CODE NOT COMPLETE
        //ADD MORE CODE NOT COMPLETE
        //ADD MORE CODE NOT COMPLETE
        //ADD MORE CODE NOT COMPLETE
        //ADD MORE CODE NOT COMPLETE
        
        requirements.append(newRequirement)
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
            throw DogRequirementManagerError.RequirementNotPresent
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
    
        //clears all requirements, should make requirements an empty string
    mutating func clearRequirements() {
        requirements.removeAll()
    }
}
