//
//  DogSpecificationManager.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogSpecificationManagerError: Error{
    case invalidKey(String?)
    case invalidNewValue(String?)
}

protocol DogSpecificationManagerProtocol {
    
    init()
    
   
    
    //dogSpecifications
    var dogSpecifications: Dictionary<String,String?> { get set }
    
    func initalizeDogSpecificationDictionary()
    
    //Management of dogSpecifcations dictionary
    mutating func changeDogSpecifications(key: String?, newValue: String?) throws
    
    func checkDogSpecificationValueValid(key: String?, value: String?) -> Bool
    func checkDogSpecificationKeyValid(key: String?) -> Bool
    
    mutating func clearDogSpecificationsValues()
}

extension DogSpecificationManagerProtocol {
    //MARK: dogSpecifications dictionary management extension
    
    //function to change the value of the dictionary dogSpecifications at the position given by the key, checks to see if valid
    mutating func changeDogSpecifications(key: String?, newValue: String?) throws {
        if checkDogSpecificationKeyValid(key: key) == false {
            throw DogSpecificationManagerError.invalidKey(key)
        }
        else if checkDogSpecificationValueValid(key: key, value: newValue) == false {
            throw DogSpecificationManagerError.invalidNewValue(newValue)
        }
        else {
            dogSpecifications[key!] = newValue!
        }
    }
    
    //checks to see if the dogSpecifications dictionary contains the given value at the given key spot, returns false if key is invalid; later implementation for value checking tbd
    func checkDogSpecificationValueValid(key: String?, value: String?) -> Bool {
        if checkDogSpecificationKeyValid(key: key) == false {
            return false
        }
        
        else if value == nil {
            return false
        }
        else{
        //later implementation
        return true
        }
    }
    
    //checks to see if the dogSpecifications dictionary contains the given key, true if it does
    func checkDogSpecificationKeyValid(key: String?) -> Bool{
        if key == nil {
            return false
        }
        else{
            return dogSpecifications.keys.contains(key!)
        }
    }
    
    //goes through all keys in dogSpecifications and resets all values to ""
    mutating func clearDogSpecificationsValues(){
        for (key, _) in dogSpecifications{
            dogSpecifications[key] = ""
        }
    }
    
}
