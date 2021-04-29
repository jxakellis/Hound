//
//  Specification.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 1/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from DogSpecificationManager
enum DogTraitManagerError: Error{
    case nilName
    case blankName
    case invalidName
}

protocol DogTraitManagerProtocol{
    ///The dog's name
    var dogName: String { get }
    ///Changes the dog's name
    mutating func changeDogName(newDogName: String?) throws
    
    ///The dog's description
    //var dogDescription: String { get }
    ///Changes the dog's description
    //mutating func changeDogDescription(newDogDescription: String) throws
}

class DogTraitManager: NSObject, NSCoding, NSCopying, DogTraitManagerProtocol {
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        storedDogName = aDecoder.decodeObject(forKey: "dogName") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedDogName, forKey: "dogName")
    }
    
    //MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogTraitManager()
        copy.storedDogName = self.storedDogName
        return copy
    }
    
    
    override init() {
        super.init()
    }
    
    private var storedDogName: String = DogConstant.defaultName
    var dogName: String { return storedDogName }
    func changeDogName(newDogName: String?) throws {
        if newDogName == nil {
            throw DogTraitManagerError.nilName
        }
        else if newDogName!.trimmingCharacters(in: .whitespaces) == ""{
            throw DogTraitManagerError.blankName
        }
        else {
            storedDogName = newDogName!
        }
    }
    
}
