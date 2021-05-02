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
    @IBOutlet private weak var logName: CustomLabel!
    @IBOutlet private weak var logDate: CustomLabel!
    @IBOutlet private weak var logNote: CustomLabel!
    
    //MARK: - Properties
    
    private var parentDogNameSource: String! = nil
    private var logNameSource: String! = nil
    private var logSource: RequirementLog! = nil
    private var isArbitrary: Bool! = nil
    
    //MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(isArbitrary: Bool, log logSource: RequirementLog, parentDogName: String, logName: String){
        self.logSource = logSource
        self.logNameSource = logName
        self.parentDogNameSource = parentDogName
        self.isArbitrary = isArbitrary
        
        self.dogName.text = parentDogName
        self.logName.text = logName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        logDate.text = dateFormatter.string(from: logSource.date)
        
        logNote.text = logSource.note

        for label in [dogName, self.logName, logDate, logNote]{
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
        
        let logNameTextWidth = self.logName.text!.boundingFrom(font: self.logName.font, height: self.logName.frame.height).width
        let logNameWidthConstaint = NSLayoutConstraint.init(item: self.logName!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: logNameTextWidth)
        labelWidthConstraints.append(logNameWidthConstaint)
        
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
