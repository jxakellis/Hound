//
//  ViewController.swift
//  test
//
//  Created by Jonathan Xakellis on 3/28/21.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var but: UIButton!
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            but.layer.masksToBounds = true
            but.layer.cornerRadius = but.frame.width/2
        
        
        label.text = "Choose\nImage"
        label.layer.masksToBounds = true
      //  label.layer.cornerRadius = label.frame.width/2
        //label.layer.masksToBounds = true
    }
    


}

