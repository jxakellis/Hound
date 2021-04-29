//
//  LogsNavigationViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsNavigationViewControllerDelegate{
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class LogsNavigationViewController: UINavigationController, LogsViewControllerDelegate{
    
    //MARK: - LogsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        passThroughDelegate.didUpdateDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    
    //MARK: - Properties
    
    var logsViewController: LogsViewController! = nil
    
    var passThroughDelegate: LogsNavigationViewControllerDelegate! = nil
    
    //MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        logsViewController = self.viewControllers[0] as? LogsViewController
        logsViewController.delegate = self
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
