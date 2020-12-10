//
//  ViewController.swift
//  TimerDemoProject
//
//  Created by Jonathan Xakellis on 12/9/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let initDate = Date()
    
    let timeInterval = TimeInterval(1)
    
    var setDate: Date?

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func changeLabel(newValue: Double){
        label.text = String(newValue)
    }

    @IBAction func buttonPressed(_ sender: Any) {
        setDate = Date()
    }
    
    @IBAction func printInfo(_ sender: Any) {
        print("CD   " + initDate.description(with: .current))
        print("TI   " + timeInterval.description)
        print("SD   " + setDate!.description(with: .current))
        if label.text != nil{
        print("L    " + label.text!)
        }
    }
    
    /*
    let alertController = UIAlertController(title: "Alert Title", message: "Alert Message", preferredStyle: .alert)
    
    let alertAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            print("all done!")
    }
    
    alertController.addAction(alertAction)
    
    alertController.addAction(UIAlertAction(title: "TWO", style: .default, handler: { (action) in
        print("all done 2!")
    }))
    
    present(alertController, animated: true, completion: nil)
     */
    
    
        
}

