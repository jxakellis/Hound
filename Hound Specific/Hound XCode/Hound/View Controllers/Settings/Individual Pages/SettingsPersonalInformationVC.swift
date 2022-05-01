//
//  SettingsPersonalInformationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsPersonalInformationViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var userName: ScaledUILabel!
    
    @IBOutlet private weak var userEmail: ScaledUILabel!
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // there is a first name and a last name for the user
        if UserInformation.userFirstName != "" && UserInformation.userLastName != "" {
            userName.text = "\(UserInformation.userFirstName) \(UserInformation.userLastName)"
        }
        // the user only has a first name
        else if UserInformation.userFirstName != "" {
            userName.text = "\(UserInformation.userFirstName)"
        }
        // the user only has a last name
        else if UserInformation.userLastName != "" {
            userName.text = "\(UserInformation.userLastName)"
        }
        // if the name is still blank, then add a placeholder
        else {
            userName.text = "No Name"
        }
        
        userEmail.text = UserInformation.userEmail ?? "No Email"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
}
