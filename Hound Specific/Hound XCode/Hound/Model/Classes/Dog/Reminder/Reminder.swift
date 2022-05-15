//
//  Remindert.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ReminderType: String, CaseIterable {
    
    init?(rawValue: String) {
        for type in ReminderType.allCases {
            if type.rawValue.lowercased() == rawValue.lowercased() {
                self = type
                return
            }
        }
        
        AppDelegate.generalLogger.fault("reminderType Not Found")
        self = .oneTime
        return
    }
    case oneTime
    case countdown
    case weekly
    case monthly
}

enum ReminderMode {
    case oneTime
    case countdown
    case weekly
    case monthly
    case snooze
}

enum ReminderAction: String, CaseIterable {
    
    init?(rawValue: String) {
       for action in ReminderAction.allCases {
            if action.rawValue.lowercased() == rawValue.lowercased() {
                self = action
                return
            }
        }
        
        AppDelegate.generalLogger.fault("reminderAction Not Found")
        self = .custom
        return
    }
    // common
    case feed = "Feed"
    case water = "Fresh Water"
    case potty = "Potty"
    case walk = "Walk"
    // next common
    case brush = "Brush"
    case bathe = "Bathe"
    case medicine = "Medicine"
    
    // more common than previous but probably used less by user as weird action
    case sleep = "Sleep"
    case trainingSession = "Training Session"
    case doctor = "Doctor Visit"
    
    case custom = "Custom"
}

