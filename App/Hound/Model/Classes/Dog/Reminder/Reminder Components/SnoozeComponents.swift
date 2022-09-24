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
        copy.executionInterval = executionInterval
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        executionInterval = aDecoder.decodeDouble(forKey: KeyConstant.snoozeExecutionInterval.rawValue)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(executionInterval, forKey: KeyConstant.snoozeExecutionInterval.rawValue)
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(executionInterval: TimeInterval?) {
        self.init()
        
        self.executionInterval = executionInterval ?? self.executionInterval
    }
    
    // MARK: - Properties
    
    /// Interval at which a timer should be triggered for reminder. If this value isn't nil, then the reminder is snoozing. 
    var executionInterval: TimeInterval?
}
