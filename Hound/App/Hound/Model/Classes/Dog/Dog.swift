//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Dog: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = try! Dog(dogName: self.dogName)
        copy.dogId = self.dogId
        copy.dogName = self.dogName
        copy.dogIcon = self.dogIcon
        copy.dogReminders = self.dogReminders.copy() as? ReminderManager ?? ReminderManager()
        copy.dogLogs = self.dogLogs.copy() as? LogManager ?? LogManager()
        return copy
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        super.init()
        dogId = aDecoder.decodeInteger(forKey: "dogId")
        dogName = aDecoder.decodeObject(forKey: "dogName") as? String ?? UUID().uuidString
        dogIcon = aDecoder.decodeObject(forKey: "dogIcon") as? UIImage ?? DogConstant.defaultDogIcon
        dogLogs = aDecoder.decodeObject(forKey: "dogLogs") as? LogManager ?? LogManager()
        dogReminders = aDecoder.decodeObject(forKey: "dogReminders") as? ReminderManager ?? ReminderManager()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogId, forKey: "dogId")
        aCoder.encode(dogName, forKey: "dogName")
        aCoder.encode(dogIcon, forKey: "dogIcon")
        aCoder.encode(dogLogs, forKey: "dogLogs")
        aCoder.encode(dogReminders, forKey: "dogReminders")
    }
    
    // MARK: - Main
    
    init(dogName: String?) throws {
        super.init()
        if dogName == nil {
            throw DogError.dogNameNil
        }
        else if dogName!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            throw DogError.dogNameBlank
        }
        self.dogName = dogName!
    }
    
    convenience init(dogId: Int = DogConstant.defaultDogId, dogName: String?, dogIcon: UIImage = DogConstant.defaultDogIcon) throws {
        try self.init(dogName: dogName)
        
        self.dogId = dogId
        self.dogIcon = dogIcon
    }
    
    /// Assume array of dog properties
    convenience init(fromBody body: [String: Any]) {
        
        // make sure the dog isn't deleted, otherwise it returns nil (indicating there is no dog left)
        // guard body[ServerDefaultKeys.dogIsDeleted.rawValue] as? Bool ?? false == false else {
        //   return nil
        // }
        
        let dogId = body[ServerDefaultKeys.dogId.rawValue] as? Int ?? DogConstant.defaultDogId
        let dogName = body[ServerDefaultKeys.dogName.rawValue] as? String ?? DogConstant.defaultDogName
        
        try! self.init(dogId: dogId, dogName: dogName, dogIcon: LocalDogIcon.getIcon(forDogId: dogId) ?? DogConstant.defaultDogIcon)
        
        dogIsDeleted = body[ServerDefaultKeys.dogIsDeleted.rawValue] as? Bool ?? false
        
        // check for any reminders
        if let reminderBodies = body[ServerDefaultKeys.reminders.rawValue] as? [[String: Any]] {
            dogReminders = ReminderManager(fromBody: reminderBodies)
        }
        
        // check for any logs
        if let logBodies = body[ServerDefaultKeys.logs.rawValue] as? [[String: Any]] {
            dogLogs = LogManager(fromBody: logBodies)
        }
    }
    
    // MARK: - Properties
    
    var dogId: Int = DogConstant.defaultDogId
    
    /// This property a marker leftover from when we went through the process of constructing a new dog from JSON and combining with an existing dog object. This markers allows us to have a new dog to overwrite the old dog, then leaves an indicator that this should be deleted. This deletion is handled by DogsRequest
    private(set) var dogIsDeleted: Bool = false
    
    // MARK: - Traits
    
    var dogIcon: UIImage = DogConstant.defaultDogIcon
    
    func resetIcon() {
        dogIcon = DogConstant.defaultDogIcon
    }
    
    // TO DO limit dogName to 32 characters
    private(set) var dogName: String = DogConstant.defaultDogName
    func changeDogName(newDogName: String?) throws {
        if newDogName == nil {
            throw DogError.dogNameNil
        }
        else if newDogName!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            throw DogError.dogNameBlank
        }
        else {
            dogName = newDogName!
        }
    }
    
    /// ReminderManager that handles all specified reminders for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogReminders: ReminderManager = ReminderManager()
    
    /// LogManager that handles all the logs for a dog
    var dogLogs: LogManager = LogManager()
    
    // MARK: - Manipulation
    
    /// Combines all of the reminders and logs in union fashion to the current dog. If a reminder or log exists in either of the dogs, then they will be present after this function is done. If a reminder or log is present in both of the dogs, the oldDog's reminder/log will be overriden with the newDogs (this object's) reminder/log
    func combine(withOldDog oldDog: Dog) {
        dogLogs.combine(withOldLogManager: oldDog.dogLogs)
        dogReminders.combine(withOldReminderManager: oldDog.dogReminders)
    }
}

extension Dog {
    // MARK: - Request
    
    /// Returns an array literal of the dog's properties (does not include nested properties, e.g. logs or reminders). This is suitable to be used as the JSON body for a HTTP request
    func createBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultKeys.dogName.rawValue] = dogName
        return body
    }
}
