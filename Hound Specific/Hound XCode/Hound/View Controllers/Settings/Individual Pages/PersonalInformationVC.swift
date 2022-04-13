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
    
    @IBOutlet private weak var accountInformation: ScaledUILabel!
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO DO revise this page to make it more details and clean
        
        // TO DO add ability for the user to delete their account (if they are in a single person family or are in a multi person family but are only a member)

        setupAccountInformation()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    private func setupAccountInformation() {
        accountInformation.text = ""
        accountInformation.text!.append("First Name: \(UserInformation.userFirstName)\n")
        accountInformation.text!.append("Last Name: \(UserInformation.userLastName)\n")
        accountInformation.text!.append("Email: \(UserInformation.userEmail ?? "unknown")\n")
       accountInformation.text!.append("User Identifier: \(UserInformation.userIdentifier ?? "unknown")")
    
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
