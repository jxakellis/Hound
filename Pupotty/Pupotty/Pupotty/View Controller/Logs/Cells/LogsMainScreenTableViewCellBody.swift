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
    @IBOutlet private weak var logType: CustomLabel!
    @IBOutlet private weak var logDate: CustomLabel!
    @IBOutlet private weak var logNote: CustomLabel!
    
    //MARK: - Properties
    
    private var parentDogNameSource: String! = nil
    private var requirementSource: Requirement? = nil
    private var logSource: KnownLog! = nil
    
    //MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(parentDogName: String, requirement: Requirement?, log logSource: KnownLog){
        self.parentDogNameSource = parentDogName
        self.logSource = logSource
        self.requirementSource = requirement
        
        self.dogName.text = parentDogName
        self.logType.text = self.logSource.logType.rawValue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        logDate.text = dateFormatter.string(from: logSource.date)
        
        logNote.text = logSource.note

        for label in [dogName, self.logType, logDate, logNote]{
            var constraintsToDeactivate: [NSLayoutConstraint] = []
            
            for constraintIndex in 0..<label!.constraints.count{
                if label!.constraints[constraintIndex].firstAttribute == .width{
                    constraintsToDeactivate.append(label!.constraints[constraintIndex])
                }
            }
            
            NSLayoutConstraint.deactivate(constraintsToDeactivate)
        }
        
        var labelWidthConstraints: [NSLayoutConstraint] = []
        
        let dogNameTextWidth = dogName.text!.boundingFrom(font: dogName.font, height: dogName.frame.height).width
        let dogNameWidthConstraint = NSLayoutConstraint.init(item: dogName!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: dogNameTextWidth)
        labelWidthConstraints.append(dogNameWidthConstraint)
        
        let logTypeTextWidth = self.logType.text!.boundingFrom(font: self.logType.font, height: self.logType.frame.height).width
        let logTypeWidthConstaint = NSLayoutConstraint.init(item: self.logType!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: logTypeTextWidth)
        labelWidthConstraints.append(logTypeWidthConstaint)
        
        let logDateTextWidth = logDate.text!.boundingFrom(font: logDate.font, height: logDate.frame.height).width
        let logDateWidthConstraint = NSLayoutConstraint.init(item: logDate!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: logDateTextWidth)
        labelWidthConstraints.append(logDateWidthConstraint)
        
        if logNote.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            let logNoteWidthConstraint = NSLayoutConstraint.init(item: logNote!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0)
            labelWidthConstraints.append(logNoteWidthConstraint)
        }
        
        NSLayoutConstraint.activate(labelWidthConstraints)
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
    }

    
}
