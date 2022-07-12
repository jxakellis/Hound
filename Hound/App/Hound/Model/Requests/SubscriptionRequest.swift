//
//  SubscriptionRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/23/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation
import StoreKit

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum SubscriptionRequest: RequestProtocol {
    
    static var baseURLWithoutParams: URL { return FamilyRequest.baseURLWithFamilyId.appendingPathComponent("/subscription") }
    
    // MARK: - Private Functions
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalGet(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalCreate(invokeErrorManager: Bool, forTransaction transaction: SKPaymentTransaction, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        
        // Get the receipt if it's available. If the receipt isn't available, we sent through an invalid base64EncodedString, then the server will return us an error
        var base64EncodedReceiptString: String? {
            guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path), let receiptData = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped) else {
                // Experienced an error, so no base64 encoded string
                return nil
            }
            
            return receiptData.base64EncodedString(options: [])
        }
        
        let body: [String: Any] = [ServerDefaultKeys.base64EncodedAppStoreReceiptURL.rawValue: base64EncodedReceiptString ?? "unknown"]
        InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
}

extension SubscriptionRequest {
    
    // MARK: - Public Functions
    
    /**
     TO DO complete function and documentation
     */
    static func getAll(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        
        SubscriptionRequest.internalGet(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [String: Any] {
                    // set up
                    print(result)
                    
                    completionHandler(true, responseStatus)
                }
                else {
                    completionHandler(false, responseStatus)
                }
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
     TO DO complete function and documentation
     */
    static func create(invokeErrorManager: Bool, forTransaction transaction: SKPaymentTransaction, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        SubscriptionRequest.internalCreate(invokeErrorManager: invokeErrorManager, forTransaction: transaction) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let transaction = responseBody?[ServerDefaultKeys.result.rawValue] as? [String: Any] {
                    completionHandler(transaction, responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
}
