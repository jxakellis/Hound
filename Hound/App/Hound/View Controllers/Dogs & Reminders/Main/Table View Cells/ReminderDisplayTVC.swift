//
//  DogsMainScreenTableViewCellReminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderDisplayTableViewCellDelegate: AnyObject {
    /// The reminder switch to toggle the enable status was flipped. The reminder was updated and the server queried.
    func didUpdateReminderEnable(sender: Sender, parentDogId: Int, reminder: Reminder)
}

final class DogsReminderDisplayTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var reminderIconImageView: UIImageView!
    @IBOutlet private weak var reminderIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderActionLabel: ScaledUILabel!
    @IBOutlet private weak var reminderActionTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderActionBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderActionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderIntervalLabel: ScaledUILabel!
    @IBOutlet private weak var reminderIntervalBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderIntervalHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var nextAlarmLabel: ScaledUILabel!
    @IBOutlet private weak var nextAlarmBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nextAlarmHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderIsEnabledSwitch: UISwitch!
    @IBAction private func didToggleReminderIsEnabled(_ sender: Any) {
        let beforeUpdateIsEnabled = reminder.reminderIsEnabled
        reminder.reminderIsEnabled = reminderIsEnabledSwitch.isOn
        delegate.didUpdateReminderEnable(sender: Sender(origin: self, localized: self), parentDogId: parentDogId, reminder: reminder)
        
        RemindersRequest.update(invokeErrorManager: true, forDogId: parentDogId, forReminder: reminder) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // revert to previous values
                self.reminderIsEnabledSwitch.setOn(beforeUpdateIsEnabled, animated: true)
                self.reminder.reminderIsEnabled = beforeUpdateIsEnabled
                self.delegate.didUpdateReminderEnable(sender: Sender(origin: self, localized: self), parentDogId: self.parentDogId, reminder: self.reminder)
            }
        }
    }
    
    @IBOutlet private weak var rightChevronWidthConstraint: NSLayoutConstraint!
    // MARK: - Properties
    
    var reminder: Reminder!
    
    var parentDogId: Int!
    
    weak var delegate: DogsReminderDisplayTableViewCellDelegate! = nil
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup
    
    // Setup function that sets up the different IBOutlet properties
    func setup(forParentDogId parentDogId: Int, forReminder reminder: Reminder) {
        self.parentDogId = parentDogId
        self.reminder = reminder
        
        //  Text and Image Configuration
        
        reminderActionLabel.text = reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)
        
        switch reminder.reminderType {
        case .countdown:
            reminderIconImageView.image = UIImage.init(systemName: "timer")
            reminderIntervalLabel.text = ("Every \(String.convertToReadable(fromTimeInterval: reminder.countdownComponents.executionInterval))")
        case .weekly:
            reminderIconImageView.image = UIImage.init(systemName: "alarm")
            reminderIntervalLabel.text = ("\(String.convertToReadable(fromHour: reminder.weeklyComponents.hour, fromMinute: reminder.weeklyComponents.minute))")
            
            // weekdays
            if reminder.weeklyComponents.weekdays == [1, 2, 3, 4, 5, 6, 7] {
                reminderIntervalLabel.text?.append(" Everyday")
            }
            else if reminder.weeklyComponents.weekdays == [1, 7] {
                reminderIntervalLabel.text?.append(" on Weekends")
            }
            else if reminder.weeklyComponents.weekdays == [2, 3, 4, 5, 6] {
                reminderIntervalLabel.text?.append(" on Weekdays")
            }
            else {
                reminderIntervalLabel.text?.append(" on")
                if reminder.weeklyComponents.weekdays.count == 1 {
                    for weekdayInt in reminder.weeklyComponents.weekdays {
                        switch weekdayInt {
                        case 1:
                            reminderIntervalLabel.text?.append(" Sunday")
                        case 2:
                            reminderIntervalLabel.text?.append(" Monday")
                        case 3:
                            reminderIntervalLabel.text?.append(" Tuesday")
                        case 4:
                            reminderIntervalLabel.text?.append(" Wednesday")
                        case 5:
                            reminderIntervalLabel.text?.append(" Thursday")
                        case 6:
                            reminderIntervalLabel.text?.append(" Friday")
                        case 7:
                            reminderIntervalLabel.text?.append(" Saturday")
                        default:
                            reminderIntervalLabel.text?.append(VisualConstant.TextConstant.unknownText)
                        }
                    }
                }
                else {
                    for weekdayInt in reminder.weeklyComponents.weekdays {
                        switch weekdayInt {
                        case 1:
                            reminderIntervalLabel.text?.append(" Su,")
                        case 2:
                            reminderIntervalLabel.text?.append(" M,")
                        case 3:
                            reminderIntervalLabel.text?.append(" Tu,")
                        case 4:
                            reminderIntervalLabel.text?.append(" W,")
                        case 5:
                            reminderIntervalLabel.text?.append(" Th,")
                        case 6:
                            reminderIntervalLabel.text?.append(" F,")
                        case 7:
                            reminderIntervalLabel.text?.append(" Sa,")
                        default:
                            reminderIntervalLabel.text?.append(VisualConstant.TextConstant.unknownText)
                        }
                    }
                }
                // checks if extra comma, then removes
                if reminderIntervalLabel.text?.last == ","{
                    reminderIntervalLabel.text?.removeLast()
                }
            }
        case .monthly:
            reminderIconImageView.image = UIImage.init(systemName: "calendar")
            reminderIntervalLabel.text = ("\(String.convertToReadable(fromHour: reminder.monthlyComponents.hour, fromMinute: reminder.monthlyComponents.minute))")
            
            // day of month
            let monthlyDay: Int = reminder.monthlyComponents.day
            reminderIntervalLabel.text?.append(" Every Month on \(monthlyDay)")
            
            reminderIntervalLabel.text?.append(String.monthlyDaySuffix(day: monthlyDay))
        case .oneTime:
            reminderIconImageView.image = UIImage.init(systemName: "calendar")
            reminderIntervalLabel.text = String.convertToReadable(fromDate: reminder.oneTimeComponents.oneTimeDate)
        }
        
        // Size Ratio Configuration
        
        let sizeRatio = UserConfiguration.remindersInterfaceScale.currentScaleFactor
        
        // Reminder Action Label Configuration
        reminderActionLabel.font = reminderActionLabel.font.withSize(25.0 * sizeRatio)
        reminderActionTopConstraint.constant = 7.5 * sizeRatio
        reminderActionHeightConstraint.constant = 30.0 * sizeRatio
        reminderActionBottomConstraint.constant = 2.5 * sizeRatio
        
        // Reminder Interval Label Configuration
        
        reminderIntervalLabel.font = reminderIntervalLabel.font.withSize(12.5 * sizeRatio)
        reminderIntervalHeightConstraint.constant = 15.0 * sizeRatio
        reminderIntervalBottomConstraint.constant = 2.5 * sizeRatio
        
        // Next Alarm Label Configuration
        
        nextAlarmLabel.font = nextAlarmLabel.font.withSize(12.5 * sizeRatio)
        nextAlarmHeightConstraint.constant = 15.0 * sizeRatio
        nextAlarmBottomConstraint.constant = 7.5 * sizeRatio
        
        // Reminder Is Enabled Switch Configuration
        
        self.reminderIsEnabledSwitch.isOn = reminder.reminderIsEnabled
        
        // Reminder Icon Configuration
        let dogIconLeadingAndWidth = 5.0 + (60.0 * sizeRatio)
        let reminderIconWidth = 35.0 * sizeRatio
        // the extra -5 to the constant makes trailing off by 5 on purpose. the dogIcon only has 5 points between the end of it and the start of the text while the reminderIcon has 10 points. So this -5 adjusts for that to make the text line up
        let reminderIconLeading = dogIconLeadingAndWidth - reminderIconWidth - (5 * sizeRatio)
        reminderIconLeadingConstraint.constant = reminderIconLeading
        reminderIconWidthConstraint.constant = reminderIconWidth
        
        // put this reload after the sizeRatio otherwise the .font sizeRatio adjustment will change the whole text label to the same font (we want some bold and some not bold)
        reloadNextAlarmText()
    }
    
    func reloadNextAlarmText() {
        
        let nextAlarmHeaderFont = UIFont.systemFont(ofSize: nextAlarmLabel.font.pointSize, weight: .semibold)
        let nextAlarmBodyFont = UIFont.systemFont(ofSize: nextAlarmLabel.font.pointSize, weight: .regular)
        
        if FamilyConfiguration.isPaused == true {
            nextAlarmLabel.attributedText = NSAttributedString(string: "Paused", attributes: [NSAttributedString.Key.font: nextAlarmHeaderFont])
            
        }
        else if reminder.reminderIsEnabled == false {
            nextAlarmLabel.attributedText = NSAttributedString(string: "Disabled", attributes: [NSAttributedString.Key.font: nextAlarmHeaderFont])
        }
        else {
            let executionDate: Date? = reminder.reminderExecutionDate
            
            if executionDate == nil {
                nextAlarmLabel.attributedText = NSAttributedString(string: "Disabled", attributes: [NSAttributedString.Key.font: nextAlarmHeaderFont])
            }
            else if Date().distance(to: executionDate!) <= 0 {
                nextAlarmLabel.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font: nextAlarmHeaderFont])
            }
            else if reminder.snoozeComponents.snoozeIsEnabled == true {
                // special message for snoozing time
                let timeLeftText = String.convertToReadable(fromTimeInterval: Date().distance(to: executionDate!))
                
                nextAlarmLabel.font = nextAlarmBodyFont
                
                nextAlarmLabel.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: nextAlarmBodyFont])
                
                nextAlarmLabel.attributedText = nextAlarmLabel.text!.addingFontToBeginning(text: "Done Snoozing In: ", font: nextAlarmHeaderFont)
            }
            else {
                // regular message for regular time
                let timeLeftText = String.convertToReadable(fromTimeInterval: Date().distance(to: executionDate!))
                
                nextAlarmLabel.font = nextAlarmBodyFont
                
                nextAlarmLabel.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: nextAlarmBodyFont])
                
                nextAlarmLabel.attributedText = nextAlarmLabel.text!.addingFontToBeginning(text: "Remind In: ", font: nextAlarmHeaderFont)
            }
        }
    }
}
