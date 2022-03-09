//
//  MonthlyComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum MonthlyComponentsError: Error {
    case dayOfMonthInvalid
}

class MonthlyComponents: Component, NSCoding, NSCopying, GeneralTimeOfDayProtocol {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MonthlyComponents()
        copy.storedDateComponents = self.storedDateComponents
        copy.isSkipping = self.isSkipping
        copy.isSkippingLogDate = self.isSkippingLogDate
        copy.storedDayOfMonth = self.storedDayOfMonth
        return copy
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        self.storedDateComponents = aDecoder.decodeObject(forKey: "dateComponents") as? DateComponents ?? DateComponents()
        self.isSkipping = aDecoder.decodeBool(forKey: "isSkipping")
        self.isSkippingLogDate = aDecoder.decodeObject(forKey: "isSkippingLogDate") as? Date
        self.storedDayOfMonth = aDecoder.decodeInteger(forKey: "dayOfMonth")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedDateComponents, forKey: "dateComponents")
        aCoder.encode(isSkipping, forKey: "isSkipping")
        aCoder.encode(isSkippingLogDate, forKey: "isSkippingLogDate")
        aCoder.encode(storedDayOfMonth, forKey: "dayOfMonth")
    }

    // MARK: Main

    override init() {
        super.init()
    }

    convenience init(parentReminder: Reminder, hour: Int?, minute: Int?, skipping: Bool?, skipDate: Date?, dayOfMonth: Int?) {
        self.init()
        storedDateComponents.hour = hour
        storedDateComponents.minute = minute
        if skipping != nil {
            isSkipping = skipping!
        }
        isSkippingLogDate = skipDate
        if dayOfMonth != nil {
            storedDayOfMonth = dayOfMonth!
        }

    }

    // MARK: - Properties

    /// Reference to the reminder that holds this component, required for connectivity when unskipping
    var parentReminder: Reminder! = nil

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
            storedDateComponents.month = newValue
        default:
            return
        }
    }

    /// Whether or not the next alarm will be skipped
    var isSkipping: Bool = false

    /// The date at which the user changed the isSkipping to true.  If is skipping is true, then a certain log date was appended. If unskipped, then we have to remove that previously added log. Slight caveat: if the skip log was modified (by the user changing its date) we don't remove it.
    var isSkippingLogDate: Date?

    private var storedDayOfMonth: Int = 1
    /// Day of the month that a reminder will fire
    var dayOfMonth: Int { return storedDayOfMonth }
    /// Changes the day of month. Throws if not within the range of [1,31]
    func changeDayOfMonth(newDayOfMonth: Int) throws {

        if newDayOfMonth < 1 || newDayOfMonth > 31 {
            throw MonthlyComponentsError.dayOfMonthInvalid
        }
        else if storedDayOfMonth != newDayOfMonth {
            storedDayOfMonth = newDayOfMonth
            parentReminder.disableIsSkipping()
        }

    }

    //// If we add a month to the date, then it might be incorrect and lose accuracy. For example, our dayOfMonth is 31. We are in April so there is only 30 days. Therefore we get a calculated date of April 30th. After adding a month, the result date is May 30th, but it should be 31st because of our dayOfMonth and that May has 31 days. This corrects that.
    private func fallShortCorrection(dateToCorrect: Date) -> Date {

         let dayOfMonthForCalculatedDate = Calendar.current.component(.day, from: dateToCorrect)
         // when adding a month, the day set fell short of what was needed. We need to correct it
         if dayOfMonth > dayOfMonthForCalculatedDate {
             // We need to find the maximum possible dayOfMonth to set the date to without having it accidentially roll into the next month.
             var calculatedDayOfMonth: Int {
                 let neededDayOfMonth = dayOfMonth
                 let maximumDayOfMonth = Calendar.current.range(of: .day, in: .month, for: dateToCorrect)!.count
                 if neededDayOfMonth <= maximumDayOfMonth {
                     return neededDayOfMonth
                 }
                 else {
                     return maximumDayOfMonth
                 }
             }

             // We have the correct dayOfMonth to set the date to, now we can change it.
             return Calendar.current.date(bySetting: .day, value: calculatedDayOfMonth, of: dateToCorrect)!
         }
        // when adding a month, the day did not fall short of what was needed
        else {
            return dateToCorrect
        }

    }

    /// Produces an array of at least two with all of the future dates that the reminder will fire given the day of month, hour, and minute
     private func futureExecutionDates(executionBasis: Date) -> [Date] {

        var calculatedDates: [Date] = []

         var calculatedDate = executionBasis

         // finds number of days in the calculated date's month, used for roll over calculations
             let numDaysInMonth = Calendar.current.range(of: .day, in: .month, for: calculatedDate)!.count

             // the day of month is greater than the number of days in the target month, so we just use the last possible day of month to get as close as possible without rolling over into the next month.
             if dayOfMonth > numDaysInMonth {
                 calculatedDate = Calendar.current.date(bySetting: .day, value: numDaysInMonth, of: calculatedDate)!
                // sets time of day
                calculatedDate = Calendar.current.date(bySettingHour: dateComponents.hour!, minute: dateComponents.minute!, second: 0, of: calculatedDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
             }
             // day of month is less than days available in the current month, so no roll over correction needed and traditional method
             else {
                 calculatedDate = Calendar.current.date(bySetting: .day, value: dayOfMonth, of: calculatedDate)!
                // sets time of day
                calculatedDate = Calendar.current.date(bySettingHour: dateComponents.hour!, minute: dateComponents.minute!, second: 0, of: calculatedDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
             }

            // We are looking for future dates, not past. If the calculated date is in the past, we correct to make it in the future.
            if executionBasis.distance(to: calculatedDate) < 0 {
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
            AppDelegate.generalLogger.warning("Calculated Dates for futureExecutionDates empty")
            // calculated dates should never be zero, this means there are somehow zero weekdays selected. Handle this weird case by just appending future dates (one 1 week ahead and the other 2 weeks ahead)
            calculatedDates.append(Calendar.current.date(byAdding: .day, value: 7, to: executionBasis)!)
            calculatedDates.append(Calendar.current.date(byAdding: .day, value: 14, to: executionBasis)!)
        }

        return calculatedDates
    }

    /// If a reminder is skipping, then we must find the next soonest executionDate. We have to find the execution date that takes place after the skipped execution date (but before any other execution date).
    private func skippingExecutionDate(reminderExecutionBasis executionBasis: Date) -> Date {
        // there will only be two future executions dates for a dayOfMonth, so we take the second one. The first one is the one used for a not skipping
        return futureExecutionDates(executionBasis: executionBasis).last!

    }

    /// This find the next execution date that takes place after the executionBasis. It purposelly not factoring in isSkipping.
    func notSkippingExecutionDate(reminderExecutionBasis executionBasis: Date) -> Date {

        // there will only be two future executions dates for a dayOfMonth, so we take the first one is the one.
        return futureExecutionDates(executionBasis: executionBasis).first!
}

    func previousExecutionDate(reminderExecutionBasis executionBasis: Date) -> Date {

        // use non skipping version
        let nextTimeOfDay = notSkippingExecutionDate(reminderExecutionBasis: executionBasis)

        var preceedingExecutionDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: nextTimeOfDay)!
        preceedingExecutionDate = fallShortCorrection(dateToCorrect: preceedingExecutionDate)
        return preceedingExecutionDate
    }

    /// Factors in isSkipping to figure out the next time of day
    func nextExecutionDate(reminderExecutionBasis executionBasis: Date) -> Date {
        if isSkipping == true {
            return skippingExecutionDate(reminderExecutionBasis: executionBasis)
        }
        else {
            return notSkippingExecutionDate(reminderExecutionBasis: executionBasis)
        }
    }

    func timerReset() {
        parentReminder.disableIsSkipping()
    }
}
