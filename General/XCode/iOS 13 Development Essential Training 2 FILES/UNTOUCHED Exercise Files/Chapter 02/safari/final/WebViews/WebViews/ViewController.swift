//
//  ViewController.swift
//  WebViews
//
//  Created by Todd Perkins on 9/27/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func didPressButton(_ sender: Any) {
        if let url = URL(string: "https://bing.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}

