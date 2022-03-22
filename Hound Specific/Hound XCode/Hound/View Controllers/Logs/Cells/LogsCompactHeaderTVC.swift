//
//  LogsMainScreenTableViewCellHeader.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsCompactHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var header: ScaledUILabel!

    @IBOutlet private weak var filterIndicator: UIImageView!

    // MARK: - Properties

    private var logSource: Log?

    // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /*
     //https://nsdateformatter.com/ "EEEE, MMMM d, yyyy"
     //DateFormatter().dateStyle = "full"
     //DateFormatter().timeStyle = "none"
     //https://stackoverflow.com/questions/24100855/set-a-datestyle-in-swift
     */

    func willShowFilterIndicator(isHidden: Bool) {
        if isHidden == false {
            for constraint in filterIndicator.constraints where constraint.firstAttribute == .height {
                constraint.constant = 30
            }
            // filterIndicator.image = filterIndicator.image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 30.0))
            filterIndicator.isHidden = false
        }
        else {
            for constraint in filterIndicator.constraints where constraint.firstAttribute == .height {
                constraint.constant = 0
            }
            // filterIndicator.image = filterIndicator.image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 0.0))
            filterIndicator.isHidden = true
        }
    }

    func setup(log logSource: Log?, showFilterIndicator: Bool) {

        willShowFilterIndicator(isHidden: !showFilterIndicator)

        if showFilterIndicator {
            for constraint in filterIndicator.constraints where constraint.firstAttribute == .height {
                constraint.constant = 30
            }
            // filterIndicator.image = filterIndicator.image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 30.0))
            filterIndicator.isHidden = false
        }
        else {
            for constraint in filterIndicator.constraints where constraint.firstAttribute == .height {
                constraint.constant = 0
            }
            // filterIndicator.image = filterIndicator.image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 0.0))
            filterIndicator.isHidden = true
        }
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()

        self.logSource = logSource
                if logSource == nil {
            header.text = "No Logs Recorded"
        }
        else {
            let dateSource = logSource!.date

            let currentYearComponent = Calendar.current.component(.year, from: Date())
            let dateSourceYearComponent = Calendar.current.component(.year, from: dateSource)

            // today
            if Calendar.current.isDateInToday(dateSource) {
                header.text = "Today"
            }
            // yesterday
            else if Calendar.current.isDateInYesterday(dateSource) {
                header.text = "Yesterday"
            }
            else if Calendar.current.isDateInTomorrow(dateSource) {
                header.text = "Tomorrow"
            }
            // this year
            else if currentYearComponent == dateSourceYearComponent {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d", options: 0, locale: Calendar.current.locale)
                header.text = dateFormatter.string(from: dateSource)
            }
            // previous year or even older
            else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d, yyyy", options: 0, locale: Calendar.current.locale)
                header.text = dateFormatter.string(from: dateSource)
            }
        }
    }

}
