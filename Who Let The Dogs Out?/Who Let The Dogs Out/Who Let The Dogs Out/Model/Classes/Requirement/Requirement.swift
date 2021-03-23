//
//  Requirementt.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

/*
 Find HDLL and interpretate then handle
 TO DO
 
 Add local handling for timerReset that calls timerReset in all components
 Add local handling so when
 */

///Enum full of cases of possible errors from Requirement
enum RequirementError: Error {
    case nameInvalid
    case descriptionInvalid
    case intervalInvalid
}

enum RequirementStyle: String {
    case countDown = "countDown"
    case timeOfDay = "timeOfDay"
}

protocol RequirementProtocol {
    
    ///name for what the requirement does, set by user, used as main name for requirement, e.g. potty or food, can't be repeated, will throw error if try to add two requirments to same requirement manager with same name
    var requirementName: String { get }
    mutating func changeRequirementName(newRequirementName: String?) throws
    
    ///descripton of reqirement
    var requirementDescription: String { get }
    ///if newDescription passes all tests, changes value, if not throws error
    mutating func changeRequirementDescription(newRequirementDescription: String?) throws
    
    ///An array of all dates that logs when the timer has fired, whether by snooze, regular timing convention, etc. ANY TIME
    var executionDates: [Date] { get set }
    
    ///Similar to executionDate but instead of being a log of everytime the time has fired it is either the date the timer has last fired or the date it should be basing its execution off of, e.g. 5 minutes into the alarm you change the countdown from 30 minutes to 15, you don't want to log an execution as there was no one but you want to start the timer fresh and have it count down from the moment it was changed.
    var executionBasis: Date { get }
    ///Changes executionBasis to the specified value, note if the Date is equal to the current date (i.e. newExecutionBasis == Date()) then resets all components intervals elapsed to zero.
    mutating func changeExecutionBasis(newExecutionBasis: Date)
    
    ///True if the presentation of the timer (when it is time to present) has been handled and sent to the presentation handler, prevents repeats of the timer being sent to the presenation handler over and over.
    var isPresentationHandled: Bool { get set }
    
    ///The components needed for a countdown based timer
    var countDownComponents: CountDownComponents { get set }
    
    ///The components needed if an alarm is snoozed
    var snoozeComponents: SnoozeComponents { get set }
    
    ///An enum that indicates whether the requirement is in countdown format or time of day format
    var timingStyle: RequirementStyle { get set }
    
    ///Calculated time interval remaining that taking into account factors to produce correct value for conditions and parameters
    var intervalRemaining: TimeInterval { get }
    
    ///Called when a timer is fired/executed and an option to deal with it is selected by the user, preps for future use
    mutating func timerReset()
    
    
    
}

class Requirement: NSObject, NSCoding, NSCopying, RequirementProtocol, EnableProtocol {
    
    //MARK: NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Requirement()
        try! copy.changeRequirementName(newRequirementName: self.requirementName)
        try! copy.changeRequirementDescription(newRequirementDescription: self.requirementDescription)
        
        copy.countDownComponents = self.countDownComponents.copy() as! CountDownComponents
        copy.snoozeComponents = self.snoozeComponents.copy() as! SnoozeComponents
        copy.timingStyle = self.timingStyle
        
        copy.setEnable(newEnableStatus: self.getEnable())
        copy.isPresentationHandled = self.isPresentationHandled
        copy.executionDates = self.executionDates
        copy.storedExecutionBasis = self.executionBasis
        
