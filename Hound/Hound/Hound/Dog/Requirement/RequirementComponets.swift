//
//  CountDownComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Component: NSObject {
    
    override init(){
        super.init()
    }
    
}

protocol GeneralCountDownProtocol {
    
    ///Interval at which a timer should be triggered for requirement
    var executionInterval: TimeInterval { get }
    mutating func changeExecutionInterval(newExecutionInterval: TimeInterval)
    
    ///How much time of the interval of been used up, this is used for when a timer is paused and then unpaused and have to calculate remaining time
    var intervalElapsed: TimeInterval { get }
    mutating func changeIntervalElapsed(newIntervalElapsed: TimeInterval)
    
    ///Called when a timer is handled and needs to be reset
    mutating func timerReset()
}

class CountDownComponents: Component, NSCoding, NSCopying, GeneralCountDownProtocol {
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CountDownComponents()
        copy.changeExecutionInterval(newExecutionInterval: self.storedExecutionInterval)
        copy.changeIntervalElapsed(newIntervalElapsed: self.storedIntervalElapsed)
        return copy
    }
    
    //MARK: - NSCoding
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.storedExecutionInterval = aDecoder.decodeDouble(forKey: "executionInterval")
        self.storedIntervalElapsed = aDecoder.decodeDouble(forKey: "intervalElapsed")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(executionInterval, forKey: "executionInterval")
        aCoder.encode(intervalElapsed, forKey: "intervalElapsed")
    }
    
    //MARK: - CountDownComponentsProtocol
    
    private var storedExecutionInterval: TimeInterval = TimeInterval(RequirementConstant.defaultTimeInterval)
    var executionInterval: TimeInterval { return storedExecutionInterval }
    func changeExecutionInterval(newExecutionInterval: TimeInterval) {
        storedExecutionInterval = newExecutionInterval
    }
    
    private var storedIntervalElapsed: TimeInterval = TimeInterval(0)
    var intervalElapsed: TimeInterval { return storedIntervalElapsed }
    func changeIntervalElapsed(newIntervalElapsed: TimeInterval) {
        storedIntervalElapsed = newIntervalElapsed
    }
    
    func timerReset() {
        //changeLastExecution(newLastExecution: Date())
        changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
    }
    
    
}

protocol SnoozeComponentsProtocol {
    
    ///Bool on whether or not the parent requirement is snoozed
    var isSnoozed: Bool { get }
    ///Change isSnoozed to new status and does accompanying changes
    mutating func changeSnooze(newSnoozeStatus: Bool)
    
}

class SnoozeComponents: Component, NSCoding, NSCopying, GeneralCountDownProtocol, SnoozeComponentsProtocol {
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SnoozeComponents()
        copy.changeSnooze(newSnoozeStatus: self.isSnoozed)
        copy.changeIntervalElapsed(newIntervalElapsed: self.intervalElapsed)
        copy.changeExecutionInterval(newExecutionInterval: self.executionInterval)
        return copy
    }
    
    //MARK: - NSCoding
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.storedIsSnoozed = aDecoder.decodeBool(forKey: "isSnoozed")
        self.storedExecutionInterval = aDecoder.decodeDouble(forKey: "executionInterval")
        self.storedIntervalElapsed = aDecoder.decodeDouble(forKey: "intervalElapsed")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedIsSnoozed, forKey: "isSnoozed")
        aCoder.encode(storedExecutionInterval, forKey: "executionInterval")
        aCoder.encode(storedIntervalElapsed, forKey: "intervalElapsed")
    }
    
    //MARK: - SnoozeComponentsProtocol
    
    private var storedIsSnoozed: Bool = false
    var isSnoozed: Bool { return storedIsSnoozed }
    func changeSnooze(newSnoozeStatus: Bool) {
        if newSnoozeStatus == true {
            storedExecutionInterval = TimerConstant.defaultSnooze
        }
        
        storedIsSnoozed = newSnoozeStatus
    }
    
    private var storedExecutionInterval = TimeInterval(60*30)
    var executionInterval: TimeInterval { return storedExecutionInterval }
    func changeExecutionInterval(newExecutionInterval: TimeInterval){
        storedExecutionInterval = newExecutionInterval
    }
    
    private var storedIntervalElapsed: TimeInterval = TimeInterval(0)
    var intervalElapsed: TimeInterval { return storedIntervalElapsed }
    func changeIntervalElapsed(newIntervalElapsed: TimeInterval) {
        storedIntervalElapsed = newIntervalElapsed
    }
    
    func timerReset() {
        self.changeSnooze(newSnoozeStatus: false)
        self.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
    }
}

