//
//  DogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from DogManager
enum DogManagerError: Error{
    case dogNameBlank
    case dogNameInvalid
    case dogNameNotPresent
    case dogNameAlreadyPresent
}

///Protocol outlining functionality of DogManger
protocol DogManagerProtocol {
    
    var dogs: [Dog] { get set }
    
    ///Returns true if any the dogs present has atleast 1 reminder, if there is no reminder present under any of the dogs (e.g. 0 reminders total) return false
    var hasCreatedReminder: Bool { get }
    
    ///Returns true if any dogs are present, if there is dogs present/created then returns false
    var hasCreatedDog: Bool { get }
    
    ///Returns true if any the dogs present has atleast 1 enabled reminder, if there is no enabled reminder present under any of the dogs (e.g. 0  enabled reminders total) return false
    var hasEnabledReminder: Bool { get }
    
    ///Counts up all enabled reminders under all enabled dogs, does not factor in isPaused, purely self
    var enabledTimersCount: Int { get }
    
    ///returns self but with only enabled dogs with enabled reminders
    var activeDogManager: DogManager { get }
    
    ///Checks dog name to see if its valid and checks to see if it is valid in context of other dog names already present, assumes reminders and traits are already validiated
     mutating func addDog(dogAdded: Dog) throws
    
    ///Adds array of dog to dogs
    mutating func addDog(dogsAdded: [Dog]) throws
    
    ///clears and sets dogs equal to dogsSet
    mutating func setDog(dogsSet: [Dog]) throws
    
    ///removes a dog with the given name
    mutating func removeDog(name dogRemoved: String) throws
    
    ///removes all dogs from dogs
    mutating func clearDogs()
    
    ///Changes a dog, takes a dog name and finds the corropsonding dog then replaces it with a new, different dog reference
    mutating func changeDog(dogNameToBeChanged: String, newDog: Dog) throws
    
    ///If a time of day alarm was skipping, looks and sees if it has passed said skipped time and should go back to normal
    mutating func synchronizeIsSkipping()
    
    ///finds and returns a reference to a dog matching the given name
    func findDog(dogName dogToBeFound: String) throws -> Dog
    
    ///finds and returns the index of a dog with a given name in terms of the dogs: [Dog] array
    func findIndex(dogName dogToBeFound: String) throws -> Int
    
    mutating func clearAllPresentationHandled()
}

extension DogManagerProtocol {
    
    mutating func addDog(dogAdded: Dog) throws {
        /*
         if try! dogAdded.dogTraits.dogName == nil{
         throw DogManagerError.dogNameInvalid
         }
         */
        
        if dogAdded.dogTraits.dogName == ""{
            throw DogManagerError.dogNameBlank
        }
        
        else{
            try dogs.forEach { (dog) in
                if dog.dogTraits.dogName.lowercased() == dogAdded.dogTraits.dogName.lowercased(){
                    throw DogManagerError.dogNameAlreadyPresent
                }
            }
        }
        
        dogs.append(dogAdded)
    }
    
    
    mutating func addDog(dogsAdded: [Dog]) throws{
        for i in 0..<dogsAdded.count{
            try addDog(dogAdded: dogsAdded[i])
        }
    }
    
    
    mutating func setDog(dogsSet: [Dog]) throws{
        clearDogs()
        try addDog(dogsAdded: dogsSet)
    }
    
   
    mutating func removeDog(name dogRemovedName: String) throws {
        var matchingDog: (Bool, Int?) = (false, nil)
        
        if dogRemovedName == "" {
            throw DogManagerError.dogNameInvalid
        }
        
        for (index, dog) in dogs.enumerated(){
            if dog.dogTraits.dogName.lowercased() == dogRemovedName.lowercased(){
                matchingDog = (true, index)
            }
        }
        
        if matchingDog.0 == false {
            throw DogManagerError.dogNameNotPresent
        }
        else {
            dogs.remove(at: matchingDog.1!)
        }
    }
    
    
    mutating func clearDogs(){
        dogs.removeAll()
    }
    
    
    mutating func changeDog(dogNameToBeChanged: String, newDog: Dog) throws{
        var newDogIndex: Int?
        
        for i in 0..<dogs.count{
            if dogs[i].dogTraits.dogName == dogNameToBeChanged {
                newDogIndex = i
            }
        }
        
        if newDogIndex == nil{
            throw DogManagerError.dogNameNotPresent
        }
        
        else{
            dogs[newDogIndex!] = newDog
        }
    }
    
