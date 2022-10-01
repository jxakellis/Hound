//
//  SettingsNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsNavigationViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class SettingsNavigationViewController: UINavigationController, SettingsViewControllerDelegate {
    
    // MARK: - SettingsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        passThroughDelegate.didUpdateDogManager(sender: sender, forDogManager: forDogManager)
    }
    
    // MARK: - Properties
    
    var settingsViewController: SettingsViewController?
    
    weak var passThroughDelegate: SettingsNavigationViewControllerDelegate!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsViewController = self.viewControllers.first as? SettingsViewController
        settingsViewController?.delegate = self
    }
    
}
