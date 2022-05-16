//
//  DogsReminderWeeklyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderWeeklyViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

class DogsReminderWeeklyViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - IB
    
    @IBOutlet var interDayOfWeekConstraints: [NSLayoutConstraint]!
    
    @IBOutlet private weak var sundayButton: ScaledUIButton!
    @IBOutlet private weak var mondayButton: ScaledUIButton!
    @IBOutlet private weak var tuesdayButton: ScaledUIButton!
    @IBOutlet private weak var wednesdayButton: ScaledUIButton!
    @IBOutlet private weak var thursdayButton: ScaledUIButton!
    @IBOutlet private weak var fridayButton: ScaledUIButton!
    @IBOutlet private weak var saturdayButton: ScaledUIButton!

    @IBOutlet var dayOfWeekBackgrounds: [ScaledUIButton]!
    
    @IBAction private func didToggleWeekdayButton(_ sender: Any) {
        delegate.willDismissKeyboard()

        let senderButton = sender as! ScaledUIButton
        var targetColor: UIColor!

        if senderButton.tag == ViewTagConstant.weekdayEnabled.rawValue {
            targetColor = UIColor.systemGray4
            senderButton.tag = ViewTagConstant.weekdayDisabled.rawValue
        }
        else {
            targetColor = UIColor.systemBlue
            senderButton.tag = ViewTagConstant.weekdayEnabled.rawValue
        }

        senderButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: AnimationConstant.weekdayButton.rawValue) {
            senderButton.tintColor = targetColor
        } completion: { (_) in
            senderButton.isUserInteractionEnabled = true
        }

    }

    @IBOutlet weak var timeOfDayDatePicker: UIDatePicker!

    @IBAction private func didUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }

    // MARK: - Properties

    weak var delegate: DogsReminderWeeklyViewControllerDelegate! = nil

    var passedTimeOfDay: Date?

    var passedWeekDays: [Int]? = [1, 2, 3, 4, 5, 6, 7]

    var initalValuesChanged: Bool {
        if weekdays != passedWeekDays {
            return true
        }
        else if timeOfDayDatePicker.date != passedTimeOfDay {
            return true
        }
        return false
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        synchronizeWeekdays()

        // keep duplicate as without it the user can see the .asyncafter visual scroll, but this duplicate stops a value changed not being called on first value change bug
        if self.passedTimeOfDay != nil {
            self.timeOfDayDatePicker.date = self.passedTimeOfDay!
        }
        else {
            self.timeOfDayDatePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: TimeInterval(60 * timeOfDayDatePicker.minuteInterval), roundingMethod: .up)
            passedTimeOfDay = timeOfDayDatePicker.date
        }

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.timeOfDayDatePicker.date = self.timeOfDayDatePicker.date
        }

        dayOfWeekBackgrounds.forEach { background in
            self.view.insertSubview(background, belowSubview: saturdayButton)
            self.view.insertSubview(background, belowSubview: mondayButton)
            self.view.insertSubview(background, belowSubview: tuesdayButton)
            self.view.insertSubview(background, belowSubview: wednesdayButton)
            self.view.insertSubview(background, belowSubview: thursdayButton)
            self.view.insertSubview(background, belowSubview: fridayButton)
            self.view.insertSubview(background, belowSubview: sundayButton)
        }
    }

    private func synchronizeWeekdays() {
        let dayOfWeekButtons = [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton]

        for dayOfWeekButton in dayOfWeekButtons where dayOfWeekButton != nil {
            dayOfWeekButton!.tintColor = UIColor.systemGray4
            dayOfWeekButton!.tag = ViewTagConstant.weekdayDisabled.rawValue
        }
        
        guard passedWeekDays != nil else {
            return
        }

        for dayOfWeek in passedWeekDays! {
            switch dayOfWeek {
            case 1:
                sundayButton.tintColor = .systemBlue
                sundayButton.tag = ViewTagConstant.weekdayEnabled.rawValue
            case 2:
                mondayButton.tintColor = .systemBlue
                mondayButton.tag = ViewTagConstant.weekdayEnabled.rawValue
            case 3:
                tuesdayButton.tintColor = .systemBlue
                tuesdayButton.tag = ViewTagConstant.weekdayEnabled.rawValue
            case 4:
                wednesdayButton.tintColor = .systemBlue
                wednesdayButton.tag = ViewTagConstant.weekdayEnabled.rawValue
            case 5:
                thursdayButton.tintColor = .systemBlue
                thursdayButton.tag = ViewTagConstant.weekdayEnabled.rawValue
            case 6:
                fridayButton.tintColor = .systemBlue
                fridayButton.tag = ViewTagConstant.weekdayEnabled.rawValue
            case 7:
                saturdayButton.tintColor = .systemBlue
                saturdayButton.tag = ViewTagConstant.weekdayEnabled.rawValue
            default:
                AppDelegate.generalLogger.fault("unknown day of week: \(dayOfWeek) while synchronizeWeekdays for DogsReminderWeeklyViewController")
            }
        }

    }

    /// Converts enabled buttons to an array of day of weeks according to CalendarComponents.weekdays, 1 being sunday and 7 being saturday
    var weekdays: [Int]? {
            var days: [Int] = []
            let dayOfWeekButtons = [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton]

            for dayOfWeekIndex in 0..<dayOfWeekButtons.count where dayOfWeekButtons[dayOfWeekIndex]?.tag == ViewTagConstant.weekdayEnabled.rawValue {
                days.append(dayOfWeekIndex+1)
            }

            if days.isEmpty == true {
                return nil
            }
            else {
                return days
            }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        for constraint in interDayOfWeekConstraints {
            // the distance between week day buttons should be 8 points on a 414 point screen, so this adjusts that ratio to fit any width of screen
            constraint.constant = (8.0/414.0)*self.view.safeAreaLayoutGuide.layoutFrame.width
        }

    }

}
