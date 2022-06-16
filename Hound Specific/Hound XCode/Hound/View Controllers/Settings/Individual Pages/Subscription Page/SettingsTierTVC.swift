//
//  SettingsSubscriptionTierTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/15/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit
import StoreKit

class SettingsSubscriptionTierTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var subscriptionTierTitleLabel: ScaledUILabel!
    @IBOutlet private weak var subscriptionTierDescriptionLabel: ScaledUILabel!
    @IBOutlet private weak var subscriptionTierPricingLabel: ScaledUILabel!
    
    // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    func setup(forSKProduct SKProduct: SKProduct) {
        
        guard SKProduct.subscriptionPeriod != nil else {
            return
        }
        
        // Add emojis to the localizedTitle since Apple won't let you normally.
        var localizedTitleWithEmojis: String {
            switch SKProduct.productIdentifier {
            case "com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly":
                return SKProduct.localizedTitle.appending(" 👫")
            case "com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly":
                return SKProduct.localizedTitle.appending(" 👨‍👩‍👧‍👦")
            case "com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly":
                return SKProduct.localizedTitle.appending(" 👨‍👩‍👧‍👦👫")
            case "com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly":
                return SKProduct.localizedTitle.appending(" 👨‍👩‍👧‍👦👨‍👩‍👧‍👦👫")
            default:
                return SKProduct.localizedTitle
            }
        }
        
        // Expand descriptions as Apple limits to 100 characters
        var localizedDescriptionExpanded: String {
            switch SKProduct.productIdentifier {
            case "com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly":
                return "Take the first step in creating your multi-user Hound family. Unlock up to two different family members and dogs."
            case "com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly":
                return "Get the essential friends and family to join your Hound family. Upgrade to up to four different family members and dogs"
            case "com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly":
                return "Expand your Hound family to all new heights. Add up to six different family members and dogs."
            case "com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly":
                return "Take full advantage of Hound and make your family into its best (and biggest) self. Boost up to ten different family members and dogs."
            default:
                return SKProduct.localizedDescription
            }
           
        }
        
        subscriptionTierTitleLabel.text = localizedTitleWithEmojis
        subscriptionTierDescriptionLabel.text = localizedDescriptionExpanded
        
        // now we have to determine what the pricing is like
        // first get the properties
        let subscriptionPriceWithSymbol = "\(SKProduct.priceLocale.currencySymbol ?? "")\(SKProduct.price)"
        let subscriptionPeriod = convertSubscriptionPeriodUnits(forUnit: SKProduct.subscriptionPeriod!.unit, forNumberOfUnits: SKProduct.subscriptionPeriod!.numberOfUnits)
        
        // no free trial
        if SKProduct.introductoryPrice == nil || SKProduct.introductoryPrice!.paymentMode != .freeTrial {
            subscriptionTierPricingLabel.text = "Enjoy all \(SKProduct.localizedTitle) has to offer for \(subscriptionPriceWithSymbol) per \(subscriptionPeriod)"
        }
        // tier offers a free trial
        else {
            print(SKProduct.introductoryPrice!.subscriptionPeriod.unit)
            print(SKProduct.introductoryPrice!.subscriptionPeriod.numberOfUnits)
            let freeTrialSubscriptionPeriod = convertSubscriptionPeriodUnits(forUnit: SKProduct.introductoryPrice!.subscriptionPeriod.unit, forNumberOfUnits: SKProduct.introductoryPrice!.subscriptionPeriod.numberOfUnits)
            
            subscriptionTierPricingLabel.text = "Begin with a free \(freeTrialSubscriptionPeriod) trial then continue your \(SKProduct.localizedTitle) experience for \(subscriptionPriceWithSymbol) per \(subscriptionPeriod)"
        }
    }
    
    /// Converts from units (time period: day, week, month, year) and numberOfUnits (duration: 1, 2, 3...) to the correct string. For example: unit = 2 & numerOfUnits = 3 -> "three (3) months"; unit = 1 & numerOfUnits = 2 -> "two (2) weeks"
    private func convertSubscriptionPeriodUnits(forUnit unit: SKProduct.PeriodUnit, forNumberOfUnits numberOfUnits: Int) -> String {
        var string = ""
        
        // if the numberOfUnits isn't equal to 1, then we append its value. This is so we get the returns of "month", "two (2) months", "three (3) months"
        
        if numberOfUnits != 1 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            let numberOfUnitsValueSpelledOut = formatter.string(from: numberOfUnits as NSNumber)
            
            // make sure to add an extra space onto the back. we can remove that at the end.
            if numberOfUnitsValueSpelledOut != nil {
                // NO TEXT FOR ONE (1)
                // "two (2) "
                // "three (3) "
                // ...
                string.append("\(numberOfUnitsValueSpelledOut!) (\(numberOfUnits)) ")
            }
            else {
                // NO TEXT FOR 1
                // "2 "
                // "3 "
                // ...
                string.append("\(numberOfUnits) ")
            }
        }
        
        // At this point, depending on our numberOfUnits.rawValue, we have:
        // " "
        // "two (2) "
        // "three (3) "
        
        // Now we need to append the correct time period
        
        switch unit.rawValue {
        case 0:
            string.append("day")
        case 1:
            string.append("week")
        case 2:
            string.append("month")
        case 3:
            string.append("year")
        default:
            string.append("unknown⚠️")
        }
        
        // If our unit is plural (e.g. 2 days, 3 days), then we need to append that "s" to go from day -> days. Additionally we check to make sure our unit is within a valid range, otherwise we don't want to append "s" to "unknown⚠️"
        if numberOfUnits != 1 && 0...3 ~= unit.rawValue {
            string.append("s")
        }
        
        return string
        
    }

}