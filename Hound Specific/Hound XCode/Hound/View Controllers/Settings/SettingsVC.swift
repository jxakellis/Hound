//
//  SettingsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didToggleIsPaused(newIsPaused: Bool)
}

class SettingsViewController: UIViewController, SettingsTableViewControllerDelegate, SettingsRemindersViewControllerDelegate {

    // MARK: - SettingsTableViewControllerDelegate

    func willPerformSegue(withIdentifier identifier: String) {
        let convertedSegueIdentifier: String!
        switch identifier {
        case "personalInformation":
            convertedSegueIdentifier = "settingsPersonalInformationViewController"
        case "family":
            convertedSegueIdentifier = "settingsFamilyViewController"
        case "appearance":
            convertedSegueIdentifier = "settingsAppearanceViewController"
        case "reminders":
            convertedSegueIdentifier = "settingsRemindersViewController"
        case "notifications":
            convertedSegueIdentifier = "settingsNotificationsViewController"
        case "about":
            convertedSegueIdentifier = "settingsAboutViewController"
        default:
            convertedSegueIdentifier = "settingsAboutViewController"
        }
        self.performSegue(withIdentifier: convertedSegueIdentifier, sender: self)
    }

    // MARK: - SettingsRemindersViewControllerDelegate

    func didToggleIsPaused(newIsPaused: Bool) {
        delegate.didToggleIsPaused(newIsPaused: newIsPaused)
    }

    // MARK: - Properties

    weak var delegate: SettingsViewControllerDelegate! = nil

    var settingsTableViewController: SettingsTableViewController?
    var settingsPersonalInformationViewController: SettingsPersonalInformationViewController?
    var settingsFamilyViewController: SettingsFamilyViewController?
    var settingsAppearanceViewController: SettingsAppearanceViewController?
    var settingsRemindersViewController: SettingsRemindersViewController?
    var settingsNotificationsViewController: SettingsNotificationsViewController?
    var settingsAboutViewController: SettingsAboutViewController?

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsTableViewController" {
            settingsTableViewController = segue.destination as? SettingsTableViewController
            settingsTableViewController?.delegate = self
        }
        if segue.identifier == "settingsPersonalInformationViewController" {
            settingsPersonalInformationViewController = segue.destination as? SettingsPersonalInformationViewController
        }
        if segue.identifier == "settingsFamilyViewController" {
            settingsFamilyViewController = segue.destination as? SettingsFamilyViewController
        }
        if segue.identifier == "settingsAppearanceViewController" {
            settingsAppearanceViewController = segue.destination as? SettingsAppearanceViewController
        }

        if segue.identifier == "settingsRemindersViewController" {
            settingsRemindersViewController = segue.destination as? SettingsRemindersViewController
            settingsRemindersViewController?.delegate = self
        }
        if segue.identifier == "settingsNotificationsViewController" {
            settingsNotificationsViewController = segue.destination as? SettingsNotificationsViewController
        }
        if segue.identifier == "settingsAboutViewController" {
            settingsAboutViewController = segue.destination as? SettingsAboutViewController
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
