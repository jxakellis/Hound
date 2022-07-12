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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SettingsFamilyViewControllerDelegate, SettingsPersonalInformationViewControllerDelegate, DogManagerControlFlowProtocol {
    
    // MARK: - SettingsFamilyViewControllerDelegate & SettingsPersonalInformationViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var settingsPagesTableView: UITableView!

    // MARK: - Properties

    // 2 separators, 5 regulars pages, 1 separator, and 1 regular page to allow for proper edge insets
    private let numberOfTableViewCells = (2 + 5 + 1 + 1)
    var settingsPersonalInformationViewController: SettingsPersonalInformationViewController?
    var settingsFamilyViewController: SettingsFamilyViewController?
    var settingsSubscriptionViewController: SettingsSubscriptionViewController?
    private var subscriptionProducts: [SKProduct] = []
    var settingsAppearanceViewController: SettingsAppearanceViewController?
    var settingsNotificationsViewController: SettingsNotificationsViewController?
    var settingsAboutViewController: SettingsAboutViewController?
    weak var delegate: SettingsViewControllerDelegate!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsPagesTableView.delegate = self
        settingsPagesTableView.dataSource = self
        settingsPagesTableView.separatorColor = .white
        // make seperator go the whole distance, then individual cells can change it.
        settingsPagesTableView.separatorInset = .zero
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
    
    // MARK: - Settings Pages Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfTableViewCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        
        let iconEdgeInset = UIEdgeInsets.init(top: 0, left: (5.0+35.5+2.5), bottom: 0, right: 0)
        switch indexPath.row {
            // we want two separators cells at the top. since the first cell has a separators on both the top and bottom, we hide it. The second cell (and all following cells) only have separators on the bottom, therefore the second cell makes it look like a full size separator is on the top of the third cell. Meanwhile, the third cell has a partial separator to stylize it.
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "spaceCellWithoutSeparator", for: indexPath)
            cell!.contentView.addConstraint(NSLayoutConstraint(item: cell!.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 11.25))
            cell!.separatorInset = .zero
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "spaceCellWithSeparator", for: indexPath)
            cell!.contentView.addConstraint(NSLayoutConstraint(item: cell!.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 11.25))
            cell!.separatorInset = .zero
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsPersonalInformationViewController", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsFamilyViewController", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsSubscriptionViewController", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsAppearanceViewController", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsNotificationsViewController", for: indexPath)
            cell!.separatorInset = .zero
        case 7:
            cell = tableView.dequeueReusableCell(withIdentifier: "spaceCellWithSeparator", for: indexPath)
            cell!.contentView.addConstraint(NSLayoutConstraint(item: cell!.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22.5))
            cell!.separatorInset = .zero
        case 8:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsAboutViewController", for: indexPath)
            cell!.separatorInset = .zero
        default:
            // fall through
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsAboutViewController", for: indexPath)
            cell!.separatorInset = .zero
        }
        cell!.selectionStyle = .blue
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cannot select the space cells so no need to worry about them
        self.settingsPagesTableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        let identifier = cell!.reuseIdentifier!
        
        if identifier == "settingsSubscriptionViewController" {
            RequestUtils.beginRequestIndictator(forRequestIndicatorType: .apple)
            InAppPurchaseManager.fetchProducts { products, inAppPurchaseError  in
                RequestUtils.endRequestIndictator {
                    
                    if let inAppPurchaseError = inAppPurchaseError {
                        ErrorManager.alert(forError: inAppPurchaseError)
                        return
                    }
                    
                    guard let products = products else {
                        ErrorManager.alert(forError: InAppPurchaseError.productRequestFailed)
                        return
                    }
                    
                    // reset array to zero
                    self.subscriptionProducts = []
                    // look for products that you can subscribe to
                    for product in products where product.subscriptionPeriod != nil {
                        self.subscriptionProducts.append(product)
                    }
                    
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: identifier)
                }
            }
        }
        else {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: identifier)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsPersonalInformationViewController" {
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
            settingsSubscriptionViewController?.subscriptionProducts = subscriptionProducts
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
