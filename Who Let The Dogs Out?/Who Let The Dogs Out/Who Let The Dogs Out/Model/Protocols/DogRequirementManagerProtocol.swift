//
//  DogRequirementManager.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from DogRequirement
enum DogRequirementError: Error {
    case nameInvalid
    case descriptionInvalid
    case intervalInvalid
}

protocol DogRequirementProtocol {
    ///name of requirement, can't be repeated, will throw error if try to add two requirments to same requirement manager with same name
    var name: String { get set }
    
    ///descripton of reqirement
    var requirementDescription: String { get set }
    
    ///interval at which a timer should be triggered for requirement
    var executionInterval: TimeInterval { get }
    
    ///The interval that is currently activated to calculate.
    var activeInterval: TimeInterval { get set }
    
    ///last time the requirement was fired
    var lastExecution: Date { get set }
    
    ///how much time of the interval of been used up, this is used for when a timer is paused and then unpaused and have to calculate remaining time
    var intervalElapsed: TimeInterval { get set }
    
    var isSnoozed: Bool { get }
    
    var executionDates: [Date] { get set }
    
    var isPresentationHandled: Bool { get set }
    
    mutating func changeName(newName: String?) throws
    
    mutating func changeDescription(newDescription: String?) throws
    
    mutating func changeInterval(newInterval: TimeInterval?) throws
    
    mutating func changeLastExecution(newLastExecution: Date)
    
    mutating func changeIntervalElapsed(newIntervalElapsed: TimeInterval)
    
    mutating func changeSnooze(newSnoozeStatus: Bool)
    
    mutating func timerReset()
    
}

extension DogRequirementProtocol {
    
    //MARK: DogRequirmentProtocol Function Extension Implementation
    
    ///if newName passes all tests, changes value, if not throws error
    mutating func changeName(newName: String?) throws{
        if newName == nil || newName == "" {
            throw DogRequirementError.nameInvalid
        }
        name = newName!
    }
    
    ///if newDescription passes all tests, changes value, if not throws error
    mutating func changeDescription(newDescription: String?) throws{
        if newDescription == nil {
            throw DogRequirementError.descriptionInvalid
        }
        
        requirementDescription = newDescription!
    }
    
    ///if newLastExecution passes all tests, changes value
    mutating func changeLastExecution(newLastExecution: Date){
        lastExecution = newLastExecution
    }
    
    ///if newLastExecution passes all tests, changes value
    mutating func changeIntervalElapsed(newIntervalElapsed: TimeInterval){
        self.intervalElapsed = intervalElapsed
    }
    
    mutating func timerReset(){
        self.changeSnooze(newSnoozeStatus: false)
        self.changeLastExecution(newLastExecution: Date())
        self.executionDates.append(Date())
        self.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
        self.isPresentationHandled = false
        /*
         targetRequirement.changeSnooze(newSnoozeStatus: false)
         targetRequirement.changeLastExecution(newLastExecution: Date())
         targetRequirement.executionDates.append(Date())
         targetRequirement.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
         */
    }
}

///Enum full of cases of possible errors from DogRequirementManager
enum DogRequirementManagerError: Error {
    case requirementAlreadyPresent
    case requirementNotPresent
    case requirementInvalid
    case requirementNameNotPresent
}

protocol DogRequirementManagerProtocol {
    
    //array of requirments, a dog should contain one of these to specify all of its requirements
    var requirements: [Requirement] { get set }
    
    init(initRequirements: [Requirement])
    
    mutating func addRequirement(newRequirement: Requirement) throws
    
    mutating func addRequirement(newRequirements: [Requirement]) throws
    
    mutating func removeRequirement(requirementName: String) throws
    mutating func changeRequirement(requirementToBeChanged: String, newRequirement: Requirement) throws
    
    mutating func clearRequirements()
    
    func findRequirement(requirementName requirementToFind: String) throws -> Requirement
    
    func findIndex(requirementName requirementToFind: String) throws -> Int
    
}

extension DogRequirementManagerProtocol {
    
    ///checks to see if a requirement with the same name is present, if not then adds new requirement, if one is then throws error
    mutating func addRequirement(newRequirement: Requirement) throws {
        var requirementAlreadyPresent = false
        
        requirements.forEach { (req) in
            if (req.name.lowercased()) == (newRequirement.name.lowercased()){
                requirementAlreadyPresent = true
            }
        }
        
        if requirementAlreadyPresent == true{
            throw DogRequirementManagerError.requirementAlreadyPresent
        }
        else {
            requirements.append(newRequirement.copy() as! Requirement)
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
            if (req.name.lowercased()) == (requirementName.lowercased()){
                requirementNotPresent = false
                
            }
        }
        
        //if provided requirement is not present, throws error
        
        if requirementNotPresent == true{
            throw DogRequirementManagerError.requirementNotPresent
        }
        //if provided requirement is present, proceeds
        else {
            //finds index of given requirement (through requirement name), returns nil if not found but it should be if code is written correctly, code should not be not be able to reach this point if requirement name was not present
            var indexOfRemovalTarget: Int?{
                for index in 0...Int(requirements.count){
                    if (requirements[index].name.lowercased()) == requirementName.lowercased(){
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
        var newRequirementIndex: Int?
        
        for i in 0..<requirements.count {
            if requirements[i].name == requirementToBeChanged {
                newRequirementIndex = i
            }
        }
        
        if newRequirementIndex == nil {
            throw DogRequirementManagerError.requirementNameNotPresent
        }
        else {
            requirements[newRequirementIndex!] = newRequirement.copy() as! Requirement
        }
    }
    
        ///clears all requirements, should make requirements an empty array
    mutating func clearRequirements() {
        requirements.removeAll()
    }
    
    ///finds and returns the reference of a requirement matching the given name
    func findRequirement(requirementName requirementToFind: String) throws -> Requirement {
        for r in 0..<requirements.count{
            if requirements[r].name == requirementToFind {
                return requirements[r]
            }
        }
        throw DogRequirementManagerError.requirementNotPresent
    }
    
    ///finds and returns the index of a requirement with a name in terms of the requirement: [Requirement] array
    func findIndex(requirementName requirementToFind: String) throws -> Int {
        for r in 0..<requirements.count{
            if requirements[r].name == requirementToFind {
                return r
            }
        }
        throw DogRequirementManagerError.requirementNotPresent
    }
}

protocol RequirementManagerControlFlowProtocol {
    
    ///Returns a copy of RequirementManager used to avoid accidental changes (due to reference type) by classes which get their dog manager from here
    func getRequirementManager() -> RequirementManager
    
    ///Sets requirementManager equal to newRequirementManager, depending on sender will also call methods to propogate change.
    func setRequirementManager(newRequirementManager: RequirementManager, sender: AnyObject?)
    
    //Updates things dependent on requirementManager
    func updateRequirementManagerDependents()
    
}
