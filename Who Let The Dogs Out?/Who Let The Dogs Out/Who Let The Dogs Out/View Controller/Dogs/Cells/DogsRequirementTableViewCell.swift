//
//  DogsRequirementTableViewCell.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
protocol DogsRequirementTableViewCellDelegate {
    func didToggleEnable(sender: Sender, requirementName: String, newEnableStatus: Bool)
}


class DogsRequirementTableViewCell: UITableViewCell {
    
    //MARK: IB
    
    @IBOutlet private weak var requirementTimeInterval: UILabel!
    @IBOutlet private weak var requirementName: UILabel!
    @IBOutlet private weak var requirementEnableStatus: UISwitch!
    
    @IBAction func didToggleEnable(_ sender: Any) {
        delegate.didToggleEnable(sender: Sender(origin: self, localized: self), requirementName: self.requirementName.text!, newEnableStatus: self.requirementEnableStatus.isOn)
    }
    
    //MARK: Properties
    
    var delegate: DogsRequirementTableViewCellDelegate! = nil
    
    //MARK: Main
    
    //when cell is awoken / init, this is executed
    override func awakeFromNib() {
        super.awakeFromNib()
        requirementTimeInterval.adjustsFontSizeToFitWidth = true
        requirementName.adjustsFontSizeToFitWidth = true
        // Initialization code
        self.contentMode = .center
        self.imageView?.contentMode = .center
    }
    
    //when the cell is selected, code is run, currently unconfigured
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setup(requirement: Requirement){
        self.requirementName.text = requirement.requirementName
        if requirement.timingStyle == .countDown {
        self.requirementTimeInterval.text = "Every \(String.convertToReadable(interperateTimeInterval: requirement.countDownComponents.executionInterval))"
        }
        else {
            try! self.requirementTimeInterval.text = String.convertToReadable(interperatedDateComponents: requirement.timeOfDayComponents.timeOfDayComponent)
        }
        self.requirementEnableStatus.isOn = requirement.getEnable()
        
    }
    
}
