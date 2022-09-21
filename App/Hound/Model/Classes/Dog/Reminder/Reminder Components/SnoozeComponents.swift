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
        snoozeIsEnabled = aDecoder.decodeObject(forKey: KeyConstant.snoozeIsEnabled.rawValue) as? Bool ?? snoozeIsEnabled
        // <= build 8000 "executionInterval"
        executionInterval = aDecoder.decodeObject(forKey: KeyConstant.snoozeExecutionInterval.rawValue) as? Double ?? aDecoder.decodeObject(forKey: "executionInterval") as? Double ?? executionInterval
        // <= build 8000 "intervalElapsed"
        intervalElapsed = aDecoder.decodeObject(forKey: KeyConstant.snoozeIntervalElapsed.rawValue) as? Double ?? aDecoder.decodeObject(forKey: "intervalElapsed") as? Double ?? intervalElapsed
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(snoozeIsEnabled, forKey: KeyConstant.snoozeIsEnabled.rawValue)
        aCoder.encode(executionInterval, forKey: KeyConstant.snoozeExecutionInterval.rawValue)
        aCoder.encode(intervalElapsed, forKey: KeyConstant.snoozeIntervalElapsed.rawValue)
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
