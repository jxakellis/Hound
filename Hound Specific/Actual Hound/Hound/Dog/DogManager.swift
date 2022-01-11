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
    
    ///Stores all the dogs. This is get only to make sure integrite of dogs added is kept
    var dogs: [Dog] { get }
    
    ///Returns true if ANY the dogs present has at least 1 CREATED reminder
    var hasCreatedReminder: Bool { get }
    
    ///Returns true if dogs.count > 0
    var hasCreatedDog: Bool { get }
    
    ///Returns true if ANY the dogs present has at least 1 ENABLED reminder
    var hasEnabledReminder: Bool { get }
    
    ///Returns number of reminders that are enabled and therefore have a timer. Does not factor in isPaused.
    var enabledTimersCount: Int { get }
    
    ///Adds a dog to dogs, checks to see if the dog itself is valid, e.g. its name is unique. Currently does NOT override other dogs
     mutating func addDog(newDog: Dog) throws
    
    ///Adds array of dogs with addDog(newDog: Dog) repition
    mutating func addDogs(newDogs: [Dog]) throws
    
    ///Removes a dog with the given name
    mutating func removeDog(forName name: String) throws
    
    ///Removes a dog at the given index
    mutating func removeDog(forIndex index: Int)
    
    ///Finds dog with the provided name then replaces it with the newDog
    mutating func changeDog(forName name: String, newDog: Dog) throws
    
    ///Synchronizes the skip status of weekly and monthly reminders. If one of these reminders was skipping, it looks to see if the skip date has passed and it should revert to normal. E.g. Its Monday night and I skip my daily morning alarm, when the app loads up Tuesday afternoon this method will remove the skip status from the alarm (as Tuesday morning was skipped and passed) and allow it to execute on the next morning (Wednesday morning).
    mutating func synchronizeIsSkipping()
    
    ///Returns reference of a dog with the given name
    func findDog(forName name: String) throws -> Dog
    
    ///Returns the index of a dog with the given name
    func findIndex(forName name: String) throws -> Int
    
    mutating func clearAllPresentationHandled()
}

extension DogManagerProtocol {
    
    func findDog(forName name: String) throws -> Dog {
        for d in 0..<dogs.count{
            if dogs[d].dogTraits.dogName == name{
                return dogs[d]
            }
        }
        
        throw DogManagerError.dogNameNotPresent
    }
    
    
    func findIndex(forName name: String) throws -> Int{
        for d in 0..<dogs.count{
            if dogs[d].dogTraits.dogName == name {
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
    
    //MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogManager()
        for i in 0..<dogs.count{
            copy.storedDogs.append(dogs[i].copy() as! Dog)
        }
        return copy
    }
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        storedDogs = aDecoder.decodeObject(forKey: "dogs") as? [Dog] ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedDogs, forKey: "dogs")
    }
    
   
    
    ///initalizes, sets dogs to []
    override init(){
        storedDogs = []
        super.init()
    }
    
    func synchronizeIsSkipping(){
        
        for dogIndex in 0..<dogs.count{
            for reminderIndex in 0..<dogs[dogIndex].dogReminders.reminders.count{
                let reminder: Reminder = dogs[dogIndex].dogReminders.reminders[reminderIndex]
                
                guard reminder.getEnable() == true else {
                    continue
                }
                
                let unskipDate = reminder.timeOfDayComponents.unskipDate(timerMode: reminder.timerMode, reminderExecutionBasis: reminder.executionBasis)
                
                if unskipDate != nil && Date().distance(to: unskipDate!) < 0{
                    self.dogs[dogIndex].dogReminders.reminders[reminderIndex].timeOfDayComponents.changeIsSkipping(newSkipStatus: true, shouldRemoveLogDuringPossibleUnskip: nil)
                    self.dogs[dogIndex].dogReminders.reminders[reminderIndex].changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
                }
            }
        }
    }
    
    private var storedDogs: [Dog]
    ///Array of dogs
    var dogs: [Dog] { return storedDogs}
    
    func addDog(newDog: Dog) throws {
        
        if newDog.dogTraits.dogName == ""{
            throw DogManagerError.dogNameBlank
        }
        
        else{
            try dogs.forEach { (dog) in
                if dog.dogTraits.dogName.lowercased() == newDog.dogTraits.dogName.lowercased(){
                    throw DogManagerError.dogNameAlreadyPresent
                }
            }
        }
        
        storedDogs.append(newDog)
        AppDelegate.endpointLogger.notice("ENDPOINT Add Dog")
    }
    
    
    func addDogs(newDogs: [Dog]) throws{
        for i in 0..<newDogs.count{
            try addDog(newDog: newDogs[i])
        }
    }
    
    func changeDog(forName name: String, newDog: Dog) throws{
        var newDogIndex: Int?
        
        for i in 0..<dogs.count{
            if dogs[i].dogTraits.dogName == name {
                newDogIndex = i
            }
        }
        
        if newDogIndex == nil{
            throw DogManagerError.dogNameNotPresent
        }
        
        else{
            storedDogs[newDogIndex!] = newDog
            AppDelegate.endpointLogger.notice("ENDPOINT Update Dog")
        }
    }
    
    func removeDog(forName name: String) throws {
        var matchingDog: (Bool, Int?) = (false, nil)
        
        if name == "" {
            throw DogManagerError.dogNameInvalid
        }
        
        for (index, dog) in dogs.enumerated(){
            if dog.dogTraits.dogName.lowercased() == name.lowercased(){
                matchingDog = (true, index)
            }
        }
        
        if matchingDog.0 == false {
            throw DogManagerError.dogNameNotPresent
        }
        else {
            storedDogs.remove(at: matchingDog.1!)
            AppDelegate.endpointLogger.notice("ENDPOINT Remove Dog (via name)")
        }
    }
    
    func removeDog(forIndex index: Int) {
        storedDogs.remove(at: index)
        AppDelegate.endpointLogger.notice("ENDPOINT Remove Dog (via index)")
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
