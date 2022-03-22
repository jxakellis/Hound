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
        let retryAlertAction = UIAlertAction(title: "Retry Connection", style: .default) { _ in
            self.retrySynchronization()
        }
        noResponseAlertController.addAction(retryAlertAction)
        failureResponseAlertController.addAction(retryAlertAction)
        getUser()
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
    private var noResponseAlertController = GeneralUIAlertController(title: "Uh oh! There was a problem.", message: ErrorManagerMessages.noResponseGeneral, preferredStyle: .alert)
    private var failureResponseAlertController = GeneralUIAlertController(title: "Uh oh! There was a problem.", message: ErrorManagerMessages.failureResponseGeneral, preferredStyle: .alert)

    /// DogManager that all of the retrieved information will be added too.
    static var dogManager = DogManager()

    // Only one call is made to the the user and one call to get all the dogs.
    private var serverContacted = false
    private var getUserFinished = false
    private var getDogsFinished = false

    // MARK: - Functions
    /// Retrieve the user
    private func getUser() {
        UserRequest.get(forUserEmail: UserInformation.userEmail) { responseBody in
            if responseBody != nil {
                self.serverContacted = true
                self.asyncUpdateStatusLabel()
                let result = responseBody!["result"] as! [[String: Any]]
                // verify that at least one user was returned. Shouldn't be possible to have no users but always good to check
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
            }
        }
    }

    /// Retrieve any dogs the user may have
    private func getDogs() {
        RequestUtils.getDogManager { dogManager in
            if dogManager != nil {
                ServerSyncViewController.dogManager = dogManager!
                self.getDogsFinished = true
                self.checkSynchronizationStatus()
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
            // MainTabBarViewController.staticDogManager = ServerSyncViewController.dogManager

            // can't use set dogmanager as will crash since VCS are still nil
            // just have maintabbarvc pull the dogmanager from here when it instantiates
        }
    }

}
