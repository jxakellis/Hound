//
//  DogsMainScreenTableViewCellRequirement.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellRequirementDisplayDelegate {
    func didToggleRequirementSwitch(sender: Sender, parentDogName: String, requirementUUID: String, isEnabled: Bool)
}

class DogsMainScreenTableViewCellRequirementDisplay: UITableViewCell {
    
    //MARK: - IB
    
    @IBOutlet private weak var requirementChevron: UIImageView!
    
    @IBOutlet private weak var requirementIcon: UIImageView!
    
    @IBOutlet private weak var requirementType: CustomLabel!
    @IBOutlet private weak var timeInterval: CustomLabel!
    
    @IBOutlet private weak var timeLeft: CustomLabel!
    @IBOutlet weak var requirementToggleSwitch: UISwitch!
    
    //When the on off switch is toggled
    @IBAction private func didToggleRequirementSwitch(_ sender: Any) {
        delegate.didToggleRequirementSwitch(sender: Sender(origin: self, localized: self), parentDogName: self.parentDogName, requirementUUID: requirement.uuid, isEnabled: self.requirementToggleSwitch.isOn)
    }
    
    //MARK: -  Properties
    private var requirement: Requirement = Requirement()
    
    private var parentDogName: String = ""
    
    var delegate: DogsMainScreenTableViewCellRequirementDisplayDelegate! = nil
    
    //MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //requirementChevron.tintColor = ColorConstant.gray.rawValue
        //requirementChevron.alpha = 1
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //Setup function that sets up the different IBOutlet properties
    func setup(parentDogName: String, requirementPassed: Requirement){
        self.parentDogName = parentDogName
        self.requirement = requirementPassed
        self.requirementType.text = requirementPassed.requirementType.rawValue
        
        if requirement.timingStyle == .countDown {
            self.requirementIcon.image = UIImage.init(systemName: "timer")
            self.timeInterval.text = ("Every \(String.convertToReadable(interperateTimeInterval: requirement.countDownComponents.executionInterval))")
        }
        else {
            self.requirementIcon.image = UIImage.init(systemName: "alarm")
            try! self.timeInterval.text = ("\(String.convertToReadable(interperatedDateComponents: requirement.timeOfDayComponents.timeOfDayComponent))")
            
            //day of month
            if requirement.timeOfDayComponents.dayOfMonth != nil {
                let dayOfMonth: Int! = requirement.timeOfDayComponents.dayOfMonth
                timeInterval.text?.append(" Every Month on \(dayOfMonth!)")
                if dayOfMonth == 1{
                    timeInterval.text?.append("st")
                }
                else if dayOfMonth == 2 {
                    timeInterval.text?.append("nd")
                }
                else if dayOfMonth == 3 {
                    timeInterval.text?.append("rd")
                }
                else {
                    timeInterval.text?.append("th")
                }
            }
            //weekdays
            else if requirement.timeOfDayComponents.weekdays == [1,2,3,4,5,6,7]{
                timeInterval.text?.append(" Everyday")
            }
            else if requirement.timeOfDayComponents.weekdays == [1,7]{
                timeInterval.text?.append(" on Weekends")
            }
            else if requirement.timeOfDayComponents.weekdays == [2,3,4,5,6]{
                timeInterval.text?.append(" on Weekdays")
            }
            else {
                timeInterval.text?.append(" on")
                if requirement.timeOfDayComponents.weekdays!.count == 1 {
                    for weekdayInt in requirement.timeOfDayComponents.weekdays!{
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
                    for weekdayInt in requirement.timeOfDayComponents.weekdays!{
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
        
        self.requirementToggleSwitch.isOn = requirementPassed.getEnable()
        
        setupTimeLeftText()
    }
    
    
    func reloadCell(){
        setupTimeLeftText()
    }
    
    private func setupTimeLeftText(){
        
        let timeLeftBodyWeight: UIFont.Weight = .regular
        let timeLeftImportantWeight: UIFont.Weight = .semibold
        
        if requirement.getEnable() == false {
            timeLeft.attributedText = NSAttributedString(string: "Reminder Disabled", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
        }
        else if TimingManager.isPaused == true {
            
            timeLeft.attributedText = NSAttributedString(string: "Paused", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
            
        }
        else{
            let fireDate: Date? = requirement.executionDate!
            
            if fireDate == nil {
                timeLeft.attributedText = NSAttributedString(string: "Reminder Disabled", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
            }
            else if Date().distance(to: fireDate!) <= 0 {
                timeLeft.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: timeLeftImportantWeight)])
            }
            else if requirement.snoozeComponents.isSnoozed == true {
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
