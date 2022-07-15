//
//  InAppPurchaseManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/13/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation
import StoreKit

// This main class provides a streamlined way to perform the main two queries
final class InAppPurchaseManager {
    
    static func initalizeInAppPurchaseManager() {
        _ = InternalInAppPurchaseManager.shared
    }
    
    /// Query apple servers to retrieve all available products. If there is an error, ErrorManager is automatically invoked and nil is returned.
    static func fetchProducts(completionHandler: @escaping ([SKProduct]?) -> Void) {
        InternalInAppPurchaseManager.shared.fetchProducts { products in
            completionHandler(products)
        }
    }
    
    /// Query apple servers to purchase a certain product. If successful, then queries Hound servers to have transaction verified and applied. If there is an error, ErrorManager is automatically invoked and nil is returned.
    static func purchaseProduct(forProduct product: SKProduct, completionHandler: @escaping (String?) -> Void) {
        InternalInAppPurchaseManager.shared.purchase(forProduct: product) { productIdentifier in
            completionHandler(productIdentifier)
        }
    }
}

// Handles the important code of InAppPurchases with Apple server communication. Segmented from main class to reduce clutter
private final class InternalInAppPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // MARK: - Properties
    
    static let shared = InternalInAppPurchaseManager()
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - Fetch Products
    
    /// Keep track of the current request completionHandler
    private var productsRequestCompletionHandler: (([SKProduct]?) -> Void)?
    
    func fetchProducts(completionHandler: @escaping ([SKProduct]?) -> Void) {
        
        guard productsRequestCompletionHandler == nil else {
            // If another request is initated while there is currently an on going request, we want to reject that request
            ErrorManager.alert(forError: InAppPurchaseError.productRequestInProgress)
            completionHandler(nil)
            return
        }
        
        let request = SKProductsRequest(productIdentifiers: Set(InAppPurchaseProduct.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
        productsRequestCompletionHandler = completionHandler
    }
    
    /// Get available products from Apple Servers
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products.sorted(by: { product1, product2 in
            // The product with a product identifier that is closer to index 0 of the InAppPurchase enum allCases should come first. If a product identifier is unknown, the known one comes first. If both product identiifers are known, we have the <= productIdentifer come first.
            
            let indexOfProduct1: Int = InAppPurchaseProduct.allCases.firstIndex(of: InAppPurchaseProduct(rawValue: product1.productIdentifier) ?? InAppPurchaseProduct.unknown)!
            let indexOfProduct2: Int = InAppPurchaseProduct.allCases.firstIndex(of: InAppPurchaseProduct(rawValue: product2.productIdentifier) ?? InAppPurchaseProduct.unknown)!
            let indexOfUnknown: Int = InAppPurchaseProduct.allCases.firstIndex(of: InAppPurchaseProduct.unknown)!
            
            // the product identifiers aren't known to us. Therefore we should sort based upon the product identifier strings themselves
            if indexOfProduct1 == indexOfUnknown && indexOfProduct2 == indexOfUnknown {
                return product1.productIdentifier <= product2.productIdentifier
            }
            // only the product identifier of product1 isn't known to us
            else if indexOfProduct1 == indexOfUnknown {
                // since product2 is known and product1 isn't, product2 should come first
                return false
            }
            // only the product identifier of product2 isn't known to us
            else if indexOfProduct2 == indexOfUnknown {
                // since product1 is known and product2 isn't, product1 should come first
                return true
            }
            // the product identifiers are both known to us
            else {
                // the product with product identifier that has the lower index in .allCases of the InAppPurchase enum comes first
                return indexOfProduct1 <= indexOfProduct2
            }})
        
        DispatchQueue.main.async {
            // If we didn't retrieve any products, return an error
            if products.count >= 1 {
                self.productsRequestCompletionHandler?(products)
            }
            else {
                if self.productsRequestCompletionHandler != nil {
                    ErrorManager.alert(forError: InAppPurchaseError.productRequestNotFound)
                }
                self.productsRequestCompletionHandler?(nil)
            }
            // Call everything on async thread. Otherwise, productsRequestCompletionHandler will be set to nil slightly before productsRequestCompletionHandler(result, result) can be called, therefore not calling the completionHandler.
            self.productsRequestCompletionHandler = nil
        }
    }
    
    /// Observe if there was an error when retrieving the products
    func request(_ request: SKRequest, didFailWithError error: Error) {
        // return to completion handler then reset for next products request
        DispatchQueue.main.async {
            if self.productsRequestCompletionHandler != nil {
                ErrorManager.alert(forError: InAppPurchaseError.productRequestFailed)
            }
            self.productsRequestCompletionHandler?(nil)
            self.productsRequestCompletionHandler = nil
        }
    }
    
    // MARK: - Purchase a Product
    
    private var productPurchaseCompletionHandler: ((String?) -> Void)?
    
    // Prompt a product payment transaction
    func purchase(forProduct product: SKProduct, completionHandler: @escaping ((String?) -> Void)) {
        
        // TO DO test interrupted purchases, restored purchases, 'Ask to Buy' purchases, failed purchases, etc.
        guard FamilyConfiguration.isFamilyHead else {
            ErrorManager.alert(forError: InAppPurchaseError.purchasePermission)
            completionHandler(nil)
            return
        }
        
        guard SKPaymentQueue.canMakePayments() else {
            ErrorManager.alert(forError: InAppPurchaseError.purchaseRestricted)
            completionHandler(nil)
            return
        }
        
        // Make sure there is no purchase transaction ongoing or pending transactions in the payment queue before trying to start a new purchase
        guard productPurchaseCompletionHandler == nil && SKPaymentQueue.default().transactions.count == 0 else {
            ErrorManager.alert(forError: InAppPurchaseError.purchaseInProgress)
            completionHandler(nil)
            return
        }
        
        productPurchaseCompletionHandler = completionHandler
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // Observe a transaction state
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
      print("queue called: \(transactions.count)")
        
        // If either of these are nil, there is not an ongoing manual request by a user (as there is no callback to provide information to). Therefore, we are dealing with asyncronously bought transactions (e.g. renewals, phone died while purchasing, etc.) that should be processed in the background.
        guard let completionHandler = productPurchaseCompletionHandler else {
            print("async background")
            // These are transactions that we know have completely failed. Clear them.
            let failedTransactionsInQueue = transactions.filter { transaction in
                return transaction.transactionState == .failed
            }
            failedTransactionsInQueue.forEach { failedTransaction in
                print("failed transaction background")
                SKPaymentQueue.default().finishTransaction(failedTransaction)
            }
            
            // These are transactions that we know have completely succeeded. Process and clear them.
            let completedTransactionsInQueue = transactions.filter { transaction in
                return transaction.transactionState == .purchased || transaction.transactionState == .restored
            }
            
            // If we have succeeded transactions, silently contact the server in the background to let it know
            guard completedTransactionsInQueue.count >= 1 else {
                return
            }
            SubscriptionRequest.create(invokeErrorManager: false) { requestWasSuccessful, _ in
                guard requestWasSuccessful else {
                    return
                }
                
                // If successful, then we know ALL of the completed transactions in queue have been updated
                completedTransactionsInQueue.forEach { completedTransaction in
                    print("compelted transaction background")
                    SKPaymentQueue.default().finishTransaction(completedTransaction)
                }
            }
            return
        }
        
        print("sync foreground")
        
        // We know there is an ongoing synchronous request by the user for a transaction
        for transaction in transactions {
            // We use the main thread so completion handler is on main thread
            DispatchQueue.main.async {
                switch transaction.transactionState {
                case .purchasing:
                    // A transaction that is being processed by the App Store.
                    
                    //  Don't finish transaction, it is still in a processing state
                    break
                case .purchased:
                    // A successfully processed transaction.
                    // Your application should provide the content the user purchased.
                    
                    SubscriptionRequest.create(invokeErrorManager: true) { requestWasSuccessful, _ in
                        guard requestWasSuccessful else {
                            completionHandler(nil)
                            self.productPurchaseCompletionHandler = nil
                            return
                        }
                        
                        completionHandler(transaction.payment.productIdentifier)
                        self.productPurchaseCompletionHandler = nil
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                case .deferred:
                    // A transaction that is in the queue, but its final status is pending external action such as Ask to Buy
                    // Update your UI to show the deferred state, and wait for another callback that indicates the final status.
                    
                    ErrorManager.alert(forError: InAppPurchaseError.purchaseDeferred)
                    completionHandler(nil)
                    self.productPurchaseCompletionHandler = nil
                    //  Don't finish transaction, it is still in a processing state
                case .restored:
                    // if we have a productPurchaseCompletionHandler, then we lock the transaction queue from other things from interfering
                    // A transaction that restores content previously purchased by the user.
                    // Read the original property to obtain information about the original purchase.
                    
                    SubscriptionRequest.create(invokeErrorManager: true) { requestWasSuccessful, _ in
                        guard requestWasSuccessful else {
                            completionHandler(nil)
                            self.productPurchaseCompletionHandler = nil
                            return
                        }
                        
                        completionHandler(transaction.payment.productIdentifier)
                        self.productPurchaseCompletionHandler = nil
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                case .failed:
                    // A failed transaction.
                    // Check the error property to determine what happened.
                    
                    ErrorManager.alert(forError: InAppPurchaseError.purchaseFailed)
                    completionHandler(nil)
                    self.productPurchaseCompletionHandler = nil
                    SKPaymentQueue.default().finishTransaction(transaction)
                @unknown default:
                    ErrorManager.alert(forError: InAppPurchaseError.purchaseUnknown)
                    completionHandler(nil)
                    self.productPurchaseCompletionHandler = nil
                    // Don't finish transaction, we can't confirm if it succeeded or failed
                }
                
            }
        }
    }
}
