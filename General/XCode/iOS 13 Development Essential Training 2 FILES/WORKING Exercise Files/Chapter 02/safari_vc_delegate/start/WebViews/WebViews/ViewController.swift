//
//  ViewController.swift
//  WebViews
//
//  Created by Todd Perkins on 9/27/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func didPressButton(_ sender: Any) {
        if let url = URL(string: "https://bing.com") {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("finished")
    }

}

