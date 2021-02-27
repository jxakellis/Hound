//
//  DogsMainScreenTableViewCellDogRequirement.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellDogRequirementDisplayDelegate {
    func didToggleRequirementSwitch(parentDogName: String, requirementName: String, isEnabled: Bool)
    func didClickTrash(parentDogName: String, requirementName: String)
}

class DogsMainScreenTableViewCellDogRequirementDisplay: UITableViewCell {
    
    //MARK:  Properties
    var requirement: Requirement = Requirement()
    
    var parentDogName: String = ""
    
    var delegate: DogsMainScreenTableViewCellDogRequirementDisplayDelegate! = nil
    
    //MARK: IB Link
    
    @IBOutlet weak var requirementName: UILabel!
    @IBOutlet weak var timeInterval: UILabel!
    @IBOutlet weak var requirementToggleSwitch: UISwitch!
    
    //When the on off switch is toggled
    @IBAction func didToggleRequirementSwitch(_ sender: Any) {
        delegate.didToggleRequirementSwitch(parentDogName: self.parentDogName, requirementName: requirement.name, isEnabled: self.requirementToggleSwitch.isOn)
    }
    @IBAction func didClickTrash(_ sender: Any) {
        delegate.didClickTrash(parentDogName: self.parentDogName, requirementName: requirement.name)
    }
    
    //MARK: General Functions
    
    //Setup function that sets up the different IBOutlet properties
    func setup(parentDogName: String, requirementPassed: Requirement){
        self.parentDogName = parentDogName
        self.requirement = requirementPassed
        self.requirementName.text = requirementPassed.name
        if requirementPassed.executionInterval < 60 {
            self.timeInterval.text = String.convertTimeIntervalToReadable(interperateTimeInterval: requirementPassed.executionInterval)
        }
        else {
            self.timeInterval.text = String.convertTimeIntervalToReadable(interperateTimeInterval: requirementPassed.executionInterval)
        }
        self.requirementToggleSwitch.isOn = requirementPassed.getEnable()
    }
    
    //MARK: Default Functionality
    
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
    
}
