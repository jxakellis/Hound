//
//  DogsMainScreenTableViewCellReminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellReminderDisplayDelegate: AnyObject {
    func didToggleReminderSwitch(sender: Sender, parentDogId: Int, reminderId: Int, isEnabled: Bool)
}

class DogsMainScreenTableViewCellReminderDisplay: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var reminderChevron: UIImageView!

    @IBOutlet private weak var reminderIcon: UIImageView!

    @IBOutlet private weak var reminderActionDisplayName: ScaledUILabel!
    @IBOutlet private weak var timeInterval: ScaledUILabel!

    @IBOutlet private weak var timeLeft: ScaledUILabel!
    @IBOutlet weak var reminderToggleSwitch: UISwitch!

    // When the on off switch is toggled
    @IBAction private func didToggleReminderSwitch(_ sender: Any) {
        delegate.didToggleReminderSwitch(sender: Sender(origin: self, localized: self), parentDogId: parentDogId, reminderId: reminder.reminderId, isEnabled: reminderToggleSwitch.isOn)
    }

    // MARK: - Properties
    private var reminder: Reminder = Reminder()

    private var parentDogId: Int!

    weak var delegate: DogsMainScreenTableViewCellReminderDisplayDelegate! = nil

    // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Setup function that sets up the different IBOutlet properties
    func setup(parentDogId: Int, reminderPassed: Reminder) {
        self.parentDogId = parentDogId
        self.reminder = reminderPassed
        self.reminderActionDisplayName.text = reminderPassed.displayTypeName

        if reminder.reminderType == .oneTime {
            self.reminderIcon.image = UIImage.init(systemName: "calendar")
            self.timeInterval.text = String.convertToReadable(fromDate: reminder.oneTimeComponents.executionDate)
        }
        else if reminder.reminderType == .countdown {
            self.reminderIcon.image = UIImage.init(systemName: "timer")
            self.timeInterval.text = ("Every \(String.convertToReadable(fromTimeInterval: reminder.countdownComponents.executionInterval))")
        }
        // weekdays
        else if reminder.reminderType == .weekly {
            self.reminderIcon.image = UIImage.init(systemName: "alarm")
            try! self.timeInterval.text = ("\(String.convertToReadable(fromDateComponents: reminder.weeklyComponents.dateComponents))")

            // weekdays
            if reminder.weeklyComponents.weekdays == [1, 2, 3, 4, 5, 6, 7] {
                timeInterval.text?.append(" Everyday")
            }
            else if reminder.weeklyComponents.weekdays == [1, 7] {
                timeInterval.text?.append(" on Weekends")
            }
            else if reminder.weeklyComponents.weekdays == [2, 3, 4, 5, 6] {
                timeInterval.text?.append(" on Weekdays")
            }
            else {
                timeInterval.text?.append(" on")
                if reminder.weeklyComponents.weekdays.count == 1 {
                    for weekdayInt in reminder.weeklyComponents.weekdays {
                        switch weekdayInt {
                        case 1:
                            timeInterval.text?.append(" Sunday")
                        case 2:
                            timeInterval.text?.append(" Monday")
                        case 3:
                            timeInterval.text?.append(" Tuesday")
                        case 4:
                            timeInterval.text?.append(" Wednesday")
                        case 5:
                            timeInterval.text?.append(" Thursday")
                        case 6:
                            timeInterval.text?.append(" Friday")
                        case 7:
                            timeInterval.text?.append(" Saturday")
                        default:
                            timeInterval.text?.append("unknown")
                        }
                    }
                }
                else {
                    for weekdayInt in reminder.weeklyComponents.weekdays {
                        switch weekdayInt {
                        case 1:
                            timeInterval.text?.append(" Su,")
                        case 2:
                            timeInterval.text?.append(" M,")
                        case 3:
                            timeInterval.text?.append(" Tu,")
                        case 4:
                            timeInterval.text?.append(" W,")
                        case 5:
                            timeInterval.text?.append(" Th,")
                        case 6:
                            timeInterval.text?.append(" F,")
                        case 7:
                            timeInterval.text?.append(" Sa,")
                        default:
                            timeInterval.text?.append("unknown")
                        }
                    }
                }
                // checks if extra comma, then removes
                if timeInterval.text?.last == ","{
                    timeInterval.text?.removeLast()
                }
            }
        }
        // monthly
        else {
            self.reminderIcon.image = UIImage.init(systemName: "calendar")
            try! self.timeInterval.text = ("\(String.convertToReadable(fromDateComponents: reminder.monthlyComponents.dateComponents))")

            // day of month
                let dayOfMonth: Int = reminder.monthlyComponents.dayOfMonth
                timeInterval.text?.append(" Every Month on \(dayOfMonth)")

             timeInterval.text?.append(String.dayOfMonthSuffix(day: dayOfMonth))
        }

        self.reminderToggleSwitch.isOn = reminderPassed.isEnabled

        setupTimeLeftText()
    }

    func reloadCell() {
        setupTimeLeftText()
    }

    private func setupTimeLeftText() {

        let timeLeftBodyWeight: UIFont.Weight = .regular
        let timeLeftImportantWeight: UIFont.Weight = .semibold

        if reminder.isEnabled == false {
            timeLeft.attributedText = NSAttributedString(string: "Reminder Disabled", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
        }
        else if UserConfiguration.isPaused == true {

            timeLeft.attributedText = NSAttributedString(string: "Paused", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])

        }
        else {
            let fireDate: Date? = reminder.executionDate!

            if fireDate == nil {
                timeLeft.attributedText = NSAttributedString(string: "Reminder Disabled", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
            }
            else if Date().distance(to: fireDate!) <= 0 {
                timeLeft.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
            }
            else if reminder.snoozeComponents.isSnoozed == true {
                let timeLeftText = String.convertToReadable(fromTimeInterval: Date().distance(to: fireDate!))

                timeLeft.font = UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftBodyWeight)

                timeLeft.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftBodyWeight)])

                timeLeft.attributedText = timeLeft.text!.addingFontToBeginning(text: "Done Snoozing In: ", font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight))
            }
            else {
                let timeLeftText = String.convertToReadable(fromTimeInterval: Date().distance(to: fireDate!))

                timeLeft.font = UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftBodyWeight)

                timeLeft.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftBodyWeight)])

                timeLeft.attributedText = timeLeft.text!.addingFontToBeginning(text: "Remind In: ", font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight))
            }
        }
    }
}
