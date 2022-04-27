//
//  SettingsFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsFamilyViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return familyMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let familyMember = familyMembers[indexPath.row]
        // family members is sorted to have the family head as its first element
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsFamilyHeadTableViewCell", for: indexPath) as! SettingsFamilyHeadTableViewCell
            cell.setup(firstName: familyMember.firstName, lastName: familyMember.lastName, userId: familyMember.userId)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsFamilyMemberTableViewCell", for: indexPath) as! SettingsFamilyMemberTableViewCell
            cell.setup(firstName: familyMember.firstName, lastName: familyMember.lastName, userId: familyMember.userId)
            
            return cell
        }
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var containerView: UIView!

    // Family Code
    @IBOutlet private weak var familyCode: ScaledUILabel!
    
    // Family Lock
    @IBOutlet private weak var familyIsLockedLabel: ScaledUILabel!
    @IBOutlet private weak var familyIsLockedSwitch: UISwitch!
    @IBAction private func didToggleFamilyIsLocked(_ sender: Any) {
        
        // assume request will go through and update values
        let initalFamilyIsLocked = FamilyConfiguration.familyIsLocked
        FamilyConfiguration.familyIsLocked = familyIsLockedSwitch.isOn
        updateFamilyIsLockedLabel()
        
        let body = [ServerDefaultKeys.familyIsLocked.rawValue: familyIsLockedSwitch.isOn]
        FamilyRequest.update(body: body) { requestWasSuccessful in
            if requestWasSuccessful == false {
                // request failed so we revert
                FamilyConfiguration.familyIsLocked = initalFamilyIsLocked
                self.updateFamilyIsLockedLabel()
                self.familyIsLockedSwitch.setOn(initalFamilyIsLocked, animated: true)
            }
        }
    }
    
    // Family Members
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // Leave Family
    @IBOutlet private weak var leaveFamilyButton: UIButton!
    
    @IBAction private func didClickLeaveFamily(_ sender: Any) {
        
        // User could have only clicked this button if they were eligible to leave the family
        
        AlertManager.enqueueAlertForPresentation(leaveFamilyAlertController)
        
    }
    // MARK: - Properties
    
    var familyMembers: [FamilyMember] = []
    
    let leaveFamilyAlertController = GeneralUIAlertController(title: "placeholder", message: "Hound will restart once this process is complete", preferredStyle: .alert)
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // (if head of family)
        // TO DO add control to kick people
        // TO DO add subscription controls
        
       // MARK: Family Code

        familyCode.text = "Code: \(FamilyConfiguration.familyCode)"
        
        // MARK: Family Lock
        
        familyIsLockedSwitch.isOn = FamilyConfiguration.familyIsLocked
        updateFamilyIsLockedLabel()
        
        // MARK: Family Members
        
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        
        var tableViewHeight: CGFloat {
            var height = 0.0
            for index in 0..<familyMembers.count {
                // head of family
                if index == 0 {
                    // icon size + top/bot constraints
                    height += 45 + 10 + 10
                }
                else {
                    // icon size + top/bot constraints
                    height += 35 + 10 + 10
                }
            }
            // add a tiny bit so you can see sepaarator at bottom
            height += 1
            return height
        }
        
        tableViewHeightConstraint.constant = tableViewHeight
        
        // MARK: Leave Family Button
        
        // find the user in the family that is the head
        let familyHead = familyMembers.first { familyMember in
            if familyMember.isFamilyHead == true {
                return true
            }
            else {
                return false
            }
        }
        
        // user is not the head of the family, so the button is enabled for them
        if familyHead?.userId != UserInformation.userId {
            leaveFamilyButton.isEnabled = true
            
            leaveFamilyButton.setTitle("Leave Family", for: .normal)
            
            leaveFamilyAlertController.title = "Are you sure you want to leave your family?"
            let leaveAlertAction = UIAlertAction(title: "Leave Family", style: .destructive) { _ in
                FamilyRequest.delete { requestWasSuccessful in
                    if requestWasSuccessful == true {
                        // family was successfully left, restart app to default state
                        exit(0)
                    }
                }
            }
            leaveFamilyAlertController.addAction(leaveAlertAction)
        }
        // user is the head of the family, further checks needed
        else {
            // user must kicked other members before they can destroy their family
            if familyMembers.count == 1 {
                leaveFamilyButton.isEnabled = true
            }
            // user is only family member so can destroy their family
            else {
                leaveFamilyButton.isEnabled = false
            }
            
            leaveFamilyButton.setTitle("Delete Family", for: .normal)
            
            leaveFamilyAlertController.title = "Are you sure you want to delete your family?"
            let deleteAlertAction = UIAlertAction(title: "Delete Family", style: .destructive) { _ in
                FamilyRequest.delete { requestWasSuccessful in
                    if requestWasSuccessful == true {
                        // family was successfully deleted, restart app to default state
                        exit(0)
                    }
                }
            }
            leaveFamilyAlertController.addAction(deleteAlertAction)
        }
        
        DesignConstant.standardizeLargeButton(forButton: leaveFamilyButton)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        leaveFamilyAlertController.addAction(cancelAlertAction)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    private func updateFamilyIsLockedLabel() {
        familyIsLockedLabel.text = "Lock: "
        if FamilyConfiguration.familyIsLocked == true {
            // locked emoji
            familyIsLockedLabel.text!.append("🔐")
        }
        else {
            // unlocked emoji
            familyIsLockedLabel.text!.append("🔓")
        }
    }
    
}
