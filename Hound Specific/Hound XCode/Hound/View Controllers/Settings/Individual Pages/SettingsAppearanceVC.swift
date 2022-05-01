//
//  SettingsAppearanceViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsAppearanceViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO DO add reminders overview mode. allow the user to switch between compact and large.

        // DARK MODE
        interfaceStyleSegmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white], for: .normal)
        interfaceStyleSegmentedControl.backgroundColor = .systemGray4

        // LOGS OVERVIEW MODE
        self.logsViewModeSegmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.white], for: .normal)
        self.logsViewModeSegmentedControl.backgroundColor = .systemGray4

        if UserConfiguration.isCompactView == true {
            logsViewModeSegmentedControl.selectedSegmentIndex = 0
        }
        else {
            logsViewModeSegmentedControl.selectedSegmentIndex = 1
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self

        // DARK MODE
        switch UserConfiguration.interfaceStyle.rawValue {
            // system/unspecified
        case 0:
            interfaceStyleSegmentedControl.selectedSegmentIndex = 2
            // light
        case 1:
            interfaceStyleSegmentedControl.selectedSegmentIndex = 0
            // dark
        case 2:
            interfaceStyleSegmentedControl.selectedSegmentIndex = 1
        default:
            interfaceStyleSegmentedControl.selectedSegmentIndex = 2
        }
    }

    // MARK: - Individual Settings

    // MARK: Interface Style

    @IBOutlet private weak var interfaceStyleSegmentedControl: UISegmentedControl!

    @IBAction private func didUpdateInterfaceStyle(_ sender: Any) {
        ViewControllerUtils.updateInterfaceStyle(forSegmentedControl: sender as! UISegmentedControl)
    }

    // MARK: Logs Overview Mode

    @IBOutlet private weak var logsViewModeSegmentedControl: UISegmentedControl!

    @IBAction private func didUpdateLogsViewMode(_ sender: Any) {

        let beforeUpdateIsCompactView = UserConfiguration.isCompactView

        if logsViewModeSegmentedControl.selectedSegmentIndex == 0 {
            UserConfiguration.isCompactView = true
        }
        else {
            UserConfiguration.isCompactView = false
        }

        let body = [ServerDefaultKeys.isCompactView.rawValue: UserConfiguration.isCompactView]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
               UserConfiguration.isCompactView = beforeUpdateIsCompactView
                if beforeUpdateIsCompactView == true {
                    self.logsViewModeSegmentedControl.selectedSegmentIndex = 0
                }
                else {
                    self.logsViewModeSegmentedControl.selectedSegmentIndex = 1
                }
            }
        }
    }
    
}
