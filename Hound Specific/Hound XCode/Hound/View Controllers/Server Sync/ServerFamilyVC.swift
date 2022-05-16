//
//  ServerFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ServerFamilyViewController: UIViewController {
    
    // MARK: IB

    @IBOutlet private weak var createFamilyButton: UIButton!
    
    @IBAction private func willCreateFamily(_ sender: Any) {
        RequestUtils.beginAlertControllerQueryIndictator()
        FamilyRequest.create(invokeErrorManager: true) { familyId, _ in
            RequestUtils.endAlertControllerQueryIndictator {
                if familyId != nil {
                    // Reset certain local configurations so they are ready for the next family ( if they were previously in one ). These local configurations just control some basic user experience things, so can be modified.
                    LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = false
                    LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = false
                    LocalConfiguration.lastDogManagerSync = Date(timeIntervalSince1970: 0)
                    LocalConfiguration.dogIcons = []
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    @IBOutlet private weak var createFamilyDisclaimerLabel: UILabel!
    @IBOutlet private weak var createFamilyDisclaimerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var createFamilyDisclaimerTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var joinFamilyButton: ScaledUILabel!
    
    @IBAction private func willJoinFamily(_ sender: Any) {
       
        let familyCodeAlertController = GeneralUIAlertController(title: "Join a Family", message: "The code is case-insensitive", preferredStyle: .alert)
        familyCodeAlertController.addTextField { textField in
            textField.placeholder = "Enter Family Code..."
            textField.autocapitalizationType = .allCharacters
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        let alertActionJoin = UIAlertAction(title: "Join", style: .default) { [weak familyCodeAlertController] _ in
            guard let textFields = familyCodeAlertController?.textFields else {
                return
            }
            // uppercase everything then replace "-" with "" (nothing) then remove any excess whitespaces/newliens
            let familyCode = (textFields[0].text ?? "").uppercased().replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            // code is empty
            if familyCode == "" {
                ErrorManager.alert(forError: FamilyRequestError.familyCodeBlank)
            }
            // code isn't long enough
            else if familyCode.count != 8 {
                ErrorManager.alert(forError: FamilyRequestError.familyCodeInvalid)
            }
            // client side the code is okay
            else {
                RequestUtils.beginAlertControllerQueryIndictator()
                FamilyRequest.update(invokeErrorManager: true, body: [ServerDefaultKeys.familyCode.rawValue: familyCode]) { requestWasSuccessful, _ in
                    RequestUtils.endAlertControllerQueryIndictator {
                        // the code successfully allowed the user to join
                        if requestWasSuccessful == true {
                            // Reset certain local configurations so they are ready for the next family ( if they were previously in one ). These local configurations just control some basic user experience things, so can be modified.
                            LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = false
                            LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = false
                            LocalConfiguration.lastDogManagerSync = Date(timeIntervalSince1970: 0)
                            LocalConfiguration.dogIcons = []
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            
        }
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        familyCodeAlertController.addAction(alertActionJoin)
        familyCodeAlertController.addAction(alertActionCancel)
        AlertManager.enqueueAlertForPresentation(familyCodeAlertController)
       
    }
    // MARK: Properties
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        repeatableSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        // Make this view the presenter if the app has to present any alert.
        AlertManager.globalPresenter = self
        
        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
    }
    
    // MARK: - Setup
    
    private func repeatableSetup() {
        setupCreateFamily()
        setupCreateFamilyDisclaimer()
        setupJoinFamily()
        func setupCreateFamily() {
            // set to made to have fully rounded corners
            createFamilyButton.layer.cornerRadius = createFamilyButton.frame.height/2
            createFamilyButton.layer.masksToBounds = true
            createFamilyButton.layer.borderWidth = 1
            createFamilyButton.layer.borderColor = UIColor.black.cgColor
        }
        
        func setupCreateFamilyDisclaimer() {
            createFamilyDisclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
            
            createFamilyDisclaimerLeadingConstraint.constant += (createFamilyButton.frame.height/6)
            createFamilyDisclaimerTrailingConstraint.constant += (createFamilyButton.frame.height/6)
        }
        
        func setupJoinFamily() {
            // set to made to have fully rounded corners
            joinFamilyButton.layer.cornerRadius = joinFamilyButton.frame.height/2
            joinFamilyButton.layer.masksToBounds = true
            joinFamilyButton.layer.borderWidth = 1
            joinFamilyButton.layer.borderColor = UIColor.black.cgColor
        }
    }

}
