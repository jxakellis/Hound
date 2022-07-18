//
//  Subscription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/14/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum InAppPurchaseProduct: String, CaseIterable {
    case unknown = "com.jonathanxakellis.hound.unknown"
    case `default` = "com.jonathanxakellis.hound.default"
    case twoFMTwoDogs = "com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly"
    case fourFMFourDogs = "com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly"
    case sixFMSixDogs = "com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly"
    case tenFMTenDogs = "com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly"
    
    /// Expands the product;s localizedTitle to add emojis, as Apple won't let you add emojis.
    static func localizedTitleExpanded(forInAppPurchaseProduct inAppPurchaseProduct: InAppPurchaseProduct) -> String {
        switch inAppPurchaseProduct {
        case .unknown:
            return VisualConstant.TextConstant.unknownText
        case .`default`:
            return "Single 🧍‍♂️"
        case .twoFMTwoDogs:
            return "Duo 👫"
        case .fourFMFourDogs:
            return "Quad 👨‍👩‍👧‍👦"
        case .sixFMSixDogs:
            return "Hexad 👨‍👩‍👧‍👦👫"
        case .tenFMTenDogs:
            return "Decad 👨‍👩‍👧‍👦👨‍👩‍👧‍👦👫"
        }
    }
    
    /// Expand the product's localizedDescription to add detail, as Apple limits their length
    static func localizedDescriptionExpanded(forInAppPurchaseProduct inAppPurchaseProduct: InAppPurchaseProduct) -> String {
        switch inAppPurchaseProduct {
        case .unknown:
            return VisualConstant.TextConstant.unknownText
        case .`default`:
            return "Explore Hound's default subscription tier by yourself with up to two different dogs"
        case .twoFMTwoDogs:
            return "Take the first step in creating your multi-user Hound family. Unlock up to two different family members and dogs."
        case .fourFMFourDogs:
            return "Get the essential friends and family to join your Hound family. Upgrade to up to four different family members and dogs"
        case .sixFMSixDogs:
            return "Expand your Hound family to all new heights. Add up to six different family members and dogs."
        case .tenFMTenDogs:
            return "Take full advantage of Hound and make your family into its best (and biggest) self. Boost up to ten different family members and dogs."
        }
    }
}

final class Subscription: NSObject {
    
    // MARK: - Main
    
    init(
        transactionId: Int?,
        product: InAppPurchaseProduct,
        userId: String?,
        subscriptionPurchaseDate: Date?,
        subscriptionExpiration: Date?,
        subscriptionNumberOfFamilyMembers: Int,
        subscriptionNumberOfDogs: Int,
        subscriptionIsActive: Bool
    ) {
        self.transactionId = transactionId
        self.product = product
        self.userId = userId
        self.subscriptionPurchaseDate = subscriptionPurchaseDate
        self.subscriptionExpiration = subscriptionExpiration
        self.subscriptionNumberOfFamilyMembers = subscriptionNumberOfFamilyMembers
        self.subscriptionNumberOfDogs = subscriptionNumberOfDogs
        self.subscriptionIsActive = subscriptionIsActive
        super.init()
    }
    
    /// Assume array of family properties
    convenience init(fromBody body: [String: Any]) {
        let transactionId = body[ServerDefaultKeys.transactionId.rawValue] as? Int
        
        let product = InAppPurchaseProduct(rawValue: body[ServerDefaultKeys.productId.rawValue] as? String ?? InAppPurchaseProduct.unknown.rawValue) ?? ClassConstant.SubscriptionConstant.defaultSubscriptionProduct
        
        let userId = body[ServerDefaultKeys.userId.rawValue] as? String
        
        var subscriptionPurchaseDate: Date?
        if let subscriptionPurchaseDateString = body[ServerDefaultKeys.subscriptionPurchaseDate.rawValue] as? String {
            subscriptionPurchaseDate = ResponseUtils.dateFormatter(fromISO8601String: subscriptionPurchaseDateString)
        }
        
        var subscriptionExpiration: Date?
        if let subscriptionExpirationString = body[ServerDefaultKeys.subscriptionExpiration.rawValue] as? String {
            subscriptionExpiration = ResponseUtils.dateFormatter(fromISO8601String: subscriptionExpirationString)
        }
        
        let subscriptionNumberOfFamilyMembers = body[ServerDefaultKeys.subscriptionNumberOfFamilyMembers.rawValue] as? Int ?? ClassConstant.SubscriptionConstant.defaultSubscriptionNumberOfFamilyMembers
        
        let subscriptionNumberOfDogs = body[ServerDefaultKeys.subscriptionNumberOfDogs.rawValue] as? Int ?? ClassConstant.SubscriptionConstant.defaultSubscriptionNumberOfDogs
        
        let subscriptionIsActive = body[ServerDefaultKeys.subscriptionIsActive.rawValue] as? Bool ?? false

        self.init(
            transactionId: transactionId,
            product: product,
            userId: userId,
            subscriptionPurchaseDate: subscriptionPurchaseDate,
            subscriptionExpiration: subscriptionExpiration,
            subscriptionNumberOfFamilyMembers: subscriptionNumberOfFamilyMembers,
            subscriptionNumberOfDogs: subscriptionNumberOfDogs,
            subscriptionIsActive: subscriptionIsActive
        )
    }
    
    // MARK: - Properties
    
    /// Transaction Id that of the subscription purchase
    private(set) var transactionId: Int?
    
    /// Product Id that the subscription purchase was for
    private(set) var product: InAppPurchaseProduct
    
    /// User Id of the user that purchased the subscription
    private(set) var userId: String?
    
    /// Date at which the subscription was purchased and completed processing on Hound's server
    private(set) var subscriptionPurchaseDate: Date?
    
    /// Date at which the subscription will expire
    private(set) var subscriptionExpiration: Date?
    
    /// How many family members the subscription allows into the family
    private(set) var subscriptionNumberOfFamilyMembers: Int
    
    /// How many dogs the subscription allows into the family
    private(set) var subscriptionNumberOfDogs: Int
    
    /// Indicates whether or not this subscription is the one thats active for the family
    var subscriptionIsActive: Bool
    
}
