//
//  ItemModel.swift
//  DelegateTesting
//
//  Created by Jonathan Xakellis on 10/13/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol GenericItem{
    var itemName: String { get }
    var itemDescription: String { get }
    var itemValue: Int { get }
    
    init(name: String, description: String, value: Int)
    
    func stringReadout() -> String
}

class Item: GenericItem{
    var itemName: String
    var itemDescription: String
    var itemValue: Int
    
    required init(name: String, description: String, value: Int) {
        itemName = name
        itemDescription = description
        itemValue = value
    }
    
    func stringReadout() -> String {
        return "Name: \(itemName)   Description: \(itemDescription)   Value: \(itemValue)"
    }
    
    func shortStringReadout() -> String{
        return itemName + " " + itemDescription + " " + String(itemValue)
    }
}

class ItemList{
    
    var list:[Item] = []
    
    var lastSelection: Item? {
        if list.count == 0 {
            return nil
        }
        else {
            return list[list.count - 1]
        }
    }
    
    func add(item: Item, amountTimesAdded: Int = 1){
        if amountTimesAdded >= 1{
            for _ in 1...amountTimesAdded{
                list.append(item)
            }
        }
    }
    
    func add(itemsList: [Item]){
        list += itemsList
    }
    func add(name:String, description: String, value: Int, amountTimesAdded: Int = 1){
        let item = Item(name: name, description: description, value: value)
        if amountTimesAdded >= 1{
            for _ in 1...amountTimesAdded{
                list.append(item)
            }
        }
    }
    
    func clearList(){
        list = []
    }
    
}

class Shop{
    
    var inventory: [Item]
    
    required init(){
        inventory = [Item(name: "Sword", description: "Stabby Stabby", value: 15), Item(name: "Mace", description: "Smashy Smashy", value: 25), Item(name: "Shield", description: "Blocky Blocky", value: 40), Item(name: "Dagger", description: "Slashy Slashy", value: 10)]
    }
}

