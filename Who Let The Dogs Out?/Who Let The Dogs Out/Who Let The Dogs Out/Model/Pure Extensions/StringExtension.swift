//
//  StringExtension.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension String {
    //Converts a time interval to a more readable string to display, e.g. 3600.0 Time interval to 1 hour 0 minutes or 7320.0 to 2 hours 2 minutes
    static func convertTimeIntervalToReadable(interperateTimeInterval: TimeInterval) -> String {
        
        let intTime = abs(Int(interperateTimeInterval.rounded()))
        
        let numHours = Int(intTime / 3600)
        let numMinutes = Int((intTime % 3600)/60)
        let numSeconds = Int((intTime % 3600)%60)
        if numHours == 0 {
            return "\(numMinutes) Minutes"
        }
        else if (numHours > 1 && (numMinutes > 1 || numMinutes == 0)){
            return "\(numHours) Hours \(numMinutes) Minutes"
        }
        else if numHours > 1 && numMinutes == 1 {
            return "\(numHours) Hours \(numMinutes) Minute"
        }
        else if numHours == 1 && (numMinutes > 1 || numMinutes == 0) {
            return "\(numHours) Hour \(numMinutes) Minutes"
        }
        else if numHours == 1 && numMinutes == 1{
            return "\(numHours) Hour \(numMinutes) Minute"
        }
        else if numSeconds > 1 || numSeconds == 0 {
            return "\(numSeconds) Seconds"
        }
        else if numSeconds == 1 {
            return "\(numSeconds) Second"
        }
        else {
            return "unable to convert, TI: \(interperateTimeInterval)"
        }
    }
}
