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

        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        let beforeUpdateIsFollowUpEnabled = UserConfiguration.isFollowUpEnabled

        if LocalConfiguration.isNotificationAuthorized == false {

            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, _) in
                LocalConfiguration.isNotificationAuthorized = isGranted
                UserConfiguration.isNotificationEnabled = isGranted
                UserConfiguration.isLoudNotification = isGranted
                UserConfiguration.isFollowUpEnabled = isGranted

                updateServerUserConfiguration()
            }

        }

        /// Contact the server about the updated values and, if there is no response or a bad response, revert the values to their previous values. isNotificationAuthorized purposefully excluded as server doesn't need to know that and its value cant exactly just be flipped (as tied to apple notif auth status)
        func updateServerUserConfiguration() {
            var body: [String: Any] = [:]
            // check for if values were changed, if there were then tell the server
            if UserConfiguration.isNotificationEnabled != beforeUpdateIsNotificationEnabled {
                body[UserDefaultsKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
            }
            if UserConfiguration.isLoudNotification != beforeUpdateIsLoudNotification {
                body[UserDefaultsKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
            }
            if UserConfiguration.isFollowUpEnabled != beforeUpdateIsFollowUpEnabled {
                body[UserDefaultsKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
            }
            UserRequest.update(body: body) { _, responseCode, _ in
                DispatchQueue.main.async {
                    // success
                    if responseCode != nil && 200...299 ~= responseCode! {
                        // do nothing as we preemptively updated the values
                    }
                    // error, revert to previous
                    else {
                        UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                        UserConfiguration.isLoudNotification = beforeUpdateIsLoudNotification
                        UserConfiguration.isFollowUpEnabled = beforeUpdateIsFollowUpEnabled

                        ErrorManager.alert(sender: Sender(origin: self, localized: self), forError: UserConfigurationResponseError.updateIsNotificationAuthorizedFailed)
                    }
                }
            }
        }

    }

}
