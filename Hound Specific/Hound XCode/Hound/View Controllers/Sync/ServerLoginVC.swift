//
//  ServerLoginViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ServerLoginViewController: UIViewController {
    // MARK: - IB
    @IBOutlet private weak var userEmail: UITextField!
    @IBOutlet private weak var userFirstName: UITextField!
    @IBOutlet private weak var userLastName: UITextField!

    @IBAction private func willSignUpUser(_ sender: Any) {
        UserInformation.userEmail = userEmail.text!
        UserInformation.userFirstName = userFirstName.text!
        UserInformation.userLastName = userLastName.text!
    }
    @IBAction private func willSignInUser(_ sender: Any) {
        UserInformation.userEmail = userEmail.text!
    }

    // MARK: - Properties

    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        // Make this view the presenter if the app has to present any alert.
        AlertManager.globalPresenter = self

        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
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
