//
//  MainViewController.swift
//  DelegateTesting
//
//  Created by Jonathan Xakellis on 10/13/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, ShopViewControllerDelegate {
    
    @IBOutlet weak var shoppedItemsView: UIView!
    
    
    
    var shoppedItemsList = ItemList()
    var shoppedItemsViewController = TableViewController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        shoppedItemsList.add(name: "default", description: "def", value: 10)
        shoppedItemsViewController.updateTable(newItemList: shoppedItemsList)
    }
    
    //MARK: - Delegates and Data Sources
    
    func didChooseItem(item: Item, amountOfItem: Int) {
        shoppedItemsList.add(item: item, amountTimesAdded: amountOfItem)
        shoppedItemsViewController.updateTable(newItemList: shoppedItemsList)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "shop"
        {
            let shopViewController = segue.destination as! ShopViewController
            shopViewController.delegate = self
        }
        if segue.identifier == "shoppedItems"{
            shoppedItemsViewController = segue.destination as! TableViewController
        }
    }
    
    // MARK: - Other Buttons

    @IBAction func clearShoppedItems(_ sender: Any) {
        shoppedItemsList.clearList()
        shoppedItemsViewController.updateTable(newItemList: shoppedItemsList)
    }

}



