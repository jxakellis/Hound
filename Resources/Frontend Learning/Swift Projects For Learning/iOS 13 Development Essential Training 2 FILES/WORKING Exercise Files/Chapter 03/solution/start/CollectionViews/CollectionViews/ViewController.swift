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

    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let i = item {
            textView.text = i.title
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let i = item {
            textView.text = "\(i.title)\n\n\(i.description)"
        }
    }

}

