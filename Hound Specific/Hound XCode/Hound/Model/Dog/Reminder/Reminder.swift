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

class Reminder: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Reminder()
        
        copy.reminderId = self.reminderId
        copy.reminderAction = self.reminderAction
        copy.customTypeName = self.customTypeName
        
        copy.countdownComponents = self.countdownComponents.copy() as! CountdownComponents
        copy.weeklyComponents = self.weeklyComponents.copy() as! WeeklyComponents
        copy.monthlyComponents = self.monthlyComponents.copy() as! MonthlyComponents
        copy.oneTimeComponents = self.oneTimeComponents.copy() as! OneTimeComponents
        copy.snoozeComponents = self.snoozeComponents.copy() as! SnoozeComponents
        copy.storedReminderType = self.reminderType
        
        copy.isPresentationHandled = self.isPresentationHandled
        copy.storedExecutionBasis = self.executionBasis
        copy.timer = self.timer
        
        copy.isEnabled = self.isEnabled
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        self.reminderId = aDecoder.decodeInteger(forKey: "reminderId")
        self.reminderAction = ReminderAction(rawValue: aDecoder.decodeObject(forKey: "reminderAction") as? String ?? ReminderConstant.defaultAction.rawValue)!
        
        self.customTypeName = aDecoder.decodeObject(forKey: "customTypeName") as? String
        
        self.countdownComponents = aDecoder.decodeObject(forKey: "countdownComponents") as? CountdownComponents ?? CountdownComponents()
        self.weeklyComponents = aDecoder.decodeObject(forKey: "weeklyComponents") as?  WeeklyComponents ?? WeeklyComponents()
        self.monthlyComponents = aDecoder.decodeObject(forKey: "monthlyComponents") as?  MonthlyComponents ?? MonthlyComponents()
        self.oneTimeComponents = aDecoder.decodeObject(forKey: "oneTimeComponents") as? OneTimeComponents ?? OneTimeComponents()
        self.snoozeComponents = aDecoder.decodeObject(forKey: "snoozeComponents") as? SnoozeComponents ?? SnoozeComponents()
        
        self.storedReminderType = ReminderType(rawValue: aDecoder.decodeObject(forKey: "reminderType") as? String ?? ReminderType.countdown.rawValue)!
        
        self.storedExecutionBasis = aDecoder.decodeObject(forKey: "executionBasis") as? Date ?? Date()
        
        self.isEnabled = aDecoder.decodeBool(forKey: "isEnabled")
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(reminderId, forKey: "reminderId")
        aCoder.encode(reminderAction.rawValue, forKey: "reminderAction")
        aCoder.encode(customTypeName, forKey: "customTypeName")
        
        aCoder.encode(countdownComponents, forKey: "countdownComponents")
        aCoder.encode(weeklyComponents, forKey: "weeklyComponents")
        aCoder.encode(monthlyComponents, forKey: "monthlyComponents")
        aCoder.encode(oneTimeComponents, forKey: "oneTimeComponents")
        aCoder.encode(snoozeComponents, forKey: "snoozeComponents")
        aCoder.encode(storedReminderType.rawValue, forKey: "reminderType")
        
        aCoder.encode(storedExecutionBasis, forKey: "executionBasis")
        
        aCoder.encode(isEnabled, forKey: "isEnabled")
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(fromBody body: [String: Any]) {
        self.init()
        if let reminderId = body["reminderId"] as? Int {
            self.reminderId = reminderId
        }
        
        reminderAction = ReminderAction(rawValue: body["reminderAction"] as? String ?? ReminderConstant.defaultType.rawValue)!
        customTypeName = body["customTypeName"] as? String
        storedReminderType = ReminderType(rawValue: body["reminderType"] as? String ?? ReminderConstant.defaultType.rawValue)!
        
        if let executionBasis = body["executionBasis"] as? String {
            storedExecutionBasis = RequestUtils.ISO8601DateFormatter.date(from: executionBasis) ?? Date()
        }
        
        if let isEnabled = body["isEnabled"] as? Bool {
            storedIsEnabled = isEnabled
        }
        
        snoozeComponents = SnoozeComponents(isSnoozed: body["isSnoozed"] as? Bool, executionInterval: body["snoozeExecutionInterval"] as? TimeInterval, intervalElapsed: body["snoozeIntervalElapsed"] as? TimeInterval)
        
        switch reminderType {
        case .countdown:
            countdownComponents = CountdownComponents(
                executionInterval: body["countdownExecutionInterval"] as? TimeInterval,
                intervalElapsed: body["countdownIntervalElapsed"] as? TimeInterval)
        case .weekly:
            
            var skipDate = Date()
            if let dateString = body["weeklySkipDate"] as? String {
                skipDate = RequestUtils.ISO8601DateFormatter.date(from: dateString) ?? Date()
            }
            
            weeklyComponents = WeeklyComponents(
                hour: body["weeklyHour"] as? Int,
                minute: body["weeklyMinute"] as? Int,
                isSkipping: body["weeklyIsSkipping"] as? Bool,
                skipDate: skipDate,
                sunday: body["sunday"] as? Bool,
                monday: body["monday"] as? Bool,
                tuesday: body["tuesday"] as? Bool,
                wednesday: body["wednesday"] as? Bool,
                thursday: body["thursday"] as? Bool,
                friday: body["friday"] as? Bool,
                saturday: body["saturday"] as? Bool)
        case .monthly:
            var skipDate = Date()
            if let dateString = body["monthlySkipDate"] as? String {
                skipDate = RequestUtils.ISO8601DateFormatter.date(from: dateString) ?? Date()
            }
            
            monthlyComponents = MonthlyComponents(
                hour: body["monthlyHour"] as? Int,
                minute: body["monthlyMinute"] as? Int,
                isSkipping: body["monthlyIsSkipping"] as? Bool,
                skipDate: skipDate,
                dayOfMonth: body["dayOfMonth"] as? Int)
        case .oneTime:
            var executionDate = Date()
            if let dateString = body["date"] as? String {
                executionDate = RequestUtils.ISO8601DateFormatter.date(from: dateString) ?? Date()
            }
            
            oneTimeComponents = OneTimeComponents(date: executionDate)
        }
    }
    
    // MARK: - Properties
    
    var reminderId: Int = ReminderConstant.defaultReminderId
    
    /// This is a user selected label for the reminder. It dictates the name that is displayed in the UI for this reminder.
    var reminderAction: ReminderAction = ReminderConstant.defaultAction
    
    /// If the reminder's type is custom, this is the name for it.
    var customTypeName: String?
    
    /// Use me if displaying the reminder's name. This handles customTypeName along with regular reminder types.
    var displayTypeName: String {
        if reminderAction == .custom && customTypeName != nil {
            return customTypeName!
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
        else if customTypeName != reminder.customTypeName {
            return false
        }
        else if executionBasis != reminder.executionBasis {
            return false
        }
        else if isEnabled != reminder.isEnabled {
            return false
        }
        // snooze
        else if snoozeComponents.isSnoozed != reminder.snoozeComponents.isSnoozed {
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
                else if monthlyComponents.dayOfMonth != reminder.monthlyComponents.dayOfMonth {
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
                if oneTimeComponents.executionDate != reminder.oneTimeComponents.executionDate {
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
    
    /// Factors in isSnoozed into reminderType to produce a current mode. For example, a reminder might be countdown but if its snoozed then this will return .snooze
    var currentReminderMode: ReminderMode {
        if snoozeComponents.isSnoozed == true {
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
    
    private var storedExecutionBasis: Date = Date()
    /// This is what the reminder should base its timing off it. This is either the last time a user responded to a reminder alarm or the last time a user changed a timing related property of the reminder. For example, 5 minutes into the timer you change the countdown from 30 minutes to 15. To start the timer fresh, having it count down from the moment it was changed, reset executionBasis to Date()
    var executionBasis: Date { return storedExecutionBasis }
    func changeExecutionBasis(newExecutionBasis: Date, shouldResetIntervalsElapsed: Bool) {
        storedExecutionBasis = newExecutionBasis
        
        // If resetting the executionBasis to the current time (and not changing it to another executionBasis of some other reminder) then resets interval elasped as timers would have to be fresh
        if shouldResetIntervalsElapsed == true {
            snoozeComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
            countdownComponents.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
        }
        
    }
    
    /// When an alert from this reminder is enqueued to be presented, this property is true. This prevents multiple alerts for the same reminder being requeued everytime timing manager refreshes.
    var isPresentationHandled: Bool = false
    
    var intervalRemaining: TimeInterval? {
        // snooze
        if currentReminderMode == .snooze {
            // the time is supposed to countdown for minus the time it has countdown
            return snoozeComponents.executionInterval - snoozeComponents.intervalElapsed
        }
        else if currentReminderMode == .countdown {
            // the time is supposed to countdown for minus the time it has countdown
            return countdownComponents.executionInterval - countdownComponents.intervalElapsed
        }
        else if currentReminderMode == .weekly {
            if self.executionBasis.distance(to: self.weeklyComponents.previousExecutionDate(reminderExecutionBasis: self.executionBasis)) > 0 {
                return nil
            }
            else {
                return Date().distance(to: self.weeklyComponents.nextExecutionDate(reminderExecutionBasis: self.executionBasis))
            }
        }
        else if currentReminderMode == .monthly {
            if self.executionBasis.distance(to:
                                                self.monthlyComponents.previousExecutionDate(reminderExecutionBasis: self.executionBasis)) > 0 {
                return nil
            }
            else {
                return Date().distance(to: self.monthlyComponents.nextExecutionDate(reminderExecutionBasis: self.executionBasis))
            }
        }
        // else if currentReminderMode == .oneTime {
        else {
            return Date().distance(to: oneTimeComponents.executionDate)
        }
    }
    
    var executionDate: Date? {
        guard self.isEnabled == true else {
            return nil
        }
        
        // Snoozing
        if self.currentReminderMode == .snooze {
            return Date.executionDate(lastExecution: executionBasis, interval: intervalRemaining!)
        }
        else if currentReminderMode == .countdown {
            return Date.executionDate(lastExecution: executionBasis, interval: intervalRemaining!)
        }
        else if currentReminderMode == .weekly {
            // If the intervalRemaining is nil than means there is no time left
            if intervalRemaining == nil {
                return Date()
            }
            else {
                return weeklyComponents.nextExecutionDate(reminderExecutionBasis: self.executionBasis)
            }
        }
        else if currentReminderMode == .monthly {
            // If the intervalRemaining is nil than means there is no time left
            if intervalRemaining == nil {
                return Date()
            }
            else {
                return monthlyComponents.nextExecutionDate(reminderExecutionBasis: self.executionBasis)
            }
        }
        // else if currentReminderMode == .oneTime {
        else {
            return oneTimeComponents.executionDate
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
            return monthlyComponents.notSkippingExecutionDate(reminderExecutionBasis: executionBasis)
        }
        else if currentReminderMode == .weekly && weeklyComponents.isSkipping == true {
            return weeklyComponents.notSkippingExecutionDate(reminderExecutionBasis: executionBasis)
        }
        else {
            return nil
        }
    }
    
    /// Typically call this function when a user driven action directly intends to change the skip status of the weekly or monthy components. This function handles both isSkipping and the logs related to isSkipping. If the newSkipStatus is false, then it will remove the log added by setting isSkipping to true, provided the log's date hasn't been modified
    func changeIsSkipping(newSkipStatus: Bool) {
        if reminderType == .weekly {
            guard newSkipStatus != weeklyComponents.isSkipping else {
                return
            }
            
            /*
             if newSkipStatus == true {
             // track this date so if the isSkipping is undone by the user, then we can remove the log
             weeklyComponents.isSkippingDate = Date()
             }
             else {
             // the user decided to remove isSkipping from the reminder, that means we must removed the log that was added.
             if weeklyComponents.isSkippingDate != nil {
             // if the log added by skipping the reminder is unmodified, finds and removes it in the unskip process
             let dogLogs = parentDog!.dogLogs.logs
             for logDateIndex in 0..<dogLogs.count {
             if dogLogs[logDateIndex].date.distance(to: weeklyComponents.isSkippingDate!) < 0.01
             && dogLogs[logDateIndex].date.distance(to: weeklyComponents.isSkippingDate!) > -0.01 {
             parentDog!.dogLogs.removeLog(forIndex: logDateIndex)
             break
             }
             }
             }
             
             weeklyComponents.isSkippingDate = nil
             }
             */
            
            weeklyComponents.isSkipping = newSkipStatus
        }
        else if reminderType == .monthly {
            guard newSkipStatus != monthlyComponents.isSkipping else {
                return
            }
            
            /*
             if newSkipStatus == true {
             // track this date so if the isSkipping is undone by the user, then we can remove the log
             monthlyComponents.isSkippingDate = Date()
             }
             else {
             
             // the user decided to remove isSkipping from the reminder, that means we must removed the log that was added.
             if monthlyComponents.isSkippingDate != nil {
             // if the log added by skipping the reminder is unmodified, finds and removes it in the unskip process
             let dogLogs = parentDog!.dogLogs.logs
             for logDateIndex in 0..<dogLogs.count {
             if dogLogs[logDateIndex].date.distance(to: monthlyComponents.isSkippingDate!) < 0.01
             && dogLogs[logDateIndex].date.distance(to: monthlyComponents.isSkippingDate!) > -0.01 {
             parentDog!.dogLogs.removeLog(forIndex: logDateIndex)
             break
             }
             }
             }
             
             monthlyComponents.isSkippingDate = nil
             }
             */
            
            monthlyComponents.isSkipping = newSkipStatus
        }
        else {
            // do nothing
        }
        
    }
    
    // MARK: - Enable
    
    private var storedIsEnabled: Bool = true
    /// Whether or not the reminder  is enabled, if disabled all reminders will not fire.
    var isEnabled: Bool {
        get {
            return storedIsEnabled
        }
        set (newEnableStatus) {
            if storedIsEnabled == false && newEnableStatus == true {
                // prepareForNextAlarm(shouldLogExecution: false)
                prepareForNextAlarm()
            }
            else if newEnableStatus == false {
                timer?.invalidate()
                timer = nil
            }
            
            storedIsEnabled = newEnableStatus
        }
    }
    
}
