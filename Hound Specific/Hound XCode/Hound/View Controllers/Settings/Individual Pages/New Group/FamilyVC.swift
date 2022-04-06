//
//  SettingsFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsFamilyViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var statusDescription: ScaledUILabel!
    
    // MARK: - Properties
    
    var familyMembers: [FamilyMember] = []
    
    private var settingsFamilyTableViewController: SettingsFamilyTableViewController!
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        statusDescription.text = "Family Code: \(FamilyConfiguration.familyCode)\nLocked: \(FamilyConfiguration.isLocked)"
        // Do any additional setup after loading the view.
        
        // TO DO fix the scroll view. SettingsFamilyTableViewController's height is constrained (when it shouldn't be) so the storyboard doesn't throw a fit about constraints
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "settingsFamilyTableViewController" {
            settingsFamilyTableViewController = segue.destination as? SettingsFamilyTableViewController
            settingsFamilyTableViewController.familyMembers = self.familyMembers
        }
    }
    
}
