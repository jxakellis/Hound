//
//  countdownComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

class CountdownComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CountdownComponents()
        copy.executionInterval = executionInterval
        copy.intervalElapsed = intervalElapsed
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.executionInterval = aDecoder.decodeDouble(forKey: "executionInterval")
        self.intervalElapsed = aDecoder.decodeDouble(forKey: "intervalElapsed")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(executionInterval, forKey: "executionInterval")
        aCoder.encode(intervalElapsed, forKey: "intervalElapsed")
    }
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(executionInterval: TimeInterval?, intervalElapsed: TimeInterval?) {
        self.init()
        
        if let executionInterval = executionInterval {
            self.executionInterval = executionInterval
        }
        if let intervalElapsed = intervalElapsed {
            self.intervalElapsed = intervalElapsed
        }
    }
    
    // MARK: - GeneralCountdownProtocol
    
    /// Interval at which a timer should be triggered for reminder
    var executionInterval: TimeInterval = ReminderComponentConstant.defaultCountdownExecutionInterval
    
    /// How much time of the interval of been used up, this is used for when a timer is paused and then unpaused and have to calculate remaining time
    var intervalElapsed: TimeInterval = TimeInterval(0)
    
}