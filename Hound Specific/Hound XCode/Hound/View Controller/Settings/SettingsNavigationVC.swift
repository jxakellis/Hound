//
//  SettingsNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsNavigationViewControllerDelegate: AnyObject {
    func didToggleIsPaused(newIsPaused: Bool)
}

class SettingsNavigationViewController: UINavigationController, SettingsViewControllerDelegate {

    // MARK: - SettingsViewControllerDelegate

    func didToggleIsPaused(newIsPaused: Bool) {
        passThroughDelegate.didToggleIsPaused(newIsPaused: newIsPaused)
    }

    // MARK: - Properties

    weak var passThroughDelegate: SettingsNavigationViewControllerDelegate! = nil

    var settingsViewController: SettingsViewController! = nil

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        settingsViewController = self.viewControllers[0] as? SettingsViewController
        settingsViewController.delegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
