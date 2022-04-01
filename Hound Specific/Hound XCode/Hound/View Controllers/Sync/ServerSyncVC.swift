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
        let retryAlertAction = UIAlertAction(title: "Retry Connection", style: .default) { _ in
            DispatchQueue.main.async {
                self.retrySynchronization()
            }
        }
        failureResponseAlertController.addAction(retryAlertAction)
        noResponseAlertController.addAction(retryAlertAction)
        noDogManagerAlertController.addAction(retryAlertAction)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        // Make this view the presenter if the app has to present any alert.
        AlertManager.globalPresenter = self

        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        // placeholder userId
        if UserInformation.userId == nil || UserInformation.userId! < 0 {
            Utils.performSegueOnceInWindowHierarchy(segueIdentifier: "serverLoginViewController", viewController: self)
        }
        // has userId
        else {
            getUser()
        }
    }

    // MARK: - Properties
    /// Called to prompt the user to retry a server connection
    private var failureResponseAlertController = GeneralUIAlertController(title: "Uh oh! There was a problem.", message: GeneralResponseError.failureGetResponse.rawValue, preferredStyle: .alert)
    private var noResponseAlertController = GeneralUIAlertController(title: "Uh oh! There was a problem.", message: GeneralResponseError.noGetResponse.rawValue, preferredStyle: .alert)
    private var noDogManagerAlertController = GeneralUIAlertController(title: "Uh oh! There was a problem.", message: "We experienced an issue while retrieving your data Hound's server. Our first request to retrieve your app settings succeeded, but we were unable to retrieve your dogs. Please verify that you are connected to the internet and retry. If the issue persists, please reinstall Hound.", preferredStyle: .alert)

    /// DogManager that all of the retrieved information will be added too.
    private var dogManager = DogManager()

    // Only one call is made to the the user and one call to get all the dogs.
    private var serverContacted = false
    private var getUserFinished = false
    private var getDogsFinished = false

    // MARK: - Functions
    /// Retrieve the user
    private func getUser() {
        UserRequest.get { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                    if responseBody != nil {
                        self.serverContacted = true
                        self.updateStatusLabel()
                        
                        // verify that at least one user was returned. Shouldn't be possible to have no users but always good to check
                        if let result = responseBody!["result"] as? [[String: Any]], result.isEmpty == false {
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
                            AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
                        }
                    }
            case .failureResponse:
                    AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
            case .noResponse:
                    AlertManager.enqueueAlertForPresentation(self.noResponseAlertController)
                }
            
        }
    }

    /// Retrieve any dogs the user may have
    private func getDogs() {
        RequestUtils.getDogManager { dogManager in
            if dogManager != nil {
                self.dogManager = dogManager!
                self.getDogsFinished = true
                self.checkSynchronizationStatus()
            }
            else {
                AlertManager.enqueueAlertForPresentation(self.noDogManagerAlertController)
            }
        }
    }

    /// If all the request has successfully completed, persist the new dogManager to memory and continue into the hound app.
    private func checkSynchronizationStatus() {

        updateStatusLabel()

        guard serverContacted && getUserFinished && getDogsFinished else {
            return
        }

        // Encode the new dogManager into userDefaults so the dogManager accessed by MainTabBarViewController is the accurate one
        // let encodedDataDogManager = try! NSKeyedArchiver.archivedData(withRootObject: ServerSyncViewController.dogManager, requiringSecureCoding: false)
        // UserDefaults.standard.setValue(encodedDataDogManager, forKey: UserDefaultsKeys.dogManager.rawValue)

        DispatchQueue.main.async {
            // figure out where to go next, if the user is new and has no dogs (aka probably no family yet either) then we help them make their first dog
            
            // hasn't shown configuration to create dog
            if LocalConfiguration.hasLoadedIntroductionViewControllerBefore == false {
                // never created a dog before, new family
                if self.dogManager.hasCreatedDog == false {
                    self.performSegue(withIdentifier: "introductionViewController", sender: self)
                }
                // dogs already created
                else {
                    // TO DO create intro page for additional family member, where they still get introduced but don't create a dog
                    
                    self.performSegue(withIdentifier: "mainTabBarViewController", sender: nil)
                    LocalConfiguration.hasLoadedIntroductionViewControllerBefore = false
                }
                
            }
            // has shown configuration before
            else {
                self.performSegue(withIdentifier: "mainTabBarViewController", sender: nil)
            }
            
        }
    }
    
    /// Update status label from a synchronous code. This will produce a 'purple' error if used from a callback or other sync function
    private func updateStatusLabel() {
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
        updateStatusLabel()
        getUser()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "mainTabBarViewController"{
            let mainTabBarViewController: MainTabBarViewController = segue.destination as! MainTabBarViewController
            mainTabBarViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
        }
        else if segue.identifier == "introductionViewController" {
            // no need to pass throgh the dog manager. This page can only be accessed when there are no dogs so 
            // let introductionViewController: IntroductionViewController = segue.destination as! IntroductionViewController
            
        }
    }

}
