//
//  WeaponItem.swift
//  DelegateTesting
//
//  Created by Jonathan Xakellis on 10/13/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Item{
    var itemName: String
    var itemDescription: String
    var itemValue: Int
    
    init(name: String, description: String, value: Int) {
        itemName = name
        itemDescription = description
        itemValue = value
    }
}

class Shop{
    var inventory: [Item]
    init(){
        inventory = [Item(name: "sword", description: "stabby stabby", value: 15), Item(name: "mace", description: "smashy smashy", value: 25), Item(name: "shield", description: "blocky blocky", value: 40), Item(name: "dagger", description: "slashy slashy", value: 10)]
    }
}
