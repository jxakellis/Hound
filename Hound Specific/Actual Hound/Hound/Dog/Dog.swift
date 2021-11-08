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
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        super.init()
        dogTraits = aDecoder.decodeObject(forKey: "dogTraits") as! TraitManager
        //for build versions <= 1513
        dogReminders = aDecoder.decodeObject(forKey: "dogReminders") as? ReminderManager ?? aDecoder.decodeObject(forKey: "dogRequirements") as? ReminderManager ?? aDecoder.decodeObject(forKey: "dogRequirments") as? ReminderManager
        dogReminders.masterDog = self
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogTraits, forKey: "dogTraits")
        aCoder.encode(dogReminders, forKey: "dogReminders")
        //aCoder.encode(isEnabled, forKey: "isEnabled")
    }
    
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Dog()
        copy.dogReminders = self.dogReminders.copy() as? ReminderManager
        copy.dogReminders.masterDog = copy
        copy.dogTraits = self.dogTraits.copy() as! TraitManager
        return copy
    }
    
    //MARK: - Properties
    
    override init() {
        super.init()
        self.dogReminders = ReminderManager(masterDog: self)
    }
    
    ///Traits
    var dogTraits: TraitManager = TraitManager()
    
    ///ReminderManager that handles all specified reminders for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogReminders: ReminderManager! = nil
    
    var catagorizedLogTypes: [(KnownLogType, [(Reminder?, KnownLog)])] {
        var catagorizedLogTypes: [(KnownLogType, [(Reminder?, KnownLog)])] = []
        
        //handles all dog logs and adds to catagorized log types
        for dogLog in dogTraits.logs{
            //already contains that dog log type, needs to append
            if catagorizedLogTypes.contains(where: { (arg1) -> Bool in
                let knownLogType = arg1.0
                if dogLog.logType == knownLogType{
                    return true
                }
                else {
                    return false
                }
            }) == true {
                //since knownLogType is already present, append on dogLog that is of that same type to the arry of logs with the given knownLogType
                let targetIndex: Int! = catagorizedLogTypes.firstIndex(where: { (arg1) -> Bool in
                    let knownLogType = arg1.0
                    if knownLogType == dogLog.logType{
                        return true
                    }
                    else {
                        return false
                    }
                })
                
                catagorizedLogTypes[targetIndex].1.append((nil, dogLog))
            }
            //does not contain that dog Log's Type
            else {
                catagorizedLogTypes.append((dogLog.logType, [(nil, dogLog)]))
            }
        }
        
        
        //sorts by the order defined by the enum, so whatever case is first in the code of the enum that is the order of the catagorizedLogTypes
        catagorizedLogTypes.sort { arg1, arg2 in
            let (knownLogType1, _) = arg1
            let (knownLogType2, _) = arg2
            
            //finds corrosponding index
            let knownLogType1Index: Int! = KnownLogType.allCases.firstIndex { arg1 in
                if knownLogType1.rawValue == arg1.rawValue{
                    return true
                }
                else {
                    return false
                }
            }
            //finds corrosponding index
            let knownLogType2Index: Int! = KnownLogType.allCases.firstIndex { arg1 in
                if knownLogType2.rawValue == arg1.rawValue{
                    return true
                }
                else {
                    return false
                }
            }
            
            if knownLogType1Index <= knownLogType2Index{
                return true
            }
            else {
                return false
            }
            
            
        }
        
        return catagorizedLogTypes
    }
    
    ///adds default set of reminders
    func addDefaultReminders(){
        try! dogReminders.addReminder(newReminders: [ReminderConstant.defaultReminderOne, ReminderConstant.defaultReminderTwo, ReminderConstant.defaultReminderThree, ReminderConstant.defaultReminderFour])
    }
    
    ///returns true if has created a reminder and has atleast one enabled
    var hasEnabledReminder: Bool {
            for reminder in dogReminders.reminders {
                if reminder.getEnable() == true {
                    return true
                }
            }
        return false
    }
}


