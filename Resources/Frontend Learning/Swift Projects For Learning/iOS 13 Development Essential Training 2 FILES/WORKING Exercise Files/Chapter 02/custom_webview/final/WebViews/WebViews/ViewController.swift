//
//  ViewController.swift
//  WebViews
//
//  Created by Todd Perkins on 9/27/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let url = URL(string: "https://bing.com") {
            webView.load(URLRequest(url: url))
        }
    }

}

