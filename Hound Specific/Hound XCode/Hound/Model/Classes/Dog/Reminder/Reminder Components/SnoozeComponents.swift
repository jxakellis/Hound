//
//  SnoozeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

class SnoozeComponents: Component, NSCoding, NSCopying, GeneralCountdownProtocol {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SnoozeComponents()
        copy.changeSnooze(newSnoozeStatus: self.snoozeIsEnabled)
        copy.changeIntervalElapsed(newIntervalElapsed: self.intervalElapsed)
        copy.changeExecutionInterval(newExecutionInterval: self.executionInterval)
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.storedSnoozeIsEnabled = aDecoder.decodeBool(forKey: "snoozeIsEnabled")
        self.storedExecutionInterval = aDecoder.decodeDouble(forKey: "executionInterval")
        self.storedIntervalElapsed = aDecoder.decodeDouble(forKey: "intervalElapsed")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedSnoozeIsEnabled, forKey: "snoozeIsEnabled")
        aCoder.encode(storedExecutionInterval, forKey: "executionInterval")
        aCoder.encode(storedIntervalElapsed, forKey: "intervalElapsed")
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(snoozeIsEnabled: Bool?, executionInterval: TimeInterval?, intervalElapsed: TimeInterval?) {
        self.init()
        
        if snoozeIsEnabled != nil {
            storedSnoozeIsEnabled = snoozeIsEnabled!
        }
        if executionInterval != nil {
            storedExecutionInterval = executionInterval!
        }
        if intervalElapsed != nil {
            storedIntervalElapsed = intervalElapsed!
        }
    }
    
    // MARK: - Properties
    
    private var storedSnoozeIsEnabled: Bool = false
    /// Bool on whether or not the parent reminder is snoozed
    var snoozeIsEnabled: Bool { return storedSnoozeIsEnabled }
    /// Change snoozeIsEnabled to new status and does accompanying changes
    func changeSnooze(newSnoozeStatus: Bool) {
        if newSnoozeStatus == true {
            storedExecutionInterval = UserConfiguration.snoozeLength
        }
        
        storedSnoozeIsEnabled = newSnoozeStatus
    }
    
    // MARK: - GeneralCountdownProtocol
    
    private var storedExecutionInterval = UserConfiguration.snoozeLength
    var executionInterval: TimeInterval { return storedExecutionInterval }
    func changeExecutionInterval(newExecutionInterval: TimeInterval) {
        storedExecutionInterval = newExecutionInterval
    }
    
    private var storedIntervalElapsed: TimeInterval = TimeInterval(0)
    // this is necessary due to the pause feature. If you snooze an alarm then pause all alarms, you want the alarm to pick up where it left off, without storing this and just storing 5 minutes (default snooze length) after the reminderExecutionBasis then the alarm couldn't have progress
    var intervalElapsed: TimeInterval { return storedIntervalElapsed }
    func changeIntervalElapsed(newIntervalElapsed: TimeInterval) {
        storedIntervalElapsed = newIntervalElapsed
    }
}
