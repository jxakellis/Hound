//
//  LogsBodyWithoutIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsBodyWithoutIconTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var dogNameLabel: ScaledUILabel!
    @IBOutlet private weak var dogNameTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logActionLabel: ScaledUILabel!
    @IBOutlet private weak var logDateLabel: ScaledUILabel!
    @IBOutlet private weak var logNoteLabel: ScaledUILabel!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(forParentDogName dogName: String, forLog log: Log) {
        
        self.dogNameLabel.text = dogName
        
        var sizeRatio: Double!
        switch UserConfiguration.logsInterfaceScale {
        case .small:
            sizeRatio = 1.0
        case .medium:
            sizeRatio = 1.25
        case .large:
            sizeRatio = 1.5
        }
        
        dogNameLabel.font =  dogNameLabel.font.withSize(15.0 * sizeRatio)
        dogNameTopConstraint.constant = 5.0 * sizeRatio
        dogNameBottomConstraint.constant = 5.0 * sizeRatio
        dogNameHeightConstraint.constant = 25.0 * sizeRatio
        
        logActionLabel.font =  logActionLabel.font.withSize(15.0 * sizeRatio)
        logDateLabel.font =  logDateLabel.font.withSize(15.0 * sizeRatio)
        logNoteLabel.font =  logNoteLabel.font.withSize(15.0 * sizeRatio)
        
        self.logActionLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName, isShowingAbreviatedCustomActionName: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        logDateLabel.text = dateFormatter.string(from: log.logDate)
        
        logNoteLabel.text = log.logNote
        
    }
    
}
