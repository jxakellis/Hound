//
//  DogsMainScreenTableViewCellRequirement.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellRequirementDisplayDelegate {
    func didToggleRequirementSwitch(sender: Sender, parentDogName: String, requirementName: String, isEnabled: Bool)
}

class DogsMainScreenTableViewCellRequirementDisplay: UITableViewCell {
    
    //MARK: IB
    
    @IBOutlet weak var requirementName: UILabel!
    @IBOutlet weak var timeInterval: UILabel!
    @IBOutlet weak var requirementToggleSwitch: UISwitch!
    
    //When the on off switch is toggled
    @IBAction func didToggleRequirementSwitch(_ sender: Any) {
        delegate.didToggleRequirementSwitch(sender: Sender(origin: self, localized: self), parentDogName: self.parentDogName, requirementName: requirement.requirementName, isEnabled: self.requirementToggleSwitch.isOn)
    }
    
    //MARK:  Properties
    var requirement: Requirement = Requirement()
    
    var parentDogName: String = ""
    
    var delegate: DogsMainScreenTableViewCellRequirementDisplayDelegate! = nil
    
    //MARK: Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.requirementName.adjustsFontSizeToFitWidth = true
        self.timeInterval.adjustsFontSizeToFitWidth = true
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
        self.requirementName.text = requirementPassed.requirementName
        
        if requirement.timingStyle == .countDown {
            self.timeInterval.text = ("Every \(String.convertToReadable(interperateTimeInterval: requirement.countDownComponents.executionInterval))")
        }
        else {
            try! self.timeInterval.text = ("\(String.convertToReadable(interperatedDateComponents: requirement.timeOfDayComponents.timeOfDayComponent))")
            
            if requirement.timeOfDayComponents.weekdays == [1,2,3,4,5,6,7]{
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
                if requirement.timeOfDayComponents.weekdays.count == 1 {
                    for weekdayInt in requirement.timeOfDayComponents.weekdays{
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
                    for weekdayInt in requirement.timeOfDayComponents.weekdays{
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
    }
    
}
