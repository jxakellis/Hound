//
//  LogsMainScreenTableViewCellBody.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsMainScreenTableViewCellBodyRegularWithIcon: UITableViewCell {

    
    //MARK: - IB
    
    
    @IBOutlet private weak var logIcon: UIImageView!
    @IBOutlet private weak var logType: ScaledUILabel!
    @IBOutlet private weak var logDate: ScaledUILabel!
    @IBOutlet private weak var logNote: ScaledUILabel!
    
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
        
        let dog = try! MainTabBarViewController.staticDogManager.findDog(dogName: parentDogName)
        logIcon.image = dog.dogTraits.icon
        logIcon.layer.masksToBounds = true
        logIcon.layer.cornerRadius = logIcon.frame.width/2
        
        
        self.logType.text = self.logSource.displayTypeName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        logDate.text = dateFormatter.string(from: logSource.date)
        
        logNote.text = logSource.note

        //deactivate old
        for label in [self.logType, logDate, logNote]{
            var constraintsToDeactivate: [NSLayoutConstraint] = []
            
            for constraintIndex in 0..<label!.constraints.count{
                if label!.constraints[constraintIndex].firstAttribute == .width{
                    constraintsToDeactivate.append(label!.constraints[constraintIndex])
                }
            }
            
            NSLayoutConstraint.deactivate(constraintsToDeactivate)
        }
        
        var labelWidthConstraints: [NSLayoutConstraint] = []
        
        //create new
        for label in [self.logType, logDate]{
            let labelTextWidth = label!.text!.boundingFrom(font: label!.font, height: label!.frame.height).width
            let labelWidthConstraint = NSLayoutConstraint.init(item: label!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: labelTextWidth)
            labelWidthConstraints.append(labelWidthConstraint)
        }
        
        if logNote.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            let logNoteWidthConstraint = NSLayoutConstraint.init(item: logNote!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 35.0)
            labelWidthConstraints.append(logNoteWidthConstraint)
        }
        
        NSLayoutConstraint.activate(labelWidthConstraints)
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
    }

    
}
