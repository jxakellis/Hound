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
    static func convertTimeIntervalToReadable(interperateTimeInterval: TimeInterval, showSeconds: Bool = false) -> String {
        
        let intTime = abs(Int(interperateTimeInterval.rounded()))
        
        let numHours = Int(intTime / 3600)
        let numMinutes = Int((intTime % 3600)/60)
        let numSeconds = Int((intTime % 3600)%60)
        
        var readableString = ""
        
        if numHours > 1 {
            readableString.append("\(numHours) Hours ")
        }
        else if numHours == 1 {
            readableString.append("\(numHours) Hour ")
        }
        
        if numMinutes > 1 {
            readableString.append("\(numMinutes) Minutes ")
        }
        else if numMinutes == 1 {
            readableString.append("\(numMinutes) Minute ")
        }
        
        
        if showSeconds == true{
            if numSeconds > 1 || numSeconds == 0 {
                readableString.append("\(numSeconds) Seconds")
            }
            else if numSeconds == 1 {
                readableString.append("\(numSeconds) Second")
            }
        }
        
        return readableString
    }
}
