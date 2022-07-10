//
//  SettingsNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsNavigationViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class SettingsNavigationViewController: UINavigationController, SettingsViewControllerDelegate {
    
    // MARK: - SettingsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        passThroughDelegate.didUpdateDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    // MARK: - Properties

    var settingsViewController: SettingsViewController! = nil
    
    weak var passThroughDelegate: SettingsNavigationViewControllerDelegate!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        settingsViewController = self.viewControllers[0] as? SettingsViewController
        settingsViewController.delegate = self
    }

}
