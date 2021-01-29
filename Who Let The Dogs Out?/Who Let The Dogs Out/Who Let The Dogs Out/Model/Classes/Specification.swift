//
//  Specification.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

/*
class Specification {
    
}
 */

class SpecificationManager {
    
    private var dogSpecificationsDictionary: Dictionary<String, String> = Dictionary<String,String>()
    
    init() {
        initalizeDogSpecificationDictionary()
    }
    
    private func initalizeDogSpecificationDictionary(){
        for i in 0..<DogConstant.defaultDogSpecificationKeys.count{
            dogSpecificationsDictionary[DogConstant.defaultDogSpecificationKeys[i].0] = DogConstant.defaultDogSpecificationKeys[i].1
        }
    }
    
    func getDogSpecification(key: String?) throws -> String{
        try checkDogSpecificationKeyValid(key: key)
        return dogSpecificationsDictionary[key!]!
    }
    
    //function to change the value of the dictionary dogSpecifications at the position given by the key, checks to see if valid
    func changeDogSpecifications(key: String?, newValue: String?) throws {
        try checkDogSpecificationValueValid(key: key, value: newValue)
        dogSpecificationsDictionary[key!] = newValue!
    }
    
    //checks to see if the dogSpecifications dictionary contains the given value at the given key spot, returns false if key is invalid; later implementation for value checking tbd
    private func checkDogSpecificationValueValid(key: String?, value: String?) throws {
        try checkDogSpecificationKeyValid(key: key)
        if value == nil{
            throw DogSpecificationManagerError.nilNewValue(key!)
        }
        else if value == "" && key! == "name"{
            throw DogSpecificationManagerError.blankNewValue(key!)
        }
        else{
            
        }
    }
    
    //checks to see if the dogSpecifications dictionary contains the given key, true if it does
    private func checkDogSpecificationKeyValid(key: String?) throws{
        var keyPresent = false
        for i in 0..<DogConstant.defaultDogSpecificationKeys.count{
            if key == DogConstant.defaultDogSpecificationKeys[i].0{
                keyPresent = true
            }
        }
        if keyPresent == false{
            throw DogSpecificationManagerError.keyNotPresentInGlobalConstantList
        }
        
        if key == nil {
            throw DogSpecificationManagerError.nilKey
        }
        else if key == ""{
            throw DogSpecificationManagerError.blankKey
        }
        else if dogSpecificationsDictionary.keys.contains(key!) == false{
            throw DogSpecificationManagerError.invalidKey
        }
        else{
            
        }
    }
    
    //goes through all keys in dogSpecifications and resets all values to ""
    func clearDogSpecificationsValues(){
        for (key, _) in dogSpecificationsDictionary{
            dogSpecificationsDictionary[key] = ""
        }
    }
    
    
}
