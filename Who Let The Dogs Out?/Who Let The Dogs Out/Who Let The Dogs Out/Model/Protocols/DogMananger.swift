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
}

protocol DogManagerProtocol {
    
    var dogs: [Dog] { get set }
    
    init()
    
    mutating func addDog(dogAdded: Dog) throws
    
    mutating func removeDog(name dogRemoved: String) throws
    
    mutating func changeDogName(dogNameToBeChanged: String, newDogName: String) throws
    
}

extension DogManagerProtocol {
    mutating func addDog(dogAdded: Dog) throws {
        
        if dogAdded.dogSpecifications.dogSpecificationsDictionary["name"] == nil{
            throw DogManagerError.dogNameInvalid
        }
            
        else if dogAdded.dogSpecifications.dogSpecificationsDictionary["name"] == ""{
            throw DogManagerError.dogNameInvalid
        }
            
        else{
         try dogs.forEach { (dog) in
            if dog.dogSpecifications.dogSpecificationsDictionary["name"]!!.lowercased() == dogAdded.dogSpecifications.dogSpecificationsDictionary["name"]!!.lowercased(){
                throw DogManagerError.dogNameAlreadyPresent
                }
            }
        }
        
        dogs.append(dogAdded)
        
    }
    
    mutating func removeDog(name dogRemovedName: String) throws {
        var matchingDog: (Bool, Int?) = (false, nil)
        
        if dogRemovedName == "" {
            throw DogManagerError.dogNameInvalid
        }
        
        for (index, dog) in dogs.enumerated(){
            if dog.dogSpecifications.dogSpecificationsDictionary["name"]!!.lowercased() == dogRemovedName.lowercased(){
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
}
