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
        FamilyRequest.create { familyId in
            RequestUtils.endAlertControllerQueryIndictator {
                if familyId != nil {
                    // server sync vc retrieves familyId so no need to save it here
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    @IBOutlet private weak var createFamilyDisclaimer: UILabel!
    @IBOutlet private weak var createFamilyDisclaimerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var createFamilyDisclaimerTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var joinFamilyButton: ScaledUILabel!
    
    @IBAction private func willJoinFamily(_ sender: Any) {
        // TO DO interpret response to tell user details about the family (e.g. not found, locked, or need to upgrade limit)
        let familyCodeAlertController = GeneralUIAlertController(title: "Join a Family", message: nil, preferredStyle: .alert)
        familyCodeAlertController.addTextField { textField in
            textField.placeholder = "Enter Family Code..."
        }
        let alertActionJoin = UIAlertAction(title: "Join", style: .default) { [weak familyCodeAlertController] _ in
            guard let textFields = familyCodeAlertController?.textFields else {
                return
            }
            let familyCode = textFields[0].text ?? ""
            // code is empty
            if familyCode.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                ErrorManager.alert(forError: FamilyRequestError.noFamilyCode)
            }
            // code isn't long enough
            else if familyCode.count != 8 {
                ErrorManager.alert(forError: FamilyRequestError.familyCodeFormatInvalid)
            }
            // client side the code is okay
            else {
                RequestUtils.beginAlertControllerQueryIndictator()
                FamilyRequest.update(familyCode: familyCode) { requestWasSuccessful in
                    RequestUtils.endAlertControllerQueryIndictator {
                        // the code successfully allowed the user to join
                        if requestWasSuccessful == true {
                            self.dismiss(animated: true, completion: nil)
                        }
                        else {
                            // TO DO add indictator that the user couldn't join the family
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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        setupCreateFamily()
        setupCreateFamilyDisclaimer()
        setupJoinFamily()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        // Make this view the presenter if the app has to present any alert.
        AlertManager.globalPresenter = self
        
        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
    }
    
    // MARK: Setup Buttons and Labels
    
    private func setupCreateFamily() {
        // set to made to have fully rounded corners
        createFamilyButton.layer.cornerRadius = createFamilyButton.frame.height/2
        createFamilyButton.layer.masksToBounds = true
        createFamilyButton.layer.borderWidth = 1
        createFamilyButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupCreateFamilyDisclaimer() {
        createFamilyDisclaimer.translatesAutoresizingMaskIntoConstraints = false
        
        createFamilyDisclaimerLeadingConstraint.constant += (createFamilyButton.frame.height/4)
        createFamilyDisclaimerTrailingConstraint.constant -= (createFamilyButton.frame.height/4)
    }
    
    private func setupJoinFamily() {
        // set to made to have fully rounded corners
        joinFamilyButton.layer.cornerRadius = joinFamilyButton.frame.height/2
        joinFamilyButton.layer.masksToBounds = true
        joinFamilyButton.layer.borderWidth = 1
        joinFamilyButton.layer.borderColor = UIColor.black.cgColor
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
