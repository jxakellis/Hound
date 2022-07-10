//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsDogDisplayTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var dogIconImageView: UIImageView!
    @IBOutlet private weak var dogIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dogNameLabel: ScaledUILabel!
    @IBOutlet private weak var dogNameTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var nextAlarmLabel: ScaledUILabel!
    @IBOutlet private weak var nextAlarmBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nextAlarmHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var rightChevronWidthConstraint: NSLayoutConstraint!
    // MARK: - Properties

    var dog: Dog! = nil

    // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()
        self.dogNameLabel.adjustsFontSizeToFitWidth = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Setup

    // Function used externally to setup dog
    func setup(forDog dogPassed: Dog) {
        dog = dogPassed
        
        // Size Ratio Scaling
        
        let sizeRatio = UserConfiguration.remindersInterfaceScale.currentScaleFactor
        
        // Dog Name Label Configuration
        self.dogNameLabel.text = dogPassed.dogName
        dogNameLabel.font = dogNameLabel.font.withSize(40.0 * sizeRatio)
        dogNameTopConstraint.constant = 7.5 * sizeRatio
        dogNameHeightConstraint.constant = 45.0 * sizeRatio
        dogNameBottomConstraint.constant = 5.0 * sizeRatio
        
        // Next Alarm Label Configuration
        nextAlarmLabel.font = nextAlarmLabel.font.withSize(15.0 * sizeRatio)
        nextAlarmHeightConstraint.constant = 20.0 * sizeRatio
        nextAlarmBottomConstraint.constant = 7.5 * sizeRatio
        
        // Right Chevron Configuration
        rightChevronWidthConstraint.constant = 20.0 * sizeRatio
        
        // Dog Icon Configuration

        dogIconImageView.image = dogPassed.dogIcon
        dogIconImageView.layer.masksToBounds = true
        let dogIconWidth = 60.0 * sizeRatio
        dogIconWidthConstraint.constant = dogIconWidth

        if dogIconImageView.image?.isEqualToImage(image: DogConstant.defaultDogIcon) == false {
            dogIconImageView.layer.cornerRadius = dogIconWidth/2
        }
        else {
            dogIconImageView.layer.cornerRadius = 0.0
        }
        
        reloadNextAlarmText()
    }

    func reloadNextAlarmText() {

        let nextAlarmHeaderFont = UIFont.systemFont(ofSize: nextAlarmLabel.font.pointSize, weight: .semibold)
        let nextAlarmBodyFont = UIFont.systemFont(ofSize: nextAlarmLabel.font.pointSize, weight: .regular)

        if dog.dogReminders.reminders.count == 0 {
            nextAlarmLabel.attributedText = NSAttributedString(string: "No Reminders Created", attributes: [NSAttributedString.Key.font: nextAlarmHeaderFont])
        }
        else if FamilyConfiguration.isPaused == true {
            // pause takes priority
            nextAlarmLabel.attributedText = NSAttributedString(string: "All Reminders Paused", attributes: [NSAttributedString.Key.font: nextAlarmHeaderFont])
            
        }
        else if dog.dogReminders.hasEnabledReminder == false {
            // disable comes secondary to paused
            nextAlarmLabel.attributedText = NSAttributedString(string: "All Reminders Disabled", attributes: [NSAttributedString.Key.font: nextAlarmHeaderFont])
        }
        else {
            // has at least once enabled reminder so soonsetFireDate won't be nil by the end
            let soonestReminderExecutionDate = dog.dogReminders.soonestReminderExecutionDate!

             if Date().distance(to: soonestReminderExecutionDate) <= 0 {
                let timeLeftText = " Now"

                nextAlarmLabel.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: nextAlarmBodyFont])

                nextAlarmLabel.attributedText = nextAlarmLabel.text!.addingFontToBeginning(text: "Next Reminder In: ", font: nextAlarmHeaderFont)
            }
            else {
                let timeLeftText = String.convertToReadable(fromTimeInterval: Date().distance(to: soonestReminderExecutionDate))

                nextAlarmLabel.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: nextAlarmBodyFont])

                nextAlarmLabel.attributedText = nextAlarmLabel.text!.addingFontToBeginning(text: "Next Reminder In: ", font: nextAlarmHeaderFont)
            }
        }
    }

}
