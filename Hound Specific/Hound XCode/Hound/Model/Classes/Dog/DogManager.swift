//
//  DogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Protocol outlining functionality of DogManger
protocol DogManagerProtocol {
    
    /// Stores all the dogs. This is get only to make sure integrite of dogs added is kept
    var dogs: [Dog] { get }
    
    /// Returns true if ANY the dogs present has at least 1 CREATED reminder
    var hasCreatedReminder: Bool { get }
    
    /// Returns true if dogs.count > 0
    var hasCreatedDog: Bool { get }
    
    /// Returns true if ANY the dogs present has at least 1 ENABLED reminder
    var hasEnabledReminder: Bool { get }
    
    /// Returns number of reminders that are enabled and therefore have a timer. Does not factor in isPaused.
    var enabledTimersCount: Int { get }
    
    /// Adds a dog to dogs, checks to see if the dog itself is valid, e.g. its dogId is unique. Currently override other dog with the same dogId
    mutating func addDog(newDog: Dog) throws
    
    /// Adds array of dogs with addDog(newDog: Dog) repition
    mutating func addDogs(newDogs: [Dog]) throws
    
    /// Removes a dog with the given dogId
    mutating func removeDog(forDogId dogId: Int) throws
    
    /// Removes a dog at the given index
    mutating func removeDog(forIndex index: Int)
    
    /// Finds dog with the provided dogId then replaces it with the newDog
    mutating func changeDog(forDogId dogId: Int, newDog: Dog) throws
    
    /// Synchronizes the skip status of weekly and monthly reminders. If one of these reminders was skipping, it looks to see if the skip date has passed and it should revert to normal. E.g. Its Monday night and I skip my daily morning alarm, when the app loads up Tuesday afternoon this method will remove the skip status from the alarm (as Tuesday morning was skipped and passed) and allow it to execute on the next morning (Wednesday morning).
    mutating func synchronizeIsSkipping()
    
    /// Returns reference of a dog with the given dogId
    func findDog(forDogId dogId: Int) throws -> Dog
    
    /// Returns the index of a dog with the given dogId
    func findIndex(forDogId dogId: Int) throws -> Int
    
    mutating func clearAllPresentationHandled()
}

extension DogManagerProtocol {
    
    func findDog(forDogId dogId: Int) throws -> Dog {
        for d in 0..<dogs.count where dogs[d].dogId == dogId {
            return dogs[d]
        }
        
        throw DogManagerError.dogIdNotPresent
    }
    
    func findIndex(forDogId dogId: Int) throws -> Int {
        for d in 0..<dogs.count where dogs[d].dogId == dogId {
            return d
        }
        
        throw DogManagerError.dogIdNotPresent
    }
    
    var hasCreatedReminder: Bool {
        for dog in 0..<dogs.count where dogs[dog].dogReminders.reminders.count > 0 {
            return true
        }
        return false
    }
    
    var hasCreatedDog: Bool {
        if dogs.count > 0 {
            return true
        }
        else {
            return false
        }
    }
    
    var hasEnabledReminder: Bool {
        for dog in dogs {
            for reminder in dog.dogReminders.reminders where reminder.isEnabled == true {
                return true
            }
        }
        return false
    }
    
    var enabledTimersCount: Int {
        var count = 0
        for d in 0..<MainTabBarViewController.staticDogManager.dogs.count {
            
            for r in 0..<MainTabBarViewController.staticDogManager.dogs[d].dogReminders.reminders.count {
                guard MainTabBarViewController.staticDogManager.dogs[d].dogReminders.reminders[r].isEnabled == true else {
                    continue
                }
                
                count += 1
            }
        }
        return count
    }
    
    mutating func clearAllPresentationHandled() {
        for dog in dogs {
            for reminder in dog.dogReminders.reminders {
                reminder.isPresentationHandled = false
            }
        }
    }
    
}

class DogManager: NSObject, DogManagerProtocol, NSCopying, NSCoding {
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogManager()
        for i in 0..<dogs.count {
            copy.storedDogs.append(dogs[i].copy() as! Dog)
        }
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        storedDogs = aDecoder.decodeObject(forKey: "dogs") as? [Dog] ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedDogs, forKey: "dogs")
    }
    
    // MARK: - Main
    
    /// initalizes, sets dogs to []
    override init() {
        super.init()
    }
    
    convenience init(forDogs dogs: [Dog]) {
        self.init()
        // verifys dogs and fixes if broken
        self.addDogs(newDogs: dogs)
    }
    
    func synchronizeIsSkipping() {
        
        for dogIndex in 0..<dogs.count {
            for reminderIndex in 0..<dogs[dogIndex].dogReminders.reminders.count {
                
                let reminder: Reminder = dogs[dogIndex].dogReminders.reminders[reminderIndex]
                
                guard reminder.isEnabled == true else {
                    continue
                }
                
                let unskipDate = reminder.unskipDate()
                
                if unskipDate != nil && Date().distance(to: unskipDate!) < 0 {
                    if reminder.reminderType == .weekly {
                        reminder.changeIsSkipping(newSkipStatus: true)
                    }
                    else {
                        reminder.changeIsSkipping(newSkipStatus: true)
                    }
                    reminder.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
                }
            }
        }
    }
    
    private var storedDogs: [Dog] = []
    /// Array of dogs
    var dogs: [Dog] { return storedDogs }
    
    func addDog(newDog: Dog) {
        
        // removes any existing dogs that have the same dogId as they would cause problems. .reversed() is needed to make it work, without it there will be an index of out bounds error.
        for (dogIndex, dog) in dogs.enumerated().reversed() where dog.dogId == newDog.dogId {
            storedDogs.remove(at: dogIndex)
        }
        
        storedDogs.append(newDog)
    }
    
    func addDogs(newDogs: [Dog]) {
        for i in 0..<newDogs.count {
            addDog(newDog: newDogs[i])
        }
    }
    
    func changeDog(forDogId dogId: Int, newDog: Dog) throws {
        var newDogIndex: Int?
        
        for i in 0..<dogs.count where dogs[i].dogId == dogId {
            newDogIndex = i
        }
        
        if newDogIndex == nil {
            throw DogManagerError.dogIdNotPresent
        }
        else {
            storedDogs[newDogIndex!] = newDog
        }
    }
    
    func removeDog(forDogId dogId: Int) throws {
        var matchingDogIndex: Int?
        
        for (index, dog) in dogs.enumerated() where dog.dogId == dogId {
            matchingDogIndex = index
            break
        }
        
        if matchingDogIndex == nil {
            throw DogManagerError.dogIdNotPresent
        }
        else {
            storedDogs.remove(at: matchingDogIndex!)
        }
    }
    
    func removeDog(forIndex index: Int) {
        storedDogs.remove(at: index)
    }
    
}

protocol DogManagerControlFlowProtocol {
    
    /// Returns a copy of DogManager, used to avoid accidental changes (due to reference type) by classes which get their dog manager from here
    func getDogManager() -> DogManager
    
    /// Sets DogManger equal to newDogManager, depending on sender will also call methods to propogate change.
    func setDogManager(sender: Sender, newDogManager: DogManager)
    
    /// Updates things dependent on dogManager
    func updateDogManagerDependents()
    
}
