//
//  ShopViewController.swift
//  DelegateTesting
//
//  Created by Jonathan Xakellis on 10/13/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol ShopViewControllerDelegate {
    func didChooseItem (items: [Item])
}

class ShopViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    var delegate:ShopViewControllerDelegate! = nil
    var purchaseList = ItemList()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shopItemPicker.delegate = self
        shopItemPicker.dataSource = self
        pickerComponents = shopList.inventory
    }
    
    //MARK: Navigation
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        purchaseList.add(name: "test", description: "test", value: 10)
        delegate.didChooseItem(items: purchaseList.list)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Picker Components
    
    @IBOutlet weak var shopItemPicker: UIPickerView!
    var pickerComponents:[Item] = []
    var shopList = Shop()
    
    //MARK: - Picker View Data Sources
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerComponents.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerComponents[row].shortStringReadout()
    }
    
     //MARK: - Picker View Delegates
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        /*
        //using row and componenet data
        if component == 0 { //size
            beverage.itemSize = pickerComponents[component][row]
        }
        if component == 1 { //Beverage name
            beverage.itemName = pickerComponents[component][row]
        }
        
        //for a complete string each time
         beverage.itemSize = pickerComponents[0][pickerView.selectedRow(inComponent: 0)]
        beverage.itemName = pickerComponents[1][pickerView.selectedRow(inComponent: 1)]
        */
    }
    
}
