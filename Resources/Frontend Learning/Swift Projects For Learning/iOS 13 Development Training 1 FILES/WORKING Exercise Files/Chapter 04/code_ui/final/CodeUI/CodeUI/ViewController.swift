//
//  ViewController.swift
//  CodeUI
//
//  Created by Todd Perkins on 9/23/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let label = UILabel()
        label.frame = CGRect(x: 100, y: 100, width: 200, height: 100)
        label.text = "Hello from code!"
        view.addSubview(label)
    }


}

