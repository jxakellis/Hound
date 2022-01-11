//
//  ViewController.swift
//  UIExamples
//
//  Created by Todd Perkins on 9/25/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func didPressButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Alert Title", message: "Alert Message", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            print("all done!")
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

