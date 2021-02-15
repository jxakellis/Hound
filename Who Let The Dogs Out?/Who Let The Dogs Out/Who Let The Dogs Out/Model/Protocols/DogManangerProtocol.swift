//
//  File.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 12/8/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogManagerError: Error{
    case dogNameNotPresent
    case dogNameAlreadyPresent
    case dogNameInvalid
    case dogNameBlank
}

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
}

extension DogManagerProtocol {
    
    //ASSUME DOG ADDED IS A VALID DOG, due to it having to go through the DogSpecificationManager to change properties.
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
    
    mutating func clearDogs(){
        dogs.removeAll()
    }
    
    /*
     mutating func changeDogName(dogNameToBeChanged: String, newDogName: String) throws{
     var dogToBeChanged: (Bool, Int?) = (false, nil)
     for i in 0..<dogs.count{
     if try! dogs[i].dogSpecifications.getDogSpecification(key: "name").lowercased() == newDogName.lowercased(){
     if dogToBeChanged.0 == true{
     throw DogManagerError.dogNameAlreadyPresent
     }
     else{
     dogToBeChanged.0 = true
     dogToBeChanged.1 = i
     }
     }
     }
     if dogToBeChanged.0 == false{
     throw DogManagerError.dogNameNotPresent
     }
     else{
     try dogs[dogToBeChanged.1!].dogSpecifications.changeDogSpecifications(key: "name", newValue: newDogName)
     }
     }
     */
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
    
    func findDog(dogName dogToBeFound: String) throws -> Dog {
        for d in 0..<dogs.count{
            if try dogs[d].dogSpecifications.getDogSpecification(key: "name") == dogToBeFound{
                return dogs[d]
            }
        }
        
        throw DogManagerError.dogNameNotPresent
    }
    
    func findIndex(dogName dogToBeFound: String) throws -> Int{
        for d in 0..<dogs.count{
            if try! dogs[d].dogSpecifications.getDogSpecification(key: "name") == dogToBeFound {
                return d
            }
        }
        throw DogManagerError.dogNameNotPresent
    }
}

protocol DogManagerControlFlowProtocol {
    
    func getDogManager() -> DogManager
    
    func setDogManager(newDogManager: DogManager, sender: AnyObject?)
    
    func updateDogManagerDependents()
    
}
