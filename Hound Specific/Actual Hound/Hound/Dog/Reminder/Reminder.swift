//
//  Remindert.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

///Enum full of cases of possible errors from Reminder
enum ReminderError: Error {
    case nameBlank
    case nameInvalid
    case descriptionInvalid
    case intervalInvalid
}

enum ReminderStyle: String, CaseIterable {
    
    init?(rawValue: String) {
        for type in ReminderStyle.allCases{
            if type.rawValue.lowercased() == rawValue.lowercased(){
                self = type
                return
            }
        }
        
        print("reminderStyle Not Found")
        self = .oneTime
    }
    //case oneTime = "oneTime"
    //case countDown = "countDown"
    //case weekly = "weekly"
    //case monthly = "monthly"
    case oneTime = "oneTime"
    case countDown = "countdown"
    case weekly = "weekly"
    case monthly = "monthly"
}

enum ReminderMode {
    case oneTime
    case countDown
    case weekly
    case monthly
    case snooze
}

protocol ReminderTraitsProtocol {
    
    ///Dog that hold this reminder, used for logs
    var masterDog: Dog? { get set }
    
    var uuid: String { get set }
    
    ///Replacement for reminderName, a way for the user to keep track of what the reminder is for
    var reminderType: ScheduledLogType { get set }
    
    ///If the reminder's type is custom, this is the name for it
    var customTypeName: String? { get set }
    
    ///If not .custom type then just .type name, if custom and has customTypeName then its that string
    var displayTypeName: String { get }
    
    ///An array of all dates that logs when the timer has fired, whether by snooze, regular timing convention, etc. ANY TIME
    //var logs: [KnownLog] { get set }
}

protocol ReminderComponentsProtocol {
    ///The components needed for a countdown based timer
    var countDownComponents: CountDownComponents { get set }
    
    ///The components needed if an timer is snoozed
    var snoozeComponents: SnoozeComponents { get set }
    
    ///The components needed if for time of day based timer
    var timeOfDayComponents: TimeOfDayComponents { get set }
    
    ///Figures out whether the reminder is in snooze, count down, time of day, or another timer mode. Returns enum case corrosponding
    var timerMode: ReminderMode { get }
    
    ///An enum that indicates whether the reminder is in countdown format or time of day format
    var timingStyle: ReminderStyle { get }
    ///Function to change timing style and adjust data corrosponding accordingly.
    mutating func changeTimingStyle(newTimingStyle: ReminderStyle)
}

protocol ReminderTimingComponentsProtocol {
    ///Similar to executionDate but instead of being a log of everytime the time has fired it is either the date the timer has last fired or the date it should be basing its execution off of, e.g. 5 minutes into the timer you change the countdown from 30 minutes to 15, you don't want to log an execution as there was no one but you want to start the timer fresh and have it count down from the moment it was changed.
    var executionBasis: Date { get }
    
    ///Changes executionBasis to the specified value, note if the Date is equal to the current date (i.e. newExecutionBasis == Date()) then resets all components intervals elapsed to zero.
    mutating func changeExecutionBasis(newExecutionBasis: Date, shouldResetIntervalsElapsed: Bool)
    
    ///True if the presentation of the timer (when it is time to present) has been handled and sent to the presentation handler, prevents repeats of the timer being sent to the presenation handler over and over.
    var isPresentationHandled: Bool { get set }
    
    ///The date at which the reminder should fire, i.e. go off to the user and display an alert
    var executionDate: Date? { get }
    
    ///Calculated time interval remaining that taking into account factors to produce correct value for conditions and parameters
    var intervalRemaining: TimeInterval? { get }
    
    ///DO NOT DUPLICATE OR ENCODE, WILL CAUSE TIMER TO FIRE TWICE. This is the timer that is used to make the reminder function. It triggers the events for the reminder. Without this then when it was time for the reminder, nothing would happen.
    var timer: Timer? { get set }
    
    ///Called when a timer is fired/executed and an option to deal with it is selected by the user, if the reset is trigger by a user doing an action that constitude a reset, specify as so, but if doing something like changing the value of some component it was did not exeute to user. If didExecuteToUse is true it does the same thing as false except it appends the current date to the array of logs which keeps tracks of each time a reminder is formally executed.
    mutating func timerReset(shouldLogExecution: Bool, knownLogType: KnownLogType?, customTypeName: String?)
}

class Reminder: NSObject, NSCoding, NSCopying, ReminderTraitsProtocol, ReminderComponentsProtocol, ReminderTimingComponentsProtocol, EnableProtocol {
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Reminder()
        
        copy.uuid = self.uuid
        copy.reminderType = self.reminderType
        copy.customTypeName = self.customTypeName
        copy.masterDog = self.masterDog
        
        copy.countDownComponents = self.countDownComponents.copy() as! CountDownComponents
        copy.timeOfDayComponents = self.timeOfDayComponents.copy() as! TimeOfDayComponents
        copy.timeOfDayComponents.masterReminder = copy
        copy.oneTimeComponents = self.oneTimeComponents.copy() as! OneTimeComponents
        copy.oneTimeComponents.masterReminder = copy
        copy.snoozeComponents = self.snoozeComponents.copy() as! SnoozeComponents
        copy.storedTimingStyle = self.timingStyle
        
