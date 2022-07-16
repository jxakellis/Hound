//
//  LogsBodyWithIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsBodyWithIconTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var dogIconImageView: UIImageView!
    
    @IBOutlet private weak var logDateLabel: ScaledUILabel!
    @IBOutlet private weak var logDateTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logDateBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logDateHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logActionLabel: ScaledUILabel!
    @IBOutlet private weak var familyMemberNameLabel: ScaledUILabel!
    @IBOutlet private weak var logNoteLabel: ScaledUILabel!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(forParentDogIcon parentDogIcon: UIImage, forLog log: Log) {
        
        let familyMemberThatLogged = FamilyMember.findFamilyMember(forUserId: log.userId)
        familyMemberNameLabel.text = familyMemberThatLogged?.displayFirstName ?? "Unknown⚠️"
        
        let fontSize = VisualConstant.FontConstant.logCellFontSize
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        
        familyMemberNameLabel.font = familyMemberNameLabel.font.withSize(fontSize * sizeRatio)
        logDateTopConstraint.constant = 5.0 * sizeRatio
        logDateBottomConstraint.constant = 5.0 * sizeRatio
        logDateHeightConstraint.constant = 25.0 * sizeRatio
        
        logActionLabel.font =  logActionLabel.font.withSize(fontSize * sizeRatio)
        logDateLabel.font =  logDateLabel.font.withSize(fontSize * sizeRatio)
        logNoteLabel.font =  logNoteLabel.font.withSize(fontSize * sizeRatio)
        
        // setup the icon afterwards otherwise the cornerRadius could be wrong since its dependent on the sizeRatio code above
        let cellHeight = logDateTopConstraint.constant + logDateBottomConstraint.constant + logDateHeightConstraint.constant
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
