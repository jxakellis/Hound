//
//  SettingsFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsFamilyViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class SettingsFamilyViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, DogManagerControlFlowProtocol {
    
    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    
    @IBAction private func willRefresh(_ sender: Any) {
        self.refreshButton.isEnabled = false
        ActivityIndicator.shared.beginAnimating(title: navigationItem.title ?? "", view: self.view, navigationItem: navigationItem)
        FamilyRequest.get(invokeErrorManager: true) { requestWasSuccessful, _ in
            self.refreshButton.isEnabled = true
            ActivityIndicator.shared.stopAnimating(navigationItem: self.navigationItem)
            if requestWasSuccessful == true {
                // update the data to reflect what was retrieved from the server
                self.repeatableSetup()
                self.tableView.reloadData()
                // its possible that the familymembers table changed its constraint for height, so re layout
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: Properties
    
    /// Returns whether or not the user is the head of the family. This changes whether or not they can kick family members, delete the family, etc.
    var isUserFamilyHead: Bool {
        let familyMember = FamilyMember.findFamilyMember(forUserId: UserInformation.userId!)
        return familyMember?.isFamilyHead ?? false
    }
    
    var leaveFamilyAlertController: GeneralUIAlertController!
    
    var kickFamilyMemberAlertController: GeneralUIAlertController!
    
    weak var delegate: SettingsFamilyViewControllerDelegate!
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // (if head of family)
        // TO DO add subscription controls
        
        oneTimeSetup()
        
        repeatableSetup()
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
        
        if sender.localized is SettingsViewController {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: newDogManager)
        }
    }
    
    // MARK: - Functions
    
    /// These properties only need assigned once.
    private func oneTimeSetup() {
        
        tableView.separatorInset = .zero
        
        leaveFamilyButton.layer.cornerRadius = 10.0
    }
    
    /// These properties can be reassigned. Does not reload anything, rather just configures.
    private func repeatableSetup() {
        // MARK: Pause All Reminders
        
        isPausedSwitch.isOn = FamilyConfiguration.isPaused
        
        // MARK: Family Code
        var code = FamilyConfiguration.familyCode
        code.insert("-", at: code.index(code.startIndex, offsetBy: 4))
        familyCode.text = "Code: \(code)"
        
        // MARK: Family Lock
        
        isLockedSwitch.isOn = FamilyConfiguration.isLocked
        updateIsLockedLabel()
        
        // MARK: Family Members
        
        tableView.allowsSelection = isUserFamilyHead
        
        var tableViewHeight: CGFloat {
            var height = 0.0
            for index in 0..<FamilyConfiguration.familyMembers.count {
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
        
        leaveFamilyAlertController = GeneralUIAlertController(title: "placeholder", message: "Hound will restart once this process is complete", preferredStyle: .alert)
        
        // user is not the head of the family, so the button is enabled for them
        if isUserFamilyHead == false {
            leaveFamilyButton.isEnabled = true
            
            leaveFamilyButton.setTitle("Leave Family", for: .normal)
            leaveFamilyButton.backgroundColor = .systemBlue
            
            leaveFamilyAlertController.title = "Are you sure you want to leave your family?"
            let leaveAlertAction = UIAlertAction(title: "Leave Family", style: .destructive) { _ in
                FamilyRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _ in
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
            if FamilyConfiguration.familyMembers.count == 1 {
                leaveFamilyButton.isEnabled = true
                leaveFamilyButton.backgroundColor = .systemBlue
            }
            // user is only family member so can destroy their family
            else {
                leaveFamilyButton.isEnabled = false
                leaveFamilyButton.backgroundColor = .systemGray4
            }
            
            leaveFamilyButton.setTitle("Delete Family", for: .normal)
            
            leaveFamilyAlertController.title = "Are you sure you want to delete your family?"
            let deleteAlertAction = UIAlertAction(title: "Delete Family", style: .destructive) { _ in
                FamilyRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _ in
                    if requestWasSuccessful == true {
                        // family was successfully deleted, restart app to default state
                        exit(0)
                    }
                }
            }
            leaveFamilyAlertController.addAction(deleteAlertAction)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        leaveFamilyAlertController.addAction(cancelAlertAction)
    }
    
    // MARK: - Individual Settings
    
    // MARK: Pause All Reminders
    /// Switch for pause all timers
    @IBOutlet private weak var isPausedSwitch: UISwitch!
    
    /// If the pause all timers switch it triggered, calls thing function
    @IBAction private func didToggleIsPaused(_ sender: Any) {
        let dogManager = MainTabBarViewController.staticDogManager
        let isPaused = isPausedSwitch.isOn
        
        guard isPaused != FamilyConfiguration.isPaused else {
            return
        }
        
        let body: [String: Any] = [
            ServerDefaultKeys.isPaused.rawValue: isPaused
        ]
        
        FamilyRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == true {
                // update the local information to reflect the server change
                FamilyConfiguration.isPaused = isPaused
                if isPaused == false {
                    // TO DO have server calculate reminderExecutionDates itself
                    // reminders are now unpaused, we must update the server with the new executionDates (can't calculate them itself)
                    DogsRequest.get(invokeErrorManager: true, dogManager: self.getDogManager()) { newDogManager, _ in
                        guard newDogManager != nil else {
                            return
                        }
                        
                        for dog in newDogManager!.dogs {
                            // update the Hound server with
                            let remindersToUpdate = dog.dogReminders.reminders.filter({ reminder in
                                // create an array of reminders with non-nil executionDates, as we are providing the Hound server with a list of reminders with the newly calculated executionDates
                                return (reminder.reminderExecutionDate == nil) == false
                            })
                            RemindersRequest.update(invokeErrorManager: true, forDogId: dog.dogId, forReminders: remindersToUpdate) { requestWasSuccessful, _ in
                                if requestWasSuccessful == true {
                                    // the call to update the server on the reminder unpause was successful, now send to delegate
                                    self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: newDogManager!)
                                }
                            }
                        }
                    }
                }
                else {
                    // reminders are now paused, so remove the timers
                    TimingManager.invalidateAll(forDogManager: dogManager)
                }
            }
            else {
                self.isPausedSwitch.setOn(!isPaused, animated: true)
            }
        }
    }
    
    // MARK: Family Code
    @IBOutlet private weak var familyCode: ScaledUILabel!
    
    // MARK: Family Lock
    @IBOutlet private weak var isLockedLabel: ScaledUILabel!
    @IBOutlet private weak var isLockedSwitch: UISwitch!
    @IBAction private func didToggleIsLocked(_ sender: Any) {
        
        // assume request will go through and update values
        let initalIsLocked = FamilyConfiguration.isLocked
        FamilyConfiguration.isLocked = isLockedSwitch.isOn
        updateIsLockedLabel()
        
        let body = [ServerDefaultKeys.isLocked.rawValue: isLockedSwitch.isOn]
        FamilyRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // request failed so we revert
                FamilyConfiguration.isLocked = initalIsLocked
                self.updateIsLockedLabel()
                self.isLockedSwitch.setOn(initalIsLocked, animated: true)
            }
        }
    }
    
    private func updateIsLockedLabel() {
        isLockedLabel.text = "Lock: "
        if FamilyConfiguration.isLocked == true {
            // locked emoji
            isLockedLabel.text!.append("🔐")
        }
        else {
            // unlocked emoji
            isLockedLabel.text!.append("🔓")
        }
    }
    
    // MARK: Family Members
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return FamilyConfiguration.familyMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let familyMember = FamilyConfiguration.familyMembers[indexPath.row]
        // family members is sorted to have the family head as its first element
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsFamilyHeadTableViewCell", for: indexPath) as! SettingsFamilyHeadTableViewCell
            cell.setup(forDisplayFullName: familyMember.displayFullName, userId: familyMember.userId)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsFamilyMemberTableViewCell", for: indexPath) as! SettingsFamilyMemberTableViewCell
            cell.setup(forDisplayFullName: familyMember.displayFullName, userId: familyMember.userId, isUserFamilyHead: isUserFamilyHead)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        // the first row is the family head who should be able to be selected
        if indexPath.row != 0 {
            // construct the alert controller which will confirm if the user wants to kick the family member
            let familyMember = FamilyConfiguration.familyMembers[indexPath.row]
            kickFamilyMemberAlertController = GeneralUIAlertController(title: "Do you want to kick \(familyMember.displayFullName) from your family?", message: nil, preferredStyle: .alert)
            
            let kickAlertAction = UIAlertAction(title: "Kick \(familyMember.displayFullName)", style: .destructive) { _ in
                // the user wants to kick the family member so query the server
                let body = [ServerDefaultKeys.kickUserId.rawValue: familyMember.userId]
                RequestUtils.beginAlertControllerQueryIndictator()
                FamilyRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
                    RequestUtils.endAlertControllerQueryIndictator {
                        if requestWasSuccessful == true {
                            // invoke the @IBAction function to refresh this page
                            self.willRefresh(0)
                        }
                    }
                }
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            kickFamilyMemberAlertController.addAction(kickAlertAction)
            kickFamilyMemberAlertController.addAction(cancelAlertAction)
            
            AlertManager.enqueueAlertForPresentation(kickFamilyMemberAlertController)
        }
    }
    
    // MARK: Leave Family
    @IBOutlet private weak var leaveFamilyButton: UIButton!
    
    @IBAction private func didClickLeaveFamily(_ sender: Any) {
        
        // User could have only clicked this button if they were eligible to leave the family
        
        AlertManager.enqueueAlertForPresentation(leaveFamilyAlertController)
        
    }
    
}
