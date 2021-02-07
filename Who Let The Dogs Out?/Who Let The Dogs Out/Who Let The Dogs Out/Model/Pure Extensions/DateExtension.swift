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
    static func executionDate(pastDate: Date,  currentDate: Date = Date(), interval: TimeInterval) -> Date {
        //I added this weird buffer to account for a possible error. If calculating the execution date and it is concincidentally equal to the current time, this buffer could possibly account for computing time, so that when the date returned is finally used instead of being 1 second old and thrown away it is about to happen and used. I have no clue if this is necessary but I have added it temporarily while I figure out if it is
        let temporaryBUFFERremoveLATER: Double = 2.0
        
        let timeElapsedSincePast = currentDate.timeIntervalSince(pastDate)
        
        let timesIntervalNeedsAdded = Int((timeElapsedSincePast/interval).rounded())
        
        return Date(timeInterval: (Double(timesIntervalNeedsAdded) * interval) + temporaryBUFFERremoveLATER, since: pastDate)
    }
    
    /*
     Used for calculating timeInterval between two dates, final print returns it in a hours and minutes representation
     let futureDate = Date(timeInterval: TimeInterval((3600)*2.5), since: Date())
     let ti = futureDate.timeIntervalSince(Date())
     print(ti)
     print(String.convertTimeIntervalToReadable(interperateTimeInterval: ti))
     */
}
