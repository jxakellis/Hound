//
//  LogsMainScreenTableViewCellBody.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsMainScreenTableViewCellBody: UITableViewCell {

    
    //MARK: - IB
    
    @IBOutlet private weak var dogName: CustomLabel!
    @IBOutlet private weak var requirementName: CustomLabel!
    @IBOutlet private weak var dateDescription: CustomLabel!
    
    //MARK: - Properties
    
    private var parentDogName: String! = nil
    private var requirementSource: Requirement! = nil
    private var logSource: RequirementLog! = nil
    
    //MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(log logSource: RequirementLog, parentDogName: String, requirement: Requirement){
        self.logSource = logSource
        self.requirementSource = requirement
        self.parentDogName = parentDogName
        
        self.dogName.text = parentDogName
        self.requirementName.text = requirement.requirementName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        dateDescription.text = dateFormatter.string(from: logSource.date)
        
        if logSource.note.trimmingCharacters(in: .whitespaces) != "" {
            dateDescription.text?.append(" - \(logSource.note)")
        }
        
        dogName.frame = CGRect(origin: dogName.frame.origin,
                               size: dogName.text!.boundingFrom(font: dogName.font, height: dogName.frame.height))
        requirementName.frame = CGRect(origin: requirementName.frame.origin,
                                            size: requirementName.text!.boundingFrom(font: requirementName.font, height: requirementName.frame.height))
        
    }

    
}
