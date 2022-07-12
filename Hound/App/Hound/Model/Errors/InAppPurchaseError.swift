//
//  InAppPurchaseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/13/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum InAppPurchaseError: String, Error {
    // MARK: Product Request Of Available In-App Purchases
    case productRequestInProgress = "There is a In-App Purchase product request currently in progress. You are unable to initiate another In-App Purchase product request until the first one has finished processing. If the issue persists, please restart and retry."
    /// The app cannot request App Store about available IAP products for some reason.
    case productRequestFailed = "Your In-App Purchase product request has failed. If the issue persists, please restart and retry."
    /// No In-App Purchase products were returned by the App Store because none was found.
    case productRequestNotFound = "Your In-App Purchase product request did not return any results. If the issue persists, please restart and retry."
    
    // MARK: User Attempting To Make An In-App Purchase
    /// User can't make any In-App purchase because SKPaymentQueue.canMakePayment() == false
    case purchaseRestricted = "Your device is restricted from accessing the Apple App Store and is unable to make In-App Purchases. Please remove this restriction before attempting to make another In-App Purchase."
    
    /// There is a In-App Purchases in progress, so a new one cannot be initiated currentProductPurchase != nil || currentProductPurchaseCompletionHandler != nil
    case purchaseInProgress = "There is an In-App Purchase currently in progress. You are unable to initiate another In-App Purchase until the first one has finished processing. If the issue persists, please restart and retry."
    
    /// Deferred. Most likely due to pending parent approval from Ask to Buy
    case purchaseDeferred = "Your In-App Purchase is pending an approval from your parent. To complete your purchase, please have your parent respond to the request within 24 hours."
    
    /// The in app purchase failed and was not completed
    case purchaseFailed = "Your In-App Purchase has failed. If the issue persists, please restart and retry."
    
    /// Unknown error
    case purchaseUnknown = "Your In-App Purchase has experienced an unknown error. If the issue persists, please restart and retry."
}
