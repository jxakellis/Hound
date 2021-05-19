//
//  VariantThreeViewController.swift
//  TimerDemoProject
//
//  Created by Jonathan Xakellis on 12/9/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class VariantThreeViewController: UIViewController {
    
    /*
     https://www.youtube.com/watch?v=tLVTlQvKsRY
     */
        
    let timeInterval = TimeInterval(1)
    
    let colors: [UIColor] = [.systemRed, .systemBlue,.systemPink,.systemTeal]
    
        override func viewDidLoad() {
            super.viewDidLoad()
            createTimer()
        }
    
    func createTimer(){
        var ran = 1
        //weak self prevents memory leak?
        _ = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true) { [weak self] timer in
            print("Execute timer: \(ran)")
            if ran >= 5 {
                timer.invalidate()
                print("Timer stopped")
            }
            DispatchQueue.main.async {
                self?.view.backgroundColor = self?.colors.randomElement() ?? .clear
                ran += 1
            }
        }
    }
    
}
