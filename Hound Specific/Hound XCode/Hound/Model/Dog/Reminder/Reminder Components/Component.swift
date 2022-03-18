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

    /// Called when a timer is handled and needs to be reset
    mutating func timerReset()
}

protocol GeneralTimeOfDayProtocol {

    /// DateComponent that stores at least hour and minute for the timeOfDay reminder, potentially can store other components if needed
    var dateComponents: DateComponents { get }
    /// Changes the values of timeOfDayComponent to the values provided by the dateComponent.
    mutating func changeDateComponents(newDateComponents: DateComponents)
    /// Changes the specific component's value from dateComponent to the value provided
    mutating func changeDateComponents(newDateComponent: Calendar.Component, newValue: Int)

}
