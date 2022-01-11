//
//  ViewController.swift
//  UIExamples
//
//  Created by Todd Perkins on 9/25/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBAction func sliderDidChange(_ sender: UISlider) {
        progressView.progress = (sender.value / sender.maximumValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}

