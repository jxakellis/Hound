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
        
        if requirementPassed.timingStyle == .countDown {
        self.timeInterval.text = "Every \(String.convertToReadable(interperateTimeInterval: requirementPassed.countDownComponents.executionInterval))"
        }
        else {
            try! self.timeInterval.text = String.convertToReadable(interperatedDateComponents: requirementPassed.timeOfDayComponents.timeOfDayComponent)
        }
        self.requirementToggleSwitch.isOn = requirementPassed.getEnable()
    }
    
}
