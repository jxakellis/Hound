//
//  ShopViewController.swift
//  DelegateTesting
//
//  Created by Jonathan Xakellis on 10/13/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ShopViewControllerDelegate {
    func didChooseItem (item: Item, amountOfItem: Int)
}

class ShopViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    var delegate:ShopViewControllerDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shopItemPicker.delegate = self
        shopItemPicker.dataSource = self
        pickerItemComponents = shopAvailableItemList.inventory
        //set default shop item
        pickedShopTuple = (shopAvailableItemList.inventory[0], 1)
    }
    
    //MARK: Navigation
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        delegate.didChooseItem(item: pickedShopTuple.0!, amountOfItem: pickedShopTuple.1)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Picker Components
    
    @IBOutlet weak var shopItemPicker: UIPickerView!
    var pickerItemComponents:[Item] = []
    var shopAvailableItemList = Shop()
    var pickedShopTuple: (Item?, Int) = (nil, 0) //itemSelected: Item?
    let numItemsAvailable = 7 //If it is <1 then picker for amount of items will not appear
    
    //MARK: - Picker View Data Sources
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if numItemsAvailable > 1 {
            return 2
        }
        else{
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch numItemsAvailable {
        case (Int.min...1):
            return pickerItemComponents.count
        default:
            if component == 0{
                return numItemsAvailable
            }
            else if component == 1{
                return pickerItemComponents.count
            }
            else{
                return 0
            }
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch numItemsAvailable {
        case (Int.min...1):
            return pickerItemComponents[row].shortStringReadout()
        default:
            if component == 0{
                return String(row+1)
            }
            else if component == 1{
                return pickerItemComponents[row].shortStringReadout()
            }
            else{
                return "Error in pickerView(titleForRow)"
            }
        }
    }
    
     //MARK: - Picker View Delegates
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //using row and componenet data
        if component == 0 { //amount
            pickedShopTuple.1 = row+1
        }
        if component == 1 { //item
            pickedShopTuple.0 = pickerItemComponents[row]
        }
    }
    
}
