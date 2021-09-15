//
//  DogsRequirementTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
protocol DogsRequirementTableViewCellDelegate {
    func didToggleEnable(sender: Sender, requirementUUID: String, newEnableStatus: Bool)
}


class DogsRequirementTableViewCell: UITableViewCell {
    
    //MARK: - IB
    
    @IBOutlet private weak var requirementDisplay: UILabel!
    @IBOutlet private weak var requirementToggleSwitch: UISwitch!
    
    @IBAction func didToggleEnable(_ sender: Any) {
        delegate.didToggleEnable(sender: Sender(origin: self, localized: self), requirementUUID: requirementSource.uuid, newEnableStatus: self.requirementToggleSwitch.isOn)
    }
    
    //MARK: - Properties
    
    var delegate: DogsRequirementTableViewCellDelegate! = nil
    
    var requirementSource: Requirement! = nil
    
    //MARK: - Main
    
    //when cell is awoken / init, this is executed
    override func awakeFromNib() {
        super.awakeFromNib()
        requirementDisplay.adjustsFontSizeToFitWidth = true
        
        //self.contentMode = .center
        //self.imageView?.contentMode = .center
    }
    
    func setup(requirement: Requirement){
        requirementSource = requirement
        
        requirementDisplay.text = ""
        
        if requirement.timingStyle == .oneTime {
            try! self.requirementDisplay.text? = " \(String.convertToReadableNonRepeating(interperatedDateComponents: requirement.oneTimeComponents.dateComponents))"
        }
        else if requirement.timingStyle == .countDown {
            self.requirementDisplay.text?.append(" Every \(String.convertToReadable(interperateTimeInterval: requirement.countDownComponents.executionInterval))")
        }
        else {
            try! self.requirementDisplay.text?.append(" \(String.convertToReadable(interperatedDateComponents: requirement.timeOfDayComponents.timeOfDayComponent))")
            
            //day of month
            if requirement.timeOfDayComponents.dayOfMonth != nil {
                let dayOfMonth: Int! = requirement.timeOfDayComponents.dayOfMonth
                requirementDisplay.text?.append(" Every Month on \(dayOfMonth!)")
            
                requirementDisplay.text?.append(String.dayOfMonthSuffix(day: dayOfMonth))
            }
            //weekdays
            else if requirement.timeOfDayComponents.weekdays == [1,2,3,4,5,6,7]{
                requirementDisplay.text?.append(" Everyday")
            }
            else if requirement.timeOfDayComponents.weekdays == [1,7]{
                requirementDisplay.text?.append(" on Weekends")
            }
            else if requirement.timeOfDayComponents.weekdays == [2,3,4,5,6]{
                requirementDisplay.text?.append(" on Weekdays")
            }
            else {
                requirementDisplay.text?.append(" on")
                if requirement.timeOfDayComponents.weekdays!.count == 1 {
                    for weekdayInt in requirement.timeOfDayComponents.weekdays!{
                        switch weekdayInt {
                        case 1:
                            requirementDisplay.text?.append(" Sunday")
                        case 2:
                            requirementDisplay.text?.append(" Monday")
                        case 3:
                            requirementDisplay.text?.append(" Tuesday")
                        case 4:
                            requirementDisplay.text?.append(" Wednesday")
                        case 5:
                            requirementDisplay.text?.append(" Thursday")
                        case 6:
                            requirementDisplay.text?.append(" Friday")
                        case 7:
                            requirementDisplay.text?.append(" Saturday")
                        default:
                            requirementDisplay.text?.append("unknown")
                        }
                    }
                }
                else {
                    for weekdayInt in requirement.timeOfDayComponents.weekdays!{
                        switch weekdayInt {
                        case 1:
                            requirementDisplay.text?.append(" Su,")
                        case 2:
                            requirementDisplay.text?.append(" M,")
                        case 3:
                            requirementDisplay.text?.append(" Tu,")
                        case 4:
                            requirementDisplay.text?.append(" W,")
                        case 5:
                            requirementDisplay.text?.append(" Th,")
                        case 6:
                            requirementDisplay.text?.append(" F,")
                        case 7:
                            requirementDisplay.text?.append(" Sa,")
                        default:
                            requirementDisplay.text?.append("unknown")
                        }
                    }
                }
                //checks if extra comma, then removes
                if requirementDisplay.text?.last == ","{
                    requirementDisplay.text?.removeLast()
                }
            }
        }
        
        requirementDisplay.attributedText = requirementDisplay.text?.addingFontToBeginning(text: requirement.displayTypeName + " -", font: UIFont.systemFont(ofSize: requirementDisplay.font.pointSize, weight: .medium))
        
        self.requirementToggleSwitch.isOn = requirement.getEnable()
        
    }
    
}
