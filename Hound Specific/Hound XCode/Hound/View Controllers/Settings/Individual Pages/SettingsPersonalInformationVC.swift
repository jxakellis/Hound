//
//  SettingsPersonalInformationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsPersonalInformationViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class SettingsPersonalInformationViewController: UIViewController, UIGestureRecognizerDelegate, DogManagerControlFlowProtocol {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var userName: ScaledUILabel!
    
    @IBOutlet private weak var userEmail: ScaledUILabel!
    
    @IBOutlet private weak var redownloadDataButton: UIButton!
    @IBAction private func didClickRedownloadData(_ sender: Any) {
        
        RequestUtils.beginAlertControllerQueryIndictator()
        
        // store the date of our old sync if the request fails (as we will be overriding the typical way of doing it)
        let currentLastDogManagerSynchronization = LocalConfiguration.lastDogManagerSynchronization
        // manually set lastDogManagerSynchronization to default value so we will retrieve everything from the server
        LocalConfiguration.lastDogManagerSynchronization = LocalConfiguration.defaultLastDogManagerSynchronization
        
        DogsRequest.get(invokeErrorManager: true, dogManager: DogManager()) { newDogManager, _ in
            RequestUtils.endAlertControllerQueryIndictator {
                
                guard newDogManager != nil else {
                    // failed query to fully redownload the dogManager
                    // revert lastDogManagerSynchronization previous value. This is necessary as we circumvented the DogsRequest automatic handling of it to allow us to retrieve all entries.
                    LocalConfiguration.lastDogManagerSynchronization = currentLastDogManagerSynchronization
                    return
                }
                
                self.performSpinningCheckmarkAnimation()
                // successful query to fully redownload the dogManager, no need to mess with lastDogManagerSynchronization as that is automatically handled
                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: newDogManager!)
            }
        }
    }
    // MARK: - Properties
    
    weak var delegate: SettingsPersonalInformationViewControllerDelegate!
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.text = UserInformation.displayFullName
        
        userEmail.text = UserInformation.userEmail ?? "No Email"
        
        oneTimeSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Dog Manager
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        dogManager = newDogManager
        
        if (sender.localized is SettingsViewController) == false {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: newDogManager)
        }
    }
    
    // MARK: - Functions
    
    /// These properties only need assigned once.
    private func oneTimeSetup() {
        
        redownloadDataButton.layer.cornerRadius = 10.0
    }
}
