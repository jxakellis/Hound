//
//  VariantOneViewController.swift
//  TimerDemoProject
//
//  Created by Jonathan Xakellis on 12/9/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class VariantOneViewController: UIViewController {
    
    let timeInterval = TimeInterval(1)
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true, block: { (timer) in
            print("timer VDL success")
            self.count = self.count + 1
            if self.count >= 5 {
                timer.invalidate()
            }
        })
        
    }
    
}
