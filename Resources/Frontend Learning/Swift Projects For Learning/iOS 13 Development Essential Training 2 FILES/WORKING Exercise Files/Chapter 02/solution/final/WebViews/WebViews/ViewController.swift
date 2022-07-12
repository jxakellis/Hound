//
//  ViewController.swift
//  WebViews
//
//  Created by Todd Perkins on 9/27/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textField.delegate = self
        if let url = URL(string: "https://bing.com") {
            webView.load(URLRequest(url: url))
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        webView.goBack()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let url = URL(string: textField.text ?? "") {
            webView.load(URLRequest(url: url))
        }
        textField.resignFirstResponder()
        return false
    }
    
}

