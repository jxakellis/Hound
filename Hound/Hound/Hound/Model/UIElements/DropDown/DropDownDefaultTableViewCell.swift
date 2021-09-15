//
//  DropDownParentDogTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DropDownDefaultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet private weak var leading: NSLayoutConstraint!
    
    @IBOutlet private weak var trailing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    func adjustLeadingTrailing(newConstant: CGFloat){
        leading.constant = newConstant
        trailing.constant = newConstant
    }
    
    func didToggleSelect(newSelectionStatus: Bool){
        if newSelectionStatus == true {
            contentView.backgroundColor = .systemBlue
            label.textColor = .white
        }
        else {
            contentView.backgroundColor = .systemBackground
            label.textColor = .label
        }
        
    }

}
