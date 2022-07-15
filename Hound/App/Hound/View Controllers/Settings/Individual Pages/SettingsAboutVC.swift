//
//  SettingsAboutViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsAboutViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet private weak var version: ScaledUILabel!

    @IBOutlet private weak var build: ScaledUILabel!

    @IBOutlet private weak var copyright: ScaledUILabel!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        // TO DO update Hound Organizer website, Hound Organizer privacy policy, old Hound Organizer @gmail accounts, and Hound Organizer App Store listing to reflect:
        // 1. new support@houndorganizer.com address
        // 2. Hound is a family, cloud-connected app
        // 3. Hound is a student project
         self.version.text = "Version \(UIApplication.appVersion ?? "nil")"
        self.build.text = "Build \(UIApplication.appBuild)"
        self.copyright.text = "© \(Calendar.current.component(.year, from: Date())) Jonathan Xakellis"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }

}
