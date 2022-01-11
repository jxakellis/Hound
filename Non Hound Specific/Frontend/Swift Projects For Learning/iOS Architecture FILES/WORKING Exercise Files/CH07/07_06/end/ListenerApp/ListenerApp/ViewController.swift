//
//  ViewController.swift
//  ListenerApp
//
//  Created by Karoly Nyisztor on 6/7/18.
//  Copyright © 2018 Karoly Nyisztor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "MessageReceived"), object: nil, queue: OperationQueue.main) { (notification) in
            
            if let message = notification.object as? String {
                self.label.text = message.removingPercentEncoding
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

