//
//  DogsReminderTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderTableViewCellDelegate: AnyObject {
    func didToggleEnable(sender: Sender, reminderId: Int, newEnableStatus: Bool)
}

class DogsReminderTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var reminderDisplay: UILabel!
    @IBOutlet private weak var reminderToggleSwitch: UISwitch!

    @IBAction func didToggleEnable(_ sender: Any) {
        delegate.didToggleEnable(sender: Sender(origin: self, localized: self), reminderId: reminderSource.reminderId, newEnableStatus: self.reminderToggleSwitch.isOn)
    }

    // MARK: - Properties

    weak var delegate: DogsReminderTableViewCellDelegate! = nil

    var reminderSource: Reminder! = nil

    // MARK: - Main

    // when cell is awoken / init, this is executed
    override func awakeFromNib() {
        super.awakeFromNib()
        reminderDisplay.adjustsFontSizeToFitWidth = true

        // self.contentMode = .center
        // self.imageView?.contentMode = .center
    }

    func setup(reminder: Reminder) {
        reminderSource = reminder

        reminderDisplay.text = ""

        if reminder.reminderType == .oneTime {
            self.reminderDisplay.text? = " \(String.convertToReadable(fromDate: reminder.oneTimeComponents.executionDate))"
        }
        else if reminder.reminderType == .countdown {
            self.reminderDisplay.text?.append(" Every \(String.convertToReadable(fromTimeInterval: reminder.countdownComponents.executionInterval))")
        }
        else if reminder.reminderType == .monthly {

                let dayOfMonth: Int! = reminder.monthlyComponents.dayOfMonth
                reminderDisplay.text?.append(" Every Month on \(dayOfMonth!)")

                reminderDisplay.text?.append(String.dayOfMonthSuffix(day: dayOfMonth))

        }

        else if reminder.reminderType == .weekly {

            try! self.reminderDisplay.text?.append(" \(String.convertToReadable(fromDateComponents: reminder.monthlyComponents.dateComponents))")

            // weekdays
            if reminder.weeklyComponents.weekdays == [1, 2, 3, 4, 5, 6, 7] {
                reminderDisplay.text?.append(" Everyday")
            }
            else if reminder.weeklyComponents.weekdays == [1, 7] {
                reminderDisplay.text?.append(" on Weekends")
            }
            else if reminder.weeklyComponents.weekdays == [2, 3, 4, 5, 6] {
                reminderDisplay.text?.append(" on Weekdays")
            }
            else {
                reminderDisplay.text?.append(" on")
                if reminder.weeklyComponents.weekdays.count == 1 {
                    for weekdayInt in reminder.weeklyComponents.weekdays {
                        switch weekdayInt {
                        case 1:
                            reminderDisplay.text?.append(" Sunday")
                        case 2:
                            reminderDisplay.text?.append(" Monday")
                        case 3:
                            reminderDisplay.text?.append(" Tuesday")
                        case 4:
                            reminderDisplay.text?.append(" Wednesday")
                        case 5:
                            reminderDisplay.text?.append(" Thursday")
                        case 6:
                            reminderDisplay.text?.append(" Friday")
                        case 7:
                            reminderDisplay.text?.append(" Saturday")
                        default:
                            reminderDisplay.text?.append("unknown")
                        }
                    }
                }
                else {
                    for weekdayInt in reminder.weeklyComponents.weekdays {
                        switch weekdayInt {
                        case 1:
                            reminderDisplay.text?.append(" Su,")
                        case 2:
                            reminderDisplay.text?.append(" M,")
                        case 3:
                            reminderDisplay.text?.append(" Tu,")
                        case 4:
                            reminderDisplay.text?.append(" W,")
                        case 5:
                            reminderDisplay.text?.append(" Th,")
                        case 6:
                            reminderDisplay.text?.append(" F,")
                        case 7:
                            reminderDisplay.text?.append(" Sa,")
                        default:
                            reminderDisplay.text?.append("unknown")
                        }
                    }
                }
                // checks if extra comma, then removes
                if reminderDisplay.text?.last == ","{
                    reminderDisplay.text?.removeLast()
                }
            }
        }

        reminderDisplay.attributedText = reminderDisplay.text?.addingFontToBeginning(text: reminder.displayTypeName + " -", font: UIFont.systemFont(ofSize: reminderDisplay.font.pointSize, weight: .medium))

        self.reminderToggleSwitch.isOn = reminder.isEnabled

    }

}
