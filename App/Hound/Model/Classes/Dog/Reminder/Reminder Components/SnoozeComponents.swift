//
//  SnoozeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class SnoozeComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SnoozeComponents()
        copy.snoozeIsEnabled = snoozeIsEnabled
        copy.executionInterval = executionInterval
        copy.intervalElapsed = intervalElapsed
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.snoozeIsEnabled = aDecoder.decodeBool(forKey: "snoozeIsEnabled")
        self.executionInterval = aDecoder.decodeDouble(forKey: "executionInterval")
        self.intervalElapsed = aDecoder.decodeDouble(forKey: "intervalElapsed")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(snoozeIsEnabled, forKey: "snoozeIsEnabled")
        aCoder.encode(executionInterval, forKey: "executionInterval")
        aCoder.encode(intervalElapsed, forKey: "intervalElapsed")
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(snoozeIsEnabled: Bool?, executionInterval: TimeInterval?, intervalElapsed: TimeInterval?) {
        self.init()
        
        self.snoozeIsEnabled = snoozeIsEnabled ?? self.snoozeIsEnabled
        self.executionInterval = executionInterval ?? self.executionInterval
        self.intervalElapsed = intervalElapsed ?? self.intervalElapsed
    }
    
    // MARK: - Properties
    
    /// Bool on whether or not the parent reminder is snoozed
    private(set) var snoozeIsEnabled: Bool = false
    /// Change snoozeIsEnabled to new status and does accompanying changes
    func changeSnoozeIsEnabled(forSnoozeIsEnabled: Bool) {
        if forSnoozeIsEnabled == true {
            executionInterval = UserConfiguration.snoozeLength
        }
        
        snoozeIsEnabled = forSnoozeIsEnabled
    }
    
    /// Interval at which a timer should be triggered for reminder
    var executionInterval: TimeInterval = UserConfiguration.snoozeLength
    
    /// How much time of the interval of been used up, this is used for when a timer is paused and then unpaused and have to calculate remaining time
    var intervalElapsed: TimeInterval = TimeInterval(0)
}
