//
//  MonthlyComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class MonthlyComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MonthlyComponents()
        copy.day = self.day
        copy.hour = self.hour
        copy.minute = self.minute
        copy.isSkipping = self.isSkipping
        copy.isSkippingDate = self.isSkippingDate
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        day = aDecoder.decodeInteger(forKey: "day")
        hour = aDecoder.decodeInteger(forKey: "hour")
        minute = aDecoder.decodeInteger(forKey: "minute")
        isSkipping = aDecoder.decodeBool(forKey: "isSkipping")
        isSkippingDate = aDecoder.decodeObject(forKey: "isSkippingDate") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(day, forKey: "day")
        aCoder.encode(hour, forKey: "hour")
        aCoder.encode(minute, forKey: "minute")
        aCoder.encode(isSkipping, forKey: "isSkipping")
        aCoder.encode(isSkippingDate, forKey: "isSkippingDate")
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(day: Int?, hour: Int?, minute: Int?, isSkipping: Bool?, isSkippingDate: Date?) {
        self.init()
        self.day = day ?? self.day
        self.hour = hour ?? self.hour
        self.minute = minute ?? self.minute
        self.isSkipping = isSkipping ?? self.isSkipping
        self.isSkippingDate = isSkippingDate
        
    }
    
    // MARK: - Properties
    
    /// Day of the month that a reminder will fire
    private(set) var day: Int = 1
    /// Throws if not within the range of [1,31]
    func changeDay(newDay: Int) throws {
        guard newDay >= 1 && newDay <= 31 else {
            throw MonthlyComponentsError.dayInvalid
        }
        day = newDay
        
    }
    
    /// Hour of the day that the reminder will fire
    private(set) var hour: Int = 7
    
    ///  Throws if not within the range of [0,24]
    func changeHour(newHour: Int) throws {
        guard newHour >= 0 && newHour <= 24 else {
            throw MonthlyComponentsError.hourInvalid
        }
        
        hour = newHour
    }
    
    /// Minute of the hour that the reminder will fire
    private(set) var minute: Int = 0
    
    /// Throws if not within the range of [0,60]
    func changeMinute(newMinute: Int) throws {
        guard newMinute >= 0 && newMinute <= 60 else {
            throw MonthlyComponentsError.minuteInvalid
        }
        
        minute = newMinute
    }
    
    /// Whether or not the next alarm will be skipped
    var isSkipping: Bool = false
    
    /// The date at which the user changed the isSkipping to true.  If is skipping is true, then a certain log date was appended. If unskipped, then we have to remove that previously added log. Slight caveat: if the skip log was modified (by the user changing its date) we don't remove it.
    var isSkippingDate: Date?
    
    // MARK: - Functions
    
    /// This find the next execution date that takes place after the reminderExecutionBasis. It purposelly not factoring in isSkipping.
    func notSkippingExecutionDate(reminderExecutionBasis: Date) -> Date {
        
        // there will only be two future executions dates for a day, so we take the first one is the one.
        return futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis).first!
    }
    
    func previousExecutionDate(reminderExecutionBasis: Date) -> Date {
        
        // use non skipping version
        let nextTimeOfDay = notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis)
        
        var preceedingExecutionDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: nextTimeOfDay)!
        preceedingExecutionDate = fallShortCorrection(dateToCorrect: preceedingExecutionDate)
        return preceedingExecutionDate
    }
    
    /// Factors in isSkipping to figure out the next time of day
    func nextExecutionDate(reminderExecutionBasis: Date) -> Date {
        if isSkipping == true {
            return skippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis)
        }
        else {
            return notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis)
        }
    }
    
    // MARK: - Private Helper Functions
    
    //// If we add a month to the date, then it might be incorrect and lose accuracy. For example, our day is 31. We are in April so there is only 30 days. Therefore we get a calculated date of April 30th. After adding a month, the result date is May 30th, but it should be 31st because of our day and that May has 31 days. This corrects that.
    private func fallShortCorrection(dateToCorrect: Date) -> Date {
        
        let dayForCalculatedDate = Calendar.current.component(.day, from: dateToCorrect)
        // when adding a month, the day set fell short of what was needed. We need to correct it
        if day > dayForCalculatedDate {
            // We need to find the maximum possible day to set the date to without having it accidentially roll into the next month.
            var calculatedDay: Int {
                let neededDay = day
                let maximumDay = Calendar.current.range(of: .day, in: .month, for: dateToCorrect)!.count
                if neededDay <= maximumDay {
                    return neededDay
                }
                else {
                    return maximumDay
                }
            }
            
            // We have the correct day to set the date to, now we can change it.
            return Calendar.current.date(bySetting: .day, value: calculatedDay, of: dateToCorrect)!
        }
        // when adding a month, the day did not fall short of what was needed
        else {
            return dateToCorrect
        }
        
    }
    
    /// Produces an array of at least two with all of the future dates that the reminder will fire given the day of month, hour, and minute
    private func futureExecutionDates(reminderExecutionBasis: Date) -> [Date] {
        
        var calculatedDates: [Date] = []
        
        var calculatedDate = reminderExecutionBasis
        
        // finds number of days in the calculated date's month, used for roll over calculations
        let numDaysInMonth = Calendar.current.range(of: .day, in: .month, for: calculatedDate)!.count
        
        // the day of month is greater than the number of days in the target month, so we just use the last possible day of month to get as close as possible without rolling over into the next month.
        if day > numDaysInMonth {
            calculatedDate = Calendar.current.date(bySetting: .day, value: numDaysInMonth, of: calculatedDate)!
            // sets time of day
            calculatedDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: calculatedDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
        }
        // day of month is less than days available in the current month, so no roll over correction needed and traditional method
        else {
            calculatedDate = Calendar.current.date(bySetting: .day, value: day, of: calculatedDate)!
            // sets time of day
            calculatedDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: calculatedDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
        }
        
        // We are looking for future dates, not past. If the calculated date is in the past, we correct to make it in the future.
        if reminderExecutionBasis.distance(to: calculatedDate) < 0 {
            calculatedDate = Calendar.current.date(byAdding: .month, value: 1, to: calculatedDate)!
            calculatedDate = fallShortCorrection(dateToCorrect: calculatedDate)
            
        }
        calculatedDates.append(calculatedDate)
        
        if calculatedDates.count > 1 {
            calculatedDates.sort()
        }
        // should have at least two dates
        else if calculatedDates.count == 1 {
            var appendedDate = Calendar.current.date(byAdding: .month, value: 1, to: calculatedDates[0])!
            appendedDate = fallShortCorrection(dateToCorrect: appendedDate)
            
            calculatedDates.append(appendedDate)
        }
        else {
            AppDelegate.generalLogger.warning("Calculated Dates For futureExecutionDates Empty")
            // calculated dates should never be zero, this means there are somehow zero weekdays selected. Handle this weird case by just appending future dates (one 1 week ahead and the other 2 weeks ahead)
            calculatedDates.append(Calendar.current.date(byAdding: .day, value: 7, to: reminderExecutionBasis)!)
            calculatedDates.append(Calendar.current.date(byAdding: .day, value: 14, to: reminderExecutionBasis)!)
        }
        
        return calculatedDates
    }
    
    /// If a reminder is skipping, then we must find the next soonest reminderExecutionDate. We have to find the execution date that takes place after the skipped execution date (but before any other execution date).
    private func skippingExecutionDate(reminderExecutionBasis: Date) -> Date {
        // there will only be two future executions dates for a day, so we take the second one. The first one is the one used for a not skipping
        return futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis).last!
        
    }
    
}
