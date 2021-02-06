//
//  Requirement.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit


class Requirement: DogRequirementProtocol, NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        //String(), Date(), Double() which TimeInterval is a typealias of are all structs aka not reference types
        var copy = Requirement(initDate: self.initalizationDate)
        try! copy.changeLabel(newLabel: self.label)
        try! copy.changeInterval(newInterval: self.interval)
        try! copy.changeDescription(newDescription: self.description)
        copy.isEnabled = self.isEnabled
        return copy
    }
    
    //label for what the requirement does, set by user, used as main name for requirement, e.g. potty or food time
    var label: String = RequirementConstant.defaultLabel
    
    //description set to describe what the requirement should do, should be set by user
    var description: String = RequirementConstant.defaultDescription
    
    //stores exact Date object of when the requirement was initalized, used in conjunction with interval to later determine when a timer should fire
    var initalizationDate: Date = Date()
    
    var lastDate: Date
    
    //TimeInterval that is used in conjunction with a Date() and timer handler to decide when an alarm should go off.
    var interval: TimeInterval = TimeInterval(RequirementConstant.defaultTimeInterval)
    
    var isEnabled: Bool = RequirementConstant.defaultEnable
    
    //if for some reason the initDate should be different, can be passed through using the init()
    required init(initDate: Date = Date()) {
        initalizationDate = initDate
        lastDate = initDate
    }
    
}

class RequirementManager: DogRequirementManagerProtocol, NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RequirementManager()
        for i in 0..<self.requirements.count {
            copy.requirements.append(self.requirements[i].copy() as! Requirement)
        }
        return copy
    }
    
    //Array of requirements
    var requirements: [Requirement]
    
    //if the array should be set to something by default, can be done so with init
    required init(initRequirements: [Requirement] = []) {
        requirements = initRequirements
    }
    
}
