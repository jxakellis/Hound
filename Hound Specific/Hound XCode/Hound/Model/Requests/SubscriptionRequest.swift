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
    
    static let baseURLWithoutParams: URL = FamilyRequest.baseURLWithFamilyId.appendingPathComponent("/subscription")
    
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
        let base64ReceiptData: String = transaction
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(base64ReceiptData)")
        InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: [ : ]) { responseBody, responseStatus in
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
    static func create(invokeErrorManager: Bool, forTransaction transaction: SKPaymentTransaction, completionHandler: @escaping (String?, ResponseStatus) -> Void) {
        
        SubscriptionRequest.internalCreate(invokeErrorManager: invokeErrorManager, forTransaction: transaction) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // check id
                if let subscriptionId = responseBody?[ServerDefaultKeys.result.rawValue] as? String {
                    completionHandler(subscriptionId, responseStatus)
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
