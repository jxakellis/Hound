//
//  VariantTwoViewController.swift
//  TimerDemoProject
//
//  Created by Jonathan Xakellis on 12/9/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class VariantTwoViewController: UIViewController {
    
    /*
    https://www.youtube.com/watch?v=tLVTlQvKsRY
    */
    
    let timeInterval = TimeInterval(1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTimer()
    }
    
    func createTimer() {
        let timer = Timer.scheduledTimer(timeInterval: self.timeInterval,
                                         target: self,
                                         selector: #selector(fireTimer),
                                         userInfo: nil,
                                         repeats: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            timer.invalidate()
        }
    }
    
    @objc func fireTimer(){
        print("timer fired")
    }
}
