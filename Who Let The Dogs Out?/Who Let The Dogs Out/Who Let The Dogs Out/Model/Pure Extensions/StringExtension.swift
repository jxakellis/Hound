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
    ///Converts a time interval to a more readable string to display, e.g. 3600.0 Time interval to 1 hour 0 minutes or 7320.0 to 2 hours 2 minutes
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
    
    ///Converts dateComponents with .hour and .minute to a readable string, e.g. 8:56AM or 2:23 PM
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
    
    ///Adds given text with given font to the end of the string, converts whole thing to NSAttributedString
    func withFontAtEnd(text: String, font customFont: UIFont) -> NSAttributedString {
        let originalString = NSMutableAttributedString(string: self)
        
        let customFontAttribute = [NSAttributedString.Key.font: customFont]
        let customAttributedString = NSMutableAttributedString(string: text, attributes: customFontAttribute)
        
        originalString.append(customAttributedString)
        
        return originalString
    }
    
    ///Adds given text with given font to the start of the string, converts whole thing to NSAttributedString
    func withFontAtBeginning(text: String, font customFont: UIFont) -> NSAttributedString {
        let originalString = NSMutableAttributedString(string: self)
        
        let customFontAttribute = [NSAttributedString.Key.font: customFont]
        let customAttributedString = NSMutableAttributedString(string: text, attributes: customFontAttribute)
        
        customAttributedString.append(originalString)
        
        return customAttributedString
    }
    
    ///Takes the string with a given font and height and finds the width the text takes up
    func withBoundedWidth(font: UIFont = UIFont.systemFont(ofSize: 17), height: CGFloat) -> CGSize {
            let attrString = NSAttributedString(string: self, attributes: [.font: font])
        
            let bounds = attrString.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height), options: .usesLineFragmentOrigin, context: nil)
        
            let size = CGSize(width: bounds.width, height: bounds.height)
        
            return size
        
    }
    
    ///Takes the string with a given font and width and finds the height the text takes up
    func withBoundedHeight(font: UIFont = UIFont.systemFont(ofSize: 17), width: CGFloat) -> CGSize {
        let attrString = NSAttributedString(string: self, attributes: [.font: font])
    
        let bounds = attrString.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
    
        let size = CGSize(width: bounds.width, height: bounds.height)
    
        return size
    
    }
    
    func withBounded(font: UIFont = UIFont.systemFont(ofSize: 17)) -> CGSize {
        let boundHeight = self.withBoundedHeight(font: font, width: .greatestFiniteMagnitude)
        let boundWidth = self.withBoundedWidth(font: font, height: .greatestFiniteMagnitude)
        return CGSize (width: boundWidth.width, height: boundHeight.height)
        
    }
}
