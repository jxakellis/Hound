//
//  SettingsNavigationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNavigationViewController: UINavigationController {

    // MARK: - Properties

    var settingsViewController: SettingsViewController! = nil

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        settingsViewController = self.viewControllers[0] as? SettingsViewController
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
