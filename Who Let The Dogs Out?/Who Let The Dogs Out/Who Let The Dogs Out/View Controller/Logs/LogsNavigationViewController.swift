//
//  LogsNavigationViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsNavigationViewController: UINavigationController{
    
    //MARK: Properties
    
    var logsViewController: LogsViewController! = nil
    
    //MARK: Main

    override func viewDidLoad() {
        super.viewDidLoad()

        logsViewController = self.viewControllers[0] as? LogsViewController
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
