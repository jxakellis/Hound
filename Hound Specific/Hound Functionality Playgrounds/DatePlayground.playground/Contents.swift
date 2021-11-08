import UIKit

enum TimeOfDayComponentsError: Error {
    case invalidCalendarComponent
    case invalidWeekdayArray
    case invalidDayOfMonth
}

protocol TimeOfDayComponentsDelegate{
    func willUnskipRequirement()
}

class TimeOfDayComponents{
    
    
    //MARK: - TimeOfDayComponentsProtocol
    
    /////var masterRequirement: Requirement! = nil
    
    private var storedTimeOfDayComponent: DateComponents = DateComponents()
    var timeOfDayComponent: DateComponents { return storedTimeOfDayComponent }
    func changeTimeOfDayComponent(newTimeOfDayComponent: DateComponents) throws {
        
        if newTimeOfDayComponent.hour != nil {
            storedTimeOfDayComponent.hour = newTimeOfDayComponent.hour
        }
        if newTimeOfDayComponent.minute != nil {
            storedTimeOfDayComponent.minute = newTimeOfDayComponent.minute
        }
    }
    func changeTimeOfDayComponent(newTimeOfDayComponent: Calendar.Component, newValue: Int) throws {
        if newTimeOfDayComponent == .hour {
            storedTimeOfDayComponent.hour = newValue
        }
        else if newTimeOfDayComponent == .minute {
            storedTimeOfDayComponent.minute = newValue
        }
        else {
            throw TimeOfDayComponentsError.invalidCalendarComponent
        }
    }
    
    /////private var storedIsSkipping: Bool = TimerConstant.defaultSkipStatus
    private var storedIsSkipping: Bool = false
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
                print("sudo looking for skip log to unskip")
                /*
                 //if the log added by skipping the reminder is unmodified, finds and removes it in the unskip process
                 for logDateIndex in 0..<masterRequirement.logs.count{
                     if masterRequirement.logs[logDateIndex].date.distance(to: isSkippingLogDate!) < 1 && masterRequirement.logs[logDateIndex].date.distance(to: isSkippingLogDate!) > -1{
                         masterRequirement.logs.remove(at: logDateIndex)
                         break
                     }
                 }
                 */
            }
            
            isSkippingLogDate = nil
        }
        
        storedIsSkipping = newSkipStatus
    }
    
    var isSkippingLogDate: Date? = nil
    
    private var storedWeekDays: [Int]? = [1,2,3,4,5,6,7]
    var weekdays: [Int]? { return storedWeekDays }
    func changeWeekdays(newWeekdays: [Int]?) throws{
        if newWeekdays == nil {
            storedWeekDays = newWeekdays
        }
        else if newWeekdays!.isEmpty{
            throw TimeOfDayComponentsError.invalidWeekdayArray
        }
        else if storedWeekDays != newWeekdays! {
            try! changeDayOfMonth(newDayOfMonth: nil)
            storedWeekDays = newWeekdays!
            changeIsSkipping(newSkipStatus: false, shouldRemoveLogDuringPossibleUnskip: false)
        }
        else {
        }
    }
    
    private var storedDayOfMonth: Int? = nil
    var dayOfMonth: Int? { return storedDayOfMonth }
    func changeDayOfMonth(newDayOfMonth: Int?) throws{
        if newDayOfMonth == nil {
            storedDayOfMonth = newDayOfMonth
        }
        else if newDayOfMonth! <= 0{
            throw TimeOfDayComponentsError.invalidDayOfMonth
        }
        else if newDayOfMonth! >= 32{
            throw TimeOfDayComponentsError.invalidDayOfMonth
        }
        else if storedDayOfMonth != newDayOfMonth!{
            try! changeWeekdays(newWeekdays: nil)
            storedDayOfMonth = newDayOfMonth
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
     func futureExecutionDates(executionBasis: Date) -> [Date] {
        
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
    func skippingNextTimeOfDay(executionBasis: Date) -> Date {
        
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
    
    ///Date that is calculated from timeOfDayComponent when the timer should next fire, does not factor in isSkipping
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
    
    func timerReset() {
        changeIsSkipping(newSkipStatus: false, shouldRemoveLogDuringPossibleUnskip: false)
    }
    
    
}

let timeOfDayComonent = TimeOfDayComponents()


var basis: Date! = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
basis = Calendar.current.date(bySetting: .day, value: 30, of: basis)!
basis = Calendar.current.date(bySetting: .hour, value: 12, of: basis)!

try! timeOfDayComonent.changeDayOfMonth(newDayOfMonth: 30)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 11)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
print("30 Month, 30 dOM")
print("1 hour before")
print("date \(basis!)")
print("prev \(timeOfDayComonent.previousTimeOfDay(requirementExecutionBasis: basis))")
print("trad \(timeOfDayComonent.traditionalNextTimeOfDay(executionBasis: basis))")
print("skipping \(timeOfDayComonent.skippingNextTimeOfDay(executionBasis: basis))")
print("next \(timeOfDayComonent.nextTimeOfDay(requirementExecutionBasis: basis))")

try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 13)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
print("1 hour after")
print("date \(basis!)")
print("prev \(timeOfDayComonent.previousTimeOfDay(requirementExecutionBasis: basis))")
print("trad \(timeOfDayComonent.traditionalNextTimeOfDay(executionBasis: basis))")
print("skipping \(timeOfDayComonent.skippingNextTimeOfDay(executionBasis: basis))")
print("next \(timeOfDayComonent.nextTimeOfDay(requirementExecutionBasis: basis))")

print()

try! timeOfDayComonent.changeDayOfMonth(newDayOfMonth: 31)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 11)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
print("30 Month, 31 dOM")
print("1 hour before")
print("date \(basis!)")
print("prev \(timeOfDayComonent.previousTimeOfDay(requirementExecutionBasis: basis))")
print("trad \(timeOfDayComonent.traditionalNextTimeOfDay(executionBasis: basis))")
print("skipping \(timeOfDayComonent.skippingNextTimeOfDay(executionBasis: basis))")
print("next \(timeOfDayComonent.nextTimeOfDay(requirementExecutionBasis: basis))")

