//
//  SettingsFamilyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsFamilyViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class SettingsFamilyViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, DogManagerControlFlowProtocol {
    
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
        _ = FamilyRequest.get(invokeErrorManager: true) { requestWasSuccessful, _ in
            self.refreshButton.isEnabled = true
            ActivityIndicator.shared.stopAnimating(navigationItem: self.navigationItem)
            
            guard requestWasSuccessful else {
                return
            }
            
            // update the data to reflect what was retrieved from the server
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.refreshFamilyTitle, forSubtitle: VisualConstant.BannerTextConstant.refreshFamilySubtitle, forStyle: .success)
            self.repeatableSetup()
            self.tableView.reloadData()
            // its possible that the familymembers table changed its constraint for height, so re layout
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func didClickShareFamily(_ sender: Any) {
        
        // Check that the family has space for at least one new member, otherwise block them from sharing the family.
        guard FamilyConfiguration.familyMembers.count < FamilyConfiguration.activeFamilySubscription.numberOfFamilyMembers else {
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.invalidSubscriptionFamilyShareTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidSubscriptionFamilyShareSubtitle, forStyle: .danger)
            return
        }
        
        // Make sure that the family is unlocked so new 
        guard FamilyConfiguration.isLocked == false else {
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.invalidLockedFamilyShareTitle, forSubtitle: VisualConstant.BannerTextConstant.invalidLockedFamilyShareSubtitle, forStyle: .danger)
            return
        }
        
        let shareHoundText = "Download Hound to help our family stay on track with caring for our pets! Never forget to lend a helping hand with Hound's reminders, and never question when your pets were last helped with logs of care. Join my Hound family today by using the following code: \(familyCode)\n\nhttps://apps.apple.com/us/app/hound-dog-schedule-organizer/id1564604025"
        
        let textToShare = [ shareHoundText ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        // Configure so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes =
        [ UIActivity.ActivityType.addToReadingList,
          UIActivity.ActivityType.assignToContact,
          UIActivity.ActivityType.markupAsPDF,
          UIActivity.ActivityType.openInIBooks ]
        
        if #available(iOS 15.4, *) {
            activityViewController.excludedActivityTypes?.append(UIActivity.ActivityType.sharePlay)
        }
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Properties
    
    var leaveFamilyAlertController: GeneralUIAlertController!
    
    var kickFamilyMemberAlertController: GeneralUIAlertController!
    
    weak var delegate: SettingsFamilyViewControllerDelegate!
    
    private var familyCode: String {
        var code = FamilyConfiguration.familyCode
        code.insert("-", at: code.index(code.startIndex, offsetBy: 4))
        return code
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneTimeSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        repeatableSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Dog Manager
    
    private var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        if (sender.localized is SettingsViewController) == false {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: forDogManager)
        }
    }
    
    // MARK: - Functions
    
    /// These properties only need assigned once.
    private func oneTimeSetup() {
        
        tableView.separatorInset = .zero
        
        leaveFamilyButton.layer.cornerRadius = VisualConstant.SizeConstant.largeRectangularButtonCornerRadious
    }
    
    /// These properties can be reassigned. Does not reload anything, rather just configures.
    private func repeatableSetup() {
        
        // MARK: Family Code
        familyCodeLabel.text = "Code: \(familyCode)"
        
        // MARK: Family Lock
        
        isLockedSwitch.isOn = FamilyConfiguration.isLocked
        updateIsLockedLabel()
        
        // MARK: Family Members
        
        tableView.allowsSelection = FamilyConfiguration.isUserFamilyHead
        
        // MARK: Leave Family Button
        
        func dismissViewControllersUntilServerSyncViewController() {
            // Dismiss anything that the main tab bar vc is currently presenting
            if let presentedViewController = MainTabBarViewController.mainTabBarViewController?.presentedViewController {
                presentedViewController.dismiss(animated: false)
            }
            
            // Store presentingViewController. MainTabBarViewController.mainTabBarViewController?.presentingViewController will turn to nil once mainTabBarViewController is dismissed (as mainTabBarViewController is no longer presented)
            let presentingViewController = MainTabBarViewController.mainTabBarViewController?.presentingViewController
            MainTabBarViewController.mainTabBarViewController?.dismiss(animated: true) {
                // If the view controller that is one level above the main vc isn't the server sync vc, we want to dismiss that view controller directly so we get to the server sync vc
                if (presentingViewController is ServerSyncViewController) == false {
                    // leave this step as animated, otherwise the user can see a jump
                    presentingViewController?.dismiss(animated: true)
                }
            }
        }
        
        leaveFamilyAlertController = GeneralUIAlertController(title: "placeholder", message: nil, preferredStyle: .alert)
        
        // user is not the head of the family, so the button is enabled for them
        if FamilyConfiguration.isUserFamilyHead == false {
            leaveFamilyButton.isEnabled = true
            
            leaveFamilyButton.setTitle("Leave Family", for: .normal)
            leaveFamilyButton.backgroundColor = .systemBlue
            
            leaveFamilyAlertController.title = "Are you sure you want to leave your family?"
            let leaveAlertAction = UIAlertAction(title: "Leave Family", style: .destructive) { _ in
                FamilyRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _ in
                    if requestWasSuccessful == true {
                        // family was successfully left, revert to server sync view controller
                        dismissViewControllersUntilServerSyncViewController()
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
            
            let familyHasPurchasedSubscription = FamilyConfiguration.activeFamilySubscription.product != ClassConstant.SubscriptionConstant.defaultSubscriptionProduct
            // If the user has an active subscription, then let them know they will lose the rest of its duration
            let forfitSubscriptionDisclaimer: String = familyHasPurchasedSubscription ? " If you delete your family, the remaining duration of your active subscription will be forfitted." : ""
            
            leaveFamilyAlertController.title = "Are you sure you want to delete your family? \(forfitSubscriptionDisclaimer)"
            let deleteAlertAction = UIAlertAction(title: "Delete Family", style: .destructive) { _ in
                FamilyRequest.delete(invokeErrorManager: true) { requestWasSuccessful, _ in
                    if requestWasSuccessful == true {
                        // family was successfully deleted, revert to server sync view controller
                        dismissViewControllersUntilServerSyncViewController()
                    }
                }
            }
            leaveFamilyAlertController.addAction(deleteAlertAction)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        leaveFamilyAlertController.addAction(cancelAlertAction)
        
        // MARK: Introduct Page
        
        if LocalConfiguration.hasLoadedSettingsFamilyIntroductionViewControllerBefore == false {
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "SettingsFamilyIntroductionViewController")
        }
    }
    
    // MARK: - Individual Settings
    
    // MARK: Family Code
    @IBOutlet private weak var familyCodeLabel: ScaledUILabel!
    
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
            isLockedLabel.text?.append("🔐")
        }
        else {
            // unlocked emoji
            isLockedLabel.text?.append("🔓")
        }
    }
    
    // MARK: Family Members
    @IBOutlet private weak var tableView: UITableView!
    
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
        if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "settingsFamilyHeadTableViewCell", for: indexPath) as? SettingsFamilyHeadTableViewCell {
            cell.setup(forDisplayFullName: familyMember.displayFullName, userId: familyMember.userId)
            
            return cell
        }
        else if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsFamilyMemberTableViewCell", for: indexPath) as? SettingsFamilyMemberTableViewCell {
            cell.setup(forDisplayFullName: familyMember.displayFullName, userId: familyMember.userId)
            
            return cell
        }
        else {
            return UITableViewCell()
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
                RequestUtils.beginRequestIndictator()
                FamilyRequest.delete(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
                    RequestUtils.endRequestIndictator {
                        if requestWasSuccessful == true {
                            // invoke the @IBAction private function to refresh this page
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
        
        guard FamilyConfiguration.isUserFamilyHead else {
            // The user isn't the family head, so we don't need to check for the status of the family subscription
            AlertManager.enqueueAlertForPresentation(leaveFamilyAlertController)
            return
        }
        
        let activeSubscription = FamilyConfiguration.activeFamilySubscription
        
        // Check to make sure either the family has the default free subsription or they have an active subscription that isn't auto-renewing. So that if they leave the family, they won't be charged for subscription that isn't attached to anything
        guard activeSubscription.product == ClassConstant.SubscriptionConstant.defaultSubscriptionProduct || (activeSubscription.product != ClassConstant.SubscriptionConstant.defaultSubscriptionProduct && activeSubscription.isAutoRenewing == false) else {
            ErrorConstant.FamilyResponseError.leaveSubscriptionActive.alert()
            return
        }
        
        // User could have only clicked this button if they were eligible to leave the family
        
        AlertManager.enqueueAlertForPresentation(leaveFamilyAlertController)
        
    }
    
}
