//
//  Component.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Component: NSObject {
    
    override init() {
        super.init()
    }
    
}

protocol GeneralCountdownProtocol {
    
    /// Interval at which a timer should be triggered for reminder
    var executionInterval: TimeInterval { get }
    mutating func changeExecutionInterval(newExecutionInterval: TimeInterval)
    
    /// How much time of the interval of been used up, this is used for when a timer is paused and then unpaused and have to calculate remaining time
    var intervalElapsed: TimeInterval { get }
    mutating func changeIntervalElapsed(newIntervalElapsed: TimeInterval)
}
