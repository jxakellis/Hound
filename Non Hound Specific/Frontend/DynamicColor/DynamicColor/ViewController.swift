//
//  ViewController.swift
//  test
//
//  Created by Jonathan Xakellis on 3/28/21.
//

import UIKit

class ViewController: UIViewController {
    
    private func updateDynamic(){
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            for window in UIApplication.shared.windows{
                window.overrideUserInterfaceStyle = .light
            }
        case 1:
            for window in UIApplication.shared.windows{
                window.overrideUserInterfaceStyle = .dark
            }
        default:
            for window in UIApplication.shared.windows{
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func didUpdateSegmentedControl(_ sender: Any) {
        updateDynamic()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDynamic()
    }
    


}

