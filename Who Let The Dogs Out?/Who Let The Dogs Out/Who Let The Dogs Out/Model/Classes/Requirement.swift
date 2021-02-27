//
//  Requirement.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit


class Requirement: DogRequirementProtocol, NSCopying, EnableProtocol {
    
    //MARK: Conformation EnableProtocol
    
    ///Whether or not the requirement  is enabled, if disabled all requirements will not fire, if parentDog isEnabled == false will not fire
    private var isEnabled: Bool = DogConstant.defaultEnable
    
    func setEnable(newEnableStatus: Bool) {
        isEnabled = newEnableStatus
    }
    
    func willToggle() {
        isEnabled.toggle()
    }
    
    func getEnable() -> Bool{
        return isEnabled
    }
    
    //MARK: Conformation NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        //String(), Date(), Double() which TimeInterval is a typealias of are all structs aka not reference types
        var copy = Requirement()
        try! copy.changeName(newName: self.name)
        try! copy.changeInterval(newInterval: self.executionInterval)
        try! copy.changeDescription(newDescription: self.description)
        copy.lastExecution = self.lastExecution
        copy.intervalElapsed = self.intervalElapsed
        copy.isEnabled = self.isEnabled
        copy.isSnoozed = self.isSnoozed
        return copy
    }
    
    ///name for what the requirement does, set by user, used as main name for requirement, e.g. potty or food
    var name: String = RequirementConstant.defaultName
    
    ///description set to describe what the requirement should do, should be set by user
    var description: String = RequirementConstant.defaultDescription
    
    ///TimeInterval that is used in conjunction with a Date() and timer handler to decide when an alarm should go off.
    var executionInterval: TimeInterval = TimeInterval(RequirementConstant.defaultTimeInterval)
    
    //Timing Calculations
    
    ///stores exact Date object of when the requirement was last executed (i.e. last fired and sent an alert)
    var lastExecution: Date = Date()
    
    ///stores time elapsed of timer, this is only utilized if a timer is paused as it is needed to calculate when to fire the timer when it is unpaused. There is no built in pause feature so a timer must be invalidated and a new one created later on, hence this being needed.
    var intervalElapsed: TimeInterval = TimeInterval(0)
    
    var isSnoozed: Bool = false
    
}

class RequirementManager: DogRequirementManagerProtocol, NSCopying {
    
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
