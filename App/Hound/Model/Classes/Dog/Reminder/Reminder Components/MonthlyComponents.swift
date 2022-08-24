//
//  MonthlyComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class MonthlyComponents: NSObject, NSCoding, NSCopying {
    
    // TO DO NOW test new timing
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MonthlyComponents()
        copy.UTCDay = self.UTCDay
        copy.UTCHour = self.UTCHour
        copy.UTCMinute = self.UTCMinute
        copy.skippedDate = self.skippedDate
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        UTCDay = aDecoder.decodeInteger(forKey: "UTCDay")
        UTCHour = aDecoder.decodeInteger(forKey: "UTCHour")
        UTCMinute = aDecoder.decodeInteger(forKey: "UTCMinute")
        skippedDate = aDecoder.decodeObject(forKey: "skippedDate") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(UTCDay, forKey: "UTCDay")
        aCoder.encode(UTCHour, forKey: "UTCHour")
        aCoder.encode(UTCMinute, forKey: "UTCMinute")
        aCoder.encode(skippedDate, forKey: "skippedDate")
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(UTCDay: Int?, UTCHour: Int?, UTCMinute: Int?, skippedDate: Date?) {
        self.init()
        self.UTCDay = UTCDay
        ?? self.UTCDay
        self.UTCHour = UTCHour ?? self.UTCHour
        self.UTCMinute = UTCMinute ?? self.UTCMinute
        self.skippedDate = skippedDate
        
    }
    
    // MARK: - Properties
    
    /// Calendar object with it's time zone set to GMT+0000
    private var UTCCalendar: Calendar {
        var UTCCalendar = Calendar.current
        UTCCalendar.timeZone = TimeZone(secondsFromGMT: 0) ?? UTCCalendar.timeZone
        return UTCCalendar
    }
    private var localCalendar: Calendar {
        return Calendar.current
    }
    
    /// Hour of the day that that the reminder should fire in GMT+0000. [1, 31]
    private(set) var UTCDay: Int = 1
    var localDay: Int {
        // Time Zones only exist in ~ +-14 hours from UTC. Therefore, someone can't be anything other than the same day as UTC
        return UTCDay
    }
    /// Throws if not within the range of [1,31]
    func changeUTCDay(forDate: Date) {
        UTCDay = UTCCalendar.component(.day, from: forDate)
    }
    
    /// Hour of the day that that the reminder should fire in GMT+0000. [0, 23]
    private(set) var UTCHour: Int = 12
    /// Hour of the day that that the reminder should fire in local time zone. [0, 23]
    var localHour: Int {
        let hoursFromUTC = Int(localCalendar.timeZone.secondsFromGMT() / 3600)
        var localHour = UTCHour + hoursFromUTC
        // Verify localHour >= 0
        if localHour < 0 {
            localHour += 24
        }
        
        // Verify localHour <= 23
        if localHour > 23 {
            localHour = localHour % 24
        }
        
        return localHour
    }
    /// Takes a given date and extracts the UTC Hour (GMT+0000) from it.
    func changeUTCHour(forDate: Date) {
        UTCHour = UTCCalendar.component(.hour, from: forDate)
    }
    
    // TO DO NOW rework this feature so it works across time zones. Should produce same result anywhere in the world. to figure this out, store secondsFromGMT (-12 hrs to +14 hrs) whenever UTCMinutes or hours is updated, therefore the minutes or hours have a relation to a timezone. then use these secondsFromGMT when calculating any date so it might say a different time of day (e.g. 4:00 PM cali, 6:00PM chic) but it always references the same exact point in time.
    
    /// Minute of the day that that the reminder should fire in GMT+0000. [0, 59]
    private(set) var UTCMinute: Int = 0
    /// Minute of the day that that the reminder should fire in local time zone. [0, 59]
    var localMinute: Int {
        let minutesFromUTC = Int((localCalendar.timeZone.secondsFromGMT() % 3600) / 60 )
        var localMinute = UTCMinute + minutesFromUTC
        // Verify localMinute >= 0
        if localMinute < 0 {
            localMinute += 60
        }
        
        // Verify localMinute <= 59
        if localMinute > 59 {
            localMinute = localMinute % 60
        }
        
        return localMinute
    }
    
    /// Takes a given date and extracts the UTC minute (GMT+0000) from it.
    func changeUTCMinute(forDate: Date) {
        UTCMinute = UTCCalendar.component(.minute, from: forDate)
    }
    
    /// Whether or not the next alarm will be skipped
    var isSkipping: Bool {
        return skippedDate != nil
    }
    
    /// The date at which the user changed the isSkipping to true.  If is skipping is true, then a certain log date was appended. If unskipped, then we have to remove that previously added log. Slight caveat: if the skip log was modified (by the user changing its date) we don't remove it.
    var skippedDate: Date?
    
    // MARK: - Functions
    
    /// This find the next execution date that takes place after the reminderExecutionBasis. It purposelly not factoring in isSkipping.
    func notSkippingExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {
        // there will only be two future executions dates for a day, so we take the first one is the one.
        return futureExecutionDates(forReminderExecutionBasis: reminderExecutionBasis).first ?? ClassConstant.DateConstant.default1970Date
    }
    
    func previousExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {
        let nextExecutionDate = notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
        
        return fallShortCorrection(forDate:
                                    UTCCalendar.date(byAdding: .month, value: -1, to: nextExecutionDate) ?? ClassConstant.DateConstant.default1970Date
        )
    }
    
    /// Factors in isSkipping to figure out the next time of day
    func nextExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {
        return isSkipping ? skippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis) : notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
    }
    
    // MARK: - Private Helper Functions
    
    //// If we add a month to the date, then it might be incorrect and lose accuracy. For example, our day is 31. We are in April so there is only 30 days. Therefore we get a calculated date of April 30th. After adding a month, the result date is May 30th, but it should be 31st because of our day and that May has 31 days. This corrects that.
    private func fallShortCorrection(forDate date: Date) -> Date {
        
       guard UTCDay > UTCCalendar.component(.day, from: date) else {
            // when adding a month, the day did not fall short of what was needed
            return date
        }
        
        // when adding a month to the date, the day of month needed fell short of the intented day of month
        
        // We need to find the maximum possible day to set the date to without having it accidentially roll into the next month.
        let targetDayOfMonth: Int = {
            let neededDay = UTCDay
            guard let maximumDay = UTCCalendar.range(of: .day, in: .month, for: date)?.count else {
                return neededDay
            }
            
            return neededDay <= maximumDay ? neededDay : maximumDay
        }()
        
        // We have the correct day to set the date to, now we can change it.
        return UTCCalendar.date(bySetting: .day, value: targetDayOfMonth, of: date) ?? ClassConstant.DateConstant.default1970Date
        
    }
    
    /// Produces an array of at least two with all of the future dates that the reminder will fire given the day of month, hour, and minute
    private func futureExecutionDates(forReminderExecutionBasis reminderExecutionBasis: Date) -> [Date] {
        
        var futureExecutionDate = reminderExecutionBasis
        
        // finds number of days in the calculated date's month, used for roll over calculations
        guard let numberOfDaysInMonth = UTCCalendar.range(of: .day, in: .month, for: futureExecutionDate)?.count else {
            return [ClassConstant.DateConstant.default1970Date, ClassConstant.DateConstant.default1970Date]
        }
        
        // We want to make sure that the day of month we are using isn't greater that the number of days in the target month. If it is, then we could accidentily roll over into the next month. For example, without this functionality, setting the day of Feburary to 31 would cause the date to roll into the next month. But, targetDayOfMonth limits the set to 28/29
        
        let targetDayOfMonth: Int = UTCDay <= numberOfDaysInMonth ? UTCDay : numberOfDaysInMonth
       
        // Set futureExecutionDate to the proper day of month
        futureExecutionDate = UTCCalendar.date(bySetting: .day, value: targetDayOfMonth, of: futureExecutionDate) ?? ClassConstant.DateConstant.default1970Date
        
        // Set futureExecutionDate to the proper day of week
        futureExecutionDate = UTCCalendar.date(bySettingHour: UTCHour, minute: UTCMinute, second: 0, of: futureExecutionDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) ?? ClassConstant.DateConstant.default1970Date
        
        // We are looking for future dates, not past. Correct dates in past to make them in the future
        
        if reminderExecutionBasis.distance(to: futureExecutionDate) < 0 {
            // Correct for falling short when we add a month
            futureExecutionDate = fallShortCorrection(forDate: UTCCalendar.date(byAdding: .month, value: 1, to: futureExecutionDate) ?? ClassConstant.DateConstant.default1970Date)
        }
        var futureExecutionDates = [futureExecutionDate]
    
        // futureExecutionDates should have at least two dates
        futureExecutionDates.append(
            fallShortCorrection(forDate:
                                    UTCCalendar.date(byAdding: .month, value: 1, to: futureExecutionDate) ?? ClassConstant.DateConstant.default1970Date
                               )
        )
        
        futureExecutionDates.sort()
        
        return futureExecutionDates
    }
    
    /// If a reminder is skipping, then we must find the next soonest reminderExecutionDate. We have to find the execution date that takes place after the skipped execution date (but before any other execution date).
    private func skippingExecutionDate(forReminderExecutionBasis reminderExecutionBasis: Date) -> Date {
        
        let nextExecutionDate = notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
        
        let futureExecutionDates = futureExecutionDates(forReminderExecutionBasis: reminderExecutionBasis)
        var soonestFutureExecutionDate: Date = futureExecutionDates.first ?? ClassConstant.DateConstant.default1970Date
        
        // Attempt to find futureExecutionDates that are further in the future than nextExecutionDate while being closer to nextExecutionDate than soonestFutureExecutionDate
        for futureExecutionDate in futureExecutionDates where
        nextExecutionDate.distance(to: futureExecutionDate) > 0
        && nextExecutionDate.distance(to: futureExecutionDate) < nextExecutionDate.distance(to: soonestFutureExecutionDate) {
            soonestFutureExecutionDate = futureExecutionDate
        }
        
        return soonestFutureExecutionDate
    }
    
}
