//
//  Reminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from ReminderManager
enum ReminderManagerError: Error {
   case reminderAlreadyPresent
    case reminderNotPresent
    case reminderInvalid
    case reminderUUIDNotPresent
}

protocol ReminderManagerProtocol {
    
    //dog that holds the reminders
    var masterDog: Dog? { get set }
    
    //array of reminders, a dog should contain one of these to specify all of its reminders
    var reminders: [Reminder] { get }
    
    ///checks to see if a reminder with the same name is present, if not then adds new reminder, if one is then throws error
    mutating func addReminder(newReminder: Reminder) throws
    
    mutating func addReminder(newReminders: [Reminder]) throws
    
    ///removes trys to find a reminder whos name (capitals don't matter) matches reminder name given, if found removes reminder, if not found throws error
    mutating func removeReminder(forUUID uuid: String) throws
    mutating func removeReminder(forIndex index: Int)
    
    mutating func changeReminder(forUUID uuid: String, newReminder: Reminder) throws
    
    ///finds and returns the reference of a reminder matching the given uuid
    func findReminder(forUUID uuid: String) throws -> Reminder
    
    ///finds and returns the index of a reminder with a uuid in terms of the reminder: [Reminder] array
    func findIndex(forUUID uuid: String) throws -> Int
    
}

extension ReminderManagerProtocol {
    
    func findReminder(forUUID uuid: String) throws -> Reminder {
        for r in 0..<reminders.count{
            if reminders[r].uuid == uuid {
                return reminders[r]
            }
        }
        throw ReminderManagerError.reminderNotPresent
    }
    
    func findIndex(forUUID uuid: String) throws -> Int {
        for r in 0..<reminders.count{
            if reminders[r].uuid == uuid {
                return r
            }
        }
        throw ReminderManagerError.reminderNotPresent
    }
    
}

class ReminderManager: NSObject, NSCoding, NSCopying, ReminderManagerProtocol {
    
