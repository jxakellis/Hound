//
//  ViewController.swift
//  CollectionViews
//
//  Created by Todd Perkins on 10/2/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var item: Item?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let i = item {
            textView.text = "\(i.title)\n\n\(i.description)"
        }
    }

}

