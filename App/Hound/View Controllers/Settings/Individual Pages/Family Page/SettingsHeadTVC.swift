//
//  SettingsFamilyHeadTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyHeadTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var fullNameLabel: ScaledUILabel!
    
    // MARK: - Properties
    
    var userId: String!
    
    // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    func setup(forDisplayFullName displayFullName: String, userId: String) {
        self.userId = userId
        
        fullNameLabel.text = displayFullName
    }

}
