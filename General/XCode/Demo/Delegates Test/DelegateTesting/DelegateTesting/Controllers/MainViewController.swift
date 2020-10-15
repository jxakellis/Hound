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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Delegates and Data Sources
    
    func didChooseItem(items: [Item]?) {
        itemList.add(itemsList: items)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "shop"{
            let shopViewController = segue.destination as! ShopViewController
            shopViewController.delegate = self
        }
    }


}



