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
        // TO DO FUTURE update Hound Organizer website, Hound Organizer privacy policy, old Hound Organizer @gmail accounts, and Hound Organizer App Store listing to reflect:
        // 1. new support@houndorganizer.com address
        // 2. Hound is a family, cloud-connected app
        // 3. Hound is a student project
        self.version.text = "Version \(UIApplication.appVersion)"
        self.build.text = "Build \(UIApplication.appBuild)"
        self.copyright.text = "© \(Calendar.localCalendar.component(.year, from: Date())) Jonathan Xakellis"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
}
