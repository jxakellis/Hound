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

        updateStatusLabel()
        getUser()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        // Make this view the presenter if the app has to present any alert.
        AlertManager.globalPresenter = self

        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.darkModeStyle
    }

    // MARK: - Properties

    /// DogManager that all of the retrieved information will be added too.
    static var dogManager = DogManager()

    // Only one call is made to the the user and one call to get all the dogs.
    private var getUserFinished = false
    private var getDogsFinished = false

    // MARK: - Functions
    /// Retrieve the user
    private func getUser() {
        do {
            try UserEndpoint.get(forUserEmail: UserInformation.userEmail, completionHandler: { body, code, error in
                self.processGetUserResponse(responseBody: body, responseCode: code, error: error)
            })
        }
        catch {
            AppDelegate.APIResponseLogger.error("getUser failed")
        }
    }

    /// Process the response from the getDogs query
    private func processGetUserResponse(responseBody: [String: Any]?, responseCode: Int?, error: Error?) {
        if responseBody != nil {
            // JSON { result : userId }
            if let result = responseBody!["result"] as? [[String: Any]] {

                // verify that at least one user was returned
                if result.isEmpty == false {
                    // set all local configuration equal to whats in the server
                    UserInformation.setup(fromBody: result[0])
                    UserConfiguration.setup(fromBody: result[0])

                    // verify that a userId was successfully retrieved from the server
                    if result[0]["userId"] is Int {
                        getDogs()
                    }

                    getUserFinished = true
                    finalizeSynchronization()
                }
                else {
                    // handle if the query returned no users
                }

            }

            // handle if the query wasn't successful, meaning a 400 code, "message", and (maybe) "error"
        }

        // handle if the query failed hard, no response body and some error.

    }

    /// Retrieve any dogs the user may have
    private func getDogs() {
        do {
            try DogsEndpoint.get(forDogId: nil, completionHandler: { body, code, error in
                self.processGetDogsResponse(responseBody: body, responseCode: code, error: error)
            })
        }
        catch {
            AppDelegate.APIResponseLogger.error("getDogs failed")
        }
    }

    /// Process the response from the getDogs query
    private func processGetDogsResponse(responseBody: [String: Any]?, responseCode: Int?, error: Error?) {
        if responseBody != nil {
            // Array of dog JSON [{dog1:'foo'},{dog2:'bar'}]
            if let result = responseBody!["result"] as? [[String: Any]] {

                // no dogs added by the user, which is weird but completely ok. We must still load though. Without this the sections would never be marked as complete and the load screen would progress
                if result.isEmpty == true {
                    getDogsFinished = true
                    finalizeSynchronization()
                }
                else {
                    // at least one dog in the queue, so it gives a chance for the loop to run and mark the sections as finished.
                    for dogBody in result {
                        do {
                            // add dog to the DogManager
                            let dog = try Dog(fromBody: dogBody)
                            ServerSyncViewController.dogManager.addDog(newDog: dog)

                            getDogsFinished = true
                            finalizeSynchronization()
                        }
                        catch {
                            AppDelegate.APIResponseLogger.error("Unable to create dog")
                            // handle if problem with adding dog
                        }

                    }
                }

            }
            // handle if the query wasn't successful, meaning a 400 code, "message", and (maybe) "error"
        }

        // handle if the query failed hard, no response body and some error.

    }

    /// Persist the new dogManager to memory and continue into the hound app
    private func finalizeSynchronization() {

        updateStatusLabel()

        // guard getUserFinished && getDogsFinished && numberOfGetLogsResponses == numberOfDogs && numberOfGetRemindersResponses == numberOfDogs else {
        guard getUserFinished && getDogsFinished else {
            return
        }

        print("sync finished")

        // Encode the new dogManager into userDefaults so the dogManager accessed by MainTabBarViewController is the accurate one
        let encodedDataDogManager = try! NSKeyedArchiver.archivedData(withRootObject: ServerSyncViewController.dogManager, requiringSecureCoding: false)
        UserDefaults.standard.setValue(encodedDataDogManager, forKey: UserDefaultsKeys.dogManager.rawValue)

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "mainTabBarViewController", sender: nil)
        }
    }

    private func updateStatusLabel() {
        DispatchQueue.main.async {
            let finishedUser = "      Fetching User ✅\n"
            let inProgressUser = "      Fetching User ❌\n"
            if self.getUserFinished == true {
                self.statusLabel.text! = finishedUser
            }
            else {
                self.statusLabel.text! = inProgressUser
            }

            let finishedDogs = "      Fetching Dogs ✅\n"
            let inProgressDogs = "      Fetching Dogs ❌\n"
            if self.getDogsFinished == true {
                self.statusLabel.text!.append(finishedDogs)
            }
            else {
                self.statusLabel.text!.append(inProgressDogs)
            }
        }
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
