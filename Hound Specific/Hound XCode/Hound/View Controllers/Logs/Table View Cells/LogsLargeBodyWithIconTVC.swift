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

    @IBOutlet private weak var dogIcon: UIImageView!
    @IBOutlet private weak var logAction: ScaledUILabel!
    @IBOutlet private weak var logDate: ScaledUILabel!
    @IBOutlet private weak var logNote: ScaledUILabel!

    // MARK: - Properties

    private var parentDogIdSource: Int! = nil
    private var logSource: Log! = nil

    // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(parentDogId: Int, log logSource: Log) {
        self.parentDogIdSource = parentDogId
        self.logSource = logSource

        let dog = try! MainTabBarViewController.staticDogManager.findDog(forDogId: parentDogIdSource)
        dogIcon.image = dog.dogIcon
        dogIcon.layer.masksToBounds = true
        dogIcon.layer.cornerRadius = dogIcon.frame.width/2

        self.logAction.text = self.logSource.displayActionName

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        logDate.text = dateFormatter.string(from: logSource.logDate)

        logNote.text = logSource.logNote

    }

}
