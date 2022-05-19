//
//  DogsReminderTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderTableViewCellDelegate: AnyObject {
    /// The reminder switch to toggle the enable status was flipped. The reminder was updated and the server was NOT queried.
    func didUpdateReminderIsEnabled(sender: Sender, reminderId: Int, reminderIsEnabled: Bool)
}

class DogsReminderTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var reminderLabel: UILabel!
    @IBOutlet private weak var reminderIsEnabledSwitch: UISwitch!

    @IBAction func didToggleReminderIsEnabled(_ sender: Any) {
        delegate.didUpdateReminderIsEnabled(sender: Sender(origin: self, localized: self), reminderId: reminderId, reminderIsEnabled: reminderIsEnabledSwitch.isOn)
    }

    // MARK: - Properties
    
    private var reminderId: Int!

    weak var delegate: DogsReminderTableViewCellDelegate! = nil

    // MARK: - Main

    // when cell is awoken / init, this is executed
    override func awakeFromNib() {
        super.awakeFromNib()
        reminderLabel.adjustsFontSizeToFitWidth = true
    }

    func setup(forReminder reminder: Reminder) {
        reminderId = reminder.reminderId

        reminderLabel.text = ""

        if reminder.reminderType == .oneTime {
            self.reminderLabel.text? = " \(String.convertToReadable(fromDate: reminder.oneTimeComponents.oneTimeDate))"
        }
        else if reminder.reminderType == .countdown {
            self.reminderLabel.text?.append(" Every \(String.convertToReadable(fromTimeInterval: reminder.countdownComponents.executionInterval))")
        }
        else if reminder.reminderType == .monthly {

                let monthlyDay: Int! = reminder.monthlyComponents.day
                reminderLabel.text?.append(" Every Month on \(monthlyDay!)")

                reminderLabel.text?.append(String.monthlyDaySuffix(day: monthlyDay))

        }
        else if reminder.reminderType == .weekly {

            reminderLabel.text?.append(" \(String.convertToReadable(fromHour: reminder.weeklyComponents.hour, fromMinute: reminder.weeklyComponents.minute))")

            // weekdays
            if reminder.weeklyComponents.weekdays == [1, 2, 3, 4, 5, 6, 7] {
                reminderLabel.text?.append(" Everyday")
            }
            else if reminder.weeklyComponents.weekdays == [1, 7] {
                reminderLabel.text?.append(" on Weekends")
            }
            else if reminder.weeklyComponents.weekdays == [2, 3, 4, 5, 6] {
                reminderLabel.text?.append(" on Weekdays")
            }
            else {
                reminderLabel.text?.append(" on")
                if reminder.weeklyComponents.weekdays.count == 1 {
                    for weekdayInt in reminder.weeklyComponents.weekdays {
                        switch weekdayInt {
                        case 1:
                            reminderLabel.text?.append(" Sunday")
                        case 2:
                            reminderLabel.text?.append(" Monday")
                        case 3:
                            reminderLabel.text?.append(" Tuesday")
                        case 4:
                            reminderLabel.text?.append(" Wednesday")
                        case 5:
                            reminderLabel.text?.append(" Thursday")
                        case 6:
                            reminderLabel.text?.append(" Friday")
                        case 7:
                            reminderLabel.text?.append(" Saturday")
                        default:
                            reminderLabel.text?.append("unknown")
                        }
                    }
                }
                else {
                    for weekdayInt in reminder.weeklyComponents.weekdays {
                        switch weekdayInt {
                        case 1:
                            reminderLabel.text?.append(" Su,")
                        case 2:
                            reminderLabel.text?.append(" M,")
                        case 3:
                            reminderLabel.text?.append(" Tu,")
                        case 4:
                            reminderLabel.text?.append(" W,")
                        case 5:
                            reminderLabel.text?.append(" Th,")
                        case 6:
                            reminderLabel.text?.append(" F,")
                        case 7:
                            reminderLabel.text?.append(" Sa,")
                        default:
                            reminderLabel.text?.append("unknown")
                        }
                    }
                }
                // checks if extra comma, then removes
                if reminderLabel.text?.last == ","{
                    reminderLabel.text?.removeLast()
                }
            }
        }

        reminderLabel.attributedText = reminderLabel.text?.addingFontToBeginning(text: reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true) + " -", font: UIFont.systemFont(ofSize: reminderLabel.font.pointSize, weight: .medium))

        reminderIsEnabledSwitch.isOn = reminder.reminderIsEnabled

    }

}
