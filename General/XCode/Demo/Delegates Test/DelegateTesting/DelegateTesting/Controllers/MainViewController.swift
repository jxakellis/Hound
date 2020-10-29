//
//  MainViewController.swift
//  DelegateTesting
//
//  Created by Jonathan Xakellis on 10/13/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, ShopViewControllerDelegate, TableViewControllerDelegate {
    
    
    
    @IBOutlet weak var shoppedItemsView: UIView!
    
    var mainViewTableSelectedItemViewController = MainViewTableSelectedItemViewController()
    
    var shoppedItemsList = ItemList()
    var shoppedItemsViewController = TableViewController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        shoppedItemsViewController.updateTable(newItemList: shoppedItemsList)
    }
    
    //MARK: - Delegates and Data Sources
    
    func didChooseItem(item: Item, amountOfItem: Int) {
        shoppedItemsList.add(item: item, amountTimesAdded: amountOfItem)
        shoppedItemsViewController.updateTable(newItemList: shoppedItemsList)
    }
    
    func didSelectTableRow(rowSelected: Int, rowSelectedItem: Item) {
        performSegue(withIdentifier: "tableSelectedItem", sender: self)
        mainViewTableSelectedItemViewController.sentTableRowItem = rowSelectedItem
        mainViewTableSelectedItemViewController.sentTableRow = rowSelected
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
            shoppedItemsViewController.delegate = self
        }
        if segue.identifier == "tableSelectedItem"{
            mainViewTableSelectedItemViewController = segue.destination as! MainViewTableSelectedItemViewController
        }
    }
    
    // MARK: - Other Buttons

    @IBAction func clearShoppedItems(_ sender: Any) {
        shoppedItemsList.clearList()
        shoppedItemsViewController.updateTable(newItemList: shoppedItemsList)
    }

}



