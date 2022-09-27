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
        for type in ReminderType.allCases where type.rawValue.lowercased() == rawValue.lowercased() {
            self = type
            return
        }
        
        self = .countdown
        return
    }
    case oneTime
    case countdown
    case weekly
    case monthly
}

final class Reminder: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Reminder()
        
        copy.reminderId = self.reminderId
        copy.reminderAction = self.reminderAction
        copy.reminderCustomActionName = self.reminderCustomActionName
        
        copy.countdownComponents = self.countdownComponents.copy() as? CountdownComponents ?? CountdownComponents()
        copy.weeklyComponents = self.weeklyComponents.copy() as? WeeklyComponents ?? WeeklyComponents()
        copy.monthlyComponents = self.monthlyComponents.copy() as? MonthlyComponents ?? MonthlyComponents()
        copy.oneTimeComponents = self.oneTimeComponents.copy() as? OneTimeComponents ?? OneTimeComponents()
        copy.snoozeComponents = self.snoozeComponents.copy() as? SnoozeComponents ?? SnoozeComponents()
        copy.storedReminderType = self.reminderType
        
        copy.hasAlarmPresentationHandled = self.hasAlarmPresentationHandled
        copy.reminderExecutionBasis = self.reminderExecutionBasis
        copy.timer = self.timer
        
        copy.reminderIsEnabled = self.reminderIsEnabled
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        reminderId = aDecoder.decodeInteger(forKey: KeyConstant.reminderId.rawValue)
        reminderAction = ReminderAction(rawValue: aDecoder.decodeObject(forKey: KeyConstant.reminderAction.rawValue) as? String ?? ClassConstant.ReminderConstant.defaultReminderAction.rawValue) ?? reminderAction
        
        reminderCustomActionName = aDecoder.decodeObject(forKey: KeyConstant.reminderCustomActionName.rawValue) as? String ?? reminderCustomActionName
        
        countdownComponents = aDecoder.decodeObject(forKey: KeyConstant.countdownComponents.rawValue) as? CountdownComponents ?? countdownComponents
        weeklyComponents = aDecoder.decodeObject(forKey: KeyConstant.weeklyComponents.rawValue) as?  WeeklyComponents ?? weeklyComponents
        monthlyComponents = aDecoder.decodeObject(forKey: KeyConstant.monthlyComponents.rawValue) as?  MonthlyComponents ?? monthlyComponents
        oneTimeComponents = aDecoder.decodeObject(forKey: KeyConstant.oneTimeComponents.rawValue) as? OneTimeComponents ?? oneTimeComponents
        snoozeComponents = aDecoder.decodeObject(forKey: KeyConstant.snoozeComponents.rawValue) as? SnoozeComponents ?? snoozeComponents
        
        storedReminderType = ReminderType(rawValue: aDecoder.decodeObject(forKey: KeyConstant.reminderType.rawValue) as? String ?? ClassConstant.ReminderConstant.defaultReminderType.rawValue) ?? storedReminderType
        
        reminderExecutionBasis = aDecoder.decodeObject(forKey: KeyConstant.reminderExecutionBasis.rawValue) as? Date ?? reminderExecutionBasis
        
        reminderIsEnabled = aDecoder.decodeBool(forKey: KeyConstant.reminderIsEnabled.rawValue)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(reminderId, forKey: KeyConstant.reminderId.rawValue)
        aCoder.encode(reminderAction.rawValue, forKey: KeyConstant.reminderAction.rawValue)
        aCoder.encode(reminderCustomActionName, forKey: KeyConstant.reminderCustomActionName.rawValue)
        
        aCoder.encode(countdownComponents, forKey: KeyConstant.countdownComponents.rawValue)
        aCoder.encode(weeklyComponents, forKey: KeyConstant.weeklyComponents.rawValue)
        aCoder.encode(monthlyComponents, forKey: KeyConstant.monthlyComponents.rawValue)
        aCoder.encode(oneTimeComponents, forKey: KeyConstant.oneTimeComponents.rawValue)
        aCoder.encode(snoozeComponents, forKey: KeyConstant.snoozeComponents.rawValue)
        aCoder.encode(storedReminderType.rawValue, forKey: KeyConstant.reminderType.rawValue)
        
        aCoder.encode(reminderExecutionBasis, forKey: KeyConstant.reminderExecutionBasis.rawValue)
        
        aCoder.encode(reminderIsEnabled, forKey: KeyConstant.reminderIsEnabled.rawValue)
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(
        reminderId: Int = ClassConstant.ReminderConstant.defaultReminderId,
        reminderAction: ReminderAction = ClassConstant.ReminderConstant.defaultReminderAction,
        reminderCustomActionName: String? = ClassConstant.ReminderConstant.defaultReminderCustomActionName,
        reminderType: ReminderType = ClassConstant.ReminderConstant.defaultReminderType,
        reminderExecutionBasis: Date = ClassConstant.ReminderConstant.defaultReminderExecutionBasis,
        reminderIsEnabled: Bool = ClassConstant.ReminderConstant.defaultReminderIsEnabled) {
            self.init()
            
            self.reminderId = reminderId
            self.reminderAction = reminderAction
            self.reminderCustomActionName = reminderCustomActionName
            self.storedReminderType = reminderType
            self.reminderExecutionBasis = reminderExecutionBasis
            self.reminderIsEnabled = reminderIsEnabled
        }
    
    convenience init(fromBody body: [String: Any]) {
        
        let reminderId = body[KeyConstant.reminderId.rawValue] as? Int ?? ClassConstant.ReminderConstant.defaultReminderId
        let reminderAction = ReminderAction(rawValue: body[KeyConstant.reminderAction.rawValue] as? String ?? ClassConstant.ReminderConstant.defaultReminderAction.rawValue) ?? ClassConstant.ReminderConstant.defaultReminderAction
        let reminderCustomActionName = body[KeyConstant.reminderCustomActionName.rawValue] as? String ?? ClassConstant.ReminderConstant.defaultReminderCustomActionName
        let reminderType = ReminderType(rawValue: body[KeyConstant.reminderType.rawValue] as? String ?? ClassConstant.ReminderConstant.defaultReminderType.rawValue) ?? ClassConstant.ReminderConstant.defaultReminderType
        var reminderExecutionBasis = ClassConstant.ReminderConstant.defaultReminderExecutionBasis
        if let reminderExecutionBasisString = body[KeyConstant.reminderExecutionBasis.rawValue] as? String {
            reminderExecutionBasis = ResponseUtils.dateFormatter(fromISO8601String: reminderExecutionBasisString) ?? ClassConstant.ReminderConstant.defaultReminderExecutionBasis
        }
        let reminderIsEnabled = body[KeyConstant.reminderIsEnabled.rawValue] as? Bool ?? ClassConstant.ReminderConstant.defaultReminderIsEnabled
        
        self.init(reminderId: reminderId, reminderAction: reminderAction, reminderCustomActionName: reminderCustomActionName, reminderType: reminderType, reminderExecutionBasis: reminderExecutionBasis, reminderIsEnabled: reminderIsEnabled)
        
        reminderIsDeleted = body[KeyConstant.reminderIsDeleted.rawValue] as? Bool ?? false
        
        // snooze
        snoozeComponents = SnoozeComponents(executionInterval: body[KeyConstant.snoozeExecutionInterval.rawValue] as? TimeInterval)
        
        // countdown
        countdownComponents = CountdownComponents(
            executionInterval: body[KeyConstant.countdownExecutionInterval.rawValue] as? TimeInterval)
        
        // weekly
        var weeklySkippedDate: Date?
        if let weeklySkippedDateString = body[KeyConstant.weeklySkippedDate.rawValue] as? String {
            weeklySkippedDate = ResponseUtils.dateFormatter(fromISO8601String: weeklySkippedDateString)
        }
        weeklyComponents = WeeklyComponents(
            UTCHour: body[KeyConstant.weeklyUTCHour.rawValue] as? Int,
            UTCMinute: body[KeyConstant.weeklyUTCMinute.rawValue] as? Int,
            skippedDate: weeklySkippedDate,
            sunday: body[KeyConstant.weeklySunday.rawValue] as? Bool,
            monday: body[KeyConstant.weeklyMonday.rawValue] as? Bool,
            tuesday: body[KeyConstant.weeklyTuesday.rawValue] as? Bool,
            wednesday: body[KeyConstant.weeklyWednesday.rawValue] as? Bool,
            thursday: body[KeyConstant.weeklyThursday.rawValue] as? Bool,
            friday: body[KeyConstant.weeklyFriday.rawValue] as? Bool,
            saturday: body[KeyConstant.weeklySaturday.rawValue] as? Bool)
        
        // monthly
        var monthlySkippedDate: Date?
        if let monthlySkippedDateString = body[KeyConstant.monthlySkippedDate.rawValue] as? String {
            monthlySkippedDate = ResponseUtils.dateFormatter(fromISO8601String: monthlySkippedDateString)
        }
        
        monthlyComponents = MonthlyComponents(
            UTCDay: body[KeyConstant.monthlyUTCDay.rawValue] as? Int,
            UTCHour: body[KeyConstant.monthlyUTCHour.rawValue] as? Int,
            UTCMinute: body[KeyConstant.monthlyUTCMinute.rawValue] as? Int,
            skippedDate: monthlySkippedDate
        )
        
        // one time
        var oneTimeDate = Date()
        if let oneTimeDateString = body[KeyConstant.oneTimeDate.rawValue] as? String {
            oneTimeDate = ResponseUtils.dateFormatter(fromISO8601String: oneTimeDateString) ?? Date()
        }
        oneTimeComponents = OneTimeComponents(date: oneTimeDate)
    }
    
    // MARK: - Properties
    
    // General
    
    var reminderId: Int = ClassConstant.ReminderConstant.defaultReminderId
    
    /// This property a marker leftover from when we went through the process of constructing a new reminder from JSON and combining with an existing reminder object. This markers allows us to have a new reminder to overwrite the old reminder, then leaves an indicator that this should be deleted. This deletion is handled by DogsRequest
    private(set) var reminderIsDeleted: Bool = false
    
    /// This is a user selected label for the reminder. It dictates the name that is displayed in the UI for this reminder.
    var reminderAction: ReminderAction = ClassConstant.ReminderConstant.defaultReminderAction
    
    /// If the reminder's type is custom, this is the name for it.
    private(set) var reminderCustomActionName: String? = ClassConstant.ReminderConstant.defaultReminderCustomActionName
    func changeReminderCustomActionName(forReminderCustomActionName: String?) throws {
        guard forReminderCustomActionName?.count ?? 0 <= ClassConstant.ReminderConstant.reminderCustomActionNameCharacterLimit else {
            throw ErrorConstant.ReminderError.reminderCustomActionNameCharacterLimitExceeded
        }
        
        reminderCustomActionName = forReminderCustomActionName
    }
    
    // Timing
    
    var storedReminderType: ReminderType = ClassConstant.ReminderConstant.defaultReminderType
    /// Tells the reminder what components to use to make sure its in the correct timing style. Changing this changes between countdown, weekly, monthly, and oneTime mode.
    var reminderType: ReminderType {
        get {
            return storedReminderType
        }
        set (newReminderType) {
            guard newReminderType != storedReminderType else {
                return
            }
            
            self.prepareForNextAlarm()
            
            storedReminderType = newReminderType
        }
    }
    
    /// This is what the reminder should base its timing off it. This is either the last time a user responded to a reminder alarm or the last time a user changed a timing related property of the reminder. For example, 5 minutes into the timer you change the countdown from 30 minutes to 15. To start the timer fresh, having it count down from the moment it was changed, reset reminderExecutionBasis to Date()
    var reminderExecutionBasis: Date = ClassConstant.ReminderConstant.defaultReminderExecutionBasis
    
    // Enable
    
    private var storedReminderIsEnabled: Bool = ClassConstant.ReminderConstant.defaultReminderIsEnabled
    /// Whether or not the reminder  is enabled, if disabled all reminders will not fire.
    var reminderIsEnabled: Bool {
        get {
            return storedReminderIsEnabled
        }
        set (newEnableStatus) {
            if storedReminderIsEnabled == false && newEnableStatus == true {
                prepareForNextAlarm()
            }
            else if newEnableStatus == false {
                timer?.invalidate()
                timer = nil
            }
            
            storedReminderIsEnabled = newEnableStatus
        }
    }
    
    // MARK: - Reminder Components
    
    var countdownComponents: CountdownComponents = CountdownComponents()
    
    var weeklyComponents: WeeklyComponents = WeeklyComponents()
    
    var monthlyComponents: MonthlyComponents = MonthlyComponents()
    
    var oneTimeComponents: OneTimeComponents = OneTimeComponents()
    
    var snoozeComponents: SnoozeComponents = SnoozeComponents()
    
    // MARK: - Timing
    
    /// When an alert from this reminder is enqueued to be presented, this property is true. This prevents multiple alerts for the same reminder being requeued everytime timing manager refreshes.
    var hasAlarmPresentationHandled: Bool = false
    
    var intervalRemaining: TimeInterval? {
        guard snoozeComponents.executionInterval == nil else {
            return snoozeComponents.executionInterval
        }
        
        switch reminderType {
        case .oneTime:
            return Date().distance(to: oneTimeComponents.oneTimeDate)
        case .countdown:
            // the time is supposed to countdown for minus the time it has countdown
            return countdownComponents.executionInterval
        case .weekly:
            if self.reminderExecutionBasis.distance(to: self.weeklyComponents.previousExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis)) > 0 {
                return nil
            }
            else {
                return Date().distance(to: self.weeklyComponents.nextExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis))
            }
        case .monthly:
            if self.reminderExecutionBasis.distance(to:
                                                        self.monthlyComponents.previousExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis)) > 0 {
                return nil
            }
            else {
                return Date().distance(to: self.monthlyComponents.nextExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis))
            }
        }
    }
    
    var reminderExecutionDate: Date? {
        // the reminder will not go off if disabled or the family is paused
        guard reminderIsEnabled == true else {
            return nil
        }
        
        guard let intervalRemaining = intervalRemaining else {
            // If the intervalRemaining is nil than means there is no time left
            return Date()
        }
        
        guard snoozeComponents.executionInterval == nil else {
            return Date(timeInterval: intervalRemaining, since: reminderExecutionBasis)
        }
        
        switch reminderType {
        case .oneTime:
            return oneTimeComponents.oneTimeDate
        case .countdown:
            return Date(timeInterval: intervalRemaining, since: reminderExecutionBasis)
        case .weekly:
            return weeklyComponents.nextExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis)
        case .monthly:
            return monthlyComponents.nextExecutionDate(forReminderExecutionBasis: self.reminderExecutionBasis)
        }
    }
    
    /// This is the timer that is used to make the reminder function. It triggers the events for the reminder. If getting rid of or replacing a reminder, invalidate this timer
    var timer: Timer?
    
    /// The reminder's alarm executed and the user responded to it. We want to restore the reminder to a state where it is ready for its next alarm. This should also be called if the timing components are updated.
    func prepareForNextAlarm() {
        
        reminderExecutionBasis = Date()
        
        hasAlarmPresentationHandled = false
        
        snoozeComponents.executionInterval = nil
        
        weeklyComponents.skippedDate = nil
        monthlyComponents.skippedDate = nil
    }
    
    /// Finds the date which the reminder should be transformed from isSkipping to not isSkipping. This is the date at which the skipped reminder would have occured.
    func unskipDate() -> Date? {
        guard reminderIsEnabled && snoozeComponents.executionInterval == nil else {
            return nil
        }
        
        if reminderType == .monthly && monthlyComponents.isSkipping == true {
            return monthlyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
        }
        else if reminderType == .weekly && weeklyComponents.isSkipping == true {
            return weeklyComponents.notSkippingExecutionDate(forReminderExecutionBasis: reminderExecutionBasis)
        }
        else {
            return nil
        }
    }
    
    /// Call this function when a user driven action directly intends to change the skip status of the weekly or monthy components. This function only timing related data, no logs are added or removed. Additioanlly, if oneTime is getting skipped, it must be deleted externally.
    func changeIsSkipping(forIsSkipping isSkipping: Bool) {
        // can't change is skipping on a disabled reminder. nothing to skip.
        guard reminderIsEnabled == true else {
            return
        }
        
        switch reminderType {
        case .oneTime: break
            // can't skip and can't unskip
            // do nothing inside the reminder, this is handled externally
        case .countdown:
            // can skip and can't unskip
            if isSkipping == true {
                // only way to skip a countdown reminder is to reset it to restart its countdown
                prepareForNextAlarm()
            }
        case .weekly:
            // can skip and can unskip
            guard isSkipping != weeklyComponents.isSkipping else {
                break
            }
            
            if let skippedDate = weeklyComponents.skippedDate {
                // since we are unskipping, we want to revert to the previous reminderExecutionBasis, which happens to be skippedDate
                reminderExecutionBasis = skippedDate
                weeklyComponents.skippedDate = nil
            }
            else {
                // skipping
                weeklyComponents.skippedDate = Date()
            }
        case .monthly:
            // can skip and can unskip
            guard isSkipping != monthlyComponents.isSkipping else {
                return
            }
            
            if let skippedDate = monthlyComponents.skippedDate {
                // since we are unskipping, we want to revert to the previous reminderExecutionBasis, which happens to be skippedDate
                reminderExecutionBasis = skippedDate
                monthlyComponents.skippedDate = nil
            }
            else {
                // skipping
                monthlyComponents.skippedDate = Date()
            }
        }
    }
    
}

