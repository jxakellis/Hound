//
//  LogsBodyWithIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsBodyWithIconTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var dogIconImageView: UIImageView!
    
    @IBOutlet private weak var userInitalsLabel: ScaledUILabel!
    @IBOutlet private weak var userInitalsTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var userInitalsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var userInitalsHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logActionLabel: ScaledUILabel!
    
    @IBOutlet private weak var logDateLabel: ScaledUILabel!
    @IBOutlet private weak var logNoteLabel: ScaledUILabel!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(forParentDogIcon parentDogIcon: UIImage, forLog log: Log) {
        
        let familyMemberThatLogged = FamilyConfiguration.familyMembers.first { familyMember in
            if familyMember.userId == log.userId {
                return true
            }
            else {
                return false
            }
        }
        self.userInitalsLabel.text = familyMemberThatLogged?.displayInitals ?? "UKN⚠️"
        
        var sizeRatio: Double!
        switch UserConfiguration.logsInterfaceScale {
        case .small:
            sizeRatio = 1.0
        case .medium:
            sizeRatio = 1.2
        case .large:
            sizeRatio = 1.4
        }
        
        userInitalsLabel.font = userInitalsLabel.font.withSize(15.0 * sizeRatio)
        userInitalsTopConstraint.constant = 5.0 * sizeRatio
        userInitalsBottomConstraint.constant = 5.0 * sizeRatio
        userInitalsHeightConstraint.constant = 25.0 * sizeRatio
        
        logActionLabel.font =  logActionLabel.font.withSize(15.0 * sizeRatio)
        
        logDateLabel.font =  logDateLabel.font.withSize(15.0 * sizeRatio)
        logNoteLabel.font =  logNoteLabel.font.withSize(15.0 * sizeRatio)
        
        // setup the icon afterwards otherwise the cornerRadius could be wrong since its dependent on the sizeRatio code above
        let cellHeight = userInitalsTopConstraint.constant + userInitalsBottomConstraint.constant + userInitalsHeightConstraint.constant
        let dogIconImageViewHeight = cellHeight - 2.5 - 2.5
        dogIconImageView.image = parentDogIcon
        dogIconImageView.layer.masksToBounds = true
        // we can't use dogIconImageView.frame.height/2 because if isCompactView is changed and this cell is reloaded, then dogIconImageView.frame is still the same as its old value at this point. That means the corner radius will be incorrect (large corner radius for compact cell and compact corner radius for large cell)
        dogIconImageView.layer.cornerRadius = dogIconImageViewHeight/2
        
        self.logActionLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName, isShowingAbreviatedCustomActionName: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        logDateLabel.text = dateFormatter.string(from: log.logDate)
        
        logNoteLabel.text = log.logNote
        
    }
    
}
