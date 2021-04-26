//
//  LogsInformationViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsInformationViewController: UIViewController {
    
    
    //MARK: IB
    
    
    
    @IBAction func willGoBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
    }
    
    
    //MARK: Main

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }

}