        copy.isPresentationHandled = self.isPresentationHandled
        copy.storedExecutionBasis = self.executionBasis
        copy.timer = self.timer
        
        copy.isEnabled = self.isEnabled
        
        return copy
    }
    
    //MARK: - NSCoding
    
    override init() {
        super.init()
        self.timeOfDayComponents.masterReminder = self
        self.oneTimeComponents.masterReminder = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as! String
        self.reminderType = ScheduledLogType(rawValue: aDecoder.decodeObject(forKey: "reminderType") as? String ?? aDecoder.decodeObject(forKey: "requirement") as? String ?? aDecoder.decodeObject(forKey: "requirment") as? String ?? aDecoder.decodeObject(forKey: "requirementType") as? String ?? aDecoder.decodeObject(forKey: "requirmentType") as! String)!
        
        self.customTypeName = aDecoder.decodeObject(forKey: "customTypeName") as? String
        
        
        if UIApplication.previousAppBuild <= 1228{
            print("grandfather in depreciated reminders logs")
            let depreciatedLogs: [KnownLog] = aDecoder.decodeObject(forKey: "logs") as? [KnownLog] ?? []
            
        
            if depreciatedLogs.count > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.masterDog == nil {
                        print("master dog nil")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                            if self.masterDog != nil {
                                print("backup reminder logs decode success")
                                for log in depreciatedLogs{
                                    try! self.masterDog?.dogTraits.addLog(newLog: log)
                                }
                            }
                            else {
                                print("backup reminder logs decode fail")
                            }
                        }
                    }
                    else {
                        print("primary reminder logs decode success")
                        for log in depreciatedLogs{
                            try! self.masterDog?.dogTraits.addLog(newLog: log)
                        }
                    }
                }
            }
           
        }
        else {
            //print("too new")
            //print(UIApplication.previousAppBuild)
        }
        
        
        self.countDownComponents = aDecoder.decodeObject(forKey: "countDownComponents") as! CountDownComponents
        self.timeOfDayComponents = aDecoder.decodeObject(forKey: "timeOfDayComponents") as! TimeOfDayComponents
        self.timeOfDayComponents.masterReminder = self
        self.oneTimeComponents = aDecoder.decodeObject(forKey: "oneTimeComponents") as? OneTimeComponents ?? OneTimeComponents()
        self.oneTimeComponents.masterReminder = self
        self.snoozeComponents = aDecoder.decodeObject(forKey: "snoozeComponents") as! SnoozeComponents
        
        self.storedTimingStyle = ReminderStyle(rawValue: aDecoder.decodeObject(forKey: "timingStyle") as! String)!
        
        //self.isPresentationHandled = aDecoder.decodeBool(forKey: "isPresentationHandled")
        self.storedExecutionBasis = aDecoder.decodeObject(forKey: "executionBasis") as! Date
        
        self.isEnabled = aDecoder.decodeBool(forKey: "isEnabled")
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(reminderType.rawValue, forKey: "reminderType")
        aCoder.encode(customTypeName, forKey: "customTypeName")
        
        aCoder.encode(countDownComponents, forKey: "countDownComponents")
        aCoder.encode(timeOfDayComponents, forKey: "timeOfDayComponents")
        aCoder.encode(oneTimeComponents, forKey: "oneTimeComponents")
        aCoder.encode(snoozeComponents, forKey: "snoozeComponents")
        aCoder.encode(storedTimingStyle.rawValue, forKey: "timingStyle")
        
        //aCoder.encode(isPresentationHandled, forKey: "isPresentationHandled")
        aCoder.encode(storedExecutionBasis, forKey: "executionBasis")
        
        aCoder.encode(isEnabled, forKey: "isEnabled")
    }
    
    //static var supportsSecureCoding: Bool = true
    
    //MARK: - ReminderTraitsProtocol
    
    var masterDog: Dog? = nil
    
    var uuid: String = UUID().uuidString
    
    var reminderType: ScheduledLogType = ReminderConstant.defaultType
    
    var customTypeName: String? = nil
    
    var displayTypeName: String {
        if reminderType == .custom && customTypeName != nil {
            return customTypeName!
        }
        else {
            return reminderType.rawValue
        }
    }
    
    //var logs: [KnownLog] = []
    
    //MARK: - ReminderComponentsProtocol
    
    var countDownComponents: CountDownComponents = CountDownComponents()
    
    var timeOfDayComponents: TimeOfDayComponents = TimeOfDayComponents()
    
    var oneTimeComponents: OneTimeComponents = OneTimeComponents()
    
    var snoozeComponents: SnoozeComponents = SnoozeComponents()
    
    var timerMode: ReminderMode {
        if snoozeComponents.isSnoozed == true{
            return .snooze
        }
        else if timingStyle == .countDown {
            return .countDown
        }
        else if timingStyle == .weekly {
            return .weekly
        }
        else if timingStyle == .monthly {
            return .monthly
        }
        else if timingStyle == .oneTime{
            return .oneTime
        }
        else {
            fatalError()
        }
    }
    
    private var storedTimingStyle: ReminderStyle = .countDown
    var timingStyle: ReminderStyle { return storedTimingStyle }
    func changeTimingStyle(newTimingStyle: ReminderStyle){
        guard newTimingStyle != storedTimingStyle else {
            return
        }
        
        self.timerReset(shouldLogExecution: false)
        
        storedTimingStyle = newTimingStyle
    }
    
    //MARK: - ReminderTimingComponentsProtocol
    
    private var storedExecutionBasis: Date = Date()
    var executionBasis: Date { return storedExecutionBasis }
    func changeExecutionBasis(newExecutionBasis: Date, shouldResetIntervalsElapsed: Bool){
        storedExecutionBasis = newExecutionBasis
        
        //If resetting the executionBasis to the current time (and not changing it to another executionBasis of some other reminder) then resets interval elasped as timers would have to be fresh
        if shouldResetIntervalsElapsed == true {
            snoozeComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
            countDownComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
        }
        
    }
    
    var isPresentationHandled: Bool = false
    
    var intervalRemaining: TimeInterval? {
        //snooze
        if timerMode == .snooze {
            return snoozeComponents.executionInterval - snoozeComponents.intervalElapsed
        }
        else if timerMode == .oneTime {
            return Date().distance(to: oneTimeComponents.executionDate!)
        }
        //countdown
        else if timerMode == .countDown{
            return countDownComponents.executionInterval - countDownComponents.intervalElapsed
        }
        else if timerMode == .weekly || timerMode == .monthly {
            //if the previousTimeOfDay is closer to the present than executionBasis returns nil, indicates missed alarm
            if self.executionBasis.distance(to: self.timeOfDayComponents.previousTimeOfDay(reminderExecutionBasis: self.executionBasis)) > 0 {
                return nil
            }
            else{
                return Date().distance(to: self.timeOfDayComponents.nextTimeOfDay(reminderExecutionBasis: self.executionBasis))
            }
        }
        else {
            //HDLL
            fatalError("not implemented timerMode for intervalRemaining, Reminder")
            //return -1
        }
    }
    
    var executionDate: Date? {
        guard self.getEnable() == true else {
            return nil
        }
        
        //Snoozing
        if self.timerMode == .snooze{
            return Date.executionDate(lastExecution: executionBasis, interval: intervalRemaining!)
        }
        //Time of Day Alarm
        else if timerMode == .weekly || timerMode == .monthly {
            //If the intervalRemaining is nil than means there is no time left
            if intervalRemaining == nil {
                return Date()
            }
            else {
                return timeOfDayComponents.nextTimeOfDay(reminderExecutionBasis: self.executionBasis)
            }
        }
        else if timerMode == .countDown{
            return Date.executionDate(lastExecution: executionBasis, interval: intervalRemaining!)
        }
        else if timerMode == .oneTime{
            return oneTimeComponents.executionDate
        }
        else {
            fatalError("not implemented timerMode for executionDate, reminder")
        }
    }
    
    var timer: Timer? = nil
    
    //private func updateTimer
    
    func timerReset(shouldLogExecution: Bool, knownLogType: KnownLogType? = nil, customTypeName: String? = nil){
        
        if shouldLogExecution == true {
            if knownLogType == nil {
                fatalError()
            }
            try! masterDog?.dogTraits.addLog(newLog: KnownLog(date: Date(), logType: knownLogType!, customTypeName: customTypeName))
            
            if masterDog == nil {
                print("masterDog nil, couldn't log")
            }
        }
        
        self.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
        
        self.isPresentationHandled = false
        
        snoozeComponents.timerReset()
        
        if timingStyle == .countDown {
            self.countDownComponents.timerReset()
        }
        else if timingStyle == .weekly || timingStyle == .monthly{
            self.timeOfDayComponents.timerReset()
        }
        else {
            self.oneTimeComponents.timerReset()
        }
        
    }
    
    //MARK: - EnableProtocol
    
    ///Whether or not the reminder  is enabled, if disabled all reminders will not fire, if parentDog isEnabled == false will not fire
    private var isEnabled: Bool = DogConstant.defaultEnable
    
    ///Changes isEnabled to newEnableStatus, note if toggling from false to true the execution basis is changed to the current Date()
    func setEnable(newEnableStatus: Bool) {
        if isEnabled == false && newEnableStatus == true {
            timerReset(shouldLogExecution: false)
        }
        else if newEnableStatus == false {
            timer?.invalidate()
            timer = nil
        }
        isEnabled = newEnableStatus
        print("ENDPOINT Update Reminder (enable)")
    }
    
    func willToggle() {
        isEnabled.toggle()
        print("ENDPOINT Update Reminder (enable)")
    }
    
    func getEnable() -> Bool{
        return isEnabled
    }
    
}



