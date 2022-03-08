//
//  Remindert.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Enum full of cases of possible errors from Reminder
enum ReminderError: Error {
    case nameBlank
    case nameInvalid
    case descriptionInvalid
    case intervalInvalid
}

enum ReminderType: String, CaseIterable {

    init?(rawValue: String) {
        for type in ReminderType.allCases {
            if type.rawValue.lowercased() == rawValue.lowercased() {
                self = type
                return
            }
        }

        AppDelegate.generalLogger.fault("ReminderType not found during init")
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
        copy.parentDog = self.parentDog

        copy.countdownComponents = self.countdownComponents.copy() as! CountdownComponents
        copy.weeklyComponents = self.weeklyComponents.copy() as! WeeklyComponents
        copy.weeklyComponents.parentReminder = copy
        copy.monthlyComponents = self.monthlyComponents.copy() as! MonthlyComponents
        copy.monthlyComponents.parentReminder = copy
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
        self.weeklyComponents.parentReminder = self
        self.monthlyComponents = aDecoder.decodeObject(forKey: "monthlyComponents") as?  MonthlyComponents ?? MonthlyComponents()
        self.monthlyComponents.parentReminder = self
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
        self.weeklyComponents.parentReminder = self
        self.monthlyComponents.parentReminder = self
    }

    convenience init(parentDog: Dog, fromBody body: [String: Any]) {
        self.init()

        self.parentDog = parentDog

        if let reminderId = body["reminderId"] as? Int {
            self.reminderId = reminderId
        }

        reminderAction = ReminderAction(rawValue: body["reminderAction"] as? String ?? ReminderConstant.defaultType.rawValue)!
        customTypeName = body["customTypeName"] as? String
        storedReminderType = ReminderType(rawValue: body["reminderType"] as? String ?? ReminderConstant.defaultType.rawValue)!

        if let executionBasis = body["executionBasis"] as? String {
            storedExecutionBasis = ISO8601DateFormatter().date(from: executionBasis) ?? Date()
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
            if let dateString = body["skipDate"] as? String {
                skipDate = ISO8601DateFormatter().date(from: dateString) ?? Date()
            }

            weeklyComponents = WeeklyComponents(
                parentReminder: self,
                hour: body["hour"] as? Int,
                minute: body["minute"] as? Int,
                skipping: body["skipping"] as? Bool,
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
            if let dateString = body["skipDate"] as? String {
                skipDate = ISO8601DateFormatter().date(from: dateString) ?? Date()
            }

            monthlyComponents = MonthlyComponents(
                parentReminder: self,
                hour: body["hour"] as? Int,
                minute: body["minute"] as? Int,
                skipping: body["skipping"] as? Bool,
                skipDate: skipDate,
                dayOfMonth: body["dayOfMonth"] as? Int)
        case .oneTime:
            var executionDate = Date()
            if let dateString = body["skipDate"] as? String {
                executionDate = ISO8601DateFormatter().date(from: dateString) ?? Date()
            }

            oneTimeComponents = OneTimeComponents(date: executionDate)
        }
    }

    // MARK: - Properties

    /// Dog that hold this reminder, used for when something is logged and it needs to be added to the dog
    var parentDog: Dog?

    var reminderId: Int = -1

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

        self.timerReset(shouldLogExecution: false)

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

    func timerReset(shouldLogExecution: Bool, logType: LogType? = nil, customTypeName: String? = nil) {

        if shouldLogExecution == true {
            if logType == nil {
                fatalError()
            }
            parentDog?.dogLogs.addLog(newLog: Log(date: Date(), logType: logType!, customTypeName: customTypeName))

            if parentDog == nil {
                AppDelegate.generalLogger.fault("parentDog nil, couldn't log")
            }
        }

        self.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)

        self.isPresentationHandled = false

        snoozeComponents.timerReset()

        if reminderType == .countdown {
            self.countdownComponents.timerReset()
        }
        else if reminderType == .weekly {
            weeklyComponents.timerReset()
        }
        else if reminderType == .monthly {
            monthlyComponents.timerReset()
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

            if newSkipStatus == true {
                // track this date so if the isSkipping is undone by the user, then we can remove the log
                weeklyComponents.isSkippingLogDate = Date()
            }
            else {
                // the user decided to remove isSkipping from the reminder, that means we must removed the log that was added.
                if weeklyComponents.isSkippingLogDate != nil {
                    // if the log added by skipping the reminder is unmodified, finds and removes it in the unskip process
                    let dogLogs = parentDog!.dogLogs.logs
                    for logDateIndex in 0..<dogLogs.count {
                        if dogLogs[logDateIndex].date.distance(to: weeklyComponents.isSkippingLogDate!) < 0.01
                            && dogLogs[logDateIndex].date.distance(to: weeklyComponents.isSkippingLogDate!) > -0.01 {
                            parentDog!.dogLogs.removeLog(forIndex: logDateIndex)
                            break
                        }
                    }
                }

                weeklyComponents.isSkippingLogDate = nil
            }

            weeklyComponents.isSkipping = newSkipStatus
        }
        else if reminderType == .monthly {
            guard newSkipStatus != monthlyComponents.isSkipping else {
                return
            }

            if newSkipStatus == true {
                // track this date so if the isSkipping is undone by the user, then we can remove the log
                monthlyComponents.isSkippingLogDate = Date()
            }
            else {
                // the user decided to remove isSkipping from the reminder, that means we must removed the log that was added.
                if monthlyComponents.isSkippingLogDate != nil {
                    // if the log added by skipping the reminder is unmodified, finds and removes it in the unskip process
                    let dogLogs = parentDog!.dogLogs.logs
                    for logDateIndex in 0..<dogLogs.count {
                        if dogLogs[logDateIndex].date.distance(to: monthlyComponents.isSkippingLogDate!) < 0.01
                            && dogLogs[logDateIndex].date.distance(to: monthlyComponents.isSkippingLogDate!) > -0.01 {
                            parentDog!.dogLogs.removeLog(forIndex: logDateIndex)
                            break
                        }
                    }
                }

                monthlyComponents.isSkippingLogDate = nil
            }

            monthlyComponents.isSkipping = newSkipStatus
        }
        else {
            // do nothing
        }

    }

    /// Typically call this function when a time driven action changes the skip status to false, or otherwise an action where we don't want to remove the log added by setting isSkipping to true. This function should be called at the time the reminder's alarm, that is currently being skipped, should have triggered. If this is not called, then the reminder will skip every single alarm. For example, take a daily alarm that is skipped. At 1 Day left on the reminder, its currently isSkipping true.  When it hits 23 hours and 59 minutes it should turn into a regular nonskipping timer.

    func disableIsSkipping() {
        if reminderType == .weekly {
            weeklyComponents.isSkippingLogDate = nil
            weeklyComponents.isSkipping = false
        }
        else if reminderType == .monthly {
            monthlyComponents.isSkippingLogDate = nil
            monthlyComponents.isSkipping = false
        }
        else {
            // do nothing
        }
    }

    // MARK: - Enable

    private var storedIsEnabled: Bool = true
    /// Whether or not the reminder  is enabled, if disabled all reminders will not fire, if parentDog isEnabled == false will not fire
    var isEnabled: Bool {
        get {
            return storedIsEnabled
        }
        set (newEnableStatus) {
            if storedIsEnabled == false && newEnableStatus == true {
                timerReset(shouldLogExecution: false)
            }

            else if newEnableStatus == false {
                timer?.invalidate()
                timer = nil
            }

            storedIsEnabled = newEnableStatus
            AppDelegate.endpointLogger.notice("ENDPOINT Update Reminder (enable)")
        }
    }

}
