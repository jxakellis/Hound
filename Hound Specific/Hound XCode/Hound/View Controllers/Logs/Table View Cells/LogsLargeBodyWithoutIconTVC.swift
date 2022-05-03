//
//  LogsLargeBodyWithoutdogIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsLargeBodyWithoutDogIconTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var dogNameLabel: ScaledUILabel!
    @IBOutlet private weak var logActionLabel: ScaledUILabel!
    @IBOutlet private weak var logDateLabel: ScaledUILabel!
    @IBOutlet private weak var logNoteLabel: ScaledUILabel!

    // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(forParentDogName parentDogName: String, forLog log: Log) {
        dogNameLabel.text = parentDogName
        logActionLabel.text = log.displayActionName

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        logDateLabel.text = dateFormatter.string(from: log.logDate)
        
        logNoteLabel.text = log.logNote
    }

}
