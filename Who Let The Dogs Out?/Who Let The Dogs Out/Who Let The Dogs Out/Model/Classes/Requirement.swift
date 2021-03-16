//
//  Requirement.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit


class Requirement: NSObject, NSCoding, NSCopying, DogRequirementProtocol,  EnableProtocol {
    
     //MARK: NSCoding
     required init?(coder aDecoder: NSCoder) {
        isEnabled = aDecoder.decodeBool(forKey: "isEnabled")
        name = aDecoder.decodeObject(forKey: "name") as! String
        requirementDescription = aDecoder.decodeObject(forKey: "requirementDescription") as! String
        storedExecutionInterval = aDecoder.decodeDouble(forKey: "executionInterval")
        lastExecution = aDecoder.decodeObject(forKey: "lastExecution") as! Date
        activeInterval = aDecoder.decodeDouble(forKey: "activeInterval") 
        intervalElapsed = aDecoder.decodeDouble(forKey: "intervalElapsed")
        executionDates = aDecoder.decodeObject(forKey: "executionDates") as! [Date]
        storedIsSnoozed = aDecoder.decodeBool(forKey: "isSnoozed")
        isPresentationHandled = aDecoder.decodeBool(forKey: "isPresentationHandled")
     }
     
     func encode(with aCoder: NSCoder) {
        aCoder.encode(isEnabled, forKey: "isEnabled")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(requirementDescription, forKey: "requirementDescription")
        aCoder.encode(executionInterval, forKey: "executionInterval")
        aCoder.encode(lastExecution, forKey: "lastExecution")
        aCoder.encode(activeInterval, forKey: "activeInterval")
        aCoder.encode(intervalElapsed, forKey: "intervalElapsed")
        aCoder.encode(executionDates, forKey: "executionDates")
        aCoder.encode(isSnoozed, forKey: "isSnoozed")
        aCoder.encode(isPresentationHandled,forKey: "isPresentationHandled")
     }
     
    //MARK: EnableProtocol
    
    ///Whether or not the requirement  is enabled, if disabled all requirements will not fire, if parentDog isEnabled == false will not fire
    private var isEnabled: Bool = DogConstant.defaultEnable
    
    func setEnable(newEnableStatus: Bool) {
        isEnabled = newEnableStatus
        if newEnableStatus == true {
            self.activeInterval = self.executionInterval
        }
    }
    
    func willToggle() {
        isEnabled.toggle()
    }
    
    func getEnable() -> Bool{
        return isEnabled
    }
    
    //MARK: NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        //String(), Date(), Double() which TimeInterval is a typealias of are all structs aka not reference types
        var copy = Requirement()
        try! copy.changeName(newName: self.name)
        try! copy.changeInterval(newInterval: self.executionInterval)
        try! copy.changeDescription(newDescription: self.requirementDescription)
        copy.changeSnooze(newSnoozeStatus: self.isSnoozed)
        copy.lastExecution = self.lastExecution
        copy.intervalElapsed = self.intervalElapsed
        copy.isEnabled = self.isEnabled
        copy.executionDates = self.executionDates
        copy.activeInterval = self.activeInterval
        copy.isPresentationHandled = self.isPresentationHandled
        return copy
    }
    
    ///name for what the requirement does, set by user, used as main name for requirement, e.g. potty or food
    var name: String = RequirementConstant.defaultName
    
    ///description set to describe what the requirement should do, should be set by user
    var requirementDescription: String = RequirementConstant.defaultDescription
    
    //MARK: Execution Interval
    
    private var storedExecutionInterval: TimeInterval = TimeInterval(RequirementConstant.defaultTimeInterval)
    ///TimeInterval that is used in conjunction with a Date() and timer handler to decide when an timer should go off.
    var executionInterval: TimeInterval {
        return storedExecutionInterval
    }
    
    ///if newInterval passes all tests, changes value, if not throws error
    func changeInterval(newInterval: TimeInterval?) throws{
        
        /*
         if newInterval == nil || newInterval! < TimeInterval(60.0){
             throw DogRequirementError.intervalInvalid
         }
         */
        if newInterval == nil{
            throw DogRequirementError.intervalInvalid
        }
        self.storedExecutionInterval = newInterval!
        if self.isSnoozed == false {
            activeInterval = newInterval!
        }
    }
    
    //MARK: Timing Calculations
    
    ///stores exact Date object of when the requirement was last executed (i.e. last fired and sent an alert)
    var lastExecution: Date = Date()
    
    var activeInterval: TimeInterval = TimeInterval(RequirementConstant.defaultTimeInterval)
    
    ///stores time elapsed of timer, this is only utilized if a timer is paused as it is needed to calculate when to fire the timer when it is unpaused. There is no built in pause feature so a timer must be invalidated and a new one created later on, hence this being needed.
    var intervalElapsed: TimeInterval = TimeInterval(0)
    
    var executionDates: [Date] = []
    
    var isPresentationHandled: Bool = false
    
    //MARK: Snooze
    
    private var storedIsSnoozed: Bool = false
    var isSnoozed: Bool {
        return storedIsSnoozed
    }
    
    func changeSnooze(newSnoozeStatus: Bool) {
        if newSnoozeStatus == true {
            activeInterval = TimerConstant.defaultSnooze
        }
        else {
            activeInterval = self.executionInterval
        }
        self.storedIsSnoozed = newSnoozeStatus
    }
    
    override init() {
        super.init()
    }
    
}

class RequirementManager: NSObject, NSCoding, NSCopying, DogRequirementManagerProtocol {
    
    //MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        requirements = aDecoder.decodeObject(forKey: "requirements") as! [Requirement]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(requirements, forKey: "requirements")
    }
    
    //MARK: NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RequirementManager()
        for i in 0..<self.requirements.count {
            copy.requirements.append(self.requirements[i].copy() as! Requirement)
        }
        return copy
    }
    
    ///Array of requirements
    var requirements: [Requirement]
    
    ///if the array should be set to something by default, can be done so with init
    required init(initRequirements: [Requirement] = []) {
        requirements = initRequirements
    }
    
}
