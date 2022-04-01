//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogError: String, Error {
    case dogNameNil = "Your dog's name is invalid, please try a different one."
    case dogNameBlank = "Your dog's name is blank, try typing something in."
}

class Dog: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = try! Dog(dogName: self.dogName)
        copy.dogId = self.dogId
        copy.storedDogName = self.storedDogName
        copy.icon = self.icon
        copy.dogReminders = self.dogReminders.copy() as? ReminderManager
        copy.dogLogs = self.dogLogs
        return copy
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        super.init()
        dogId = aDecoder.decodeInteger(forKey: "dogId")
        storedDogName = aDecoder.decodeObject(forKey: "dogName") as? String ?? UUID().uuidString
        icon = aDecoder.decodeObject(forKey: "icon") as? UIImage ?? DogConstant.defaultIcon
        dogLogs = aDecoder.decodeObject(forKey: "dogLogs") as? LogManager ?? LogManager()
        dogReminders = aDecoder.decodeObject(forKey: "dogReminders") as? ReminderManager ?? ReminderManager()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogId, forKey: "dogId")
        aCoder.encode(storedDogName, forKey: "dogName")
        aCoder.encode(icon, forKey: "icon")
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
        self.storedDogName = dogName!
        self.dogReminders = ReminderManager()
        self.dogLogs = LogManager()
    }
    
    convenience init(dogName: String?, dogIcon: UIImage? = nil) throws {
        try self.init(dogName: dogName)
        if dogIcon != nil {
            self.icon = dogIcon!
        }
    }
    
    /// Assume array of dog properties
    convenience init(fromBody body: [String: Any]) {
        
        let dogName = body["dogName"] as? String ?? DogConstant.defaultDogName
        try! self.init(dogName: dogName)
        
        if let dogId = body["dogId"] as? Int {
            self.dogId = dogId
        }
        
        // check for any reminders
        if let reminderBodies = body["reminders"] as? [[String: Any]] {
            for reminderBody in reminderBodies {
                let reminder = Reminder(fromBody: reminderBody)
                self.dogReminders.addReminder(newReminder: reminder)
            }
        }
        
        // check for any logs
        if let logBodies = body["logs"] as? [[String: Any]] {
            for logBody in logBodies {
                let log = Log(fromBody: logBody)
                self.dogLogs.addLog(newLog: log)
            }
        }
    }
    
    // MARK: - Properties
    
    var dogId: Int = DogConstant.defaultDogId
    
    // MARK: - Traits
    
    var icon: UIImage = DogConstant.defaultIcon
    
    func resetIcon() {
        icon = DogConstant.defaultIcon
    }
    
    private var storedDogName: String = DogConstant.defaultDogName
    var dogName: String { return storedDogName }
    func changeDogName(newDogName: String?) throws {
        if newDogName == nil {
            throw DogError.dogNameNil
        }
        else if newDogName!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            throw DogError.dogNameBlank
        }
        else {
            storedDogName = newDogName!
        }
    }
    
    /// ReminderManager that handles all specified reminders for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogReminders: ReminderManager! = nil
    
    /// LogManager that handles all the logs for a dog
    var dogLogs: LogManager! = nil
}
