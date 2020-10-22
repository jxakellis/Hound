//
//  ViewController.swift
//  Core Skills
//
//  Created by Todd Perkins on 9/21/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var myLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        myLabel.text = "Changed with Code!"
    }

    @IBAction func buttonWasPressed(_ sender: Any) {
        myLabel.text = "Button Pressed!"
    }
    
}