extension Reminder {
    
    // MARK: - Compare
    
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
        else if snoozeComponents.executionInterval != reminder.snoozeComponents.executionInterval {
            return false
        }
        // reminder types (countdown, weekly, monthly, one time)
        else if reminderType != reminder.reminderType {
            return false
        }
        
        // known at this point that the reminderTypes are the same
        switch reminderType {
        case .countdown:
            if countdownComponents.executionInterval != reminder.countdownComponents.executionInterval {
                return false
            }
            else {
                // everything the same!
                return true
            }
        case .weekly:
            if weeklyComponents.UTCHour != reminder.weeklyComponents.UTCHour {
                return false
            }
            else if weeklyComponents.UTCMinute != reminder.weeklyComponents.UTCMinute {
                return false
            }
            else if weeklyComponents.weekdays != reminder.weeklyComponents.weekdays {
                return false
            }
            else if weeklyComponents.isSkipping != reminder.weeklyComponents.isSkipping {
                return false
            }
            else if weeklyComponents.skippedDate != reminder.weeklyComponents.skippedDate {
                return false
            }
            else {
                // all the same!
                return true
            }
        case .monthly:
            if monthlyComponents.UTCHour != reminder.monthlyComponents.UTCHour {
                return false
            }
            else if monthlyComponents.UTCMinute != reminder.monthlyComponents.UTCMinute {
                return false
            }
            else if monthlyComponents.UTCDay != reminder.monthlyComponents.UTCDay {
                return false
            }
            else if monthlyComponents.isSkipping != reminder.monthlyComponents.isSkipping {
                return false
            }
            else if monthlyComponents.skippedDate != reminder.monthlyComponents.skippedDate {
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
    
    // MARK: - Request
    
    /// Returns an array literal of the reminders's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[KeyConstant.reminderId.rawValue] = reminderId
        body[KeyConstant.reminderType.rawValue] = reminderType.rawValue
        body[KeyConstant.reminderAction.rawValue] = reminderAction.rawValue
        body[KeyConstant.reminderCustomActionName.rawValue] = reminderCustomActionName
        body[KeyConstant.reminderExecutionBasis.rawValue] = reminderExecutionBasis.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.reminderExecutionDate.rawValue] = reminderExecutionDate?.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.reminderIsEnabled.rawValue] = reminderIsEnabled
        
