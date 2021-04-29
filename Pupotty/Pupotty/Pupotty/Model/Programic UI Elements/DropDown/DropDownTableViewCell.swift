//
//  DropDownTableViewCell.swift
//  MakeDropDown
//
//  Created by ems on 02/05/19.
//  Copyright © 2019 Majesco. All rights reserved.
//

import UIKit

class DropDownTableViewCell: UITableViewCell {

    @IBOutlet weak var requirementName: UILabel!
    
    @IBOutlet private weak var coveringView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func didToggleSelect(newSelectionStatus: Bool){
        if newSelectionStatus == true {
            coveringView.backgroundColor = .systemBlue
            requirementName.textColor = .white
        }
        else {
            coveringView.backgroundColor = .white
            requirementName.textColor = .label
        }
        
    }
    
}
