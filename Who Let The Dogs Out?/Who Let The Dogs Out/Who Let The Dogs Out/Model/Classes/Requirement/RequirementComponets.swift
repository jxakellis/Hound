//
//  CountDownComponents.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Component: NSObject {
    
    override init(){
        super.init()
    }
    
}

protocol GeneralCountDownProtocol {
    
    ///Interval at which a timer should be triggered for requirement
    var executionInterval: TimeInterval { get }
    mutating func changeExecutionInterval(newExecutionInterval: TimeInterval)
    
    ///How much time of the interval of been used up, this is used for when a timer is paused and then unpaused and have to calculate remaining time
    var intervalElapsed: TimeInterval { get }
    mutating func changeIntervalElapsed(newIntervalElapsed: TimeInterval)
    
    ///Called when a timer is handled and needs to be reset
    mutating func timerReset()
}

class CountDownComponents: Component, NSCoding, NSCopying, GeneralCountDownProtocol {
    
    //MARK: NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CountDownComponents()
        copy.changeExecutionInterval(newExecutionInterval: self.storedExecutionInterval)
        copy.changeIntervalElapsed(newIntervalElapsed: self.storedIntervalElapsed)
        return copy
    }
    
    //MARK: NSCoding
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.storedExecutionInterval = aDecoder.decodeDouble(forKey: "executionInterval")
        self.storedIntervalElapsed = aDecoder.decodeDouble(forKey: "intervalElapsed")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(executionInterval, forKey: "executionInterval")
        aCoder.encode(intervalElapsed, forKey: "intervalElapsed")
    }
    
    //MARK: CountDownComponentsProtocol
    
    private var storedExecutionInterval: TimeInterval = TimeInterval(RequirementConstant.defaultTimeInterval)
    var executionInterval: TimeInterval { return storedExecutionInterval }
    func changeExecutionInterval(newExecutionInterval: TimeInterval) {
        storedExecutionInterval = newExecutionInterval
    }
    
    private var storedIntervalElapsed: TimeInterval = TimeInterval(0)
    var intervalElapsed: TimeInterval { return storedIntervalElapsed }
    func changeIntervalElapsed(newIntervalElapsed: TimeInterval) {
        storedIntervalElapsed = newIntervalElapsed
    }
    
    func timerReset() {
        //changeLastExecution(newLastExecution: Date())
        changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
    }
    
    
}

protocol SnoozeComponentsProtocol {
    
    ///Bool on whether or not the parent requirement is snoozed
    var isSnoozed: Bool { get }
    ///Change isSnoozed to new status and does accompanying changes
    mutating func changeSnooze(newSnoozeStatus: Bool)
    
}

class SnoozeComponents: Component, NSCoding, NSCopying, GeneralCountDownProtocol, SnoozeComponentsProtocol {
    
    //MARK: NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SnoozeComponents()
        copy.changeSnooze(newSnoozeStatus: self.isSnoozed)
        copy.changeIntervalElapsed(newIntervalElapsed: self.intervalElapsed)
        copy.changeExecutionInterval(newExecutionInterval: self.executionInterval)
        return copy
    }
    
    //MARK: NSCoding
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.storedIsSnoozed = aDecoder.decodeBool(forKey: "isSnoozed")
        self.storedExecutionInterval = aDecoder.decodeDouble(forKey: "executionInterval")
        self.storedIntervalElapsed = aDecoder.decodeDouble(forKey: "intervalElapsed")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedIsSnoozed, forKey: "isSnoozed")
        aCoder.encode(storedExecutionInterval, forKey: "executionInterval")
        aCoder.encode(storedIntervalElapsed, forKey: "intervalElapsed")
    }
    
    //MARK: SnoozeComponentsProtocol
    
    private var storedIsSnoozed: Bool = false
    var isSnoozed: Bool { return storedIsSnoozed }
    func changeSnooze(newSnoozeStatus: Bool) {
        if newSnoozeStatus == true {
            storedExecutionInterval = TimerConstant.defaultSnooze
        }
    
        storedIsSnoozed = newSnoozeStatus
    }
    
    private var storedExecutionInterval = TimeInterval(60*30)
    var executionInterval: TimeInterval { return storedExecutionInterval }
    func changeExecutionInterval(newExecutionInterval: TimeInterval){
        storedExecutionInterval = newExecutionInterval
    }
    
    private var storedIntervalElapsed: TimeInterval = TimeInterval(0)
    var intervalElapsed: TimeInterval { return storedIntervalElapsed }
    func changeIntervalElapsed(newIntervalElapsed: TimeInterval) {
        //HDLL
        storedIntervalElapsed = newIntervalElapsed
    }
    
    func timerReset() {
        self.changeSnooze(newSnoozeStatus: false)
        self.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
    }
}