enum TimeOfDayComponentsError: Error {
    case invalidCalendarComponent
    case invalidWeekdayArray
    case invalidDayOfMonth
    case bothDayIndicatorsNil
    case bothDayIndicatorsActive
}

protocol TimeOfDayComponentsProtocol {
    
    ///Reference to the requirement that holds the timeOfDayComponent, required for connectivity.
    var masterRequirement: Requirement! { get set }
    
    ///DateComponent that stores the hour and minute specified (e.g. 8:26 am) of the time of day timer
    var timeOfDayComponent: DateComponents { get }
    mutating func changeTimeOfDayComponent(newTimeOfDayComponent: DateComponents) throws
    mutating func changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.Component, newValue: Int) throws
    
    ///Whether or not the next time of day alarm will be skipped
    var isSkipping: Bool { get }
    ///Changes isSkipping and data associated
    mutating func changeIsSkipping(newSkipStatus: Bool, shouldRemoveLogDuringPossibleUnskip: Bool?)
    
    ///If is skipping is true, then a certain log date was appended. If unskipped it has to remove that certain logDate, but if logs was modified with the Logs page then you have to figure out if that certain log date is still there and if so then remove it.
    var isSkippingLogDate: Date? { get set }
    
    ///The weekdays on which the requirement should fire. Nil is dayOfMonth mode
    var weekdays: [Int]? { get }
    
    ///Changes the weekdays, if empty throws an error due to the fact that there needs to be atleast one time of week. Nil is dayOfMonth mode
    mutating func changeWeekdays(newWeekdays: [Int]?) throws
    
    ///If the requirement is firing once a month, then this is the day of month it occurs. Nil if weekday mode.
    var dayOfMonth: Int? { get }
    ///Changes the day of month that the requirement should fire
    func changeDayOfMonth(newDayOfMonth: Int?) throws
    
    ///The Date that the alarm should next fire at
    func nextTimeOfDay(requirementExecutionBasis executionBasis: Date) -> Date
    
    ///The Date that the alarm should have last fired at
    func previousTimeOfDay(requirementExecutionBasis executionBasis: Date) -> Date
    
    ///If the next timeOfDay alarm is skipped then at some point the time will pass where it transfers from being skipped to regular mode, this is that date at which is should transition back
    func unskipDate(timerMode: RequirementMode, requirementExecutionBasis executionBasis: Date) -> Date?
    
    ///Called when a timer is handled and needs to be reset
    func timerReset()
}

protocol TimeOfDayComponentsDelegate{
    func willUnskipRequirement()
}

