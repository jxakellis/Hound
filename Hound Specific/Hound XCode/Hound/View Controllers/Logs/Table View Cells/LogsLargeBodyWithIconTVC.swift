//
//  LogsLargeBodyWithDogIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsLargeBodyWithDogIconTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var dogIconImageView: UIImageView!
    @IBOutlet private weak var logActionLabel: ScaledUILabel!
    @IBOutlet private weak var logDateLabel: ScaledUILabel!
    @IBOutlet private weak var logNoteLabel: ScaledUILabel!

   // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(forParentDogIcon parentDogIcon: UIImage, forLog log: Log) {
        
        dogIconImageView.image = parentDogIcon
        dogIconImageView.layer.masksToBounds = true
        dogIconImageView.layer.cornerRadius = dogIconImageView.frame.width/2

        self.logActionLabel.text = log.displayActionName

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        logDateLabel.text = dateFormatter.string(from: log.logDate)

        logNoteLabel.text = log.logNote

    }

}
