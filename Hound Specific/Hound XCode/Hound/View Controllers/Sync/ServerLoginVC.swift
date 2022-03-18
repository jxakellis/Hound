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
        createUser()
    }
    @IBAction private func willSignInUser(_ sender: Any) {
        UserInformation.userEmail = userEmail.text!
        getUser()
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

    /// This function queries the server to retrieve all the information for an existing user.
    private func getUser() {
         UserRequest.get(forUserEmail: UserInformation.userEmail) { responseBody, responseCode, error in
                self.processGetUserResponse(responseBody: responseBody, responseCode: responseCode, error: error)
            }
    }

    /// Processes the data from the server response to update local device
    private func processGetUserResponse(responseBody: [String: Any]?, responseCode: Int?, error: Error?) {

        var userIdResult: Int?

        // persist data from the server response (if it was successful)
        if responseBody != nil {
            // result indicates a successful query
            if responseBody!["result"] != nil {
                // special cast here due to userId. Not normal array setup
                let userIdResultBody = responseBody as? [String: [[String: Any]]]
                // result contains array of users, we take the 0th index as there will be only one user that matches the userId
                if let userId: Int = userIdResultBody?["result"]?[0]["userId"] as? Int {
                    userIdResult = userId
                    UserInformation.userId = userId
                    AppDelegate.APIResponseLogger.notice("UserId Aquired: \(userId)")
                }
            }
        }
        // successful server response and the userId was successfully set
        if responseCode != nil && 200...299 ~= responseCode! && userIdResult != nil {
            DispatchQueue.main.async {
                AppDelegate.APIResponseLogger.notice("Get User Successful")
                // self.performSegue(withIdentifier: "mainTabBarViewController", sender: nil)
                return

            }
        }
        // failure
        else {

            // the message displayed in a the alert viewcontroller for the user if the get user failed.
                let failureHeaderForUser: String = "Failed To Sign In"
                let failureMessageForUser: String = "Please try again later."

                let failureBody = responseBody!

                AppDelegate.APIResponseLogger.notice("Get User Failed")

            // check to see that the response has an error message
            if failureBody["error"] != nil, let failureError = failureBody["error"]! as? String {
                    AppDelegate.APIResponseLogger.notice("Get User Failure Error: \(failureError)")

                    // This code is output by MariaDB if there is an attempt to add a repeat value to a unique column

                }
            DispatchQueue.main.async {
                let alertController = GeneralUIAlertController(title: failureHeaderForUser, message: failureMessageForUser, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                AlertManager.shared.enqueueAlertForPresentation(alertController)
            }
            }
    }

    /// This functions queries the server to create a user
    private func createUser() {
            // temp user creation
                UserRequest.create { responseBody, responseCode, error in
                    self.processCreateUserResponse(responseBody: responseBody, responseCode: responseCode, error: error)
                }

    }

    /// Saves potential data from the server response and takes the next steps to continue to the regular app or alert for error
    private func processCreateUserResponse(responseBody: [String: Any]?, responseCode: Int?, error: Error?) {

        // persist data from the server response (if it was successful)
        if responseBody != nil {
            // result indicates a successful query
            if responseBody!["result"] != nil {
                // special cast here due to userId. Not normal array setup
                let userIdResultBody = responseBody as? [String: Int]
                if let userId: Int = userIdResultBody?["result"] {
                    UserInformation.userId = userId
                    AppDelegate.APIResponseLogger.notice("UserId Aquired: \(userId)")
                }
            }
        }

        // successful server response and the userId was successfully set
        if responseCode != nil && 200...299 ~= responseCode! && UserInformation.userId != -1 {
            DispatchQueue.main.async {
                AppDelegate.APIResponseLogger.notice("Create User Successful")
                // self.performSegue(withIdentifier: "mainTabBarViewController", sender: nil)
                return

            }
        }
        // failure
        else {

                // the message displayed in a the alert viewcontroller for the user if the create user failed.
                var failureHeaderForUser: String = "Failed To Create Account"
                var failureMessageForUser: String = "Please try again later."

                let failureBody = responseBody!

                AppDelegate.APIResponseLogger.notice("Create User Failed")

            // check to see that the response has an error message
            if failureBody["error"] != nil, let failureError = failureBody["error"]! as? String {
                    AppDelegate.APIResponseLogger.notice("Create User Failure Error: \(failureError)")

                    // This code is output by MariaDB if there is an attempt to add a repeat value to a unique column
                switch failureError {
                case "ER_DUP_ENTRY":
                    failureHeaderForUser = "Email Already In Use"
                    failureMessageForUser = "Please login to the existing account or try again with a different email."
                case "ER_EMAIL_BLANK":
                    failureHeaderForUser = "Email Blank"
                    failureMessageForUser = "Please enter a valid email and try again."
                case "ER_EMAIL_INVALID":
                    failureHeaderForUser = "Email Invalid"
                    failureMessageForUser = "Please enter a valid email and try again."
                case "ER_FIRST_NAME_BLANK":
                    failureHeaderForUser = "First Name Blank"
                    failureMessageForUser = "Please provide your first name and try again."
                case "ER_LAST_NAME_BLANK":
                    failureHeaderForUser = "Last Name Blank"
                    failureMessageForUser = "Please provide your last name and try again."
                default:
                    failureHeaderForUser = "Failed To Create Account"
                    failureMessageForUser = "Please try again later."
                }

                }
            DispatchQueue.main.async {
                let alertController = GeneralUIAlertController(title: failureHeaderForUser, message: failureMessageForUser, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                AlertManager.shared.enqueueAlertForPresentation(alertController)
            }
            }

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
