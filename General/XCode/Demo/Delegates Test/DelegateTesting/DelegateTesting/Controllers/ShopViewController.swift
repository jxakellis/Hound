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

class ShopViewController: UIViewController{
    
    var delegate:ShopViewControllerDelegate! = nil
    var purchaseList = ItemList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        purchaseList.add(name: "test", description: "test", value: 10)
        delegate.didChooseItem(items: purchaseList.list)
        self.navigationController?.popViewController(animated: true)
    }
}
