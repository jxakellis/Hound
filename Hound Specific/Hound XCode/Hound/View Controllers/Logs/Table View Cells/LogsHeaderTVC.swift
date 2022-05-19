//
//  LogsHeaderTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsHeaderTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var headerLabel: ScaledUILabel!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var filterImageView: UIImageView!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(fromDate date: Date?, shouldShowFilterIndictator: Bool) {
        
        if date == nil {
            headerLabel.text = "No Logs Recorded"
        }
        else {
            let currentYear = Calendar.current.component(.year, from: Date())
            let dateYear = Calendar.current.component(.year, from: date!)
            
            // today
            if Calendar.current.isDateInToday(date!) {
                headerLabel.text = "Today"
            }
            // yesterday
            else if Calendar.current.isDateInYesterday(date!) {
                headerLabel.text = "Yesterday"
            }
            else if Calendar.current.isDateInTomorrow(date!) {
                headerLabel.text = "Tomorrow"
            }
            // this year
            else if currentYear == dateYear {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d", options: 0, locale: Calendar.current.locale)
                headerLabel.text = dateFormatter.string(from: date!)
            }
            // previous year or even older
            else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d, yyyy", options: 0, locale: Calendar.current.locale)
                headerLabel.text = dateFormatter.string(from: date!)
            }
        }
        
        var sizeRatio: Double!
        switch UserConfiguration.logsInterfaceScale {
        case .small:
            sizeRatio = 1.0
        case .medium:
            sizeRatio = 1.25
        case .large:
            sizeRatio = 1.5
        }
        
        headerLabel.font =  headerLabel.font.withSize(20.0 * sizeRatio)
        headerTopConstraint.constant = 5.0 * sizeRatio
        headerBottomConstraint.constant = 5.0 * sizeRatio
        headerHeightConstraint.constant = 30.0 * sizeRatio
        
        filterImageView.isHidden = !shouldShowFilterIndictator
    }
    
}