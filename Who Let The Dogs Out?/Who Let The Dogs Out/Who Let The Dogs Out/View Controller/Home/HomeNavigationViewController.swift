//
//  HomeNavigationViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HomeNavigationViewController: UINavigationController {

    var homeViewController: HomeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeViewController = self.viewControllers[0] as? HomeViewController
    }

}
