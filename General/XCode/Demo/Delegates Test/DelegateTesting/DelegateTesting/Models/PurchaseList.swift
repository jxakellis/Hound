//
//  PurchaseList.swift
//  DelegateTesting
//
//  Created by Jonathan Xakellis on 10/13/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class PurchaseItem {
    var purchaseName: String
    var purchaseDescription: String
    var purchaseValue: Int
    
    init(item: Item){
        purchaseName = item.itemName
        purchaseDescription = item.itemDescription
        purchaseValue = item.itemValue
    }
}

class PurchaseList {
    var list: [PurchaseItem] = []
    var lastSelection = "None"
    
    func add(purchasedItem: PurchaseItem){
            list += [purchasedItem]
        lastSelection = purchasedItem.purchaseName
    }
    
    func add(purchasedItemName: String, purchasedItemDescription: String, purchasedItemValue: Int){
        let item = PurchaseItem(item: Item(name: purchasedItemName, description: purchasedItemDescription, value: purchasedItemValue))
        list += [item]
        lastSelection = item.purchaseName
    }
}
