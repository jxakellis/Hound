//
//  DogsMainScreenTableViewCellDogRequirement.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellDogRequirementDelegate {
    func didToggleRequirementSwitch(parentDogName: String, requirementName: String, isEnabled: Bool)
    func didClickTrash(parentDogName: String, requirementName: String)
}

class DogsMainScreenTableViewCellDogRequirement: UITableViewCell {
    
    
    //MARK:  Properties
    var requirement: Requirement = Requirement()
    
    var parentDogName: String = ""
    
    var delegate: DogsMainScreenTableViewCellDogRequirementDelegate! = nil
    
    //MARK: IB Link
    
    @IBOutlet weak var requirementName: UILabel!
    @IBOutlet weak var timeInterval: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    //When the on off switch is toggled
    @IBAction func didToggleRequirementSwitch(_ sender: Any) {
        delegate.didToggleRequirementSwitch(parentDogName: self.parentDogName, requirementName: requirement.label, isEnabled: self.switch.isOn)
    }
    @IBAction func didClickTrash(_ sender: Any) {
        delegate.didClickTrash(parentDogName: self.parentDogName, requirementName: requirement.label)
    }
    
    //MARK: General Functions
    
    //Setup function that sets up the different IBOutlet properties
    func requirementSetup(parentDogName: String, requirementPassed: Requirement){
        self.parentDogName = parentDogName
        self.requirement = requirementPassed
        self.requirementName.text = requirementPassed.label
        self.timeInterval.text = String.convertTimeIntervalToReadable(interperateTimeInterval: requirementPassed.interval)
    }
    
    //MARK: Default Functionality
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
