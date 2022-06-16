//
//  InAppPurchaseManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/13/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation
import StoreKit

class InAppPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    enum InAppPurchase: String, CaseIterable {
        case twoFMTwoDogs = "com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly"
        case fourFMFourDogs = "com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly"
        case sixFMSixDogs = "com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly"
        case tenFMTenDogs = "com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly"
    }
    
    static let shared = InAppPurchaseManager()
    
    private var products = [SKProduct]()
    
    private var productBeingPurchased: SKProduct?
    
    /// Keep track of the current request
    private var currentRequest: SKProductsRequest?
    
    /// Keep track of the current request completionHandelr
    private var currentRequestCompletionHandler: (([SKProduct]?) -> Void)?

    private override init() {
        super.init()
    }
    
    func fetchProducts(completionHandler: @escaping ([SKProduct]?) -> Void) {
        // If another request is initated while there is currently an on going request, we want to invalidate that request. Otherwise, their completionHandlers could mingle and return to the wrong function invokes.
        currentRequest?.cancel()
        
        let request = SKProductsRequest(productIdentifiers: Set(InAppPurchase.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
        currentRequest = request
        currentRequestCompletionHandler = completionHandler
    }
    
    // Get available products from Apple Servers
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        products = response.products
        
        print("Count: \(products.count)")
        
        for product in products {
            print("Found product: \(product.productIdentifier)")
        }
        
        // return to completion handler then reset for next products request
        DispatchQueue.main.async {
            self.currentRequestCompletionHandler?(self.products)
            // we have to call these lines on the async thread as well because if we don't then currentRequestCompletionHandler will be set to nil slightly before this piece of async code executes, therefore not calling the completionHandler at all
            self.currentRequest = nil
            self.currentRequestCompletionHandler = nil
        }
    }
    
    // Observe if there was an error when retrieving the products
    func request(_ request: SKRequest, didFailWithError error: Error) {
        // TO DO implement error message
        print("Product request didFailWithError: \(error)")
        
        // return to completion handler then reset for next products request
        DispatchQueue.main.async {
            self.currentRequestCompletionHandler?(nil)
            // we have to call these lines on the async thread as well because if we don't then currentRequestCompletionHandler will be set to nil slightly before this piece of async code executes, therefore not calling the completionHandler at all
            self.currentRequest = nil
            self.currentRequestCompletionHandler = nil
        }
    }
    
    // Prompt a product payment transaction
    func purchase(product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else {
            // TO DO handle case if can't make payments
            return
        }
        
        productBeingPurchased = product
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        
    }
    
    // Observe a transaction state
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            
            // make sure we are only handling the transaction of the product being purhcased
            guard transaction.payment.productIdentifier == self.productBeingPurchased?.productIdentifier else {
                continue
            }
            
            // (for example) the product for the target transaction in the loop that was purchased (case .purchased below) is not necessarily the payment that was queued above
            switch transaction.transactionState {
                // TO DO implement messages for non .purchased cases
                // TO DO implement server api endpoint for .purchased
                // TO DO implement server api endpoint for .restored
            case .purchasing:
                break
            case .purchased:
                // handle purchase
                // Need to be very explict about the transaction payment and what product its for. For example: you queue a purchase then your phone dies. This purchase isn't completed but might still be in the queue. If it's not handled, then could accidently send through a transaction that wasn't actually completed
                handlePurchase(transaction.payment.productIdentifier)
            case .deferred:
                break
            case .restored:
                //
                break
            case .failed:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func handlePurchase(_ id: String) {
        // TO DO handle purchase
    }
}
