//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogError: Error {
    case noRemindersPresent
}

class Dog: NSObject, NSCoding, NSCopying {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Dog()
        copy.dogReminders = self.dogReminders.copy() as? ReminderManager
        copy.dogReminders.parentDog = copy
        copy.dogTraits = self.dogTraits.copy() as! TraitManager
        return copy
    }

    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        super.init()
        dogTraits = aDecoder.decodeObject(forKey: "dogTraits") as? TraitManager ?? TraitManager()
        // for build versions <= 1513
        dogReminders = aDecoder.decodeObject(forKey: "dogReminders") as? ReminderManager ?? aDecoder.decodeObject(forKey: "dogRequirements") as? ReminderManager ?? aDecoder.decodeObject(forKey: "dogRequirments") as? ReminderManager ?? ReminderManager(parentDog: self)
        dogReminders.parentDog = self
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogTraits, forKey: "dogTraits")
        aCoder.encode(dogReminders, forKey: "dogReminders")
    }

    // MARK: - Properties

    override init() {
        super.init()
        self.dogReminders = ReminderManager(parentDog: self)
    }

    convenience init(defaultReminders: Bool) {
        self.init()
        if defaultReminders == true {
            self.dogReminders.addDefaultReminders()
        }
    }

    var dogId: Int = -1

    /// Traits
    var dogTraits: TraitManager = TraitManager()

    /// ReminderManager that handles all specified reminders for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogReminders: ReminderManager! = nil

    /// Returns an array of known log types. Each known log type has an array of logs attached to it. This means you can find every log for a given log type
    var catagorizedLogTypes: [(KnownLogType, [KnownLog])] {
        var catagorizedLogTypes: [(KnownLogType, [KnownLog])] = []

        // handles all dog logs and adds to catagorized log types
        for dogLog in dogTraits.logs {
            // already contains that dog log type, needs to append
            if catagorizedLogTypes.contains(where: { (arg1) -> Bool in
                let knownLogType = arg1.0
                if dogLog.logType == knownLogType {
                    return true
                }
                else {
                    return false
                }
            }) == true {
                // since knownLogType is already present, append on dogLog that is of that same type to the arry of logs with the given knownLogType
                let targetIndex: Int! = catagorizedLogTypes.firstIndex(where: { (arg1) -> Bool in
                    let knownLogType = arg1.0
                    if knownLogType == dogLog.logType {
                        return true
                    }
                    else {
                        return false
                    }
                })

                catagorizedLogTypes[targetIndex].1.append(dogLog)
            }
            // does not contain that dog Log's Type
            else {
                catagorizedLogTypes.append((dogLog.logType, [dogLog]))
            }
        }

        // sorts by the order defined by the enum, so whatever case is first in the code of the enum that is the order of the catagorizedLogTypes
        catagorizedLogTypes.sort { arg1, arg2 in
            let (knownLogType1, _) = arg1
            let (knownLogType2, _) = arg2

            // finds corrosponding index
            let knownLogType1Index: Int! = KnownLogType.allCases.firstIndex { arg1 in
                if knownLogType1.rawValue == arg1.rawValue {
                    return true
                }
                else {
                    return false
                }
            }
            // finds corrosponding index
            let knownLogType2Index: Int! = KnownLogType.allCases.firstIndex { arg1 in
                if knownLogType2.rawValue == arg1.rawValue {
                    return true
                }
                else {
                    return false
                }
            }

            if knownLogType1Index <= knownLogType2Index {
                return true
            }
            else {
                return false
            }

        }

        return catagorizedLogTypes
    }

    /// returns true if has created a reminder and has at least one enabled
    var hasEnabledReminder: Bool {
            for reminder in dogReminders.reminders {
                if reminder.getEnable() == true {
                    return true
                }
            }
        return false
    }
}
