//
//  InAppPurchaseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/13/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum InAppPurchaseError: String, Error {
    // It indicates that the product identifiers could not be found.
    case productIDsNotFound = "No In-App Purchase product identifiers were found."
    // No IAP products were returned by the App Store because none was found.
    case noProductsFound = "No In-App Purchases were found."
    // The user cancelled an initialized purchase process.
    case paymentWasCancelled = "Unable to fetch available In-App Purchase products at the moment."
    // The app cannot request App Store about available IAP products for some reason.
    case productRequestFailed = "In-App Purchase process was cancelled."
}
