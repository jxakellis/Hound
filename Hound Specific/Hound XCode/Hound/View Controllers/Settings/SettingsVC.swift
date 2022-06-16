//
//  SettingsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
import StoreKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class SettingsViewController: UIViewController, SettingsTableViewControllerDelegate, SettingsFamilyViewControllerDelegate, SettingsPersonalInformationViewControllerDelegate, DogManagerControlFlowProtocol {
    
    // MARK: - SettingsFamilyViewControllerDelegate & SettingsPersonalInformationViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    // MARK: - SettingsTableViewControllerDelegate

    func willPerformSegue(withIdentifier identifier: String) {
        let convertedSegueIdentifier: String!
        switch identifier {
        case "personalInformation":
            convertedSegueIdentifier = "settingsPersonalInformationViewController"
        case "family":
            convertedSegueIdentifier = "settingsFamilyViewController"
        case "subscription":
            convertedSegueIdentifier = "settingsSubscriptionViewController"
        case "appearance":
            convertedSegueIdentifier = "settingsAppearanceViewController"
        case "notifications":
            convertedSegueIdentifier = "settingsNotificationsViewController"
        case "about":
            convertedSegueIdentifier = "settingsAboutViewController"
        default:
            convertedSegueIdentifier = "settingsAboutViewController"
        }
        
        if convertedSegueIdentifier == "settingsSubscriptionViewController" {
            // TO DO make this query indicator special so it says contacting apple servers as this request isn't related to hound servers
            RequestUtils.beginAlertControllerQueryIndictator()
            InAppPurchaseManager.shared.fetchProducts { SKProducts in
                RequestUtils.endAlertControllerQueryIndictator {
                    guard SKProducts != nil else {
                        return
                    }
                    
                    // reset array to zero
                    self.subscriptionSKProducts = []
                    // look for products that you can subscribe to
                    for product in SKProducts! where product.subscriptionPeriod != nil {
                        self.subscriptionSKProducts.append(product)
                    }
                    
                    // TO DO sort subscriptions in correct order
                    print("retrieved")
                    print(self.subscriptionSKProducts.count)
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: convertedSegueIdentifier)
                }
            }
        }
        else {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: convertedSegueIdentifier)
        }
    }

    // MARK: - Properties

    var settingsTableViewController: SettingsTableViewController?
    var settingsPersonalInformationViewController: SettingsPersonalInformationViewController?
    var settingsFamilyViewController: SettingsFamilyViewController?
    var settingsSubscriptionViewController: SettingsSubscriptionViewController?
    private var subscriptionSKProducts: [SKProduct] = []
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
    
    // MARK: - Dog Manager
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        dogManager = newDogManager
        
        // pass down
        if (sender.localized is SettingsFamilyViewController) == false {
            settingsFamilyViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: newDogManager)
        }
        if (sender.localized is SettingsPersonalInformationViewControllerDelegate) == false {
            settingsPersonalInformationViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: newDogManager)
        }
        // pass up
        if (sender.localized is MainTabBarViewController) == false {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: newDogManager)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsTableViewController" {
            settingsTableViewController = segue.destination as? SettingsTableViewController
            settingsTableViewController?.delegate = self
        }
        else if segue.identifier == "settingsPersonalInformationViewController" {
            settingsPersonalInformationViewController = segue.destination as? SettingsPersonalInformationViewController
            settingsPersonalInformationViewController?.delegate = self
            settingsPersonalInformationViewController?.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
        }
        else if segue.identifier == "settingsFamilyViewController" {
            settingsFamilyViewController = segue.destination as? SettingsFamilyViewController
            settingsFamilyViewController?.delegate = self
            settingsFamilyViewController?.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
        }
        else if segue.identifier == "settingsSubscriptionViewController" {
            settingsSubscriptionViewController = segue.destination as? SettingsSubscriptionViewController
            print("assigned")
            print(subscriptionSKProducts.count)
            settingsSubscriptionViewController?.subscriptionSKProducts = subscriptionSKProducts
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
