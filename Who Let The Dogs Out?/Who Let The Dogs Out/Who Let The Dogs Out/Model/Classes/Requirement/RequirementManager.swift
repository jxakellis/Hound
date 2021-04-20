//
//  Requirement.swift
//  Who Let The Dogs Out
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
    case requirementNameNotPresent
}

protocol RequirementManagerProtocol {
    
    //array of requirments, a dog should contain one of these to specify all of its requirements
    var requirements: [Requirement] { get set }
    
    init(initRequirements: [Requirement])
    
    mutating func addRequirement(newRequirement: Requirement) throws
    
    mutating func addRequirement(newRequirements: [Requirement]) throws
    
    mutating func removeRequirement(requirementName: String) throws
    mutating func changeRequirement(requirementToBeChanged: String, newRequirement: Requirement) throws
    
    func findRequirement(requirementName requirementToFind: String) throws -> Requirement
    
    func findIndex(requirementName requirementToFind: String) throws -> Int
    
}

extension RequirementManagerProtocol {
    
    ///checks to see if a requirement with the same name is present, if not then adds new requirement, if one is then throws error
    mutating func addRequirement(newRequirement: Requirement) throws {
        var requirementAlreadyPresent = false
        
        requirements.forEach { (req) in
            if (req.requirementName.lowercased()) == (newRequirement.requirementName.lowercased()){
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
        
    }
    
    mutating func addRequirement(newRequirements: [Requirement]) throws {
        for requirement in newRequirements {
            try addRequirement(newRequirement: requirement)
        }
    }
    
    ///removes trys to find a requirement whos name (capitals don't matter) matches requirement name given, if found removes requirement, if not found throws error
    mutating func removeRequirement(requirementName: String) throws{
        var requirementNotPresent = true
        
        //goes through requirements to see if the given requirement name (aka requirement name) is in the array of requirments
        requirements.forEach { (req) in
            if (req.requirementName.lowercased()) == (requirementName.lowercased()){
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
                    if (requirements[index].requirementName.lowercased()) == requirementName.lowercased(){
                        return index
                    }
                }
                return nil
            }
            
        requirements.remove(at: indexOfRemovalTarget ?? -1)
        }
    }
    
    ///
    mutating func changeRequirement(requirementToBeChanged: String, newRequirement: Requirement) throws {
        
        //check to find the index of targetted requirement
        var newRequirementIndex: Int?
        for i in 0..<requirements.count {
            if requirements[i].requirementName.lowercased() == requirementToBeChanged.lowercased() {
                newRequirementIndex = i
            }
        }
        
        //check to see if new name is a duplicate of another requirement name
        for i in 0..<requirements.count {
            if requirements[i].requirementName.lowercased() == newRequirement.requirementName.lowercased() {
                if i != newRequirementIndex {
                    throw RequirementManagerError.requirementAlreadyPresent
                }
            }
        }
        
        if newRequirementIndex == nil {
            throw RequirementManagerError.requirementNameNotPresent
        }
        
        else {
            //RequirementEfficencyImprovements requirements[newRequirementIndex!] = newRequirement.copy() as! Requirement
            requirements[newRequirementIndex!] = newRequirement
        }
    }
    
    ///finds and returns the reference of a requirement matching the given name
    func findRequirement(requirementName requirementToFind: String) throws -> Requirement {
        for r in 0..<requirements.count{
            if requirements[r].requirementName.lowercased() == requirementToFind.lowercased() {
                return requirements[r]
            }
        }
        throw RequirementManagerError.requirementNotPresent
    }
    
    ///finds and returns the index of a requirement with a name in terms of the requirement: [Requirement] array
    func findIndex(requirementName requirementToFind: String) throws -> Int {
        for r in 0..<requirements.count{
            if requirements[r].requirementName == requirementToFind {
                return r
            }
        }
        throw RequirementManagerError.requirementNotPresent
    }
}

class RequirementManager: NSObject, NSCoding, NSCopying, RequirementManagerProtocol {
    
    //MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        requirements = aDecoder.decodeObject(forKey: "requirements") as! [Requirement]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(requirements, forKey: "requirements")
    }
    
    //MARK: NSCopying
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
