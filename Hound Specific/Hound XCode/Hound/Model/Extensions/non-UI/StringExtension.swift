//
//  StringExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension String {
    
    /// Converts a time interval to a more readable string to display. E.g. (1800.0, true) to 30 Minutes or (7320.0, false) to 2 hours 2 minutes. Capital letters dictates whether or not the labels are capitalized (minute vs Minute)
    static func convertToReadable(fromTimeInterval timeInterval: TimeInterval, capitalizeLetters: Bool = true) -> String {
        let intTime = abs(Int(timeInterval.rounded()))
        
        let numWeeks = Int((intTime / (86400))/7)
        let numDaysUnderAWeek = Int((intTime / (86400))%7)
        let numDays = Int(intTime / (86400))
        let numHours = Int((intTime % (86400))/(3600))
        let numMinutes = Int((intTime % 3600)/60)
        let numSeconds = Int((intTime % 3600)%60)
        
        var readableString = ""
        
        switch intTime {
        case 0..<60:
            readableString.addSeconds(numSeconds: numSeconds)
        case 60..<3600:
            readableString.addMinutes(numMinutes: numMinutes)
        case 3600..<86400:
            readableString.addHours(numHours: numHours)
            readableString.addMinutes(numMinutes: numMinutes)
        case 86400..<604800:
            readableString.addDays(numDays: numDays)
            readableString.addHours(numHours: numHours)
        default:
            readableString.addWeeks(numWeeks: numWeeks)
            readableString.addDays(numDays: numDaysUnderAWeek)
        }
        
        if readableString.last == " "{
            readableString.removeLast()
        }
        
        if capitalizeLetters == false {
            return readableString.lowercased()
        }
        else {
            return readableString
        }
    }
    
    /// Converts dateComponents with .hour and .minute to a readable string, e.g. 8:56AM or 2:23 PM
    static func convertToReadable(fromHour hour: Int, fromMinute minute: Int) -> String {
        
        var amOrPM: String {
            if hour < 12 {
                return "AM"
            }
            else {
                return "PM"
            }
        }
        
        var adjustedHour = hour
        if adjustedHour > 12 {
            adjustedHour -= 12
        }
        else if adjustedHour == 0 {
            adjustedHour = 12
        }
        
        if minute < 10 {
            return "\(adjustedHour):0\(minute) \(amOrPM)"
        }
        else {
            return "\(adjustedHour):\(minute) \(amOrPM)"
        }
    }
    
    /// Converts a date into a readable string. The year is only added if its different from the current. e.g. 8:58 PM March 7, 2021
    static func convertToReadable(fromDate date: Date) -> String {
        
        var dateString = ""
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        dateString = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM d", options: 0, locale: Calendar.current.locale)
        dateString.append(" \(dateFormatter.string(from: date))")
        
        let day = Calendar.current.component(.day, from: date)
        dateString.append(String.monthlyDaySuffix(day: day))
        
        let year = Calendar.current.component(.year, from: date)
        if year != Calendar.current.component(.year, from: Date()) {
            dateString.append(", \(year)")
        }
        
        return dateString
    }
    
    /// Takes the given day of month and appends an appropiate suffix of st, nd, rd, or th, e.g. 31 returns st, 20 returns th, 2 returns nd
    static func monthlyDaySuffix(day monthlyDay: Int) -> String {
        switch monthlyDay {
        case 1:
            return "st"
        case 2:
            return "nd"
        case 3:
            return "rd"
        case 21:
            return "st"
        case 22:
            return "nd"
        case 23:
            return "rd"
        case 31:
            return "st"
        default:
            return "th"
        }
    }
    
    mutating private func addMonths(numMonths: Int) {
        if numMonths > 1 {
            self.append("\(numMonths) Months ")
        }
        else if numMonths == 1 {
            self.append("\(numMonths) Month ")
        }
    }
    
    mutating private func addWeeks(numWeeks: Int) {
        if numWeeks > 1 {
            self.append("\(numWeeks) Weeks ")
        }
        else if numWeeks == 1 {
            self.append("\(numWeeks) Week ")
        }
    }
    
    mutating private func addDays(numDays: Int) {
        if numDays > 1 {
            self.append("\(numDays) Days ")
        }
        else if numDays == 1 {
            self.append("\(numDays) Day ")
        }
    }
    
    mutating private func addHours(numHours: Int) {
        if numHours > 1 {
            self.append("\(numHours) Hours ")
        }
        else if numHours == 1 {
            self.append("\(numHours) Hour ")
        }
    }
    
    mutating private func addMinutes(numMinutes: Int) {
        if numMinutes > 1 {
            self.append("\(numMinutes) Minutes ")
        }
        else if numMinutes == 1 {
            self.append("\(numMinutes) Minute ")
        }
    }
    
    mutating private func addSeconds(numSeconds: Int) {
        if numSeconds > 1 || numSeconds == 0 {
            self.append("\(numSeconds) Seconds")
        }
        else if numSeconds == 1 {
            self.append("\(numSeconds) Second")
        }
    }
    
    /// Adds given text with given font to the end of the string, converts whole thing to NSAttributedString
    func addingFontToEnd(text: String, font customFont: UIFont) -> NSAttributedString {
        let originalString = NSMutableAttributedString(string: self)
        
        let customFontAttribute = [NSAttributedString.Key.font: customFont]
        let customAttributedString = NSMutableAttributedString(string: text, attributes: customFontAttribute)
        
        originalString.append(customAttributedString)
        
        return originalString
    }
    
    /// Adds given text with given font to the start of the string, converts whole thing to NSAttributedString
    func addingFontToBeginning(text: String, font customFont: UIFont) -> NSAttributedString {
        let originalString = NSMutableAttributedString(string: self)
        
        let customFontAttribute = [NSAttributedString.Key.font: customFont]
        let customAttributedString = NSMutableAttributedString(string: text, attributes: customFontAttribute)
        
        customAttributedString.append(originalString)
        
        return customAttributedString
    }
    
    /// Takes the string with a given font and height and finds the width the text takes up
    func boundingFrom(font: UIFont = UIFont.systemFont(ofSize: 17), height: CGFloat) -> CGSize {
        let attrString = NSAttributedString(string: self, attributes: [.font: font])
        
        let bounds = attrString.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height), options: .usesLineFragmentOrigin, context: nil)
        
        let size = CGSize(width: bounds.width, height: bounds.height)
        
        return size
        
    }
    
    /// Takes the string with a given font and width and finds the height the text takes up
    func boundingFrom(font: UIFont = UIFont.systemFont(ofSize: 17), width: CGFloat) -> CGSize {
        let attrString = NSAttributedString(string: self, attributes: [.font: font])
        
        let bounds = attrString.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let size = CGSize(width: bounds.width, height: bounds.height)
        
        return size
        
    }
    
    /// Only works if the label it is being used on has a single line of text OR has its paragraphs predefined with \n (s).
    func bounding(font: UIFont = UIFont.systemFont(ofSize: 17)) -> CGSize {
        let boundHeight = self.boundingFrom(font: font, width: .greatestFiniteMagnitude)
        let boundWidth = self.boundingFrom(font: font, height: .greatestFiniteMagnitude)
        return CGSize(width: boundWidth.width, height: boundHeight.height)
        
    }
    
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    subscript (range: Range<Int>) -> Substring {
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
        return self[startIndex..<stopIndex]
    }
}
