//
//  SettingsSubscriptionsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/15/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit
import StoreKit

class SettingsSubscriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: Properties
    
    var subscriptionProducts: [SKProduct] = []
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO DO lock subscription controls to only the head of the family
        // TO DO add subscription history
        // TO DO add active subscription
        // TO DO add disclaimer about grace period, after that say that if subscription expires, you have x amount of time
        // TO DO add restore button to restore purchases
        
        oneTimeSetup()
        
        repeatableSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    /// These properties only need assigned once.
    private func oneTimeSetup() {
        
        tableView.separatorInset = .zero
        
    }
    
    /// These properties can be reassigned. Does not reload anything, rather just configures.
    private func repeatableSetup() {
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsSubscriptionTierTableViewCell", for: indexPath) as! SettingsSubscriptionTierTableViewCell
        
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
        
        // TO DO block user from attempting to downgrade if they have too many dogs or family members, give them an error
        
        // indexPath 0 is the default so we won't be making a purchase
        guard indexPath.row != 0 else {
            // TO DO let the user downgrade their subscription to free
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as? SettingsSubscriptionTierTableViewCell
        
        // make sure we have a product to query
        guard let product = cell?.product else {
            return
        }
        
        RequestUtils.beginRequestIndictator()
        InAppPurchaseManager.purchaseProduct(forProduct: product) { productIdentifier, inAppPurchaseError in
            // TO DO update how message appears, change to "Contacting Apple Server..."
            RequestUtils.endRequestIndictator {
                if let inAppPurchaseError = inAppPurchaseError {
                    ErrorManager.alert(forError: inAppPurchaseError)
                    return
                }
                
                self.performSpinningCheckmarkAnimation()
                
                print("success \(productIdentifier)")
            }
        }
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