enum TimeOfDayComponentsError: Error {
    case invalidCalendarComponent
}

protocol TimeOfDayComponentsProtocol {
    ///DateComponent that stores the hour and minute specified (e.g. 8:26 am) of the time of day timer
    var timeOfDayComponent: DateComponents { get }
    mutating func changeTimeOfDayComponent(newTimeOfDayComponent: DateComponents) throws
    mutating func changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.Component, newValue: Int) throws
    
    ///Whether or not the next time of day alarm will be skipped
    var isSkipping: Bool { get }
    ///Changes isSkipping and data associated
    mutating func changeIsSkipping(newSkipStatus: Bool)
    
    ///Date that is calculated from timeOfDayComponent when the timer should next fire
    var nextTimeOfDay: Date { get }
    
    ///nextTimeOfDay except 24 hours before
    var previousTimeOfDay: Date { get }
    
    ///If the next timeOfDay alarm is skipped then at some point the time will pass where it transfers from being skipped to regular mode, this is that date at which is should transition back
    var unskipDate: Date? { get }
    
    ///Called when a timer is handled and needs to be reset
    func timerReset()
}

class TimeOfDayComponents: Component, NSCoding, NSCopying, TimeOfDayComponentsProtocol {
    
    //MARK: NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TimeOfDayComponents()
        copy.storedTimeOfDayComponent = self.storedTimeOfDayComponent
        copy.storedIsSkipping = self.storedIsSkipping
        return copy
    }
    
    //MARK: NSCoding
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.storedTimeOfDayComponent = aDecoder.decodeObject(forKey: "timeOfDayComponent") as! DateComponents
        self.storedIsSkipping = aDecoder.decodeBool(forKey: "isSkipping")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedTimeOfDayComponent, forKey: "timeOfDayComponent")
        aCoder.encode(storedIsSkipping, forKey: "isSkipping")
    }
    
    
    //MARK: TimeOfDayComponentsProtocol
    
    private var storedTimeOfDayComponent: DateComponents = TimerConstant.defaultTimeOfDay
    var timeOfDayComponent: DateComponents { return storedTimeOfDayComponent }
    func changeTimeOfDayComponent(newTimeOfDayComponent: DateComponents) throws {
        
        if newTimeOfDayComponent.hour != nil {
            storedTimeOfDayComponent.hour = newTimeOfDayComponent.hour
        }
        if newTimeOfDayComponent.minute != nil {
            storedTimeOfDayComponent.minute = newTimeOfDayComponent.minute
        }
       // if newTimeOfDayComponent.second != nil {
        //    storedTimeOfDayComponent.second = newTimeOfDayComponent.second
        //}
    }
    func changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.Component, newValue: Int) throws {
        if newTimeOfDayComponent == .hour {
            storedTimeOfDayComponent.hour = newValue
        }
        else if newTimeOfDayComponent == .minute {
            storedTimeOfDayComponent.minute = newValue
        }
       // else if newTimeOfDayComponent == .second {
        //    storedTimeOfDayComponent.second = newValue
       // }
        else {
            throw TimeOfDayComponentsError.invalidCalendarComponent
        }
    }
    
    private var storedIsSkipping: Bool = TimerConstant.defaultSkipStatus
    var isSkipping: Bool { return storedIsSkipping }
    func changeIsSkipping(newSkipStatus: Bool) {
        storedIsSkipping = newSkipStatus
    }
    
    var nextTimeOfDay: Date { var calculatedDate: Date = Date()
        calculatedDate = Calendar.current.date(bySettingHour: timeOfDayComponent.hour!, minute: timeOfDayComponent.minute!, second: 0, of: calculatedDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
        
        
        //If the nextTimeOfDay is actually in the past, adds 24 hours to make it into the nextTimeOfDay
        if Date().distance(to: calculatedDate) <= 0 {
            if isSkipping == true {
                calculatedDate = calculatedDate + (24.0 * 60 * 60)
            }
            return (calculatedDate.addingTimeInterval(TimeInterval(24*60*60)))
        }
        
        if isSkipping == true {
            calculatedDate = calculatedDate + (24.0 * 60 * 60)
        }
        
        return calculatedDate
    }
    
    var previousTimeOfDay: Date {
        var calculatedDate = Date(timeInterval: TimeInterval(-1*60*60*24), since: nextTimeOfDay)
        //correction for isSkipping as without it the previous time of day would be in the future while isSkipping == true
        if isSkipping == true {
            calculatedDate = calculatedDate - (24.0 * 60 * 60)
        }
        
        return calculatedDate
    }
    
    var unskipDate: Date? {
        guard isSkipping == true else {
            return nil
        }
        
        return nextTimeOfDay.addingTimeInterval(-1.0*60*60*24)
    }
    
    func timerReset() {
        changeIsSkipping(newSkipStatus: false)
    }
    
    
}


