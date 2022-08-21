//
//  LogsBodyWithoutIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsBodyWithoutIconTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var dogNameLabel: ScaledUILabel!
    @IBOutlet private weak var dogNameTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var familyMemberNameLabel: ScaledUILabel!
    @IBOutlet private weak var logActionLabel: ScaledUILabel!
    @IBOutlet private weak var logDateLabel: ScaledUILabel!
    @IBOutlet private weak var logNoteLabel: ScaledUILabel!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // TO DO NOW if a log has a note, then make the table view cell "two lines", so that there is adequte space to display one line (probably 5-10 words) of a note
    }
    
    func setup(forParentDogName dogName: String, forLog log: Log) {
        
        self.dogNameLabel.text = dogName
        
        let fontSize = VisualConstant.FontConstant.logCellFontSize
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        
        dogNameLabel.font = dogNameLabel.font.withSize(fontSize * sizeRatio)
        dogNameTopConstraint.constant = 5.0 * sizeRatio
        dogNameBottomConstraint.constant = 5.0 * sizeRatio
        dogNameHeightConstraint.constant = 25.0 * sizeRatio
        
        familyMemberNameLabel.font = familyMemberNameLabel.font.withSize(fontSize * sizeRatio)
        logActionLabel.font = logActionLabel.font.withSize(fontSize * sizeRatio)
        logDateLabel.font = logDateLabel.font.withSize(fontSize * sizeRatio)
        logNoteLabel.font = logNoteLabel.font.withSize(fontSize * sizeRatio)
        
        familyMemberNameLabel.text = FamilyMember.findFamilyMember(forUserId: log.userId)?.displayFirstName ?? VisualConstant.TextConstant.unknownText
        
        self.logActionLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName, isShowingAbreviatedCustomActionName: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        logDateLabel.text = dateFormatter.string(from: log.logDate)
        
        logNoteLabel.text = log.logNote
        
    }
    
}
