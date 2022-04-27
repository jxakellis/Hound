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

    @IBOutlet private weak var dogIcon: UIImageView!

    @IBOutlet private weak var dogName: ScaledUILabel!

    @IBOutlet private weak var nextReminder: ScaledUILabel!

    // MARK: - Properties

    var dog: Dog! = nil

    // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()
        self.dogName.adjustsFontSizeToFitWidth = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Function used externally to setup dog
    func setup(forDog dogPassed: Dog) {
        dog = dogPassed

        dogIcon.image = dogPassed.dogIcon

        if dogIcon.image != nil && !(dogIcon.image!.isEqualToImage(image: DogConstant.defaultDogIcon)) {
            dogIcon.layer.masksToBounds = true
            dogIcon.layer.cornerRadius = dogIcon.frame.width/2
        }
        else {
            dogIcon.layer.masksToBounds = false
        }

        self.dogName.text = dogPassed.dogName

        setupTimeLeftText()
    }

    func reloadCell() {
        setupTimeLeftText()
    }

    private func setupTimeLeftText() {

        let nextReminderBodyWeight: UIFont.Weight = .regular
        let nextReminderImportantWeight: UIFont.Weight = .semibold

        if dog.dogReminders.reminders.count == 0 {
            nextReminder.attributedText = NSAttributedString(string: "No Reminders Created", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight)])
        }
        else if FamilyConfiguration.isPaused == true {
            // pause takes priority
            nextReminder.attributedText = NSAttributedString(string: "All Reminders Paused", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight)])
            
        }
        else if dog.dogReminders.hasEnabledReminder == false {
            // disable comes secondary to paused
            nextReminder.attributedText = NSAttributedString(string: "All Reminders Disabled", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight)])
        }
        
        else {
            // has at least once enabled reminder so soonsetFireDate won't be nil by the end
            var soonestFireDate: Date! = nil
            for reminder in dog.dogReminders.reminders {
                guard reminder.reminderIsEnabled else {
                    continue
                }
                if soonestFireDate == nil {
                    soonestFireDate = reminder.reminderExecutionDate!
                }
                else {
                    if Date().distance(to: reminder.reminderExecutionDate!) < Date().distance(to: soonestFireDate) {
                        soonestFireDate = reminder.reminderExecutionDate!
                    }
                }
            }

             if Date().distance(to: soonestFireDate!) <= 0 {
                let timeLeftText = " Now"

                nextReminder.font = UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderBodyWeight)

                nextReminder.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: nextReminder.font!])

                nextReminder.attributedText = nextReminder.text!.addingFontToBeginning(text: "Next Reminder In: ", font: UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight))
            }
            else {
                let timeLeftText = String.convertToReadable(fromTimeInterval: Date().distance(to: soonestFireDate))

                nextReminder.font = UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderBodyWeight)

                nextReminder.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: nextReminder.font!])

                nextReminder.attributedText = nextReminder.text!.addingFontToBeginning(text: "Next Reminder In: ", font: UIFont.systemFont(ofSize: nextReminder.font.pointSize, weight: nextReminderImportantWeight))
            }
        }
    }

}
