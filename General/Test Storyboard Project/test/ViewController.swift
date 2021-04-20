//
//  ViewController.swift
//  test
//
//  Created by Jonathan Xakellis on 3/28/21.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var but: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            self.but.layer.cornerRadius = self.but.frame.size.width
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+8.0) {
            self.but.setImage(nil, for: .normal)
        }
        
    }
    


}

