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
    required init(dogName: String?, dogDescription: String?, dogBreed: String?) {
        var tempDogSpecification = Dictionary<String,String?>()
        tempDogSpecification["name"] = dogName
        tempDogSpecification["description"] = dogDescription
        tempDogSpecification["breed"] = dogBreed
        dogSpecification = tempDogSpecification
    }
    
    var dogSpecification: Dictionary<String, String?>
    
    //attributes
        //naming and description, use seperate class
        //requirements, pull from requirement manager
    //functions
}
