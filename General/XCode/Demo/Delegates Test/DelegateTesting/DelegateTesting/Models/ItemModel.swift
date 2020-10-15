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
    
    func add(item: Item?){
        if item != nil{
        list += [item!]
        }
    }
    
    func add(itemsList: [Item]?){
        if itemsList != nil{
            for item in itemsList!{
                list += [item]
            }
       
        }
    }
    func add(name:String, description: String, value: Int){
        let item = Item(name: name, description: description, value: value)
        list += [item]
    }
    
}

class Shop{
    
    var inventory: [Item]
    
    init(){
        inventory = [Item(name: "sword", description: "stabby stabby", value: 15), Item(name: "mace", description: "smashy smashy", value: 25), Item(name: "shield", description: "blocky blocky", value: 40), Item(name: "dagger", description: "slashy slashy", value: 10)]
    }
}

