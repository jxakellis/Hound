//
//  ViewController.swift
//  test
//
//  Created by Jonathan Xakellis on 3/28/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func didUpdateSegmentedControl(_ sender: Any) {
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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    


}

