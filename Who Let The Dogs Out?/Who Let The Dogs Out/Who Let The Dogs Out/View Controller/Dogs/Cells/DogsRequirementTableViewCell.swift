//
//  DogsRequirementTableViewCell.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
protocol DogsRequirementTableViewCellDelegate {
    //func didClickTrash(requiremntName: String)
    func didToggleEnable(sender: Sender, requirementName: String, newEnableStatus: Bool)
}


class DogsRequirementTableViewCell: UITableViewCell {
    
    var delegate: DogsRequirementTableViewCellDelegate! = nil
    
    @IBOutlet private weak var requirementTimeInterval: UILabel!
    @IBOutlet private weak var requirementName: UILabel!
    @IBOutlet private weak var requirementEnableStatus: UISwitch!
    
    /*
    //When the trash button icon is clicked it executes this func, thru delegate finds a requirement with a matching name and then deletes it (handled elsewhere tho)
    @IBAction private func didClickTrash(_ sender: Any) {
        delegate.didClickTrash(dogName: name.text!)
    }
     */
    
    @IBAction func didToggleEnable(_ sender: Any) {
        delegate.didToggleEnable(sender: Sender(origin: self, localized: self), requirementName: self.requirementName.text!, newEnableStatus: self.requirementEnableStatus.isOn)
    }
    
    func setup(requirement: Requirement){
        self.requirementName.text = requirement.requirementName
        self.requirementTimeInterval.text = String.convertTimeIntervalToReadable(interperateTimeInterval: requirement.countDownComponents.executionInterval)
        self.requirementEnableStatus.isOn = requirement.getEnable()
        
    }
    
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
    
}
