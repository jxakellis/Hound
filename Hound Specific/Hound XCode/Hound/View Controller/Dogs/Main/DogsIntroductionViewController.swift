//
//  DogsIntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/6/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsIntroductionViewControllerDelegate: AnyObject {
    func didSetDefaultReminderState(sender: Sender, newDefaultReminderStatus: Bool)
}

class DogsIntroductionViewController: UIViewController {

    // MARK: - IB

    @IBOutlet private weak var introductionBody: ScaledUILabel!

    @IBOutlet private weak var remindersBody: ScaledUILabel!
    @IBOutlet private weak var remindersToggleSwitch: UISwitch!
    @IBOutlet private weak var continueButton: UIButton!
    @IBAction private func willContinue(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Properties

    weak var delegate: DogsIntroductionViewControllerDelegate! = nil

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.layer.cornerRadius = 8.0

       // notificationsToggleSwitch.isOn = UserConfiguration.isNotificationEnabled
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        LocalConfiguration.hasLoadedDogsIntroductionViewControllerBefore = true

        delegate.didSetDefaultReminderState(sender: Sender(origin: self, localized: self), newDefaultReminderStatus: remindersToggleSwitch.isOn)

        if UserConfiguration.isNotificationAuthorized == false {

            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, _) in
                UserConfiguration.isNotificationAuthorized = isGranted
                UserConfiguration.isNotificationEnabled = isGranted
                UserConfiguration.isLoudNotification = isGranted
                UserConfiguration.isFollowUpEnabled = isGranted

            }

        }

    }

}
