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
    
    var dogs: [Dog] { get }
    
    ///Returns true if any the dogs present has atleast 1 reminder, if there is no reminder present under any of the dogs (e.g. 0 reminders total) return false
    var hasCreatedReminder: Bool { get }
    
    ///Returns true if any dogs are present, if there is dogs present/created then returns false
    var hasCreatedDog: Bool { get }
    
    ///Returns true if any the dogs present has atleast 1 enabled reminder, if there is no enabled reminder present under any of the dogs (e.g. 0  enabled reminders total) return false
    var hasEnabledReminder: Bool { get }
    
    ///Counts up all enabled reminders under all enabled dogs, does not factor in isPaused, purely self
    var enabledTimersCount: Int { get }
    
    ///Checks dog name to see if its valid and checks to see if it is valid in context of other dog names already present, assumes reminders and traits are already validiated
     mutating func addDog(newDog: Dog) throws
    
    ///Adds array of dog to dogs
    mutating func addDogs(newDogs: [Dog]) throws
    
    ///removes a dog with the given name
    mutating func removeDog(forName name: String) throws
    
    ///removes dog at the given index
    mutating func removeDog(forIndex index: Int)
    
    ///removes all dogs from dogs
    mutating func clearDogs()
    
    ///Changes a dog, takes a dog name and finds the corropsonding dog then replaces it with a new, different dog reference
    mutating func changeDog(forName name: String, newDog: Dog) throws
    
    ///If a time of day alarm was skipping, looks and sees if it has passed said skipped time and should go back to normal
    mutating func synchronizeIsSkipping()
    
    ///finds and returns a reference to a dog matching the given name
    func findDog(forName name: String) throws -> Dog
    
    ///finds and returns the index of a dog with a given name in terms of the dogs: [Dog] array
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
       // let decoded: Data = aDecoder.decodeData()!
      //  let unarchived = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: decoded)! as! [Dog]
       // dogs = unarchived
        storedDogs = aDecoder.decodeObject(forKey: "dogs") as! [Dog]
    }
    
    func encode(with aCoder: NSCoder) {
       // let encoded = try! NSKeyedArchiver.archivedData(withRootObject: dogs, requiringSecureCoding: false)
      //  aCoder.encode(encoded)
        aCoder.encode(storedDogs, forKey: "dogs")
    }
    
    //static var supportsSecureCoding: Bool = true
    
   
    
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
        print("ENDPOINT Add Dog")
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
            print("ENDPOINT Update Dog")
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
            print("ENDPOINT Remove Dog (via name)")
        }
    }
    
    func removeDog(forIndex index: Int) {
        storedDogs.remove(at: index)
        print("ENDPOINT Remove Dog (via index)")
    }
    
    func clearDogs(){
        storedDogs.removeAll()
        print("ENDPOINT Remove All Dogs (ignore)")
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
