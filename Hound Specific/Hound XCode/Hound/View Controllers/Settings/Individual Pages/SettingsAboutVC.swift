//
//  SettingsAboutViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsAboutViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet private weak var version: ScaledUILabel!

    @IBOutlet private weak var build: ScaledUILabel!

    @IBOutlet private weak var copyright: ScaledUILabel!

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
         self.version.text = "Version \(UIApplication.appVersion ?? "nil")"
        self.build.text = "Build \(UIApplication.appBuild)"
        self.copyright.text = "© \(Calendar.current.component(.year, from: Date())) Jonathan Xakellis"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }

}
