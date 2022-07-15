//
//  DropDownLogFilterTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/2/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DropDownLogFilterTableViewCell: DropDownTableViewCell {
    
    // MARK: Properties
    
    var dogId: Int?
    
    var logAction: LogAction?
    
    // MARK: Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Functions
    
    func setup(forDog dog: Dog?, forLogAction logAction: LogAction?) {
        adjustLeadingTrailing(newConstant: DropDownUIView.insetForLogFilter)
        
        self.dogId = dog?.dogId
        self.logAction = logAction
        
        // first: try dog log setup
        if logAction != nil {
            label.attributedText = NSAttributedString(string: logAction!.rawValue, attributes: [.font: FontConstant.filterByLogFont])
        }
        // second: try dog setup
        else if dogId != nil {
            label.attributedText = NSAttributedString(string: dog!.dogName, attributes: [.font: FontConstant.filterByDogFont])
        }
        // last: no dog or log action
        else {
            label.attributedText = NSAttributedString(string: "Clear Filter", attributes: [.font: FontConstant.filterByDogFont])
        }
    }
}
