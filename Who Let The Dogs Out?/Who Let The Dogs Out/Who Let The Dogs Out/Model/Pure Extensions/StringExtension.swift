//
//  StringExtension.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum StringExtensionError: Error {
    case invalidDateComponents
}

extension String {
    //Converts a time interval to a more readable string to display, e.g. 3600.0 Time interval to 1 hour 0 minutes or 7320.0 to 2 hours 2 minutes
    static func convertToReadable(interperateTimeInterval: TimeInterval) -> String {
        
        let intTime = abs(Int(interperateTimeInterval.rounded()))
        
        let numHours = Int(intTime / 3600)
        let numMinutes = Int((intTime % 3600)/60)
        let numSeconds = Int((intTime % 3600)%60)
        
        var readableString = ""
        
        
        switch intTime {
        case 0..<60:
            readableString.addSeconds(numSeconds: numSeconds)
        case 60..<3600:
            readableString.addMinutes(numMinutes: numMinutes)
        default:
            readableString.addHours(numHours: numHours)
            readableString.addMinutes(numMinutes: numMinutes)
        }
        
        return readableString
    }
    
    static func convertToReadable(interperatedDateComponents: DateComponents) throws -> String {
        
        if interperatedDateComponents.hour == nil || interperatedDateComponents.minute == nil {
            throw StringExtensionError.invalidDateComponents
        }
        
        let hour: Int = interperatedDateComponents.hour!
        let minute: Int = interperatedDateComponents.minute!
        
        var amOrPM: String {
            if hour <= 12 {
                return "AM"
            }
            else {
                return "PM"
            }
        }
        
        var adjustedHour = hour
        if adjustedHour > 12 {
            adjustedHour = adjustedHour - 12
        }
        
        if minute < 10 {
            return "\(adjustedHour):0\(minute) \(amOrPM)"
        }
        else {
            return "\(adjustedHour):\(minute) \(amOrPM)"
        }
    }
    
    mutating private func addHours(numHours: Int){
        if numHours > 1 {
            self.append("\(numHours) Hours ")
        }
        else if numHours == 1 {
            self.append("\(numHours) Hour ")
        }
    }
    
    mutating private func addMinutes(numMinutes: Int){
        if numMinutes > 1 {
            self.append("\(numMinutes) Minutes ")
        }
        else if numMinutes == 1 {
            self.append("\(numMinutes) Minute ")
        }
    }
    
    mutating private func addSeconds(numSeconds: Int){
        if numSeconds > 1 || numSeconds == 0 {
            self.append("\(numSeconds) Seconds")
        }
        else if numSeconds == 1 {
            self.append("\(numSeconds) Second")
        }
    }
    
    func withFontAtEnd(text: String, font customFont: UIFont) -> NSAttributedString {
        let originalString = NSMutableAttributedString(string: self)
        
        let customFontAttribute = [NSAttributedString.Key.font: customFont]
        let customAttributedString = NSMutableAttributedString(string: text, attributes: customFontAttribute)
        
        originalString.append(customAttributedString)
        
        return originalString
    }
    
    func withFontAtBeginning(text: String, font customFont: UIFont) -> NSAttributedString {
        let originalString = NSMutableAttributedString(string: self)
        
        let customFontAttribute = [NSAttributedString.Key.font: customFont]
        let customAttributedString = NSMutableAttributedString(string: text, attributes: customFontAttribute)
        
        customAttributedString.append(originalString)
        
        return customAttributedString
    }
}
