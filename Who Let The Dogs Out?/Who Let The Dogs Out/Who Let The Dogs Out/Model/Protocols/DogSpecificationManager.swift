//
//  DogSpecificationManager.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogSpecificationManagerError: Error{
    case invalidDogSpecification(String)
    case invalidNewValue(String)
}

protocol DogSpecificationManagerProtocol {
    
    init(dogName: String?, dogDescription: String?, dogBreed: String?)
    
    //name
    var dogSpecification: Dictionary<String,String?> { get set }
    
    mutating func changeDogSpecification(intendedDogSpecification: String, newValue: String) throws
    
}

extension DogSpecificationManagerProtocol {
    
    mutating func changeDogSpecification(intendedDogSpecification: String, newValue: String) throws {
        guard dogSpecification.keys.contains(intendedDogSpecification) else {
            throw DogSpecificationManagerError.invalidDogSpecification(intendedDogSpecification)
        }
        dogSpecification[intendedDogSpecification] = newValue
    }
}
