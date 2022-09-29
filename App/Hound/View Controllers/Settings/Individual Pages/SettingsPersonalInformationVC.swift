//
//  SettingsPersonalInformationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsPersonalInformationViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class SettingsPersonalInformationViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var userName: ScaledUILabel!
    
    @IBOutlet private weak var userEmail: ScaledUILabel!
    
    @IBOutlet private weak var userId: ScaledUILabel!
    
    @IBOutlet private weak var redownloadDataButton: UIButton!
    @IBAction private func didClickRedownloadData(_ sender: Any) {
        
        RequestUtils.beginRequestIndictator()
        
        // store the date of our old sync if the request fails (as we will be overriding the typical way of doing it)
        let currentLastDogManagerSynchronization = LocalConfiguration.lastDogManagerSynchronization
        // manually set lastDogManagerSynchronization to default value so we will retrieve everything from the server
        LocalConfiguration.lastDogManagerSynchronization = ClassConstant.DateConstant.default1970Date
        
        _ = DogsRequest.get(invokeErrorManager: true, dogManager: DogManager()) { newDogManager, _ in
            RequestUtils.endRequestIndictator {
                
                guard let newDogManager = newDogManager else {
                    // failed query to fully redownload the dogManager
                    // revert lastDogManagerSynchronization previous value. This is necessary as we circumvented the DogsRequest automatic handling of it to allow us to retrieve all entries.
                    LocalConfiguration.lastDogManagerSynchronization = currentLastDogManagerSynchronization
                    return
                }
                
                AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.redownloadDataTitle, forSubtitle: VisualConstant.BannerTextConstant.redownloadDataSubtitle, forStyle: .success)
                
                // successful query to fully redownload the dogManager, no need to mess with lastDogManagerSynchronization as that is automatically handled
                self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: SettingsPersonalInformationViewControllerDelegate!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneTimeSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    /// These properties only need assigned once.
    private func oneTimeSetup() {
        userName.text = UserInformation.displayFullName
        
        userEmail.text = UserInformation.userEmail ?? VisualConstant.TextConstant.unknownText
        
        userId.text = UserInformation.userId ?? VisualConstant.TextConstant.unknownText
        
        redownloadDataButton.layer.cornerRadius = VisualConstant.SizeConstant.largeRectangularButtonCornerRadious
    }
}
