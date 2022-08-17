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
        purchaseDate: Date?,
        expirationDate: Date?,
        numberOfFamilyMembers: Int,
        numberOfDogs: Int,
        isActive: Bool,
        isAutoRenewing: Bool?
    ) {
        self.transactionId = transactionId
        self.product = product
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.numberOfFamilyMembers = numberOfFamilyMembers
        self.numberOfDogs = numberOfDogs
        self.isActive = isActive
        self.isAutoRenewing = isAutoRenewing
        super.init()
    }
    
    /// Assume array of family properties
    convenience init(fromBody body: [String: Any]) {
        let transactionId = body[ServerDefaultKeys.transactionId.rawValue] as? Int
        
        let product = InAppPurchaseProduct(rawValue: body[ServerDefaultKeys.productId.rawValue] as? String ?? InAppPurchaseProduct.unknown.rawValue) ?? ClassConstant.SubscriptionConstant.defaultSubscriptionProduct
        
        var purchaseDate: Date?
        if let purchaseDateString = body[ServerDefaultKeys.purchaseDate.rawValue] as? String {
            purchaseDate = ResponseUtils.dateFormatter(fromISO8601String: purchaseDateString)
        }
        
        var expirationDate: Date?
        if let expirationDateString = body[ServerDefaultKeys.expirationDate.rawValue] as? String {
            expirationDate = ResponseUtils.dateFormatter(fromISO8601String: expirationDateString)
        }
        
        let numberOfFamilyMembers = body[ServerDefaultKeys.numberOfFamilyMembers.rawValue] as? Int ?? ClassConstant.SubscriptionConstant.defaultSubscriptionNumberOfFamilyMembers
        
        let numberOfDogs = body[ServerDefaultKeys.numberOfDogs.rawValue] as? Int ?? ClassConstant.SubscriptionConstant.defaultSubscriptionNumberOfDogs
        
        let isActive = body[ServerDefaultKeys.isActive.rawValue] as? Bool ?? false
        
        let isAutoRenewing = body[ServerDefaultKeys.isAutoRenewing.rawValue] as? Bool

        self.init(
            transactionId: transactionId,
            product: product,
            purchaseDate: purchaseDate,
            expirationDate: expirationDate,
            numberOfFamilyMembers: numberOfFamilyMembers,
            numberOfDogs: numberOfDogs,
            isActive: isActive,
            isAutoRenewing: isAutoRenewing
        )
    }
    
    // MARK: - Properties
    
    /// Transaction Id that of the subscription purchase
    private(set) var transactionId: Int?
    
    /// Product Id that the subscription purchase was for
    private(set) var product: InAppPurchaseProduct
    
    /// Date at which the subscription was purchased and completed processing on Hound's server
    private(set) var purchaseDate: Date?
    
    /// Date at which the subscription will expire
    private(set) var expirationDate: Date?
    
    /// How many family members the subscription allows into the family
    private(set) var numberOfFamilyMembers: Int
    
    /// How many dogs the subscription allows into the family
    private(set) var numberOfDogs: Int
    
    /// Indicates whether or not this subscription is the one thats active for the family
    var isActive: Bool
    
    /// Indicates whether or not this subscription will renew itself when it expires
    private(set) var isAutoRenewing: Bool?
    
}
