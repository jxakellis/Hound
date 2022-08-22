//
//  SettingsSubscriptionsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/15/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit
import StoreKit

final class SettingsSubscriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var activeSubscriptionTitleLabel: ScaledUILabel!
    @IBOutlet private weak var activeSubscriptionDescriptionLabel: ScaledUILabel!
    @IBOutlet private weak var activeSubscriptionPurchaseDateLabel: ScaledUILabel!
    @IBOutlet private weak var activeSubscriptionExpirationLabel: ScaledUILabel!
    
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    @IBAction private func willRefresh(_ sender: Any) {
        // If a transaction was syncronized to the Hound server from the background, i.e. the system recognized there was a transaction sitting in the queue so silently contacted Hound to process it, we don't want to cause any visual indicators that would confuse the user. Instead we just update the information on the server then reload the labels. No fancy animations or error messages if anything fails.
        let refreshWasInvokedByUser = sender as? Bool ?? true
        
        self.refreshButton.isEnabled = false
        if refreshWasInvokedByUser {
            ActivityIndicator.shared.beginAnimating(title: navigationItem.title ?? "", view: self.view, navigationItem: navigationItem)
        }
        
        SubscriptionRequest.get(invokeErrorManager: refreshWasInvokedByUser) { requestWasSuccessful, _ in
            self.refreshButton.isEnabled = true
            if refreshWasInvokedByUser {
                ActivityIndicator.shared.stopAnimating(navigationItem: self.navigationItem)
            }
            
            guard requestWasSuccessful else {
                return
            }
            
            if refreshWasInvokedByUser {
                AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.refreshSubscriptionTitle, forSubtitle: VisualConstant.BannerTextConstant.refreshSubscriptionSubtitle, forStyle: .success)
            }
            
            self.reloadTableAndLabels()
        }
    }
    
    @IBOutlet private weak var restoreTransactionsButton: UIButton!
    @IBAction private func didClickRestoreTransactions(_ sender: Any) {
        // The user doesn't have permission to perform this action
        guard FamilyConfiguration.isFamilyHead else {
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }
        
        restoreTransactionsButton.isEnabled = false
        RequestUtils.beginRequestIndictator(forRequestIndicatorType: .apple)
        
        InAppPurchaseManager.restorePurchases { requestWasSuccessful in
            RequestUtils.endRequestIndictator {
                self.restoreTransactionsButton.isEnabled = true
                guard requestWasSuccessful else {
                    return
                }
                
                AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.restoreTransactionsTitle, forSubtitle: VisualConstant.BannerTextConstant.restoreTransactionsSubtitle, forStyle: .success)
            }
        }
    }
    
    // MARK: Properties
    
    var subscriptionProducts: [SKProduct] = []
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO DO FUTURE add subscription history
        
        oneTimeSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        repeatableSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    /// If a transaction was syncronized to the Hound server from the background, i.e. the system recognized there was a transaction sitting in the queue so silently contacted Hound to process it, call this function. It will refresh the page without any animations that would confuse the user
    func willRefreshAfterTransactionsSyncronizedInBackground() {
        self.willRefresh(false)
    }
    
    /// These properties only need assigned once.
    private func oneTimeSetup() {
        
        tableView.separatorInset = .zero
        
        restoreTransactionsButton.layer.cornerRadius = VisualConstant.SizeConstant.largeRectangularButtonCornerRadious
    }
    
    /// These properties can be reassigned. Does not reload anything, rather just configures.
    private func repeatableSetup() {
        
        setupActiveSubscriptionLabels()
    }
    
    private func setupActiveSubscriptionLabels() {
        let activeSubscription = FamilyConfiguration.activeFamilySubscription
        
        activeSubscriptionTitleLabel.text = InAppPurchaseProduct.localizedTitleExpanded(forInAppPurchaseProduct: activeSubscription.product)
        activeSubscriptionDescriptionLabel.text = InAppPurchaseProduct.localizedDescriptionExpanded(forInAppPurchaseProduct: activeSubscription.product)
        
        var purchaseDateString: String {
            guard let purchaseDate = activeSubscription.purchaseDate else {
                return "Never"
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: EnumConstant.DevelopmentConstant.subscriptionDateFormatTemplate, options: 0, locale: Calendar.current.locale)
            return dateFormatter.string(from: purchaseDate)
        }
        
        activeSubscriptionPurchaseDateLabel.text = "Purchased: \(purchaseDateString)"
        
        var expirationDateString: String {
            guard let expirationDate = activeSubscription.expirationDate else {
                return "Never"
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: EnumConstant.DevelopmentConstant.subscriptionDateFormatTemplate, options: 0, locale: Calendar.current.locale)
            return dateFormatter.string(from: expirationDate)
        }
        
        activeSubscriptionExpirationLabel.text = "Expires: \(expirationDateString)"
    }
    
    private func reloadTableAndLabels() {
        setupActiveSubscriptionLabels()
        tableView.reloadData()
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // first row in a static "default" subscription, then the rest are subscription products
        return 1 + subscriptionProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSubscriptionTierTableViewCell", for: indexPath) as? SettingsSubscriptionTierTableViewCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            // necessary to make sure defaults are properly used for "Single" tier
            cell.setup(forProduct: nil)
        }
        else {
            // index path 0 is the first row and that is the default subscription
            cell.setup(forProduct: subscriptionProducts[indexPath.row - 1])
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // The user doesn't have permission to perform this action
        guard FamilyConfiguration.isFamilyHead else {
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidFamilyPermissionSubtitle, forStyle: .danger)
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SettingsSubscriptionTierTableViewCell else {
            return
        }
        
        guard let indexOfActiveSubscription = InAppPurchaseProduct.allCases.firstIndex(of: FamilyConfiguration.activeFamilySubscription.product), let indexOfSelectedRow = InAppPurchaseProduct.allCases.firstIndex(of: cell.inAppPurchaseProduct) else {
            return
        }
        
        // Make sure the user didn't select the cell of the subscription that they are currently subscribed to
        guard indexOfSelectedRow != indexOfActiveSubscription else {
            return
        }
        
        // Make sure that the user didn't try to downgrade
        guard indexOfSelectedRow > indexOfActiveSubscription else {
            // The user is downgrading their subscription, show a disclaimer
            let downgradeSubscriptionDisclaimer = GeneralUIAlertController(title: "Are you sure you want to downgrade your Hound subscription?", message: "If you exceed your new family member or dog limit, you won't be able to add or update any dogs, reminders, or logs. This means you might have to delete family members or dogs to restore functionality.", preferredStyle: .alert)
            downgradeSubscriptionDisclaimer.addAction(UIAlertAction(title: "Yes, I'm sure", style: .default, handler: { _ in
                purchaseSelectedProduct()
            }))
            downgradeSubscriptionDisclaimer.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            AlertManager.enqueueAlertForPresentation(downgradeSubscriptionDisclaimer)
            return
        }
        
        // The user is upgrading their subscription so no need for a disclaimer
        purchaseSelectedProduct()
        
        func purchaseSelectedProduct() {
            // If the cell has no SKProduct, that means it's the default subscription cell
            guard let product = cell.product else {
                guard let windowScene = UIApplication.windowScene else {
                    guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else {
                        return
                    }
                    UIApplication.shared.open(url)
                    return
                }
                
                Task {
                    do {
                        try await AppStore.showManageSubscriptions(in: windowScene)
                    }
                    catch {
                        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else {
                            return
                        }
                        await UIApplication.shared.open(url)
                    }
                }
                return
            }
            
            RequestUtils.beginRequestIndictator(forRequestIndicatorType: .apple)
            InAppPurchaseManager.purchaseProduct(forProduct: product) { productIdentifier in
                RequestUtils.endRequestIndictator {
                    guard productIdentifier != nil else {
                        // ErrorManager already invoked by purchaseProduct
                        return
                    }
                    
                    AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.purchasedSubscriptionTitle, forSubtitle: VisualConstant.BannerTextConstant.purchasedSubscriptionSubtitle, forStyle: .success)
                    
                    self.reloadTableAndLabels()
                }
            }
        }
    }
    
}