    //MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ReminderManager(masterDog: masterDog, initReminders: self.reminders)
        return copy
    }
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        storedReminders = aDecoder.decodeObject(forKey: "reminders") as? [Reminder] ?? aDecoder.decodeObject(forKey: "requirements") as? [Reminder] ?? aDecoder.decodeObject(forKey: "requirments") as! [Reminder]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedReminders, forKey: "reminders")
    }
    
    //static var supportsSecureCoding: Bool = true
    
    init(masterDog: Dog?, initReminders: [Reminder] = []){
        self.storedMasterDog = masterDog
        super.init()
        for reminder in initReminders{
            appendReminder(newReminder: reminder)
        }
    }
    
    private var storedMasterDog: Dog? = nil
    
    var masterDog: Dog? {
        get {
            return storedMasterDog
        }
        set (newMasterDog){
            self.storedMasterDog = newMasterDog
            for reminder in storedReminders{
                reminder.masterDog = storedMasterDog
            }
        }
    }
    
    ///Array of reminders
    private var storedReminders: [Reminder] = []
    var reminders: [Reminder] { return storedReminders }
    
    ///This handles the proper appending of a reminder. This function assumes an already checked reminder and its purpose is to bypass the add reminder endpoint
    private func appendReminder(newReminder: Reminder){
        let newReminderCopy = newReminder.copy() as! Reminder
        newReminderCopy.masterDog = self.masterDog
       storedReminders.append(newReminderCopy)
    }
    
    func addReminder(newReminder: Reminder) throws {
        
        var reminderAlreadyPresent = false
        
        reminders.forEach { (reminder) in
            if (reminder.uuid == newReminder.uuid){
                reminderAlreadyPresent = true
            }
        }
        
        if reminderAlreadyPresent == true{
            throw ReminderManagerError.reminderAlreadyPresent
        }
        else {
            //copying needed for master dog to work, is just newReq.masterDog = self.masterDog it for some reason does not work
            
            appendReminder(newReminder: newReminder)
            print("ENDPOINT Add Reminder")
        }
        sortReminders()
    }
    
    func addReminder(newReminders: [Reminder]) throws {
        for reminder in newReminders {
            try addReminder(newReminder: reminder)
        }
        sortReminders()
    }
    
    
    func removeReminder(forUUID uuid: String) throws{
        var reminderNotPresent = true
        
        //goes through reminders to see if the given reminder name (aka reminder name) is in the array of reminders
        reminders.forEach { (reminder) in
            if reminder.uuid == uuid{
                reminderNotPresent = false
            }
        }
        
        //if provided reminder is not present, throws error
        
        if reminderNotPresent == true{
            throw ReminderManagerError.reminderNotPresent
        }
        //if provided reminder is present, proceeds
        else {
            //finds index of given reminder (through reminder name), returns nil if not found but it should be if code is written correctly, code should not be not be able to reach this point if reminder name was not present
            var indexOfRemovalTarget: Int?{
                for index in 0...Int(reminders.count){
                    if reminders[index].uuid == uuid{
                        return index
                    }
                }
                return nil
            }
            
        storedReminders.remove(at: indexOfRemovalTarget ?? -1)
        print("ENDPOINT Remove Reminder (via uuid)")
        }
    }
    
    func removeReminder(forIndex index: Int){
        storedReminders.remove(at: index)
        print("ENDPOINT Remove Reminder (via index)")
    }
    
    func removeAllReminders(){
        print("ENDPOINT Remove All Reminder (ignore)")
        self.storedReminders.removeAll()
    }
    
    func changeReminder(forUUID uuid: String, newReminder: Reminder) throws {
        
        //check to find the index of targetted reminder
        var newReminderIndex: Int?
        
        for i in 0..<reminders.count {
            if reminders[i].uuid == uuid {
                newReminderIndex = i
            }
        }
        
        if newReminderIndex == nil {
            throw ReminderManagerError.reminderUUIDNotPresent
        }
        
        else {
            newReminder.masterDog = self.masterDog
            storedReminders[newReminderIndex!] = newReminder
            print("ENDPOINT Update Reminder (trait)")
        }
        sortReminders()
    }
    
    private func sortReminders(){
    storedReminders.sort { (reminder1, reminder2) -> Bool in
        if reminder1.timingStyle == .oneTime && reminder2.timingStyle == .oneTime{
            if Date().distance(to: reminder1.oneTimeComponents.executionDate!) < Date().distance(to: reminder2.oneTimeComponents.executionDate!){
                return true
            }
            else {
                return false
            }
        }
        //both countdown
        else if reminder1.timingStyle == .countDown && reminder2.timingStyle == .countDown{
            //shorter is listed first
            if reminder1.countDownComponents.executionInterval <= reminder2.countDownComponents.executionInterval{
                return true
            }
            else {
                return false
            }
        }
        //both weekly
        else if reminder1.timingStyle == .weekly && reminder2.timingStyle == .weekly{
            //earlier in the day is listed first
            let reminder1Hour = reminder1.timeOfDayComponents.timeOfDayComponent.hour!
            let reminder2Hour = reminder2.timeOfDayComponents.timeOfDayComponent.hour!
            if reminder1Hour == reminder2Hour{
                let reminder1Minute = reminder1.timeOfDayComponents.timeOfDayComponent.minute!
                let reminder2Minute = reminder2.timeOfDayComponents.timeOfDayComponent.minute!
                if reminder1Minute <= reminder2Minute{
                    return true
                }
                else {
                    return false
                }
            }
            else if reminder1Hour <= reminder2Hour {
                return true
            }
            else {
                return false
            }
        }
        //both monthly
        else if reminder1.timingStyle == .monthly && reminder2.timingStyle == .monthly{
            let reminder1Day: Int! = reminder1.timeOfDayComponents.dayOfMonth
            let reminder2Day: Int! = reminder2.timeOfDayComponents.dayOfMonth
            //first day of the month comes first
            if reminder1Day == reminder2Day{
                //earliest in day comes first if same days
                let reminder1Hour = reminder1.timeOfDayComponents.timeOfDayComponent.hour!
                let reminder2Hour = reminder2.timeOfDayComponents.timeOfDayComponent.hour!
                if reminder1Hour == reminder2Hour{
                //earliest in hour comes first if same hour
                    let reminder1Minute = reminder1.timeOfDayComponents.timeOfDayComponent.minute!
                    let reminder2Minute = reminder2.timeOfDayComponents.timeOfDayComponent.minute!
                    if reminder1Minute <= reminder2Minute{
                        return true
                    }
                    else {
                        return false
                    }
                }
                else if reminder1Hour <= reminder2Hour {
                    return true
                }
                else {
                    return false
                }
            }
            else if reminder1Day < reminder2Day{
                return true
            }
            else {
                return false
            }
        }
        //different timing styles
        else {
            
            //reminder1 and reminder2 are known to be different styles
            switch reminder1.timingStyle {
            case .countDown:
                //can assume is comes first as countdown always first and different
                return true
            case .weekly:
                if reminder2.timingStyle == .countDown{
                    return false
                }
                else {
                    return true
                }
            case .monthly:
                if reminder2.timingStyle == .oneTime{
                    return true
                }
                else {
                    return false
                }
            case .oneTime:
                return false
            }
            
        }
    }
}
    
}

protocol ReminderManagerControlFlowProtocol {
    
    ///Returns a copy of ReminderManager used to avoid accidental changes (due to reference type) by classes which get their dog manager from here
    func getReminderManager() -> ReminderManager
    
    ///Sets reminderManager equal to newReminderManager, depending on sender will also call methods to propogate change.
    func setReminderManager(sender: Sender, newReminderManager: ReminderManager)
    
    //Updates things dependent on reminderManager
    func updateReminderManagerDependents()
    
}
