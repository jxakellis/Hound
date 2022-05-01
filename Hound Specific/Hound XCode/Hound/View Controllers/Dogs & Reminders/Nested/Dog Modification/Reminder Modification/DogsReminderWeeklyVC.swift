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

    @IBOutlet private var interWeekdayConstraints: [NSLayoutConstraint]!

    @IBOutlet private weak var sunday: ScaledUIButton!
    @IBOutlet private weak var monday: ScaledUIButton!
    @IBOutlet private weak var tuesday: ScaledUIButton!
    @IBOutlet private weak var wednesday: ScaledUIButton!
    @IBOutlet private weak var thursday: ScaledUIButton!
    @IBOutlet private weak var friday: ScaledUIButton!
    @IBOutlet private weak var saturday: ScaledUIButton!

    @IBOutlet private var dayOfWeekBackgrounds: [ScaledUIButton]!

    @IBAction private func toggleWeekdayButton(_ sender: Any) {
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

    @IBOutlet weak var timeOfDay: UIDatePicker!

    @IBAction private func willUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }

    // MARK: - Properties

    weak var delegate: DogsReminderWeeklyViewControllerDelegate! = nil

    var passedTimeOfDay: Date?

    var passedWeekDays: [Int]? = [1, 2, 3, 4, 5, 6, 7]

    var initalValuesChanged: Bool {
        if self.weekdays != passedWeekDays {
            return true
        }
        else if self.timeOfDay.date != passedTimeOfDay {
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
            self.timeOfDay.date = self.passedTimeOfDay!
        }
        else {
            self.timeOfDay.date = Date.roundDate(targetDate: Date(), roundingInterval: TimeInterval(60 * timeOfDay.minuteInterval), roundingMethod: .up)
            passedTimeOfDay = timeOfDay.date
        }

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.timeOfDay.date = self.timeOfDay.date
        }

        dayOfWeekBackgrounds.forEach { background in
            self.view.insertSubview(background, belowSubview: saturday)
            self.view.insertSubview(background, belowSubview: monday)
            self.view.insertSubview(background, belowSubview: tuesday)
            self.view.insertSubview(background, belowSubview: wednesday)
            self.view.insertSubview(background, belowSubview: thursday)
            self.view.insertSubview(background, belowSubview: friday)
            self.view.insertSubview(background, belowSubview: sunday)
        }
    }

    private func synchronizeWeekdays() {
        let dayOfWeekButtons = [self.sunday, self.monday, self.tuesday, self.wednesday, self.thursday, self.friday, self.saturday]

        for dayOfWeekButton in dayOfWeekButtons {
            dayOfWeekButton!.tintColor = UIColor.systemGray4
            dayOfWeekButton!.tag = ViewTagConstant.weekdayDisabled.rawValue
        }

        if passedWeekDays != nil {
            for dayOfWeek in passedWeekDays! {
                switch dayOfWeek {
                case 1:
                    sunday.tintColor = .systemBlue
                    sunday.tag = ViewTagConstant.weekdayEnabled.rawValue
                case 2:
                    monday.tintColor = .systemBlue
                    monday.tag = ViewTagConstant.weekdayEnabled.rawValue
                case 3:
                    tuesday.tintColor = .systemBlue
                    tuesday.tag = ViewTagConstant.weekdayEnabled.rawValue
                case 4:
                    wednesday.tintColor = .systemBlue
                    wednesday.tag = ViewTagConstant.weekdayEnabled.rawValue
                case 5:
                    thursday.tintColor = .systemBlue
                    thursday.tag = ViewTagConstant.weekdayEnabled.rawValue
                case 6:
                    friday.tintColor = .systemBlue
                    friday.tag = ViewTagConstant.weekdayEnabled.rawValue
                case 7:
                    saturday.tintColor = .systemBlue
                    saturday.tag = ViewTagConstant.weekdayEnabled.rawValue
                default:
                    AppDelegate.generalLogger.fault("unknown day of week: \(dayOfWeek) while synchronizeWeekdays for DogsReminderWeeklyViewController")
                }
            }
        }

    }

    /// Converts enabled buttons to an array of day of weeks according to CalendarComponents.weekdays, 1 being sunday and 7 being saturday
    var weekdays: [Int]? {
            var days: [Int] = []
            let dayOfWeekButtons = [self.sunday, self.monday, self.tuesday, self.wednesday, self.thursday, self.friday, self.saturday]

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

        for constraint in interWeekdayConstraints {
            // the distance between week day buttons should be 8 points on a 414 point screen, so this adjusts that ratio to fit any width of screen
            constraint.constant = (8.0/414.0)*self.view.safeAreaLayoutGuide.layoutFrame.width
        }

    }

}
