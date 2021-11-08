//
//  DogsMainScreenTableViewCellReminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellReminderDisplayDelegate {
    func didToggleReminderSwitch(sender: Sender, parentDogName: String, reminderUUID: String, isEnabled: Bool)
}

class DogsMainScreenTableViewCellReminderDisplay: UITableViewCell {
    
    //MARK: - IB
    
    @IBOutlet private weak var reminderChevron: UIImageView!
    
    @IBOutlet private weak var reminderIcon: UIImageView!
    
    @IBOutlet private weak var reminderTypeDisplayName: ScaledUILabel!
    @IBOutlet private weak var timeInterval: ScaledUILabel!
    
    @IBOutlet private weak var timeLeft: ScaledUILabel!
    @IBOutlet weak var reminderToggleSwitch: UISwitch!
    
    //When the on off switch is toggled
    @IBAction private func didToggleReminderSwitch(_ sender: Any) {
        delegate.didToggleReminderSwitch(sender: Sender(origin: self, localized: self), parentDogName: self.parentDogName, reminderUUID: reminder.uuid, isEnabled: self.reminderToggleSwitch.isOn)
    }
    
    //MARK: -  Properties
    private var reminder: Reminder = Reminder()
    
    private var parentDogName: String = ""
    
    var delegate: DogsMainScreenTableViewCellReminderDisplayDelegate! = nil
    
    //MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //reminderChevron.tintColor = ColorConstant.gray.rawValue
        //reminderChevron.alpha = 1
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //Setup function that sets up the different IBOutlet properties
    func setup(parentDogName: String, reminderPassed: Reminder){
        self.parentDogName = parentDogName
        self.reminder = reminderPassed
        self.reminderTypeDisplayName.text = reminderPassed.displayTypeName
        
        if reminder.timingStyle == .oneTime {
            self.reminderIcon.image = UIImage.init(systemName: "calendar")
            try! self.timeInterval.text = String.convertToReadableNonRepeating(interperatedDateComponents: reminder.oneTimeComponents.dateComponents)
        }
        else if reminder.timingStyle == .countDown {
            self.reminderIcon.image = UIImage.init(systemName: "timer")
            self.timeInterval.text = ("Every \(String.convertToReadable(interperateTimeInterval: reminder.countDownComponents.executionInterval))")
        }
        //weekdays
        else if reminder.timingStyle == .weekly{
            self.reminderIcon.image = UIImage.init(systemName: "alarm")
            try! self.timeInterval.text = ("\(String.convertToReadable(interperatedDateComponents: reminder.timeOfDayComponents.timeOfDayComponent))")
            
            
            //weekdays
            if reminder.timeOfDayComponents.weekdays == [1,2,3,4,5,6,7]{
                timeInterval.text?.append(" Everyday")
            }
            else if reminder.timeOfDayComponents.weekdays == [1,7]{
                timeInterval.text?.append(" on Weekends")
            }
            else if reminder.timeOfDayComponents.weekdays == [2,3,4,5,6]{
                timeInterval.text?.append(" on Weekdays")
            }
            else {
                timeInterval.text?.append(" on")
                if reminder.timeOfDayComponents.weekdays!.count == 1 {
                    for weekdayInt in reminder.timeOfDayComponents.weekdays!{
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
                    for weekdayInt in reminder.timeOfDayComponents.weekdays!{
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
                //checks if extra comma, then removes
                if timeInterval.text?.last == ","{
                    timeInterval.text?.removeLast()
                }
            }
        }
        //monthly
        else {
            self.reminderIcon.image = UIImage.init(systemName: "calendar")
            try! self.timeInterval.text = ("\(String.convertToReadable(interperatedDateComponents: reminder.timeOfDayComponents.timeOfDayComponent))")
            
            
            //day of month
                let dayOfMonth: Int! = reminder.timeOfDayComponents.dayOfMonth
                timeInterval.text?.append(" Every Month on \(dayOfMonth!)")
            
             timeInterval.text?.append(String.dayOfMonthSuffix(day: dayOfMonth))
        }
        
        self.reminderToggleSwitch.isOn = reminderPassed.getEnable()
        
        setupTimeLeftText()
    }
    
    
    func reloadCell(){
        setupTimeLeftText()
    }
    
    private func setupTimeLeftText(){
        
        let timeLeftBodyWeight: UIFont.Weight = .regular
        let timeLeftImportantWeight: UIFont.Weight = .semibold
        
        if reminder.getEnable() == false {
            timeLeft.attributedText = NSAttributedString(string: "Reminder Disabled", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
        }
        else if TimingManager.isPaused == true {
            
            timeLeft.attributedText = NSAttributedString(string: "Paused", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
            
        }
        else{
            let fireDate: Date? = reminder.executionDate!
            
            if fireDate == nil {
                timeLeft.attributedText = NSAttributedString(string: "Reminder Disabled", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
            }
            else if Date().distance(to: fireDate!) <= 0 {
                timeLeft.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
            }
            else if reminder.snoozeComponents.isSnoozed == true {
                let timeLeftText = String.convertToReadable(interperateTimeInterval: Date().distance(to: fireDate!))
                
                timeLeft.font = UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftBodyWeight)
                
                timeLeft.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftBodyWeight)])
                
                timeLeft.attributedText = timeLeft.text!.addingFontToBeginning(text: "Done Snoozing In: ", font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight))
            }
            else {
                let timeLeftText = String.convertToReadable(interperateTimeInterval: Date().distance(to: fireDate!))
                
                timeLeft.font = UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftBodyWeight)
                
                timeLeft.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftBodyWeight)])
                
                timeLeft.attributedText = timeLeft.text!.addingFontToBeginning(text: "Remind In: ", font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight))
            }
        }
    }
}
