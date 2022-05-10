//
//  ServerSyncViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ServerSyncViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var statusLabel: UILabel!
    
    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneTimeSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        // Make this view the presenter if the app has to present any alert.
        AlertManager.globalPresenter = self
        
        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        repeatableSetup()
    }
    
    // MARK: - Properties
    /// Called to prompt the user to retry a server connection
    private var failureResponseAlertController = GeneralUIAlertController(title: "Uh oh! There was a problem.", message: GeneralResponseError.failureGetResponse.rawValue, preferredStyle: .alert)
    private var noResponseAlertController = GeneralUIAlertController(title: "Uh oh! There was a problem.", message: GeneralResponseError.noGetResponse.rawValue, preferredStyle: .alert)
    
    /// DogManager that all of the retrieved information will be added too.
    private var dogManager = DogManager()
    
    private var serverContacted = false
    private var getUserFinished = false
    private var getFamilyFinished = false
    private var getDogsFinished = false
    
    // MARK: - Functions
    
    private func oneTimeSetup() {
        updateStatusLabel()
        let retryAlertAction = UIAlertAction(title: "Retry Login", style: .default) { _ in
            self.repeatableSetup()
        }
        let loginPageAlertAction = UIAlertAction(title: "Go to Login Page", style: .default) { _ in
            ViewControllerUtils.performSegueOnceInWindowHierarchy(segueIdentifier: "serverLoginViewController", viewController: self)
        }
        failureResponseAlertController.addAction(retryAlertAction)
        noResponseAlertController.addAction(retryAlertAction)
        
        failureResponseAlertController.addAction(loginPageAlertAction)
        noResponseAlertController.addAction(loginPageAlertAction)
    }
    
    private func repeatableSetup() {
        serverContacted = false
        getUserFinished = false
        getFamilyFinished = false
        getDogsFinished = false
        updateStatusLabel()
        
        // placeholder userId, therefore we need to have them login to even know who they are
        if UserInformation.userId == nil || UserInformation.userId! < 0 {
            // we have the user sign into their apple id, then attempt to first create an account then get an account (if the creates fails) then throw an error message (if the get fails too).
            // if all succeeds, then the user information and user configuration is loaded
            ViewControllerUtils.performSegueOnceInWindowHierarchy(segueIdentifier: "serverLoginViewController", viewController: self)
        }
        // has userId, possibly has familyId, will check inside getUser
        else {
            self.getUser()
        }
    }
    
    /// If all the request has successfully completed, persist the new dogManager to memory and continue into the hound app.
    private func checkSynchronizationStatus() {
        
        guard serverContacted && getUserFinished && getFamilyFinished && getDogsFinished else {
            return
        }
        
        // figure out where to go next, if the user is new and has no dogs (aka probably no family yet either) then we help them make their first dog
        
        // hasn't shown configuration to create/update dog
        if LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore == false {
            // Created family, no dogs present
            // OR joined family, no dogs present
            // OR joined family, dogs already present
            ViewControllerUtils.performSegueOnceInWindowHierarchy(segueIdentifier: "familyIntroductionViewController", viewController: self)
            
        }
        // has shown configuration before
        else {
            ViewControllerUtils.performSegueOnceInWindowHierarchy(segueIdentifier: "mainTabBarViewController", viewController: self)
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
        
        let finishedFamily = "      Fetching Family ✅\n"
        let inProgressFamily = "      Fetching Family ❌\n"
        if self.getFamilyFinished == true {
            self.statusLabel.text!.append(finishedFamily)
        }
        else {
            self.statusLabel.text!.append(inProgressFamily)
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
    
    // MARK: - Get Functions
    
    /// Retrieve the user
    private func getUser() {
        // TO DO make user request send current app build
        UserRequest.get(invokeErrorManager: false) { _, familyId, responseStatus in
            switch responseStatus {
            case .successResponse:
                // we got the user information back and have setup the user config based off of that info
                self.serverContacted = true
                self.getUserFinished = true
                self.updateStatusLabel()
                
                // user has family
                if familyId != nil {
                    self.getFamily()
                }
                // no family for user
                else {
                    // We failed to retrieve a familyId for the user so that means they have no family. Segue to page to make them create/join one.
                    ViewControllerUtils.performSegueOnceInWindowHierarchy(segueIdentifier: "serverFamilyViewController", viewController: self)
                }
            case .failureResponse:
                AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
            case .noResponse:
                AlertManager.enqueueAlertForPresentation(self.noResponseAlertController)
            }
        }
    }
    
    /// get the family configuration from the server
    private func getFamily() {
        // we want to use our own custom error message so we can have custom alert actions
        FamilyRequest.get(invokeErrorManager: false) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                // we got the family configuration from the server and loaded it, now we can proceed to the next step
                self.getFamilyFinished = true
                self.updateStatusLabel()
                self.getDogs()
            case .failureResponse:
                AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
            case .noResponse:
                AlertManager.enqueueAlertForPresentation(self.noResponseAlertController)
            }
        }
    }
    
    /// Retrieve any dogs the user may have
    private func getDogs() {
        // we want to use our own custom error message
        RequestUtils.getDogManager(invokeErrorManager: false) { dogManager, responseStatus in
            switch responseStatus {
            case .successResponse:
                if dogManager != nil {
                    self.dogManager = dogManager!
                    self.getDogsFinished = true
                    self.updateStatusLabel()
                    self.checkSynchronizationStatus()
                }
                else {
                    AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
                }
            case .failureResponse:
                AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
            case .noResponse:
                AlertManager.enqueueAlertForPresentation(self.noResponseAlertController)
            }
            
        }
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
        else if segue.identifier == "familyIntroductionViewController"{
            let familyIntroductionViewController: FamilyIntroductionViewController = segue.destination as! FamilyIntroductionViewController
            familyIntroductionViewController.dogManager = dogManager
        }
    }
    
}
