//
//  Dog.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Dog: DogSpecificationManagerProtocol {
    
    
    //MARK: DogSpecificationManagerProtocol implementation
    
    //initalizes dictionary of specifications for the dog, each key e.g. "name", "breed" had default values
    required init() {
        initalizeDogSpecificationDictionary()
    }
    
    //dictionary of specifications for a dog, e.g. "name", "breed", "description"
    var dogSpecifications: Dictionary<String, String?> = Dictionary<String,String?>()
    
    //RequirmentManager that handles all specified requirements for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogRequirments: RequirementManager = RequirementManager()
    
    //initalizes dictionary default values
    internal func initalizeDogSpecificationDictionary(){
        dogSpecifications["name"] = DogConstant.defaultLabel
        dogSpecifications ["description"] = DogConstant.defaultDescription
        dogSpecifications ["breed"] = DogConstant.defaultBreed
    }
    
    //functions
    
}

class DogManager {
    
}
