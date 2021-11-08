//
//  TraitManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from DogSpecificationManager
enum TraitManagerError: Error{
    case nilName
    case blankName
    case invalidName
}

protocol TraitManagerProtocol{
    
    ///Icon for dog, default paw but can be picture from camera roll
    var icon: UIImage { get set }
    
    ///Resets to default
    mutating func resetIcon()
    
    ///logs that aren't attached to a reminder object, free standing with no timing involved
    var logs: [KnownLog] { get set }
    
    ///The dog's name
    var dogName: String { get }
    ///Changes the dog's name
    mutating func changeDogName(newDogName: String?) throws
    
    ///The dog's description
    //var dogDescription: String { get }
    ///Changes the dog's description
    //mutating func changeDogDescription(newDogDescription: String) throws
}

class TraitManager: NSObject, NSCoding, NSCopying, TraitManagerProtocol {
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        icon = aDecoder.decodeObject(forKey: "icon") as! UIImage
        storedDogName = aDecoder.decodeObject(forKey: "dogName") as! String
        logs = aDecoder.decodeObject(forKey: "logs") as! [KnownLog]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedDogName, forKey: "dogName")
        aCoder.encode(logs, forKey: "logs")
        aCoder.encode(icon, forKey: "icon")
    }
    
    //MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TraitManager()
        copy.icon = self.icon
        copy.storedDogName = self.storedDogName
        copy.logs = self.logs
        return copy
    }
    
    
    override init() {
        super.init()
    }
    
    var icon: UIImage = UIImage.init(named: "pawFullResolutionWhite")!
    
    func resetIcon(){
        icon = UIImage.init(named: "pawFullResolutionWhite")!
    }
    
    var logs: [KnownLog] = []
    
    private var storedDogName: String = DogConstant.defaultName
    var dogName: String { return storedDogName }
    func changeDogName(newDogName: String?) throws {
        if newDogName == nil {
            throw TraitManagerError.nilName
        }
        else if newDogName!.trimmingCharacters(in: .whitespaces) == ""{
            throw TraitManagerError.blankName
        }
        else {
            storedDogName = newDogName!
        }
    }
    
    
}
