//
//  DogManager.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from DogManager
enum DogManagerError: Error{
    case dogNameNotPresent
    case dogNameAlreadyPresent
    case dogNameInvalid
    case dogNameBlank
}

///Protocol outlining functionality of DogManger
protocol DogManagerProtocol {
    
    var dogs: [Dog] { get set }
    
    mutating func addDog(dogAdded: Dog) throws
    mutating func addDog(dogsAdded: [Dog]) throws
    
    mutating func setDog(dogsSet: [Dog]) throws
    
    mutating func removeDog(name dogRemoved: String) throws
    
    mutating func clearDogs()
    
    //mutating func changeDogName(dogNameToBeChanged: String, newDogName: String) throws
    
    mutating func changeDog(dogNameToBeChanged: String, newDog: Dog) throws
    
    func findDog(dogName dogToBeFound: String) throws -> Dog
    
    func findIndex(dogName dogToBeFound: String) throws -> Int
    
    func revokeIsPresentationHandled()
}

extension DogManagerProtocol {
    
    ///Checks dog name to see if its valid and checks to see if it is valid in context of other dog names already present, assumes requirements and specifications are already validiated
    mutating func addDog(dogAdded: Dog) throws {
        /*
         if try! dogAdded.dogSpecifications.getDogSpecification(key: "name") == nil{
         throw DogManagerError.dogNameInvalid
         }
         */
        
        if try! dogAdded.dogSpecifications.getDogSpecification(key: "name") == ""{
            throw DogManagerError.dogNameBlank
        }
        
        else{
            try dogs.forEach { (dog) in
                if try! dog.dogSpecifications.getDogSpecification(key: "name").lowercased() == dogAdded.dogSpecifications.getDogSpecification(key: "name").lowercased(){
                    throw DogManagerError.dogNameAlreadyPresent
                }
            }
        }
        
        dogs.append(dogAdded.copy() as! Dog)
        
    }
    
    ///Adds array of dog to dogs
    mutating func addDog(dogsAdded: [Dog]) throws{
        for i in 0..<dogsAdded.count{
            try addDog(dogAdded: dogsAdded[i])
        }
    }
    
    ///clears and sets dogs equal to dogsSet
    mutating func setDog(dogsSet: [Dog]) throws{
        clearDogs()
        try addDog(dogsAdded: dogsSet)
    }
    
    ///removes a dog the given name
    mutating func removeDog(name dogRemovedName: String) throws {
        var matchingDog: (Bool, Int?) = (false, nil)
        
        if dogRemovedName == "" {
            throw DogManagerError.dogNameInvalid
        }
        
        for (index, dog) in dogs.enumerated(){
            if try! dog.dogSpecifications.getDogSpecification(key: "name").lowercased() == dogRemovedName.lowercased(){
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
    
    ///removes all dogs from dogs
    mutating func clearDogs(){
        dogs.removeAll()
    }
    
    ///Changes a dog, takes a dog name and finds the corropsonding dog then replaces it with a new, different dog reference
    mutating func changeDog(dogNameToBeChanged: String, newDog: Dog) throws{
        var newDogIndex: Int?
        
        for i in 0..<dogs.count{
            if try! dogs[i].dogSpecifications.getDogSpecification(key: "name") == dogNameToBeChanged {
                newDogIndex = i
            }
        }
        
        if newDogIndex == nil{
            throw DogManagerError.dogNameNotPresent
        }
        
        else{
            dogs[newDogIndex!] = newDog.copy() as! Dog
        }
    }
    
    ///finds and returns a reference to a dog matching the given name
    func findDog(dogName dogToBeFound: String) throws -> Dog {
        for d in 0..<dogs.count{
            if try dogs[d].dogSpecifications.getDogSpecification(key: "name") == dogToBeFound{
                return dogs[d]
            }
        }
        
        throw DogManagerError.dogNameNotPresent
    }
    
    ///finds and returns the index of a dog with a given name in terms of the dogs: [Dog] array
    func findIndex(dogName dogToBeFound: String) throws -> Int{
        for d in 0..<dogs.count{
            if try! dogs[d].dogSpecifications.getDogSpecification(key: "name") == dogToBeFound {
                return d
            }
        }
        throw DogManagerError.dogNameNotPresent
    }
    
    ///If the application is terminated while one of the alertcontrollers is poped up, .isPresentationHandled stays true for the requirement but the alert controller is killed and never compleded, when the app is restarted it believes there is an alertcontroller already queued for the past due requirement but that alert controller isn't present because it was destroyed.
    func revokeIsPresentationHandled() {
        for dog in dogs {
            for req in dog.dogRequirments.requirements{
                req.isPresentationHandled = false
            }
        }
    }
}

class DogManager: NSObject, DogManagerProtocol, NSCopying, NSCoding {
    
    //MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        dogs = aDecoder.decodeObject(forKey: "dogs") as! [Dog]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogs, forKey: "dogs")
    }
    
    //MARK: NSCopying
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
    
}

protocol DogManagerControlFlowProtocol {
    
    ///Returns a copy of DogManager, used to avoid accidental changes (due to reference type) by classes which get their dog manager from here
    func getDogManager() -> DogManager
    
    ///Sets DogManger equal to newDogManager, depending on sender will also call methods to propogate change.
    func setDogManager(sender: Sender, newDogManager: DogManager)
    
    ///Updates things dependent on dogManager
    func updateDogManagerDependents()
    
}
