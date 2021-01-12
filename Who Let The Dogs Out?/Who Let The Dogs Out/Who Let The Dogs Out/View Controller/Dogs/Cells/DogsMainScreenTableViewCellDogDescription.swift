//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsMainScreenTableViewCellDogDescription: UITableViewCell {
    
    
    @IBOutlet weak var dogName: UILabel!
    
    @IBOutlet weak var dogDescription: UILabel!
    
    @IBOutlet weak var dogTimeInterval: UILabel!
    
    @IBOutlet weak var dogToggleSwitch: UISwitch!
    
    @IBAction func dogSwitchToggled(_ sender: Any) {
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
