//
//  MainViewController.swift
//  DelegateTesting
//
//  Created by Jonathan Xakellis on 10/13/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, ShopViewControllerDelegate {
    
    var itemList = ItemList()
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var selectedItemsView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        itemList.add(name: "default", description: "default", value: 15)
        mainLabel.text = itemList.list[0].stringReadout()
    }
    
    //MARK: - Delegates and Data Sources
    
    func didChooseItem(items: [Item]) {
        itemList.add(itemsList: items)
        mainLabel.text! += "\n" + itemList.list[itemList.list.count-1].stringReadout()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "shop"
        {
            let shopViewController = segue.destination as! ShopViewController
            shopViewController.delegate = self
        }
    }


}



