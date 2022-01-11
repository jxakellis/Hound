//
//  ViewController.swift
//  UIExamples
//
//  Created by Todd Perkins on 9/25/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func onOffSwitch(_ sender: UISwitch) {
        if sender.isOn == false{
            textField.text = "Off"
        }
        else{
            textField.text = "On"
        }
        //another way to do this
        //textField.text = sender.isOn ? "On" : "Off"
    }
    
    //should be label instead lmao
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
}

