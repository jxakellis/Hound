//
//  LocalDogIcon.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LocalDogIcon: NSObject, NSCoding {
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        dogId = aDecoder.decodeInteger(forKey: KeyConstant.dogId.rawValue)
        dogIcon = aDecoder.decodeObject(forKey: KeyConstant.dogIcon.rawValue) as? UIImage ?? dogIcon
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogId, forKey: KeyConstant.dogId.rawValue)
        aCoder.encode(dogIcon, forKey: KeyConstant.dogIcon.rawValue)
    }
    
    // MARK: - Main
    
    init(forDogId dogId: Int, forDogIcon dogIcon: UIImage) {
        super.init()
        self.dogId = dogId
        self.dogIcon = dogIcon
    }
    
    // MARK: - Properties
    
    var dogId: Int = ClassConstant.DogConstant.defaultDogId
    var dogIcon: UIImage = ClassConstant.DogConstant.defaultDogIcon
    
    // MARK: - Functions
    
    /// Attempts to retrieve the dogIcon for the provided dogId. If no dogIcon is found, then nil is returned
    static func getIcon(forDogId dogId: Int) -> UIImage? {
        // iterate through dogIcons to find if we have one stored under the dogId provided, if found then we return it
        for localDogIcon in LocalConfiguration.dogIcons where localDogIcon.dogId == dogId {
            return localDogIcon.dogIcon
        }
        return nil
    }
    
    /// Removes all LocalDogIcons stored in LocalConfiguration.dogIcons that match the provided dogId, then adds a LocalDogIcon to LocalConfiguration.dogIcons with the provided dogId and dogIcon.
    static func addIcon(forDogId dogId: Int, forDogIcon dogIcon: UIImage) {
        
        // remove all localDogIcons that have the same dogId as the new one, as those are duplicates, ideally there should be no matches
        LocalConfiguration.dogIcons.removeAll(where: { $0.dogId == dogId })
        // append new element after any duplicates removed
        LocalConfiguration.dogIcons.append(LocalDogIcon(forDogId: dogId, forDogIcon: dogIcon))
    }
    
    /// Goes through all LocalDogIcons stored in LocalConfiguration.dogIcons to find dogIds that are no longer stored on the server. This means the dog was deleted and we should delete
    static func checkForExtraIcons(forDogs dogs: [Dog]) {
        // iterate through the dogIds of the stored dogIcons
        // if the dogArray does not contain the dogIdKey from the dictionary, that means we are storing a dogId & UIImage key-value pair for a dog that no longer exists
        for localDogIcon in LocalConfiguration.dogIcons where dogs.contains(where: { $0.dogId == localDogIcon.dogId }) == false {
            // remove all localDogIcons that match the dogId. this is the dogId that is stored locally but was found to not be stored on the server data retrieved (aka it was deleted
            removeIcon(forDogId: localDogIcon.dogId)
        }
    }
    
    /// Removes all LocalDogIcons stored in LocalConfiguration.dogIcons that match the provided dogId
    static func removeIcon(forDogId dogId: Int) {
        // remove all localDogIcons that match the dogId, ideally there should be one match
        LocalConfiguration.dogIcons.removeAll(where: { $0.dogId == dogId })
    }
    
}
