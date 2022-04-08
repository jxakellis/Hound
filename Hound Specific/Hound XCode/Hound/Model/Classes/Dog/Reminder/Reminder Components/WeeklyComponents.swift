//
//  WeeklyComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

class WeeklyComponents: Component, NSCoding, NSCopying, GeneralTimeOfDayProtocol {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = WeeklyComponents()
        copy.storedDateComponents = self.storedDateComponents
        copy.isSkipping = self.isSkipping
        copy.isSkippingDate = self.isSkippingDate
        copy.storedWeekdays = self.storedWeekdays
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.storedDateComponents = aDecoder.decodeObject(forKey: "dateComponents") as? DateComponents ?? DateComponents()
        self.isSkipping = aDecoder.decodeBool(forKey: "isSkipping")
        self.isSkippingDate = aDecoder.decodeObject(forKey: "isSkippingDate") as? Date
        self.storedWeekdays = aDecoder.decodeObject(forKey: "weekdays") as? [Int] ?? [1, 2, 3, 4, 5, 6, 7]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedDateComponents, forKey: "dateComponent")
        aCoder.encode(isSkipping, forKey: "isSkipping")
        aCoder.encode(isSkippingDate, forKey: "isSkippingDate")
        aCoder.encode(storedWeekdays, forKey: "weekdays")
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(hour: Int?, minute: Int?, isSkipping: Bool?, skipDate: Date?, sunday: Bool?, monday: Bool?, tuesday: Bool?, wednesday: Bool?, thursday: Bool?, friday: Bool?, saturday: Bool?) {
        self.init()
        storedDateComponents.hour = hour
        storedDateComponents.minute = minute
        if isSkipping != nil {
            self.isSkipping = isSkipping!
        }
        isSkippingDate = skipDate
        
        var weekdays: [Int] = []
        if sunday == true {
            weekdays.append(1)
        }
        if monday == true {
            weekdays.append(2)
        }
        if tuesday == true {
            weekdays.append(3)
        }
        if wednesday == true {
            weekdays.append(4)
        }
        if thursday == true {
            weekdays.append(5)
        }
        if friday == true {
            weekdays.append(6)
        }
        if saturday == true {
            weekdays.append(7)
        }
        
        if weekdays.isEmpty == false {
            storedWeekdays = weekdays
        }
        
    }
    
    // MARK: - Properties
    
    private var storedDateComponents: DateComponents = DateComponents()
    var dateComponents: DateComponents { return storedDateComponents }
    
    func changeDateComponents(newDateComponents: DateComponents) {
        if newDateComponents.hour != nil {
            storedDateComponents.hour = newDateComponents.hour
        }
        if newDateComponents.minute != nil {
            storedDateComponents.minute = newDateComponents.minute
        }
    }
    
    func changeDateComponents(newDateComponent: Calendar.Component, newValue: Int) {
        switch newDateComponent {
        case .hour:
            storedDateComponents.hour = newValue
        case .minute:
            storedDateComponents.minute = newValue
        default:
            return
        }
    }
    
    /// Whether or not the next alarm will be skipped
    var isSkipping: Bool = false
    
    /// The date at which the user changed the isSkipping to true.  If is skipping is true, then a certain log date was appended. If unskipped, then we have to remove that previously added log. Slight caveat: if the skip log was modified (by the user changing its date) we don't remove it.
    var isSkippingDate: Date?
    
    private var storedWeekdays: [Int] = [1, 2, 3, 4, 5, 6, 7]
    /// The weekdays on which the reminder should fire. 1 - 7, where 1 is sunday and 7 is saturday.
    var weekdays: [Int] { return storedWeekdays }
    /// Changes the weekdays, if empty throws an error due to the fact that there needs to be at least one time of week.
    func changeWeekdays(newWeekdays: [Int]) throws {
        if newWeekdays.isEmpty {
            throw WeeklyComponentsError.weekdayArrayInvalid
        }
        else if storedWeekdays != newWeekdays {
            storedWeekdays = newWeekdays
        }
    }
    
    // MARK: - Functions
    
    /// Produces an array of at least two with all of the future dates that the reminder will fire given the weekday(s), hour, and minute
    private func futureExecutionDates(reminderExecutionBasis: Date) -> [Date] {
        
        // the dates calculated to be reminderExecutionDates
        var calculatedDates: [Date] = []
        
        // iterate throguh all weekdays
        for weekday in weekdays {
            // set calculated date to the last time the reminder went off
            var calculatedDate = reminderExecutionBasis
            // iterate the calculated day forward until it is the correct weekday
            calculatedDate = Calendar.current.date(bySetting: .weekday, value: weekday, of: calculatedDate)!
            // iterate the time of day forward until the first result is found
            calculatedDate = Calendar.current.date(bySettingHour: dateComponents.hour!, minute: dateComponents.minute!, second: 0, of: calculatedDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
            
            // Correction for setting components to the same day. e.g. if its 11:00Am friday and you apply 8:30AM Friday to the current date, then it is in the past, this gets around this by making it 8:30AM Next Friday
            if reminderExecutionBasis.distance(to: calculatedDate) < 0 {
                calculatedDate = Calendar.current.date(byAdding: .day, value: 7, to: calculatedDate)!
            }
            
            calculatedDates.append(calculatedDate)
        }
        
        if calculatedDates.count > 1 {
            calculatedDates.sort()
        }
        // should have at least two dates
        else if calculatedDates.count == 1 {
            // in this situation, only one weekday is active, we take the execution date for that single weekday and add a duplicate, but a week in the future
            calculatedDates.append(Calendar.current.date(byAdding: .day, value: 7, to: calculatedDates[0])!)
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
        
        let traditionalNextTOD = notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis)
        
        // If there are multiple dates to be sorted through to find the date that is closer in time to traditionalNextTimeOfDay but still in the future
        if weekdays.count > 1 {
            let calculatedDates = futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis)
            var nextSoonestCalculatedDate: Date = calculatedDates.last!
            
            for calculatedDate in calculatedDates {
                // If the calculated date is greater in time (future) that the normal non skipping time and the calculatedDate is closer in time to the trad date, then sets nextSoonest to calculatedDate
                if traditionalNextTOD.distance(to: calculatedDate) > 0 && traditionalNextTOD.distance(to: calculatedDate) < traditionalNextTOD.distance(to: nextSoonestCalculatedDate) {
                    nextSoonestCalculatedDate = calculatedDate
                }
            }
            
            return nextSoonestCalculatedDate
        }
        // If only 1 day of week selected then all you have to do is add 1 week.
        else {
            return Calendar.current.date(byAdding: .day, value: 7, to: traditionalNextTOD)!
        }
        
    }
    
    /// This find the next execution date that takes place after the reminderExecutionBasis. It purposelly not factoring in isSkipping.
    func notSkippingExecutionDate(reminderExecutionBasis: Date) -> Date {
        
        let calculatedDates = futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis)
        
        // want to start with the date furthest away in time
        var soonestCalculatedDate: Date = calculatedDates.last!
        
        // iterate through all of the future execution dates to find the one that after the execution basis but is also closet to the execution basis
        for calculatedDate in calculatedDates {
            // if calculated date is in the future (as trad should be) and if its closer to the present that the soonestCalculatedDate, then sets soonest to calculated
            if reminderExecutionBasis.distance(to: calculatedDate) > 0 && reminderExecutionBasis.distance(to: calculatedDate) < reminderExecutionBasis.distance(to: soonestCalculatedDate) {
                soonestCalculatedDate = calculatedDate
            }
        }
        
        return soonestCalculatedDate
    }
    
    /// Returns the date that the reminder should have last sounded an alarm at. This helps in finding alarms that might have been missed
    func previousExecutionDate(reminderExecutionBasis: Date) -> Date {
        
        let traditionalNextTOD = notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis)
        
        // multiple days of week so need to do math to figure out correct
        if weekdays.count > 1 {
            var preceedingExecutionDates = futureExecutionDates(reminderExecutionBasis: reminderExecutionBasis)
            
            // Subtracts a week from all futureExecutionDates
            for futureExecutionDateIndex in 0..<preceedingExecutionDates.count {
                let preceedingExecutionDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: preceedingExecutionDates[futureExecutionDateIndex])!
                preceedingExecutionDates[futureExecutionDateIndex] = preceedingExecutionDate
            }
            
            // choose most extreme
            var closestCalculatedDate: Date = preceedingExecutionDates.first!
            
            // Looks for a date that is both before the nextTimeOfDay but closet in time to
            for preceedingExecutionDate in preceedingExecutionDates {
                
                // for the two .distance comparisions after the &&, the distances are going to be negative because it is going in reverse time. This means that the > is in the right direction. Write it out if it doesn't make sense
                if traditionalNextTOD.distance(to: preceedingExecutionDate) < 0 && traditionalNextTOD.distance(to: preceedingExecutionDate) > traditionalNextTOD.distance(to: closestCalculatedDate) {
                    closestCalculatedDate = preceedingExecutionDate
                }
            }
            
            return closestCalculatedDate
        }
        // only 1 day of week so all you have to do is subtract a week
        else {
            return Calendar.current.date(byAdding: .day, value: -7, to: traditionalNextTOD)!
        }
        
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
}
