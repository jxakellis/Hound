//
//  EnableProtocol.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/6/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol EnableProtocol {
    
    //var isEnabled: Bool { get set }
    
    ///Changes isEnabled to newEnableStatus
    func setEnable(newEnableStatus: Bool)
    
    ///Toggles isEnabled
    func willToggle()
    
    ///Returns isEnabled state
    func getEnable() -> Bool
    
}

protocol CountDownComponents {
    
    //To be added later when time of day reminders (e.g. tuesdays at 8:53 AM) are added instead of just countdowns.
    
    ///interval at which a timer should be triggered for requirement
    var executionInterval: TimeInterval { get }
    mutating func changeExecutionInterval(newExecutionInterval: TimeInterval)
    
    ///The interval that is currently activated to calculate.
    var activeInterval: TimeInterval { get }
    mutating func changeActiveInterval(newActiveInterval: TimeInterval)
    
    ///last time the requirement was fired
    var lastExecution: Date { get }
    mutating func changeLastExecution(newLastExecution: Date)
    
    ///how much time of the interval of been used up, this is used for when a timer is paused and then unpaused and have to calculate remaining time
    var intervalElapsed: TimeInterval { get }
    mutating func changeIntervalElapsed(newIntervalElapsed: TimeInterval)
    
    
    
    
   
    
}