try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 13)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
print("1 hour after")
print("date \(basis!)")
print("prev \(timeOfDayComonent.previousTimeOfDay(requirementExecutionBasis: basis))")
print("trad \(timeOfDayComonent.traditionalNextTimeOfDay(executionBasis: basis))")
print("skipping \(timeOfDayComonent.skippingNextTimeOfDay(executionBasis: basis))")
print("next \(timeOfDayComonent.nextTimeOfDay(requirementExecutionBasis: basis))")

print()

basis = Calendar.current.date(byAdding: .month, value: 0, to: Date())!
basis = Calendar.current.date(bySetting: .day, value: 31, of: basis)!
basis = Calendar.current.date(bySetting: .hour, value: 12, of: basis)!

try! timeOfDayComonent.changeDayOfMonth(newDayOfMonth: 30)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 11)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
print("31 Month, 30 dOM")
print("1 hour before")
print("date \(basis!)")
print("prev \(timeOfDayComonent.previousTimeOfDay(requirementExecutionBasis: basis))")
print("trad \(timeOfDayComonent.traditionalNextTimeOfDay(executionBasis: basis))")
print("skipping \(timeOfDayComonent.skippingNextTimeOfDay(executionBasis: basis))")
print("next \(timeOfDayComonent.nextTimeOfDay(requirementExecutionBasis: basis))")

try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 13)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
print("1 hour after")
print("date \(basis!)")
print("prev \(timeOfDayComonent.previousTimeOfDay(requirementExecutionBasis: basis))")
print("trad \(timeOfDayComonent.traditionalNextTimeOfDay(executionBasis: basis))")
print("skipping \(timeOfDayComonent.skippingNextTimeOfDay(executionBasis: basis))")
print("next \(timeOfDayComonent.nextTimeOfDay(requirementExecutionBasis: basis))")

print()

try! timeOfDayComonent.changeDayOfMonth(newDayOfMonth: 31)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 11)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
print("31 Month, 31 dOM")
print("1 hour before")
print("date \(basis!)")
print("prev \(timeOfDayComonent.previousTimeOfDay(requirementExecutionBasis: basis))")
print("trad \(timeOfDayComonent.traditionalNextTimeOfDay(executionBasis: basis))")
print("skipping \(timeOfDayComonent.skippingNextTimeOfDay(executionBasis: basis))")
print("next \(timeOfDayComonent.nextTimeOfDay(requirementExecutionBasis: basis))")

try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .hour, newValue: 13)
try! timeOfDayComonent.changeTimeOfDayComponent(newTimeOfDayComponent: .minute, newValue: 0)
print("1 hour after")
print("date \(basis!)")
print("prev \(timeOfDayComonent.previousTimeOfDay(requirementExecutionBasis: basis))")
print("trad \(timeOfDayComonent.traditionalNextTimeOfDay(executionBasis: basis))")
print("skipping \(timeOfDayComonent.skippingNextTimeOfDay(executionBasis: basis))")
print("next \(timeOfDayComonent.nextTimeOfDay(requirementExecutionBasis: basis))")

print()


/*
 print("prev \(timeOfDayComonent.previousTimeOfDay(requirementExecutionBasis: basis))")
 print("trad \(timeOfDayComonent.traditionalNextTimeOfDay(executionBasis: basis))")
 print("skipping \(timeOfDayComonent.skippingNextTimeOfDay(executionBasis: basis))")
 print("next \(timeOfDayComonent.nextTimeOfDay(requirementExecutionBasis: basis))")
 */



