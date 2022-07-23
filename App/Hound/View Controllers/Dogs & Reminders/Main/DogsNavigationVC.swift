//
//  DogsNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsNavigationViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
    func checkForRemindersIntroductionPage()
}

final class DogsNavigationViewController: UINavigationController, DogsViewControllerDelegate {

    // MARK: - DogsViewControllerDelegate

    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        passThroughDelegate.didUpdateDogManager(sender: sender, forDogManager: forDogManager)
    }

    // MARK: - Properties

    weak var passThroughDelegate: DogsNavigationViewControllerDelegate! = nil

    var dogsViewController: DogsViewController!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        dogsViewController = self.viewControllers[0] as? DogsViewController
        dogsViewController.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        passThroughDelegate.checkForRemindersIntroductionPage()
        
    }

}
