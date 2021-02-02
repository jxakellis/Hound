//
//  DogsMainScreenTableViewCellDogRequirement.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellDogRequirementDelegate {
    func requirementSwitchToggled(parentDogName: String, requirementName: String, isEnabled: Bool)
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
    @IBAction func switchToggled(_ sender: Any) {
        delegate.requirementSwitchToggled(parentDogName: self.parentDogName, requirementName: requirement.label, isEnabled: self.switch.isOn)
    }
    
    //MARK: General Functions
    
    //Setup function that sets up the different IBOutlet properties
    func requirementSetup(parentDogName: String, requirementPassed: Requirement){
        self.parentDogName = parentDogName
        self.requirement = requirementPassed
        self.requirementName.text = requirementPassed.label
        self.timeInterval.text = convertTimeIntervalToReadable(interperateTimeInterval: requirementPassed.interval)
    }
    
    //MARK: Private functions
    
    //Converts a time interval to a readable string e.g. TimeInterval(3600) -> 1 Hour 0 Minutes
    private func convertTimeIntervalToReadable(interperateTimeInterval: TimeInterval) -> String {
        let intTime = Int(interperateTimeInterval.rounded())
        
        let numHours = Int(intTime / 3600)
        let numMinutes = Int((intTime % 3600)/60)
        if numHours == 0 {
            return "\(numMinutes) Minutes"
        }
        else if (numHours > 1 && numMinutes > 1){
            return "\(numHours) Hours \(numMinutes) Minutes"
        }
        else if numHours > 1 && numMinutes == 1 {
            return "\(numHours) Hours \(numMinutes) Minute"
        }
        else if numHours == 1 && numMinutes > 1 {
            return "\(numHours) Hour \(numMinutes) Minutes"
        }
        else{
            return "\(numHours) Hour \(numMinutes) Minute"
        }
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
