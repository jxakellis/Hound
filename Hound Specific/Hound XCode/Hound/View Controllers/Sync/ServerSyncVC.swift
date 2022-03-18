//
//  ServerSyncViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ServerSyncViewController: UIViewController {

    /*
     
     Sync Flow:
     
     START
     - Fetch userConfiguration (with userId)
         - userId valid and authenticated
            - Fetch familyId (with userId)
                - familyId valid and authenticated
                    - fetch dogs, logs, reminders, and shared configuration
                - familyId invalid and/or not authenticated
                    - create family
                        - return to start
                    - join family
                        - return to start
         - userId invalid and/or not authenticated
            - create user
                - return to start
            - login user
                - return to start
     
     */

    // MARK: - IB

    @IBOutlet private weak var statusLabel: UILabel!

    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()

        syncUpdateStatusLabel()
        getUser()
        let retryAlertAction = UIAlertAction(title: "Retry Connection", style: .default) { _ in
            self.retrySynchronization()
        }
        retryAlertController.addAction(retryAlertAction)
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

    // MARK: - Properties
    /// Called to prompt the user to retry a server connection
    private var retryAlertController = GeneralUIAlertController(title: "Server Sync Failed", message: "Uh oh! We were unable to reach Hound's server. Please verify that you are connected to the internet and retry.", preferredStyle: .alert)

    /// DogManager that all of the retrieved information will be added too.
    static var dogManager = DogManager()

    // Only one call is made to the the user and one call to get all the dogs.
    private var serverContacted = false
    private var getUserFinished = false
    private var getDogsFinished = false

    // MARK: - Functions
    /// Retrieve the user
    private func getUser() {
       UserRequest.get(forUserEmail: UserInformation.userEmail, completionHandler: { responseBody, _, _ in
           if responseBody != nil {
               // know that the server was reached as we got a body back
               self.serverContacted = true
               self.asyncUpdateStatusLabel()
               // JSON { result : userId }
               if let result = responseBody!["result"] as? [[String: Any]] {

                   // known that was 200 or 204 with valid body
                   // verify that at least one user was returned
                   if result.isEmpty == false {
                       // set all local configuration equal to whats in the server
                       UserInformation.setup(fromBody: result[0])
                       UserConfiguration.setup(fromBody: result[0])

                       // verify that a userId was successfully retrieved from the server
                       if result[0]["userId"] is Int {
                           self.getDogs()
                       }

                       self.getUserFinished = true
                       self.checkSynchronizationStatus()
                   }
                   else {
                       // TO DO handle if the query returned no users
                       DispatchQueue.main.async {
                           AlertManager.shared.enqueueAlertForPresentation(self.retryAlertController)
                       }
                   }

               }
               else {
                   // TO DO handle if the query wasn't successful, meaning a 400 code, "message", and (maybe) "error"
                   DispatchQueue.main.async {
                       AlertManager.shared.enqueueAlertForPresentation(self.retryAlertController)
                   }
               }

           }
           else {
               // TO DO handle if the query failed hard, no response body and some error.
               DispatchQueue.main.async {
                   AlertManager.shared.enqueueAlertForPresentation(self.retryAlertController)
               }
           }
            })
    }

    /// Retrieve any dogs the user may have
    private func getDogs() {
        RequestUtils.getDogManager { dogManager in
            // success
            if dogManager != nil {
                ServerSyncViewController.dogManager = dogManager!
                self.getDogsFinished = true
                self.checkSynchronizationStatus()
            }
            else {
                // TO DO failed to get dogManager
                DispatchQueue.main.async {
                    AlertManager.shared.enqueueAlertForPresentation(self.retryAlertController)
                }
            }
        }
    }

    /// If all the request has successfully completed, persist the new dogManager to memory and continue into the hound app.
    private func checkSynchronizationStatus() {

        asyncUpdateStatusLabel()

        guard serverContacted && getUserFinished && getDogsFinished else {
            return
        }

        // Encode the new dogManager into userDefaults so the dogManager accessed by MainTabBarViewController is the accurate one
        let encodedDataDogManager = try! NSKeyedArchiver.archivedData(withRootObject: ServerSyncViewController.dogManager, requiringSecureCoding: false)
        UserDefaults.standard.setValue(encodedDataDogManager, forKey: UserDefaultsKeys.dogManager.rawValue)

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "mainTabBarViewController", sender: nil)
        }
    }

    /// Update status label from a callback. This call back isn't on the main thread so will produce an error without a main thread call
    private func asyncUpdateStatusLabel() {
        DispatchQueue.main.async {
            self.syncUpdateStatusLabel()
                    }
    }
    /// Update status label from a synchronous code. This will produce a 'purple' error if used from a callback or other sync function
    private func syncUpdateStatusLabel() {
        let finishedContact = "      Contacting Server ✅\n"
        let inProgressContact = "      Contacting Server ❌\n"
        if self.serverContacted == true {
            self.statusLabel.text! = finishedContact
        }
        else {
            self.statusLabel.text! = inProgressContact
        }
        let finishedUser = "      Fetching User ✅\n"
        let inProgressUser = "      Fetching User ❌\n"
        if self.getUserFinished == true {
            self.statusLabel.text!.append(finishedUser)
        }
        else {
            self.statusLabel.text!.append(inProgressUser)
        }
        let finishedUserConfiguration = "      Fetching User Configuration ✅\n"
        let inProgressUserConfiguration = "      Fetching User Configuration ❌\n"
        if self.getUserFinished == true {
            self.statusLabel.text!.append(finishedUserConfiguration)
        }
        else {
            self.statusLabel.text!.append(inProgressUserConfiguration)
        }

        let finishedDogs = "      Fetching Dogs ✅"
        let inProgressDogs = "      Fetching Dogs ❌"
        if self.getDogsFinished == true {
            self.statusLabel.text!.append(finishedDogs)
        }
        else {
            self.statusLabel.text!.append(inProgressDogs)
        }
    }
    /// Server sync failed and cannot continue into the Hound app. This function attempts to retry the whole process from the very beginning.
    private func retrySynchronization() {
        serverContacted = false
        getUserFinished = false
        getDogsFinished = false
        asyncUpdateStatusLabel()
        getUser()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "mainTabBarViewController"{
            // let mainTabBarViewController: MainTabBarViewController = segue.destination as! MainTabBarViewController
            MainTabBarViewController.staticDogManager = ServerSyncViewController.dogManager
        }
    }

}
