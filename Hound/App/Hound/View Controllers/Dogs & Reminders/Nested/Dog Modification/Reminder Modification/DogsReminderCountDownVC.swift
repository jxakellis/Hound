//
//  DogsReminderCountdownViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderCountdownViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsReminderCountdownViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - IB

    @IBOutlet weak var countdown: UIDatePicker!

    @IBAction func willUpdateCountdown(_ sender: Any) {
        delegate.willDismissKeyboard()
    }

    // MARK: - Properties

   weak var delegate: DogsReminderCountdownViewControllerDelegate! = nil

    var passedInterval: TimeInterval?

    var initalValuesChanged: Bool {
        if countdown.countDownDuration != passedInterval {
            return true
        }
        else {
            return false
        }
    }
    // MARK: - Main

    override func viewDidLoad() {

        // keep duplicate as without it the user can see the .asyncafter visual scroll, but this duplicate stops a value changed not being called on first value change bug
        if self.passedInterval != nil {
            self.countdown.countDownDuration = self.passedInterval!
        }
        else {
            self.countdown.countDownDuration = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
            passedInterval = countdown.countDownDuration
        }

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.passedInterval != nil {
                self.countdown.countDownDuration = self.passedInterval!
            }
            else {
                self.countdown.countDownDuration = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
            }
        }

    }
    
}