        // snooze
        body[KeyConstant.snoozeExecutionInterval.rawValue] = snoozeComponents.executionInterval
        
        // countdown
        body[KeyConstant.countdownExecutionInterval.rawValue] = countdownComponents.executionInterval
        
        // weekly
        body[KeyConstant.weeklyUTCHour.rawValue] = weeklyComponents.UTCHour
        body[KeyConstant.weeklyUTCMinute.rawValue] = weeklyComponents.UTCMinute
        body[KeyConstant.weeklySkippedDate.rawValue] = weeklyComponents.skippedDate?.ISO8601FormatWithFractionalSeconds()
        
        body[KeyConstant.weeklySunday.rawValue] = false
        body[KeyConstant.weeklyMonday.rawValue] = false
        body[KeyConstant.weeklyTuesday.rawValue] = false
        body[KeyConstant.weeklyWednesday.rawValue] = false
        body[KeyConstant.weeklyThursday.rawValue] = false
        body[KeyConstant.weeklyFriday.rawValue] = false
        body[KeyConstant.weeklySaturday.rawValue] = false
        
        for weekday in weeklyComponents.weekdays {
            switch weekday {
            case 1:
                body[KeyConstant.weeklySunday.rawValue] = true
            case 2:
                body[KeyConstant.weeklyMonday.rawValue] = true
            case 3:
                body[KeyConstant.weeklyTuesday.rawValue] = true
            case 4:
                body[KeyConstant.weeklyWednesday.rawValue] = true
            case 5:
                body[KeyConstant.weeklyThursday.rawValue] = true
            case 6:
                body[KeyConstant.weeklyFriday.rawValue] = true
            case 7:
                body[KeyConstant.weeklySaturday.rawValue] = true
            default:
                continue
            }
        }
        
        // monthly
        body[KeyConstant.monthlyUTCDay.rawValue] = monthlyComponents.UTCDay
        body[KeyConstant.monthlyUTCHour.rawValue] = monthlyComponents.UTCHour
        body[KeyConstant.monthlyUTCMinute.rawValue] = monthlyComponents.UTCMinute
        body[KeyConstant.monthlySkippedDate.rawValue] = monthlyComponents.skippedDate?.ISO8601FormatWithFractionalSeconds()
        
        // one time
        body[KeyConstant.oneTimeDate.rawValue] = oneTimeComponents.oneTimeDate.ISO8601FormatWithFractionalSeconds()
        
        return body
    }
    
    /// Returns an array literal of the reminders's reminderId and no other properties. This is suitable to be used as the JSON body for a HTTP request
    func createIdBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[KeyConstant.reminderId.rawValue] = reminderId
        return body
    }
}