class TimeOfDayComponents: Component, NSCoding, NSCopying, TimeOfDayComponentsProtocol {
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TimeOfDayComponents()
        copy.storedTimeOfDayComponent = self.storedTimeOfDayComponent
        copy.storedIsSkipping = self.storedIsSkipping
        copy.isSkippingLogDate = self.isSkippingLogDate
        copy.storedWeekdays = self.storedWeekdays
        copy.storedDayOfMonth = self.storedDayOfMonth
        return copy
    }
    
    //MARK: - NSCoding
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.storedTimeOfDayComponent = aDecoder.decodeObject(forKey: "timeOfDayComponent") as! DateComponents
        self.storedIsSkipping = aDecoder.decodeBool(forKey: "isSkipping")
        self.isSkippingLogDate = aDecoder.decodeObject(forKey: "isSkippingLogDate") as? Date
        self.storedWeekdays = aDecoder.decodeObject(forKey: "weekdays") as? [Int]
        self.storedDayOfMonth = aDecoder.decodeObject(forKey: "dayOfMonth") as? Int
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedTimeOfDayComponent, forKey: "timeOfDayComponent")
        aCoder.encode(storedIsSkipping, forKey: "isSkipping")
        aCoder.encode(isSkippingLogDate, forKey: "isSkippingLogDate")
        aCoder.encode(storedWeekdays, forKey: "weekdays")
        aCoder.encode(storedDayOfMonth, forKey: "dayOfMonth")
    }
    
    
    //MARK: - TimeOfDayComponentsProtocol
    
    var masterRequirement: Requirement! = nil
    
    private var storedTimeOfDayComponent: DateComponents = DateComponents()
    var timeOfDayComponent: DateComponents { return storedTimeOfDayComponent }
    func changeTimeOfDayComponent(newTimeOfDayComponent: DateComponents) throws {
        
        if newTimeOfDayComponent.hour != nil {
            storedTimeOfDayComponent.hour = newTimeOfDayComponent.hour
        }
        if newTimeOfDayComponent.minute != nil {
            storedTimeOfDayComponent.minute = newTimeOfDayComponent.minute
        }
        // if newTimeOfDayComponent.second != nil {
        //    storedTimeOfDayComponent.second = newTimeOfDayComponent.second
        //}
    }
    func changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.Component, newValue: Int) throws {
        if newTimeOfDayComponent == .hour {
            storedTimeOfDayComponent.hour = newValue
        }
        else if newTimeOfDayComponent == .minute {
            storedTimeOfDayComponent.minute = newValue
        }
        // else if newTimeOfDayComponent == .second {
        //    storedTimeOfDayComponent.second = newValue
        // }
        else {
            throw TimeOfDayComponentsError.invalidCalendarComponent
        }
    }
    
    private var storedIsSkipping: Bool = TimerConstant.defaultSkipStatus
    var isSkipping: Bool { return storedIsSkipping }
    func changeIsSkipping(newSkipStatus: Bool, shouldRemoveLogDuringPossibleUnskip: Bool?) {
        guard newSkipStatus != storedIsSkipping else {
            return
        }
        
        if newSkipStatus == true {
            isSkippingLogDate = Date()
        }
        else {
            if isSkippingLogDate != nil && shouldRemoveLogDuringPossibleUnskip == true{
                //if the log added by skipping the reminder is unmodified, finds and removes it in the unskip process
                for logDateIndex in 0..<masterRequirement.logs.count{
                    if masterRequirement.logs[logDateIndex].date.distance(to: isSkippingLogDate!) < 1 && masterRequirement.logs[logDateIndex].date.distance(to: isSkippingLogDate!) > -1{
                        masterRequirement.logs.remove(at: logDateIndex)
                        break
                    }
                }
            }
            
            isSkippingLogDate = nil
        }
        
        storedIsSkipping = newSkipStatus
    }
    
    var isSkippingLogDate: Date? = nil
    
    private var storedWeekdays: [Int]? = [1,2,3,4,5,6,7]
    var weekdays: [Int]? { return storedWeekdays }
    func changeWeekdays(newWeekdays: [Int]?) throws{
        if newWeekdays == nil {
            if dayOfMonth == nil {
                throw TimeOfDayComponentsError.bothDayIndicatorsNil
            }
            storedWeekdays = newWeekdays
        }
        else if newWeekdays!.isEmpty{
            throw TimeOfDayComponentsError.invalidWeekdayArray
        }
        else if storedWeekdays != newWeekdays! {
            storedWeekdays = newWeekdays!
            try! changeDayOfMonth(newDayOfMonth: nil)
            changeIsSkipping(newSkipStatus: false, shouldRemoveLogDuringPossibleUnskip: false)
        }
        else {
        }
    }
    
    private var storedDayOfMonth: Int? = nil
    var dayOfMonth: Int? { return storedDayOfMonth }
    func changeDayOfMonth(newDayOfMonth: Int?) throws{
        if newDayOfMonth == nil {
            if weekdays == nil {
                throw TimeOfDayComponentsError.bothDayIndicatorsNil
            }
            storedDayOfMonth = newDayOfMonth
        }
        else if newDayOfMonth! <= 0{
            throw TimeOfDayComponentsError.invalidDayOfMonth
        }
        else if newDayOfMonth! >= 32{
            throw TimeOfDayComponentsError.invalidDayOfMonth
        }
        else if storedDayOfMonth != newDayOfMonth!{
            storedDayOfMonth = newDayOfMonth
            try! changeWeekdays(newWeekdays: nil)
            changeIsSkipping(newSkipStatus: false, shouldRemoveLogDuringPossibleUnskip: false)
        }
        else {
        }
        
    }
    
    ///USE ONLY ON DATES THAT HAVE HAD A MONTH ADDED OR SUBTRACTED. Each month has a different number of days, 28, 29, 30, 31, and if you have a dayOfMonth that might be greater than the amount possible (e.g. dOM is 31 but month only has 30) this will cause a roll over to the next month instead of going ton the last day. Similarly, if you correct this with a roll under by setting it to the last day possible (so day 30 of a 30 day month for 31 dOM) then the next month, which has an additional day, will be one day short. This corrects for that ambiguity.
    private func rollUnderCorrection(correctingDate: Date) -> Date{
        var correctedDate = correctingDate
        
        //the date cannot be greater that what is needed (e.g. day 17 when you need 15) because this method is used after you use Calendar.current... and add one month, is can only fall short of what is needed
         let dayOfMonthForDate = Calendar.current.component(.day, from: correctedDate)
         //when adding a month, the day set fell short of what was needed
         if dayOfMonth! > dayOfMonthForDate{
             //maximum possible day of month without rolling over into the next month
             var calculatedDayOfMonth: Int {
                 let neededDayOfMonth = dayOfMonth!
                 let maximumDayOfMonth = Calendar.current.range(of: .day, in: .month, for: correctedDate)!.count
                 if neededDayOfMonth <= maximumDayOfMonth{
                     return neededDayOfMonth
                 }
                 else {
                     return maximumDayOfMonth
                 }
             }
             //sets day and time
            correctedDate = Calendar.current.date(bySetting: .day, value: calculatedDayOfMonth, of: correctedDate)!
            correctedDate = Calendar.current.date(bySettingHour: timeOfDayComponent.hour!, minute: timeOfDayComponent.minute!, second: 0, of: correctedDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
         }
        return correctedDate
    }
    
    ///Produces an array of atleast two with all of the future dates that the requirement will fire given the weekday(s), hour, and minute
     private func futureExecutionDates(executionBasis: Date) -> [Date] {
        
        var calculatedDates: [Date] = []
        
        if dayOfMonth != nil && weekdays != nil {
            fatalError("one has to be nil")
        }
        else if dayOfMonth == nil && weekdays == nil{
            fatalError("both cannot be nil")
        }
        //once a month
        else if dayOfMonth != nil {
            
            var calculatedDate = executionBasis
            
             //finds number of days in the calculated date's month, used for roll over calculations
                 let numDaysInExecutionBasisMonth = Calendar.current.range(of: .day, in: .month, for: calculatedDate)!.count
            
                 //can apply rollUnderCorrection to get needed date as it is a case where roll over logic is needed
                 if dayOfMonth! > numDaysInExecutionBasisMonth{
                     calculatedDate = rollUnderCorrection(correctingDate: calculatedDate)
                    //calculatedDate = Calendar.current.date(bySetting: .day, value: numDaysInExecutionBasisMonth, of: calculatedDate)!
                 }
                 //day of month is less than days available in the current month, so no roll over correction needed and traditional method
                 else {
                     calculatedDate = Calendar.current.date(bySetting: .day, value: dayOfMonth!, of: calculatedDate)!
                    //sets time of day
                    calculatedDate = Calendar.current.date(bySettingHour: timeOfDayComponent.hour!, minute: timeOfDayComponent.minute!, second: 0, of: calculatedDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
                 }
             
             
             
            
            //this is future dates, not past, so if in the past it will correct for future
            if executionBasis.distance(to: calculatedDate) < 0 {
                calculatedDate = Calendar.current.date(byAdding: .month, value: 1, to: calculatedDate)!
                calculatedDate = rollUnderCorrection(correctingDate: calculatedDate)
            }
            calculatedDates.append(calculatedDate)
        }
        //weekdays instead of once a month
        else {
            if weekdays == nil {
                fatalError("either dayOfMonth or weekdays should be nil, not both")
            }
            for weekday in weekdays!{
                var calculatedDate = executionBasis
                calculatedDate = Calendar.current.date(bySetting: .weekday, value: weekday, of: calculatedDate)!
                calculatedDate = Calendar.current.date(bySettingHour: timeOfDayComponent.hour!, minute: timeOfDayComponent.minute!, second: 0, of: calculatedDate, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
                
                //Correction for if setting components to the same day, e.g. if its 11:00Am friday and you apply 8:30AM Friday to the current date, then it is in the past, this gets around this by making it 8:30AM Next Friday
                if executionBasis.distance(to: calculatedDate) < 0 {
                    calculatedDate = Calendar.current.date(byAdding: .day, value: 7, to: calculatedDate)!
                }
                
                calculatedDates.append(calculatedDate)
            }
        }
        
        
        
        if calculatedDates.count > 1 {
            calculatedDates.sort()
        }
        //should have atleast two dates
        else if calculatedDates.count == 1{
            //day of month
            if dayOfMonth != nil {
                var appendedDate = Calendar.current.date(byAdding: .month, value: 1, to: calculatedDates[0])!
                appendedDate = rollUnderCorrection(correctingDate: appendedDate)
                
                calculatedDates.append(appendedDate)
            }
            //weekdays
            else {
                calculatedDates.append(Calendar.current.date(byAdding: .day, value: 7, to: calculatedDates[0])!)
            }
        }
        else {
            fatalError("calculatedDates 0 for futureExecutionDates, RequirementComponents")
        }
        
        
        return calculatedDates
    }
    
    ///Date that is calculated from timeOfDayComponent when the timer should next fire when the requirement is skipping
    private func skippingNextTimeOfDay(executionBasis: Date) -> Date {
        
        let traditionalNextTOD = traditionalNextTimeOfDay(executionBasis: executionBasis)
        
        if dayOfMonth != nil {
            return futureExecutionDates(executionBasis: executionBasis).last!
        }
        else {
            //If there are multiple dates to be sorted through to find the date that is closer in time to traditionalNextTimeOfDay but still in the future
            if weekdays!.count > 1 {
                let calculatedDates = futureExecutionDates(executionBasis: executionBasis)
                var nextSoonestCalculatedDate: Date = calculatedDates.last!
                
                for calculatedDate in calculatedDates {
                    //If the calculated date is greater in time (future) that the normal non skipping time and the calculatedDate is closer in time to the trad date, then sets nextSoonest to calculatedDate
                    if traditionalNextTOD.distance(to: calculatedDate) > 0 && traditionalNextTOD.distance(to: calculatedDate) < traditionalNextTOD.distance(to: nextSoonestCalculatedDate){
                        nextSoonestCalculatedDate = calculatedDate
                    }
                }
                
                return nextSoonestCalculatedDate
            }
            //If only 1 day of week selected then all you have to do is add 1 week.
            else {
                return Calendar.current.date(byAdding: .day, value: 7, to: traditionalNextTOD)!
            }
        }
        
    }
    
    ///DO NOT USE UNLESS EXPLICIT KNOWLEDGE Date that is calculated from timeOfDayComponent when the timer should next fire, does not factor in isSkipping
    func traditionalNextTimeOfDay(executionBasis: Date) -> Date {
    
    let calculatedDates = futureExecutionDates(executionBasis: executionBasis)
    
    //want to start with the date furthest away in time
    var soonestCalculatedDate: Date = calculatedDates.last!
    
    for calculatedDate in calculatedDates {
        //if calculated date is in the future (as trad should be) and if its closer to the present that the soonestCalculatedDate, then sets soonest to calculated
        if executionBasis.distance(to: calculatedDate) > 0 && executionBasis.distance(to: calculatedDate) < executionBasis.distance(to: soonestCalculatedDate){
            soonestCalculatedDate = calculatedDate
        }
    }
    
    return soonestCalculatedDate
}
    
    func previousTimeOfDay(requirementExecutionBasis executionBasis: Date) -> Date {
        
        let traditionalNextTOD = traditionalNextTimeOfDay(executionBasis: executionBasis)
        
        if dayOfMonth != nil {
                //goes back a month in time
                var preceedingExecutionDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: traditionalNextTOD)!
                preceedingExecutionDate = rollUnderCorrection(correctingDate: preceedingExecutionDate)
                return preceedingExecutionDate
        }
        else {
            //weekdays is known to not be nil as dayOfMonth and weekday nil status was checked
            //multiple days of week so need to do math to figure out correct
            if weekdays!.count > 1{
                var preceedingExecutionDates = futureExecutionDates(executionBasis: executionBasis)
                
                //Subtracts a week from all futureExecutionDates
                for futureExecutionDateIndex in 0..<preceedingExecutionDates.count{
                    let preceedingExecutionDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: preceedingExecutionDates[futureExecutionDateIndex])!
                    preceedingExecutionDates[futureExecutionDateIndex] = preceedingExecutionDate
                }
                
                //choose most extreme
                var closestCalculatedDate: Date = preceedingExecutionDates.first!
                
                //Looks for a date that is both before the nextTimeOfDay but closer in time to
                for preceedingExecutionDate in preceedingExecutionDates {
                    
                    //for the two .distance comparisions after the &&, the distances are going to be negative because it is going in reverse time. This means that the > is in the right direction. Write it out if it doesn't make sense
                    if traditionalNextTOD.distance(to: preceedingExecutionDate) < 0 && traditionalNextTOD.distance(to: preceedingExecutionDate) > traditionalNextTOD.distance(to: closestCalculatedDate){
                        closestCalculatedDate = preceedingExecutionDate
                    }
                }
                
                return closestCalculatedDate
            }
            //only 1 day of week so all you have to do is subtract a week
            else {
                return Calendar.current.date(byAdding: .day, value: -7, to: traditionalNextTOD)!
            }
        }
    }
    
    ///Factors in isSkipping to figure out the next time of day
    func nextTimeOfDay(requirementExecutionBasis executionBasis: Date) -> Date {
        if isSkipping == true {
            return skippingNextTimeOfDay(executionBasis: executionBasis)
        }
        else {
            return traditionalNextTimeOfDay(executionBasis: executionBasis)
        }
    }
    
    func unskipDate(timerMode: RequirementMode, requirementExecutionBasis executionBasis: Date) -> Date? {
        guard (timerMode == .weekly || timerMode == .monthly) && isSkipping == true else {
            return nil
        }
        
        return traditionalNextTimeOfDay(executionBasis: executionBasis)
    }
    
    func timerReset() {
        changeIsSkipping(newSkipStatus: false, shouldRemoveLogDuringPossibleUnskip: false)
    }
    
    
}


