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
    mutating func changeSnooze(newSnoozeStatus: Bool)
    
}

class SnoozeComponents: Component, NSCoding, NSCopying, GeneralCountDownProtocol, SnoozeComponentsProtocol {
    
    //MARK: NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SnoozeComponents()
        copy.changeSnooze(newSnoozeStatus: self.isSnoozed)
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
        //HDLL
        /*
         HDLL
        if newSnoozeStatus == true {
            activeInterval = TimerConstant.defaultSnooze
        }
        else {
            activeInterval = self.executionInterval
        }
    */
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


