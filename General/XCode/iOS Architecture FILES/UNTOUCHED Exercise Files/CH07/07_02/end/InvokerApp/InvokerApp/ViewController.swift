//
//  ViewController.swift
//  InvokerApp
//
//  Created by Nyisztor, Karoly on 6/2/18.
//  Copyright © 2018 Nyisztor, Karoly. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTapped(_ sender: Any) {
        guard let listenerAppURL = URL(string: "listenerapp://"),
        UIApplication.shared.canOpenURL(listenerAppURL) else {
                print("Could not open listenerapp://")
                return
        }

        UIApplication.shared.open(listenerAppURL, options: [:]) { (success) in
            if success == false {
                print("Could not open URL \(listenerAppURL.absoluteString)")
            }
        }
    }
    
}

