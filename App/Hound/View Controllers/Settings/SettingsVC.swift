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
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SettingsFamilyViewControllerDelegate, SettingsPersonalInformationViewControllerDelegate, DogManagerControlFlowProtocol {
    
    // MARK: - SettingsFamilyViewControllerDelegate & SettingsPersonalInformationViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Dog Manager
    
    private var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        // pass down
        if (sender.localized is SettingsFamilyViewController) == false {
            settingsFamilyViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
        }
        if (sender.localized is SettingsPersonalInformationViewControllerDelegate) == false {
            settingsPersonalInformationViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
        }
        // pass up
        if (sender.localized is MainTabBarViewController) == false {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
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
        
        let iconEdgeInset = UIEdgeInsets.init(top: 0, left: (5.0 + 35.5 + 2.5), bottom: 0, right: 0)
        switch indexPath.row {
            // we want two separators cells at the top. since the first cell has a separators on both the top and bottom, we hide it. The second cell (and all following cells) only have separators on the bottom, therefore the second cell makes it look like a full size separator is on the top of the third cell. Meanwhile, the third cell has a partial separator to stylize it.
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCellWithoutSeparatorTableViewCell", for: indexPath)
            cell!.contentView.addConstraint(NSLayoutConstraint(item: cell!.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 11.25))
            cell!.separatorInset = .zero
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCellWithSeparatorTableViewCell", for: indexPath)
            cell!.contentView.addConstraint(NSLayoutConstraint(item: cell!.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 11.25))
            cell!.separatorInset = .zero
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsPersonalInformationViewController", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsFamilyViewController", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSubscriptionViewController", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsAppearanceViewController", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsNotificationsViewController", for: indexPath)
            cell!.separatorInset = .zero
        case 7:
            cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCellWithSeparatorTableViewCell", for: indexPath)
            cell!.contentView.addConstraint(NSLayoutConstraint(item: cell!.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22.5))
            cell!.separatorInset = .zero
        case 8:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsAboutViewController", for: indexPath)
            cell!.separatorInset = .zero
        default:
            // fall through
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingsAboutViewController", for: indexPath)
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
        
        if identifier == "SettingsSubscriptionViewController" {
            RequestUtils.beginRequestIndictator(forRequestIndicatorType: .apple)
            InAppPurchaseManager.fetchProducts { products  in
                RequestUtils.endRequestIndictator {
                    guard let products = products else {
                        return
                    }
                    
                    // reset array to zero
                    self.subscriptionProducts = []
                    // look for products that you can subscribe to
                    for product in products where product.subscriptionPeriod != nil {
                        self.subscriptionProducts.append(product)
                    }
                    
                    SubscriptionRequest.getAll(invokeErrorManager: true) { requestWasSuccessful, _ in
                        guard requestWasSuccessful else {
                            return
                        }
                        
                        self.performSegueOnceInWindowHierarchy(segueIdentifier: identifier)
                    }
                }
            }
        }
        else {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: identifier)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsPersonalInformationViewController = segue.destination as? SettingsPersonalInformationViewController {
            self.settingsPersonalInformationViewController = settingsPersonalInformationViewController
            
            settingsPersonalInformationViewController.delegate = self
            settingsPersonalInformationViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
        else if let settingsFamilyViewController = segue.destination as? SettingsFamilyViewController {
            self.settingsFamilyViewController = settingsFamilyViewController
            settingsFamilyViewController.delegate = self
            settingsFamilyViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
        else if let settingsSubscriptionViewController = segue.destination as? SettingsSubscriptionViewController {
            self.settingsSubscriptionViewController = settingsSubscriptionViewController
            settingsSubscriptionViewController.subscriptionProducts = subscriptionProducts
        }
        else if let settingsAppearanceViewController = segue.destination as? SettingsAppearanceViewController {
            self.settingsAppearanceViewController = settingsAppearanceViewController
        }
        else if let settingsNotificationsViewController = segue.destination as? SettingsNotificationsViewController {
            self.settingsNotificationsViewController = settingsNotificationsViewController
        }
        else if let settingsAboutViewController = segue.destination as? SettingsAboutViewController {
            self.settingsAboutViewController = settingsAboutViewController
        }
    }

}
