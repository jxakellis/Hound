//
//  ViewController.swift
//  CollectionViews
//
//  Created by Todd Perkins on 10/2/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var item: Item?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(item?.title)")
    }

}

