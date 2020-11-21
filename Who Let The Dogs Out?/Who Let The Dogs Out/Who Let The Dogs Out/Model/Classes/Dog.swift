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
        //initalizeds dogSpecifications to default nil values, use func later to change
        dogSpecifications = Dictionary<String,String?>()
        dogSpecifications["name"] = ""
        dogSpecifications ["description"] = ""
        dogSpecifications ["breed"] = ""
    }
    
    var dogSpecifications: Dictionary<String, String?>
    
    //attributes
        //naming and description, use seperate class
        //requirements, pull from requirement manager
    //functions
}