class Reminder: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Reminder()
        
        copy.reminderId = self.reminderId
        copy.reminderAction = self.reminderAction
        copy.reminderCustomActionName = self.reminderCustomActionName
        
        copy.countdownComponents = self.countdownComponents.copy() as! CountdownComponents
        copy.weeklyComponents = self.weeklyComponents.copy() as! WeeklyComponents
        copy.monthlyComponents = self.monthlyComponents.copy() as! MonthlyComponents
        copy.oneTimeComponents = self.oneTimeComponents.copy() as! OneTimeComponents
        copy.snoozeComponents = self.snoozeComponents.copy() as! SnoozeComponents
        copy.storedReminderType = self.reminderType
        
        copy.isPresentationHandled = self.isPresentationHandled
        copy.storedReminderExecutionBasis = self.reminderExecutionBasis
        copy.timer = self.timer
        
        copy.reminderIsEnabled = self.reminderIsEnabled
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        self.reminderId = aDecoder.decodeInteger(forKey: "reminderId")
        self.reminderAction = ReminderAction(rawValue: aDecoder.decodeObject(forKey: "reminderAction") as? String ?? ReminderConstant.defaultAction.rawValue)!
        
        self.reminderCustomActionName = aDecoder.decodeObject(forKey: "reminderCustomActionName") as? String
        
        self.countdownComponents = aDecoder.decodeObject(forKey: "countdownComponents") as? CountdownComponents ?? CountdownComponents()
        self.weeklyComponents = aDecoder.decodeObject(forKey: "weeklyComponents") as?  WeeklyComponents ?? WeeklyComponents()
        self.monthlyComponents = aDecoder.decodeObject(forKey: "monthlyComponents") as?  MonthlyComponents ?? MonthlyComponents()
        self.oneTimeComponents = aDecoder.decodeObject(forKey: "oneTimeComponents") as? OneTimeComponents ?? OneTimeComponents()
        self.snoozeComponents = aDecoder.decodeObject(forKey: "snoozeComponents") as? SnoozeComponents ?? SnoozeComponents()
        
        self.storedReminderType = ReminderType(rawValue: aDecoder.decodeObject(forKey: "reminderType") as? String ?? ReminderType.countdown.rawValue)!
        
        self.storedReminderExecutionBasis = aDecoder.decodeObject(forKey: "reminderExecutionBasis") as? Date ?? Date()
        
        self.reminderIsEnabled = aDecoder.decodeBool(forKey: "reminderIsEnabled")
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(reminderId, forKey: "reminderId")
        aCoder.encode(reminderAction.rawValue, forKey: "reminderAction")
        aCoder.encode(reminderCustomActionName, forKey: "reminderCustomActionName")
        
        aCoder.encode(countdownComponents, forKey: "countdownComponents")
        aCoder.encode(weeklyComponents, forKey: "weeklyComponents")
        aCoder.encode(monthlyComponents, forKey: "monthlyComponents")
        aCoder.encode(oneTimeComponents, forKey: "oneTimeComponents")
        aCoder.encode(snoozeComponents, forKey: "snoozeComponents")
        aCoder.encode(storedReminderType.rawValue, forKey: "reminderType")
        
        aCoder.encode(storedReminderExecutionBasis, forKey: "reminderExecutionBasis")
        
        aCoder.encode(reminderIsEnabled, forKey: "reminderIsEnabled")
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(fromBody body: [String: Any]) {
        self.init()
        if let reminderId = body[ServerDefaultKeys.reminderId.rawValue] as? Int {
            self.reminderId = reminderId
        }
        
        reminderAction = ReminderAction(rawValue: body[ServerDefaultKeys.reminderAction.rawValue] as? String ?? ReminderConstant.defaultType.rawValue)!
        reminderCustomActionName = body[ServerDefaultKeys.reminderCustomActionName.rawValue] as? String
        storedReminderType = ReminderType(rawValue: body[ServerDefaultKeys.reminderType.rawValue] as? String ?? ReminderConstant.defaultType.rawValue)!
        
        if let reminderExecutionBasisString = body[ServerDefaultKeys.reminderExecutionBasis.rawValue] as? String {
           
            storedReminderExecutionBasis = ResponseUtils.dateFormatter(fromISO8601String: reminderExecutionBasisString) ?? Date()
        }
        
        if let reminderIsEnabled = body[ServerDefaultKeys.reminderIsEnabled.rawValue] as? Bool {
            storedReminderIsEnabled = reminderIsEnabled
        }
        
        snoozeComponents = SnoozeComponents(snoozeIsEnabled: body[ServerDefaultKeys.snoozeIsEnabled.rawValue] as? Bool, executionInterval: body[ServerDefaultKeys.snoozeExecutionInterval.rawValue] as? TimeInterval, intervalElapsed: body[ServerDefaultKeys.snoozeIntervalElapsed.rawValue] as? TimeInterval)
        
        switch reminderType {
        case .countdown:
            countdownComponents = CountdownComponents(
                executionInterval: body[ServerDefaultKeys.countdownExecutionInterval.rawValue] as? TimeInterval,
                intervalElapsed: body[ServerDefaultKeys.countdownIntervalElapsed.rawValue] as? TimeInterval)
        case .weekly:
            
            var weeklyIsSkippingDate = Date()
            if let weeklyIsSkippingDateString = body[ServerDefaultKeys.weeklyIsSkippingDate.rawValue] as? String {
                weeklyIsSkippingDate = ResponseUtils.dateFormatter(fromISO8601String: weeklyIsSkippingDateString) ?? Date()
            }
            
            weeklyComponents = WeeklyComponents(
                hour: body[ServerDefaultKeys.weeklyHour.rawValue] as? Int,
                minute: body[ServerDefaultKeys.weeklyMinute.rawValue] as? Int,
                isSkipping: body[ServerDefaultKeys.weeklyIsSkipping.rawValue] as? Bool,
                skipDate: weeklyIsSkippingDate,
                sunday: body[ServerDefaultKeys.sunday.rawValue] as? Bool,
                monday: body[ServerDefaultKeys.monday.rawValue] as? Bool,
                tuesday: body[ServerDefaultKeys.tuesday.rawValue] as? Bool,
                wednesday: body[ServerDefaultKeys.wednesday.rawValue] as? Bool,
                thursday: body[ServerDefaultKeys.thursday.rawValue] as? Bool,
                friday: body[ServerDefaultKeys.friday.rawValue] as? Bool,
                saturday: body[ServerDefaultKeys.saturday.rawValue] as? Bool)
        case .monthly:
            var monthlyIsSkippingDate = Date()
            if let monthlyIsSkippingDateString = body[ServerDefaultKeys.monthlyIsSkippingDate.rawValue] as? String {
                monthlyIsSkippingDate = ResponseUtils.dateFormatter(fromISO8601String: monthlyIsSkippingDateString) ?? Date()
            }
            
            monthlyComponents = MonthlyComponents(
                hour: body[ServerDefaultKeys.monthlyHour.rawValue] as? Int,
                minute: body[ServerDefaultKeys.monthlyMinute.rawValue] as? Int,
                isSkipping: body[ServerDefaultKeys.monthlyIsSkipping.rawValue] as? Bool,
                skipDate: monthlyIsSkippingDate,
                monthlyDay: body[ServerDefaultKeys.monthlyDay.rawValue] as? Int)
        case .oneTime:
            var reminderExecutionDate = Date()
            
            if let reminderExecutionDateString = body[ServerDefaultKeys.oneTimeDate.rawValue] as? String {
                reminderExecutionDate = ResponseUtils.dateFormatter(fromISO8601String: reminderExecutionDateString) ?? Date()
            }
            
            oneTimeComponents = OneTimeComponents(date: reminderExecutionDate)
        }
    }
    
    // MARK: - Properties
    
    var reminderId: Int = ReminderConstant.defaultReminderId
    
    /// This is a user selected label for the reminder. It dictates the name that is displayed in the UI for this reminder.
    var reminderAction: ReminderAction = ReminderConstant.defaultAction
    
    /// If the reminder's type is custom, this is the name for it.
    var reminderCustomActionName: String?
    
    /// Use me if displaying the reminder's name. This handles reminderCustomActionName along with regular reminder types.
    var displayActionName: String {
        if reminderAction == .custom && reminderCustomActionName != nil {
            return reminderCustomActionName!
        }
        else {
            return reminderAction.rawValue
        }
    }
    
    // MARK: - Comparison
    
    /// Returns true if all the server synced properties for the reminder are the same. This includes all the base properties here (yes the reminderId too) and the reminder components for the corresponding reminderAction
    func isSame(asReminder reminder: Reminder) -> Bool {
        if reminderId != reminder.reminderId {
            return false
        }
        else if reminderAction != reminder.reminderAction {
            return false
        }
        else if reminderCustomActionName != reminder.reminderCustomActionName {
            return false
        }
        else if reminderExecutionBasis != reminder.reminderExecutionBasis {
            return false
        }
        else if reminderIsEnabled != reminder.reminderIsEnabled {
            return false
        }
        // snooze
        else if snoozeComponents.snoozeIsEnabled != reminder.snoozeComponents.snoozeIsEnabled {
            return false
        }
        else if snoozeComponents.executionInterval != reminder.snoozeComponents.executionInterval {
            return false
        }
        else if snoozeComponents.intervalElapsed != reminder.snoozeComponents.intervalElapsed {
            return false
        }
        // reminder types (countdown, weekly, monthly, one time)
        else if reminderType != reminder.reminderType {
            return false
        }
        else {
            // known at this point that the reminderTypes are the same
            switch reminderType {
            case .countdown:
                if countdownComponents.executionInterval != reminder.countdownComponents.executionInterval {
                    return false
                }
                else if countdownComponents.intervalElapsed != reminder.countdownComponents.intervalElapsed {
                    return false
                }
                else {
                    // everything the same!
                    return true
                }
            case .weekly:
                if weeklyComponents.dateComponents.hour != reminder.weeklyComponents.dateComponents.hour {
                    return false
                }
                else if weeklyComponents.dateComponents.minute != reminder.weeklyComponents.dateComponents.minute {
                    return false
                }
                else if weeklyComponents.weekdays != reminder.weeklyComponents.weekdays {
                    return false
                }
                else if weeklyComponents.isSkipping != reminder.weeklyComponents.isSkipping {
                    return false
                }
                else if weeklyComponents.isSkippingDate != reminder.weeklyComponents.isSkippingDate {
                    return false
                }
                else {
                    // all the same!
                    return true
                }
            case .monthly:
                if monthlyComponents.dateComponents.hour != reminder.monthlyComponents.dateComponents.hour {
                    return false
                }
                else if monthlyComponents.dateComponents.minute != reminder.monthlyComponents.dateComponents.minute {
                    return false
                }
                else if monthlyComponents.monthlyDay != reminder.monthlyComponents.monthlyDay {
                    return false
                }
                else if monthlyComponents.isSkipping != reminder.monthlyComponents.isSkipping {
                    return false
                }
                else if monthlyComponents.isSkippingDate != reminder.monthlyComponents.isSkippingDate {
                    return false
                }
                else {
                    // all the same!
                    return true
                }
            case .oneTime:
                if oneTimeComponents.oneTimeDate != reminder.oneTimeComponents.oneTimeDate {
                    return false
                }
                else {
                    // all the same!
                    return true
                }
            }
        }
    }
    
    // MARK: - Reminder Components
    
    var countdownComponents: CountdownComponents = CountdownComponents()
    
    var weeklyComponents: WeeklyComponents = WeeklyComponents()
    
    var monthlyComponents: MonthlyComponents = MonthlyComponents()
    
    var oneTimeComponents: OneTimeComponents = OneTimeComponents()
    
    var snoozeComponents: SnoozeComponents = SnoozeComponents()
    
    private var storedReminderType: ReminderType = .countdown
    /// Tells the reminder what components to use to make sure its in the correct timing style. Changing this changes between countdown, weekly, monthly, and oneTime mode.
    var reminderType: ReminderType { return storedReminderType }
    func changeReminderType(newReminderType: ReminderType) {
        guard newReminderType != storedReminderType else {
            return
        }
        
        // self.prepareForNextAlarm(shouldLogExecution: false)
        self.prepareForNextAlarm()
        
        storedReminderType = newReminderType
    }
    
    /// Factors in snoozeIsEnabled into reminderType to produce a current mode. For example, a reminder might be countdown but if its snoozed then this will return .snooze
    var currentReminderMode: ReminderMode {
        if snoozeComponents.snoozeIsEnabled == true {
            return .snooze
        }
        else if reminderType == .countdown {
            return .countdown
        }
        else if reminderType == .weekly {
            return .weekly
        }
        else if reminderType == .monthly {
            return .monthly
        }
        // else if reminderType == .oneTime {
        else {
            return .oneTime
        }
    }
    
    // MARK: - Timing
    
    private var storedReminderExecutionBasis: Date = Date()
    /// This is what the reminder should base its timing off it. This is either the last time a user responded to a reminder alarm or the last time a user changed a timing related property of the reminder. For example, 5 minutes into the timer you change the countdown from 30 minutes to 15. To start the timer fresh, having it count down from the moment it was changed, reset reminderExecutionBasis to Date()
    var reminderExecutionBasis: Date { return storedReminderExecutionBasis }
    func changeExecutionBasis(newExecutionBasis: Date, shouldResetIntervalsElapsed: Bool) {
        storedReminderExecutionBasis = newExecutionBasis
        
        // If resetting the reminderExecutionBasis to the current time (and not changing it to another reminderExecutionBasis of some other reminder) then resets interval elasped as timers would have to be fresh
        if shouldResetIntervalsElapsed == true {
            snoozeComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
            countdownComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
        }
        
    }
    
    /// When an alert from this reminder is enqueued to be presented, this property is true. This prevents multiple alerts for the same reminder being requeued everytime timing manager refreshes.
    var isPresentationHandled: Bool = false
    
    var intervalRemaining: TimeInterval? {
        switch currentReminderMode {
        case .oneTime:
            return Date().distance(to: oneTimeComponents.oneTimeDate)
        case .countdown:
            // the time is supposed to countdown for minus the time it has countdown
            return countdownComponents.executionInterval - countdownComponents.intervalElapsed
        case .weekly:
            if self.reminderExecutionBasis.distance(to: self.weeklyComponents.previousExecutionDate(reminderExecutionBasis: self.reminderExecutionBasis)) > 0 {
                return nil
            }
            else {
                return Date().distance(to: self.weeklyComponents.nextExecutionDate(reminderExecutionBasis: self.reminderExecutionBasis))
            }
        case .monthly:
            if self.reminderExecutionBasis.distance(to:
                                                self.monthlyComponents.previousExecutionDate(reminderExecutionBasis: self.reminderExecutionBasis)) > 0 {
                return nil
            }
            else {
                return Date().distance(to: self.monthlyComponents.nextExecutionDate(reminderExecutionBasis: self.reminderExecutionBasis))
            }
        case .snooze:
            // the time is supposed to countdown for minus the time it has countdown
            return snoozeComponents.executionInterval - snoozeComponents.intervalElapsed
        }
    }
    
    var reminderExecutionDate: Date? {
        // the reminder will not go off if disabled or the family is paused
        guard self.reminderIsEnabled == true && FamilyConfiguration.isPaused == false else {
            return nil
        }
        
        switch currentReminderMode {
        case .oneTime:
            return oneTimeComponents.oneTimeDate
        case .countdown:
            return Date.reminderExecutionDate(lastExecution: reminderExecutionBasis, interval: intervalRemaining!)
        case .weekly:
            // If the intervalRemaining is nil than means there is no time left
            if intervalRemaining == nil {
                return Date()
            }
            else {
                return weeklyComponents.nextExecutionDate(reminderExecutionBasis: self.reminderExecutionBasis)
            }
        case .monthly:
            // If the intervalRemaining is nil than means there is no time left
            if intervalRemaining == nil {
                return Date()
            }
            else {
                return monthlyComponents.nextExecutionDate(reminderExecutionBasis: self.reminderExecutionBasis)
            }
        case .snooze:
            return Date.reminderExecutionDate(lastExecution: reminderExecutionBasis, interval: intervalRemaining!)
        }
    }
    
    /// This is the timer that is used to make the reminder function. It triggers the events for the reminder. If getting rid of or replacing a reminder, invalidate this timer
    var timer: Timer?
    
    /// The reminder's alarm executed and the user responded to it. We want to restore the reminder to a state where it is ready for its next alarm. This should also be called if the timing components are updated.
    func prepareForNextAlarm() {
        
        self.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
        
        self.isPresentationHandled = false
        
        snoozeComponents.changeSnooze(newSnoozeStatus: false)
        snoozeComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
        
        if reminderType == .countdown {
            countdownComponents.changeIntervalElapsed(newIntervalElapsed: 0)
        }
        else if reminderType == .weekly {
            weeklyComponents.isSkippingDate = nil
            weeklyComponents.isSkipping = false
        }
        else if reminderType == .monthly {
            monthlyComponents.isSkippingDate = nil
            monthlyComponents.isSkipping = false
        }
        
    }
    
    /// Finds the date which the reminder should be transformed from isSkipping to not isSkipping. This is the date at which the skipped reminder would have occured.
    func unskipDate() -> Date? {
        if currentReminderMode == .monthly && monthlyComponents.isSkipping == true {
            return monthlyComponents.notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis)
        }
        else if currentReminderMode == .weekly && weeklyComponents.isSkipping == true {
            return weeklyComponents.notSkippingExecutionDate(reminderExecutionBasis: reminderExecutionBasis)
        }
        else {
            return nil
        }
    }
    
    /// Call this function when a user driven action directly intends to change the skip status of the weekly or monthy components. This function only timing related data, no logs are added or removed. Additioanlly, if oneTime is getting skipped, it must be deleted externally.
    func changeIsSkipping(newSkipStatus: Bool) {
        switch reminderType {
        case .oneTime: break
            // can only skip, can't unskip
            // do nothing inside the reminder, this is handled externally
        case .countdown:
            // can only skip, can't unskip
            if newSkipStatus == true {
                // skipped, reset to now so the reminder will start counting down all over again
                self.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
            }
        case .weekly:
            // weekly can skip and unskip
            guard newSkipStatus != weeklyComponents.isSkipping else {
                break
            }
            // store new state
            weeklyComponents.isSkipping = newSkipStatus
            
            if newSkipStatus == true {
                // skipping
                weeklyComponents.isSkippingDate = Date()
            }
            else {
                // since we are unskipping, we want to revert to the previous reminderExecutionBasis, which happens to be isSkippingDate
                self.changeExecutionBasis(newExecutionBasis: weeklyComponents.isSkippingDate!, shouldResetIntervalsElapsed: true)
                weeklyComponents.isSkippingDate = nil
            }
        case .monthly:
            guard newSkipStatus != monthlyComponents.isSkipping else {
                return
            }
            // store new state
            monthlyComponents.isSkipping = newSkipStatus
            
            if newSkipStatus == true {
                // skipping
                monthlyComponents.isSkippingDate = Date()
            }
            else {
                // since we are unskipping, we want to revert to the previous reminderExecutionBasis, which happens to be isSkippingDate
                self.changeExecutionBasis(newExecutionBasis: monthlyComponents.isSkippingDate!, shouldResetIntervalsElapsed: true)
                monthlyComponents.isSkippingDate = nil
            }
        }
    }
    
    // MARK: - Enable
    
    private var storedReminderIsEnabled: Bool = true
    /// Whether or not the reminder  is enabled, if disabled all reminders will not fire.
    var reminderIsEnabled: Bool {
        get {
            return storedReminderIsEnabled
        }
        set (newEnableStatus) {
            if storedReminderIsEnabled == false && newEnableStatus == true {
                // prepareForNextAlarm(shouldLogExecution: false)
                prepareForNextAlarm()
            }
            else if newEnableStatus == false {
                timer?.invalidate()
                timer = nil
            }
            
            storedReminderIsEnabled = newEnableStatus
        }
    }
    
}
