//
//  SKProductExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/10/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct {
    // Expands the product;s localizedTitle to add emojis, as Apple won't let you add emojis.
    var localizedTitleExpanded: String {
        switch self.productIdentifier {
        case "com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly":
            return self.localizedTitle.appending(" 👫")
        case "com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly":
            return self.localizedTitle.appending(" 👨‍👩‍👧‍👦")
        case "com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly":
            return self.localizedTitle.appending(" 👨‍👩‍👧‍👦👫")
        case "com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly":
            return self.localizedTitle.appending(" 👨‍👩‍👧‍👦👨‍👩‍👧‍👦👫")
        default:
            return self.localizedTitle
        }
    }
    
    // Expand the product's localizedDescription to add detail, as Apple limits their length
    var localizedDescriptionExpanded: String {
        switch self.productIdentifier {
        case "com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly":
            return "Take the first step in creating your multi-user Hound family. Unlock up to two different family members and dogs."
        case "com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly":
            return "Get the essential friends and family to join your Hound family. Upgrade to up to four different family members and dogs"
        case "com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly":
            return "Expand your Hound family to all new heights. Add up to six different family members and dogs."
        case "com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly":
            return "Take full advantage of Hound and make your family into its best (and biggest) self. Boost up to ten different family members and dogs."
        default:
            return self.localizedDescription
        }
        
    }
}
