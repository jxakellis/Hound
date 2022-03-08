//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogError: Error {
    case nilName
    case blankName
}

class Dog: NSObject, NSCoding, NSCopying {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Dog()
        copy.dogId = self.dogId
        copy.storedDogName = self.storedDogName
        copy.icon = self.icon
        copy.dogReminders = self.dogReminders.copy() as? ReminderManager
        copy.dogReminders.parentDog = copy
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
        dogReminders = aDecoder.decodeObject(forKey: "dogReminders") as? ReminderManager ?? ReminderManager(parentDog: self)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogId, forKey: "dogId")
        aCoder.encode(storedDogName, forKey: "dogName")
        aCoder.encode(icon, forKey: "icon")
        aCoder.encode(dogLogs, forKey: "dogLogs")
        aCoder.encode(dogReminders, forKey: "dogReminders")
    }

    // MARK: - Main

    override init() {
        super.init()
        self.dogReminders = ReminderManager(parentDog: self)
        self.dogLogs = LogManager()
    }

    convenience init(defaultReminders: Bool) {
        self.init()
        if defaultReminders == true {
            self.dogReminders.addDefaultReminders()
        }
    }

    /// Assume array of dog properties
    convenience init(fromBody body: [String: Any]) {
        self.init()

        if let dogId = body["dogId"] as? Int {
            self.dogId = dogId
        }
        if let dogName = body["dogName"] as? String {
            storedDogName = dogName
        }
    }

    // MARK: - Properties

    var dogId: Int = -1

    // MARK: - Traits

    var icon: UIImage = DogConstant.defaultIcon

    func resetIcon() {
        icon = DogConstant.defaultIcon
    }

    private var storedDogName: String = DogConstant.defaultName
    var dogName: String { return storedDogName }
    func changeDogName(newDogName: String?) throws {
        if newDogName == nil {
            throw DogError.nilName
        }
        else if newDogName!.trimmingCharacters(in: .whitespaces) == ""{
            throw DogError.blankName
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
