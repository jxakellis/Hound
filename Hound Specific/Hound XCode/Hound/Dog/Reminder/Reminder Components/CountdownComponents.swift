//
//  countdownComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

class CountdownComponents: Component, NSCoding, NSCopying, GeneralCountdownProtocol {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CountdownComponents()
        copy.changeExecutionInterval(newExecutionInterval: self.storedExecutionInterval)
        copy.changeIntervalElapsed(newIntervalElapsed: self.storedIntervalElapsed)
        return copy
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        self.storedExecutionInterval = aDecoder.decodeDouble(forKey: "executionInterval")
        self.storedIntervalElapsed = aDecoder.decodeDouble(forKey: "intervalElapsed")
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

        if executionInterval != nil {
            storedExecutionInterval = executionInterval!
        }
        if intervalElapsed != nil {
            storedIntervalElapsed = intervalElapsed!
        }
    }

    // MARK: - GeneralCountdownProtocol

    private var storedExecutionInterval: TimeInterval = TimeInterval(ReminderConstant.defaultTimeInterval)
    var executionInterval: TimeInterval { return storedExecutionInterval }
    func changeExecutionInterval(newExecutionInterval: TimeInterval) {
        storedExecutionInterval = newExecutionInterval
    }

    private var storedIntervalElapsed: TimeInterval = TimeInterval(0)
    var intervalElapsed: TimeInterval { return storedIntervalElapsed }
    func changeIntervalElapsed(newIntervalElapsed: TimeInterval) {
        storedIntervalElapsed = newIntervalElapsed
    }

    func timerReset() {
        changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
    }

}
