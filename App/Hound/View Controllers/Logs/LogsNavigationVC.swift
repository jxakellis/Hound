//
//  LogsNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsNavigationViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class LogsNavigationViewController: UINavigationController, LogsViewControllerDelegate {
    
    // MARK: - LogsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        passThroughDelegate.didUpdateDogManager(sender: sender, forDogManager: forDogManager)
    }
    
    // MARK: - Properties
    
    var logsViewController: LogsViewController?
    
    weak var passThroughDelegate: LogsNavigationViewControllerDelegate! = nil
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logsViewController = self.viewControllers.first as? LogsViewController
        logsViewController?.delegate = self
    }
    
}
