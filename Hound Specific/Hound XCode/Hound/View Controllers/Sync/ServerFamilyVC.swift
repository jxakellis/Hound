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

    @IBOutlet weak var createFamilyButton: UIButton!
    @IBOutlet weak var createFamilyDisclaimer: UILabel!
    
    @IBOutlet weak var joinFamilyButton: ScaledUILabel!
    
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
        createFamilyButton.layer.cornerRadius = 99999.9
    }
    
    private func setupCreateFamilyDisclaimer() {
        // remove storyboard constraints in favor of programic ones
        var constraintsToDeactivate: [NSLayoutConstraint] = []
        for constraint in createFamilyDisclaimer.constraints where constraint.firstAttribute == .leading ||
            constraint.secondAttribute == .leading ||
            constraint.firstAttribute == .trailing ||
            constraint.secondAttribute == .trailing {
            constraintsToDeactivate.append(constraint)
                
        }
        NSLayoutConstraint.deactivate(constraintsToDeactivate)
        
        // add proper constraints that adapt to the rounded corners
        let constraints = [
            createFamilyDisclaimer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0 + (createFamilyButton.frame.height/2)),
            createFamilyDisclaimer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10 - (createFamilyButton.frame.height/2))]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupJoinFamily() {
        // set to made to have fully rounded corners
        joinFamilyButton.layer.cornerRadius = 99999.9
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
