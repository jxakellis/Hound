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
class InAppPurchaseManager {
    
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
    
    // TO DO implement function to restore subscriptions/purchases
}

private enum InAppPurchase: String, CaseIterable {
    case twoFMTwoDogs = "com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly"
    case fourFMFourDogs = "com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly"
    case sixFMSixDogs = "com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly"
    case tenFMTenDogs = "com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly"
    case unknown = "com.jonathanxakellis.hound.unknown"
}

// Handles the important code of InAppPurchases with Apple server communication. Segmented from main class to reduce clutter
private class InternalInAppPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // MARK: Properties
    
    static let shared = InternalInAppPurchaseManager()
    
    // MARK: Fetch Products
    
    /// Keep track of the current request
    private var currentProductsRequest: SKProductsRequest?
    
    /// Keep track of the current request completionHandelr
    private var currentProductsRequestCompletionHandler: (([SKProduct]?) -> Void)?
    
    func fetchProducts(completionHandler: @escaping ([SKProduct]?) -> Void) {
        // If another request is initated while there is currently an on going request, we want to invalidate that request. Otherwise, their completionHandlers could mingle and return to the wrong function invokes.
        currentProductsRequest?.cancel()
        
        let request = SKProductsRequest(productIdentifiers: Set(InAppPurchase.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
        currentProductsRequest = request
        currentProductsRequestCompletionHandler = completionHandler
    }
    
    // Get available products from Apple Servers
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products.sorted(by: { product1, product2 in
            // The product with a product identifier that is closer to index 0 of the InAppPurchase enum allCases should come first. If a product identifier is unknown, the known one comes first. If both product identiifers are known, we have the <= productIdentifer come first.
            
            let indexOfProduct1: Int = InAppPurchase.allCases.firstIndex(of: InAppPurchase(rawValue: product1.productIdentifier) ?? InAppPurchase.unknown)!
            let indexOfProduct2: Int = InAppPurchase.allCases.firstIndex(of: InAppPurchase(rawValue: product2.productIdentifier) ?? InAppPurchase.unknown)!
            let indexOfUnknown: Int = InAppPurchase.allCases.firstIndex(of: InAppPurchase.unknown)!
            
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
        
        print("Count: \(products.count)")
        
        for product in products {
            print("Found product: \(product.productIdentifier)")
        }
        
        // return to completion handler then reset for next products request
        DispatchQueue.main.async {
            self.currentProductsRequestCompletionHandler?(products)
            // we have to call these lines on the async thread as well because if we don't then currentProductsRequestCompletionHandler will be set to nil slightly before this piece of async code executes, therefore not calling the completionHandler at all
            self.currentProductsRequest = nil
            self.currentProductsRequestCompletionHandler = nil
        }
    }
    
    // Observe if there was an error when retrieving the products
    func request(_ request: SKRequest, didFailWithError error: Error) {
        // TO DO implement error message
        print("Product request didFailWithError: \(error)")
        
        // return to completion handler then reset for next products request
        DispatchQueue.main.async {
            self.currentProductsRequestCompletionHandler?(nil)
            // we have to call these lines on the async thread as well because if we don't then currentProductsRequestCompletionHandler will be set to nil slightly before this piece of async code executes, therefore not calling the completionHandler at all
            self.currentProductsRequest = nil
            self.currentProductsRequestCompletionHandler = nil
        }
    }
    
    // MARK: Purchase a Product
    
    private var currentProductPurchase: SKProduct?
    
    private var currentProductPurchaseIsLocked: Bool = false
    
    private var currentProductPurchaseCompletionHandler: ((String?) -> Void)?
    
    // Prompt a product payment transaction
    func purchase(forProduct product: SKProduct, completionHandler: @escaping ((String?) -> Void)) {
        guard SKPaymentQueue.canMakePayments() else {
            // TO DO handle case if can't make payments
            return
        }
        
      // TO DO reject cases where there is a transaction in progress
        
        currentProductPurchase = product
        currentProductPurchaseCompletionHandler = completionHandler
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    // Observe a transaction state
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // make sure we are only handling the transaction of the product being purhcased
        guard currentProductPurchaseIsLocked == false else {
            return
        }
        
        for transaction in transactions where transaction.payment.productIdentifier == self.currentProductPurchase?.productIdentifier {
            // We use the main thread so completion handler is on main thread
            DispatchQueue.main.async {
                // Need to be very explict about the transaction payment and what product its for. For example: you queue a purchase then your phone dies. This purchase isn't completed but might still be in the queue. If it's not handled, then could accidently send through a transaction that wasn't actually completed
                
                // Use guard statement again. This is because we are executing on the async thread, so inital guard statement could be passed because currentProductPurchaseIsLocked is set to true milliseconds after.
                guard self.currentProductPurchaseIsLocked == false else {
                    return
                }
                
                switch transaction.transactionState {
                case .purchasing:
                    // A transaction that is being processed by the App Store.
                    
                    // transaction is not finished, don't call finishTransaction
                    break
                case .purchased:
                    self.currentProductPurchaseIsLocked = true
                    // A successfully processed transaction.
                    // Your application should provide the content the user purchased.
                    
                    // TO DO implement and test server api endpoint for .purchased
                    SubscriptionRequest.create(invokeErrorManager: true, forTransaction: transaction) { receiptId, _ in
                        guard receiptId != nil else {
                            return
                        }
                        
                        self.currentProductPurchaseCompletionHandler?(transaction.payment.productIdentifier)
                        self.finishTransaction(forTransaction: transaction)
                    }
                case .deferred:
                    // A transaction that is in the queue, but its final status is pending external action such as Ask to Buy
                    // Update your UI to show the deferred state, and wait for another callback that indicates the final status.
                    
                    // TO DO update UI to show deferred state
                    self.currentProductPurchaseCompletionHandler?(nil)
                    // transaction is not finished, don't call finishTransaction
                case .restored:
                    self.currentProductPurchaseIsLocked = true
                    // A transaction that restores content previously purchased by the user.
                    // Read the original property to obtain information about the original purchase.
                    
                    // TO DO implement and test server api endpoint for .restored
                    SubscriptionRequest.create(invokeErrorManager: true, forTransaction: transaction) { receiptId, _ in
                        guard receiptId != nil else {
                            return
                        }
                        
                        self.currentProductPurchaseCompletionHandler?(transaction.payment.productIdentifier)
                        self.finishTransaction(forTransaction: transaction)
                    }
                case .failed:
                    // A failed transaction.
                    // Check the error property to determine what happened.
                    
                    // TO DO show error message about the failure reason
                    self.currentProductPurchaseCompletionHandler?(nil)
                    self.finishTransaction(forTransaction: transaction)
                @unknown default:
                    // TO DO show error message about unknown case
                    self.currentProductPurchaseCompletionHandler?(nil)
                    self.finishTransaction(forTransaction: transaction)
                }
                
            }
        }
    }
    
    /// Invoke this function when a transaction has reached the end of its processing. This would be in the case that it was successfully purchased and the Hound servers successfully updated, successfully restored and Hound servers sucessfully updated, or a failed ( or unknown) purchase that has been discarded.
    private func finishTransaction(forTransaction transaction: SKPaymentTransaction) {
        currentProductPurchase = nil
        currentProductPurchaseIsLocked = false
        currentProductPurchaseCompletionHandler = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
