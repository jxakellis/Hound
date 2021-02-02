//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellDogDescriptionDelegate{
    func dogSwitchToggled(dogName: String, isEnabled: Bool)
}

class DogsMainScreenTableViewCellDogDescription: UITableViewCell {
    
    let delegate: DogsMainScreenTableViewCellDogDescriptionDelegate! = nil
    
    @IBOutlet weak var dogName: UILabel!
    
    @IBOutlet weak var dogDescription: UILabel!
    
    @IBOutlet weak var dogToggleSwitch: UISwitch!
    
    @IBAction func dogSwitchToggled(_ sender: Any) {
        delegate.dogSwitchToggled(dogName: dogName.text!, isEnabled: dogToggleSwitch.isOn)
    }
    
    convenience init(dogName: String, dogDescription: String, dogEnabled: Bool){
        self.init()
        self.dogName.text = dogName
        self.dogDescription.text = dogDescription
        self.dogToggleSwitch.isOn = dogEnabled
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
