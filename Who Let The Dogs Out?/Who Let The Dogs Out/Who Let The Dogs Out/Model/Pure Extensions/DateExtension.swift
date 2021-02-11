//
//  DateExtension.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 12/8/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension Date {
    
    //Returns a Date object that is the product of adding interval: TimeInterval to pastDate until it is greater than or equal to current date.
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
    
    /*
     Used for calculating timeInterval between two dates, final print returns it in a hours and minutes representation
     let futureDate = Date(timeInterval: TimeInterval((3600)*2.5), since: Date())
     let ti = futureDate.timeIntervalSince(Date())
     print(ti)
     print(String.convertTimeIntervalToReadable(interperateTimeInterval: ti))
     */
}