        return copy
    }
    
     //MARK: NSCoding
    
    override init() {
        super.init()
    }
    
     required init?(coder aDecoder: NSCoder) {
        self.isEnabled = aDecoder.decodeBool(forKey: "isEnabled")
        self.storedRequirementName = aDecoder.decodeObject(forKey: "requirementName") as! String
        self.storedRequirementDescription = aDecoder.decodeObject(forKey: "requirementDescription") as! String
        self.executionDates = aDecoder.decodeObject(forKey: "executionDates") as! [Date]
        self.storedExecutionBasis = aDecoder.decodeObject(forKey: "executionBasis") as! Date
        self.isPresentationHandled = aDecoder.decodeBool(forKey: "isPresentationHandled")
        self.countDownComponents = aDecoder.decodeObject(forKey: "countDownComponents") as! CountDownComponents
        self.snoozeComponents = aDecoder.decodeObject(forKey: "snoozeComponents") as! SnoozeComponents
        self.timingStyle = RequirementStyle(rawValue: aDecoder.decodeObject(forKey: "timingStyle") as! String)!
     }
     
     func encode(with aCoder: NSCoder) {
        aCoder.encode(isEnabled, forKey: "isEnabled")
        aCoder.encode(storedRequirementName, forKey: "requirementName")
        aCoder.encode(storedRequirementDescription, forKey: "requirementDescription")
        aCoder.encode(executionDates, forKey: "executionDates")
        aCoder.encode(storedExecutionBasis, forKey: "executionBasis")
        aCoder.encode(isPresentationHandled, forKey: "isPresentationHandled")
        aCoder.encode(countDownComponents, forKey: "countDownComponents")
        aCoder.encode(snoozeComponents, forKey: "snoozeComponents")
        aCoder.encode(timingStyle.rawValue, forKey: "timingStyle")
     }
     
    //MARK: EnableProtocol
    
    ///Whether or not the requirement  is enabled, if disabled all requirements will not fire, if parentDog isEnabled == false will not fire
    private var isEnabled: Bool = DogConstant.defaultEnable
    
    func setEnable(newEnableStatus: Bool) {
        isEnabled = newEnableStatus
        //HDLL
        //if newEnableStatus == true {
        //    self.activeInterval = self.executionInterval
       // }
    }
    
    func willToggle() {
        isEnabled.toggle()
    }
    
    func getEnable() -> Bool{
        return isEnabled
    }
    
    //MARK: RequirementProtocol
    
    private var storedRequirementName: String = RequirementConstant.defaultName
    var requirementName: String { return storedRequirementName }
    func changeRequirementName(newRequirementName: String?) throws {
        if newRequirementName == nil || newRequirementName == "" {
            throw RequirementError.nameInvalid
        }
        storedRequirementName = newRequirementName!
    }
    
    ///description set to describe what the requirement should do, should be set by user
    private var storedRequirementDescription: String = RequirementConstant.defaultDescription
    var requirementDescription: String { return storedRequirementDescription }
    func changeRequirementDescription(newRequirementDescription: String?) throws{
        if newRequirementDescription == nil {
            throw RequirementError.descriptionInvalid
        }
        
        storedRequirementDescription = newRequirementDescription!
    }
    
    var executionDates: [Date] = []
    
    private var storedExecutionBasis: Date = Date()
    var executionBasis: Date { return storedExecutionBasis }
    func changeExecutionBasis(newExecutionBasis: Date){
        storedExecutionBasis = newExecutionBasis
        
        //If resetting the executionBasis to the current time (and not changing it to another executionBasis of some other requirement) then resets interval elasped as timers would have to be fresh
        if newExecutionBasis.distance(to: Date()) <= 1{
            snoozeComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
            countDownComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
        }
        
    }
    
    var isPresentationHandled: Bool = false
    
    var countDownComponents: CountDownComponents = CountDownComponents()
    
    var snoozeComponents: SnoozeComponents = SnoozeComponents()
    
    var timingStyle: RequirementStyle = .countDown
    
    var intervalRemaining: TimeInterval {
        if snoozeComponents.isSnoozed == true {
            return snoozeComponents.executionInterval - snoozeComponents.intervalElapsed
        }
        else {
            return countDownComponents.executionInterval - countDownComponents.intervalElapsed
        }
    }
    
    func timerReset(){
        self.executionDates.append(Date())
        self.changeExecutionBasis(newExecutionBasis: Date())
        self.isPresentationHandled = false
        
        snoozeComponents.timerReset()
        
        if timingStyle == .countDown {
            self.countDownComponents.timerReset()
        }
        else {
            //HDLL
        }
        
    }
    
}



