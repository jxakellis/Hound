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
        let activityview = UIActivityViewController(activityItems: ["Data From My App"], applicationActivities: nil)
        present(activityview, animated: true, completion: nil)
    }
    
}

