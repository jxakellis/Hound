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
    
    required init() {
        initalizeDogSpecificationDictionary()
    }
    
    var dogSpecifications: Dictionary<String, String?> = Dictionary<String,String?>()
    var dogRequirments: RequirementManager = RequirementManager()
    
    //initalizes dictionary default values
    func initalizeDogSpecificationDictionary(){
        dogSpecifications["name"] = DogConstant.defaultLabel
        dogSpecifications ["description"] = DogConstant.defaultDescription
        dogSpecifications ["breed"] = DogConstant.defaultBreed
    }
    
    //functions
    
}