    mutating func synchronizeIsSkipping(){
        let activeDogManager = self.activeDogManager
        
        for dogIndex in 0..<activeDogManager.dogs.count{
            for reminderIndex in 0..<activeDogManager.dogs[dogIndex].dogReminders.reminders.count{
                let reminder = activeDogManager.dogs[dogIndex].dogReminders.reminders[reminderIndex]
                
                let unskipDate = reminder.timeOfDayComponents.unskipDate(timerMode: reminder.timerMode, reminderExecutionBasis: reminder.executionBasis)
                
                if unskipDate != nil && Date().distance(to: unskipDate!) < 0{
                    self.dogs[dogIndex].dogReminders.reminders[reminderIndex].timeOfDayComponents.changeIsSkipping(newSkipStatus: true, shouldRemoveLogDuringPossibleUnskip: nil)
                    self.dogs[dogIndex].dogReminders.reminders[reminderIndex].changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
                }
            }
        }
    }
    
    
    func findDog(dogName dogToBeFound: String) throws -> Dog {
        for d in 0..<dogs.count{
            if dogs[d].dogTraits.dogName == dogToBeFound{
                return dogs[d]
            }
        }
        
        throw DogManagerError.dogNameNotPresent
    }
    
    
    func findIndex(dogName dogToBeFound: String) throws -> Int{
        for d in 0..<dogs.count{
            if dogs[d].dogTraits.dogName == dogToBeFound {
                return d
            }
        }
        throw DogManagerError.dogNameNotPresent
    }
    
    var hasCreatedReminder: Bool {
        for dog in 0..<dogs.count {
            if dogs[dog].dogReminders.reminders.count > 0 {
                return true
            }
        }
        return false
    }
    
    var hasCreatedDog: Bool {
        for _ in dogs {
            return true
        }
        return false
    }
    
    var hasEnabledReminder: Bool {
        for dog in dogs {
            for reminder in dog.dogReminders.reminders {
                if reminder.getEnable() == true {
                    return true
                }
            }
        }
        return false
    }
    
    var enabledTimersCount: Int {
        var count = 0
        for d in 0..<MainTabBarViewController.staticDogManager.dogs.count {
            
            for r in 0..<MainTabBarViewController.staticDogManager.dogs[d].dogReminders.reminders.count {
                guard MainTabBarViewController.staticDogManager.dogs[d].dogReminders.reminders[r].getEnable() == true else{
                    continue
                }
                
                count = count + 1
            }
        }
        return count
    }
    
    mutating func clearAllPresentationHandled(){
        for dog in dogs{
            for reminder in dog.dogReminders.reminders{
                reminder.isPresentationHandled = false
            }
        }
    }
    
    
}

class DogManager: NSObject, DogManagerProtocol, NSCopying, NSCoding {
    
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        dogs = aDecoder.decodeObject(forKey: "dogs") as! [Dog]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogs, forKey: "dogs")
    }
    
    //MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogManager()
        for i in 0..<dogs.count{
            copy.dogs.append(dogs[i].copy() as! Dog)
        }
        return copy
    }
    
    ///Array of dogs
    var dogs: [Dog]
    
    ///initalizes, sets dogs to []
    override init(){
        dogs = []
        super.init()
    }
    
    var activeDogManager: DogManager{
        var activeDogManager = DogManager()
        activeDogManager.dogs.removeAll()
        
        for d in 0..<self.dogs.count {
            
            let dogAdd = self.dogs[d].copy() as! Dog
            dogAdd.dogReminders.removeAllReminders()
            
            for r in 0..<self.dogs[d].dogReminders.reminders.count {
                guard self.dogs[d].dogReminders.reminders[r].getEnable() == true else{
                    continue
                }
                
                try! dogAdd.dogReminders.addReminder(newReminder: self.dogs[d].dogReminders.reminders[r].copy() as! Reminder)
            }
            
            try! activeDogManager.addDog(dogAdded: dogAdd)
        }
        
        return activeDogManager
    }
    
}

protocol DogManagerControlFlowProtocol {
    
    ///Returns a copy of DogManager, used to avoid accidental changes (due to reference type) by classes which get their dog manager from here
    func getDogManager() -> DogManager
    
    ///Sets DogManger equal to newDogManager, depending on sender will also call methods to propogate change.
    func setDogManager(sender: Sender, newDogManager: DogManager)
    
    ///Updates things dependent on dogManager
    func updateDogManagerDependents()
    
}
