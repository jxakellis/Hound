//
//  LogsNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsNavigationViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class LogsNavigationViewController: UINavigationController, LogsViewControllerDelegate {

    // MARK: - LogsViewControllerDelegate

    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        passThroughDelegate.didUpdateDogManager(sender: sender, newDogManager: newDogManager)
    }

    // MARK: - Properties

    var logsViewController: LogsViewController! = nil

    weak var passThroughDelegate: LogsNavigationViewControllerDelegate! = nil

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        logsViewController = self.viewControllers[0] as? LogsViewController
        logsViewController.delegate = self
    }

}
