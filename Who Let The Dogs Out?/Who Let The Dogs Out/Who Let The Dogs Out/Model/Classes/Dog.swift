//
//  Dog.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Dog {
    
    //dictionary of specifications for a dog, e.g. "name", "breed", "description"
    var dogSpecifications: SpecificationManager = SpecificationManager()
    
    //RequirmentManager that handles all specified requirements for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogRequirments: RequirementManager = RequirementManager()
    
}

class DogManager {
    
}
