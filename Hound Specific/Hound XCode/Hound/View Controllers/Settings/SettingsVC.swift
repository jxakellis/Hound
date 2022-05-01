//
//  SettingsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class SettingsViewController: UIViewController, SettingsTableViewControllerDelegate, SettingsFamilyViewControllerDelegate {
    
    // MARK: - SettingsFamilyViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        delegate.didUpdateDogManager(sender: sender, newDogManager: newDogManager)
    }
    
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
        case "notifications":
            convertedSegueIdentifier = "settingsNotificationsViewController"
        case "about":
            convertedSegueIdentifier = "settingsAboutViewController"
        default:
            convertedSegueIdentifier = "settingsAboutViewController"
        }
        
        ViewControllerUtils.performSegueOnceInWindowHierarchy(segueIdentifier: convertedSegueIdentifier, viewController: self)
    }

    // MARK: - Properties

    var settingsTableViewController: SettingsTableViewController?
    var settingsPersonalInformationViewController: SettingsPersonalInformationViewController?
    var settingsFamilyViewController: SettingsFamilyViewController?
    var settingsAppearanceViewController: SettingsAppearanceViewController?
    var settingsNotificationsViewController: SettingsNotificationsViewController?
    var settingsAboutViewController: SettingsAboutViewController?
    weak var delegate: SettingsViewControllerDelegate!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsTableViewController" {
            settingsTableViewController = segue.destination as? SettingsTableViewController
            settingsTableViewController?.delegate = self
        }
        else if segue.identifier == "settingsPersonalInformationViewController" {
            settingsPersonalInformationViewController = segue.destination as? SettingsPersonalInformationViewController
        }
        else if segue.identifier == "settingsFamilyViewController" {
            settingsFamilyViewController = segue.destination as? SettingsFamilyViewController
            settingsFamilyViewController?.delegate = self
        }
        else if segue.identifier == "settingsAppearanceViewController" {
            settingsAppearanceViewController = segue.destination as? SettingsAppearanceViewController
        }
        else if segue.identifier == "settingsNotificationsViewController" {
            settingsNotificationsViewController = segue.destination as? SettingsNotificationsViewController
        }
        else if segue.identifier == "settingsAboutViewController" {
            settingsAboutViewController = segue.destination as? SettingsAboutViewController
        }
    }

}
