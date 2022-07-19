//
//  ServerSyncViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ServerSyncViewController: UIViewController, ServerFamilyViewControllerDelegate, DogManagerControlFlowProtocol {

    // MARK: - ServerFamilyViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var getRequestsProgressView: UIProgressView!
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // As soon as this view disappears, we want to halt the observers to clean up / deallocate resources.
        getUserProgressObserver?.invalidate()
        getUserProgressObserver = nil
        getFamilyProgressObserver?.invalidate()
        getFamilyProgressObserver = nil
        getDogsProgressObserver?.invalidate()
        getDogsProgressObserver = nil
    }
    
    // MARK: - Properties
    /// Called to prompt the user to retry a server connection
    private var failureResponseAlertController = GeneralUIAlertController(title: "Uh oh! There was a problem.", message: GeneralResponseError.getFailureResponse.rawValue, preferredStyle: .alert)
    private var noResponseAlertController = GeneralUIAlertController(title: "Uh oh! There was a problem.", message: GeneralResponseError.getNoResponse.rawValue, preferredStyle: .alert)
    
    /// DogManager that all of the retrieved information will be added too.
    static var dogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return ServerSyncViewController.dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        ServerSyncViewController.dogManager = newDogManager
    }
    
    /// What fraction of the loading/progress bar the user request is worth when completed
    private var getUserProgressFractionOfWhole = 0.2
    @objc dynamic private var getUserProgress: Progress?
    private var getUserProgressObserver: NSKeyValueObservation?
    
    /// What fraction of the loading/progress bar the family request is worth when completed
    private var getFamilyProgressFractionOfWhole = 0.2
    @objc dynamic private var getFamilyProgress: Progress?
    private var getFamilyProgressObserver: NSKeyValueObservation?
    
    /// What fraction of the loading/progress bar the dogs request is worth when completed
    private var getDogsProgressFractionOfWhole = 0.6
    @objc dynamic private var getDogsProgress: Progress?
    private var getDogsProgressObserver: NSKeyValueObservation?
    
    // MARK: - Functions
    
    private func oneTimeSetup() {
        let retryAlertAction = UIAlertAction(title: "Retry Login", style: .default) { _ in
            self.repeatableSetup()
        }
        let loginPageAlertAction = UIAlertAction(title: "Go to Login Page", style: .default) { _ in
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "serverLoginViewController")
        }
        failureResponseAlertController.addAction(retryAlertAction)
        noResponseAlertController.addAction(retryAlertAction)
        
        failureResponseAlertController.addAction(loginPageAlertAction)
        noResponseAlertController.addAction(loginPageAlertAction)
    }
    
    private func repeatableSetup() {
        getUserProgress = nil
        getUserProgressObserver = nil
        getFamilyProgress = nil
        getFamilyProgressObserver = nil
        getDogsProgress = nil
        getDogsProgressObserver = nil
        
        // placeholder userId, therefore we need to have them login to even know who they are
        if UserInformation.userId == nil || UserInformation.userId! == EnumConstant.HashConstant.defaultSHA256Hash {
            // we have the user sign into their apple id, then attempt to first create an account then get an account (if the creates fails) then throw an error message (if the get fails too).
            // if all succeeds, then the user information and user configuration is loaded
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "serverLoginViewController")
        }
        // has userId, possibly has familyId, will check inside getUser
        else {
            self.getUser()
        }
    }
    
    // MARK: - Get Functions
    
    private func getUser() {
        getUserProgress = UserRequest.get(invokeErrorManager: false) { _, familyId, responseStatus in
            switch responseStatus {
            case .successResponse:
                // we got the user information back and have setup the user config based off of that info
                // user has family
                if familyId != nil {
                    self.getFamilyConfiguration()
                }
                // no family for user
                else {
                    // We failed to retrieve a familyId for the user so that means they have no family. Segue to page to make them create/join one.
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "serverFamilyViewController")
                }
            case .failureResponse:
                AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
            case .noResponse:
                AlertManager.enqueueAlertForPresentation(self.noResponseAlertController)
            }
        }?.progress
        
        getUserProgressObserver = observe(\.getUserProgress?.fractionCompleted, options: [.new]) { _, _ in
            self.didObserveProgressChange()
        }
    }
    
    private func getFamilyConfiguration() {
        getFamilyProgress = FamilyRequest.get(invokeErrorManager: false) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                self.getDogs()
            case .failureResponse:
                AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
            case .noResponse:
                AlertManager.enqueueAlertForPresentation(self.noResponseAlertController)
            }
        }?.progress
        
        getFamilyProgressObserver = observe(\.getFamilyProgress?.fractionCompleted, options: [.new]) { _, _ in
            self.didObserveProgressChange()
        }
    }

    private func getDogs() {
        // we want to use our own custom error message
        // Additionally, getDogManager first makes sure the familyConfiguration is up to date with inital query then if successful it sends a second query to get our dogManager
        getDogsProgress = DogsRequest.get(invokeErrorManager: false, dogManager: ServerSyncViewController.dogManager) { newDogManager, responseStatus in
            switch responseStatus {
            case .successResponse:
                guard let newDogManager = newDogManager else {
                    AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
                    return
                }
                
                ServerSyncViewController.dogManager = newDogManager
                
                // hasn't shown configuration to create/update dog
                if LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore == false {
                    // Created family, no dogs present
                    // OR joined family, no dogs present
                    // OR joined family, dogs already present
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "familyIntroductionViewController")
                    
                }
                // has shown configuration before
                else {
                    self.performSegueOnceInWindowHierarchy(segueIdentifier: "mainTabBarViewController")
                }
            case .failureResponse:
                AlertManager.enqueueAlertForPresentation(self.failureResponseAlertController)
            case .noResponse:
                AlertManager.enqueueAlertForPresentation(self.noResponseAlertController)
            }
        }?.progress
        
        getDogsProgressObserver = observe(\.getDogsProgress?.fractionCompleted, options: [.new]) { _, _ in
            self.didObserveProgressChange()
        }
    }
    
    // The .fractionCompleted variable on one of the progress objects was updated. Therefore, we must update our loading bar
    private func didObserveProgressChange() {
        DispatchQueue.main.async {
            let userProgress = (self.getUserProgress?.fractionCompleted ?? 0.0) * self.getUserProgressFractionOfWhole
            
            let familyProgress =
            (self.getFamilyProgress?.fractionCompleted ?? 0.0) * self.getFamilyProgressFractionOfWhole
            
            let dogsProgress =
            (self.getDogsProgress?.fractionCompleted ?? 0.0) * self.getDogsProgressFractionOfWhole
            
            self.getRequestsProgressView.progress = Float(userProgress + familyProgress + dogsProgress)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "mainTabBarViewController"{
            let mainTabBarViewController: MainTabBarViewController = segue.destination as! MainTabBarViewController
            mainTabBarViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: ServerSyncViewController.dogManager)
        }
        else if segue.identifier == "familyIntroductionViewController"{
            let familyIntroductionViewController: FamilyIntroductionViewController = segue.destination as! FamilyIntroductionViewController
            familyIntroductionViewController.dogManager = ServerSyncViewController.dogManager
        }
        else if segue.identifier == "serverFamilyViewController" {
            let serverFamilyViewController: ServerFamilyViewController = segue.destination as! ServerFamilyViewController
            serverFamilyViewController.delegate = self
        }
    }
    
}
