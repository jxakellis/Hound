//
//  DateExtension.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 12/8/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension Date {
    
    ///Returns a Date object that is the product of adding interval: TimeInterval to pastDate until it is greater than or equal to current date.
    static func executionDate(lastExecution pastDate: Date,  currentDate: Date = Date(), interval: TimeInterval) -> Date {
        
        let timeElapsedSincePast = currentDate.timeIntervalSince(pastDate)
        
        var timesIntervalNeedsAdded: Int {
            //In case current date is almost equal to pastDate, like when initalizing for the first time, this makes sure it still returns the correct amount of intervals needed
            if currentDate.distance(to: pastDate).isLessThanOrEqualTo(5.0){
                return 1
            }
            return Int((timeElapsedSincePast/interval).rounded())
        }
        
        return Date(timeInterval: (Double(timesIntervalNeedsAdded) * interval), since: pastDate)
    }
    
    ///Returns a rounded version of targetDate depending on roundingInterval, e.g. targetDate 18:41:51 -> rounded 18:42:00 for RI of 10 but for a RI of 5 rounded 18:41:50
    static func roundDate(targetDate: Date, roundingInterval: TimeInterval) -> Date{
        let rounded = Date(timeIntervalSinceReferenceDate: (targetDate.timeIntervalSinceReferenceDate / roundingInterval).rounded(.toNearestOrEven) * roundingInterval)
        return rounded
    }
    
    ///Mutates self depending on roundingInterval, e.g. self 18:41:51 -> newRoundedSelf 18:42:00 for RI of 10 but for a RI of 5 rounded 18:41:50
    mutating func roundDate(roundingInterval: TimeInterval) {
        let rounded = Date(timeIntervalSinceReferenceDate: (self.timeIntervalSinceReferenceDate / roundingInterval).rounded(.toNearestOrEven) * roundingInterval)
        self = rounded
    }
    
    ///Returns Date in respect to self but adjusted to current time zone to reflect
    func withCurrentTimeZone() -> Date {
        return Date(timeInterval: TimeInterval(TimeZone.current.secondsFromGMT()), since: self)
    }
}
