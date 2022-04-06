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

    @IBOutlet private weak var statusDescription: ScaledUILabel!
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var familyMembers: [FamilyMember] = []
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        statusDescription.text = "Family Code: \(FamilyConfiguration.familyCode)\nLocked: \(FamilyConfiguration.isLocked)"
        
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        
        // TO DO add placeholder row if no family members are found
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
}
