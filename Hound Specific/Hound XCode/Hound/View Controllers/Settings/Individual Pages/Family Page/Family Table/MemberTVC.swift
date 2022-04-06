//
//  SettingsFamilyMemberTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsFamilyMemberTableViewCell: UITableViewCell {

    // MARK: - IB
    
    @IBOutlet private weak var fullName: ScaledUILabel!
    
    // MARK: - Properties
    
    var userId: Int!
    
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
    
    func setup(firstName: String, lastName: String, userId: Int) {
        self.userId = userId
        
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // check to see if anything is blank
        if trimmedFirstName == "" && trimmedLastName == "" {
            fullName.text = "No Name"
        }
        else if trimmedFirstName == "" {
            // no first name but has last name
            fullName.text = trimmedLastName
        }
        else if trimmedLastName == "" {
            // no last name but has first name
            fullName.text = trimmedFirstName
        }
        else {
            fullName.text = "\(trimmedFirstName) \(trimmedLastName)"
        }
    }

}
