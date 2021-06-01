//
//  DogsRequirementTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementTableViewControllerDelegate {
    ///When the requirement list is updated, the whole list is pushed through to the DogsAddDogVC, this is much simplier than updating one item at a time, easier for consistant arrays
    func didUpdateRequirements(newRequirementList: [Requirement])
}

class DogsRequirementTableViewController: UITableViewController, RequirementManagerControlFlowProtocol, DogsNestedRequirementViewControllerDelegate, DogsRequirementTableViewCellDelegate {
    
    //MARK: - Dogs Requirement Table View Cell
    
    func didToggleEnable(sender: Sender, requirementUUID: String, newEnableStatus: Bool) {
        let sudoRequirementManager = getRequirementManager()
        do {
            try sudoRequirementManager.findRequirement(forUUID: requirementUUID).setEnable(newEnableStatus: newEnableStatus)
            setRequirementManager(sender: sender, newRequirementManager: sudoRequirementManager)
        }
        catch {
            fatalError("DogsRequirementTableViewController func didToggleEnable(requirementName: String, newEnableStatus: Bool) error")
        }
        
        
    }
    
    //MARK: - Dogs Nested Requirement
    
    var dogsNestedRequirementViewController = DogsNestedRequirementViewController()
    
    ///When this function is called through a delegate, it adds the information to the list of requirements and updates the cells to display it
    func didAddRequirement(sender: Sender, newRequirement: Requirement) throws{
        var sudoRequirementManager = getRequirementManager()
        try sudoRequirementManager.addRequirement(newRequirement: newRequirement)
        setRequirementManager(sender: sender, newRequirementManager: sudoRequirementManager)
    }
    
    func didUpdateRequirement(sender: Sender, updatedRequirement: Requirement) throws {
        var sudoRequirementManager = getRequirementManager()
        try sudoRequirementManager.changeRequirement(forUUID: updatedRequirement.uuid, newRequirement: updatedRequirement)
        setRequirementManager(sender: sender, newRequirementManager: sudoRequirementManager)
    }
    
    func didRemoveRequirement(sender: Sender, removedRequirementUUID: String) {
        var sudoRequirementManager = getRequirementManager()
        try! sudoRequirementManager.removeRequirement(forUUID: removedRequirementUUID)
        setRequirementManager(sender: sender, newRequirementManager: sudoRequirementManager)
    }
    
    //MARK: - Requirement Manager Control Flow Protocol
    
    private var requirementManager = RequirementManager()
    
    func getRequirementManager() -> RequirementManager {
        //RequirementManagerEfficencyImprovements return requirementManager.copy() as! RequirementManager
        return requirementManager
    }
    
    func setRequirementManager(sender: Sender, newRequirementManager: RequirementManager) {
        //RequirementManagerEfficencyImprovements requirementManager = newRequirementManager.copy() as! RequirementManager
        requirementManager = newRequirementManager
        
        if !(sender.localized is DogsRequirementNavigationViewController){
            delegate.didUpdateRequirements(newRequirementList: getRequirementManager().requirements)
        }
        
        if !(sender.origin is DogsRequirementTableViewCell) && !(sender.origin is DogsRequirementTableViewController){
            updateRequirementManagerDependents()
        }
        
        reloadTableConstraints()
        
    }
    
    private func reloadTableConstraints(){
        if getRequirementManager().requirements.count > 0{
            self.tableView.rowHeight = -1
        }
        else {
            self.tableView.rowHeight = 65.5
        }
    }
    
    func updateRequirementManagerDependents() {
        self.reloadTable()
    }
    
    //MARK: - Properties
    
    ///Used for when a requirement is selected (aka clicked) on the table view in order to pass information to open the editing page for the requirement
    private var selectedRequirement: Requirement?
    
    var delegate: DogsRequirementTableViewControllerDelegate! = nil
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.getRequirementManager().requirements.count == 0 {
            self.tableView.allowsSelection = false
        }
        else {
            self.tableView.allowsSelection = true
        }
        
        MainTabBarViewController.mainTabBarViewController.dogsViewController.dogsAddDogViewController.willHideButtons(isHidden: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MainTabBarViewController.mainTabBarViewController.dogsViewController.dogsAddDogViewController.willHideButtons(isHidden: true)
    }
    // MARK: Table View Management
    
    //Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    ///Returns the number of cells present in section (currently only 1 section)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //if getRequirementManager().requirements.count == 0{
        //    return 1
        //}
        return getRequirementManager().requirements.count
    }
    
    ///Configures cells at the given index path, pulls from requirement manager requirements to get configuration parameters for each cell, corrosponding cell goes to corrosponding index of requirement manager requirement e.g. cell 1 at [0]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogsRequirementTableViewCell", for: indexPath)
        
        let castCell = cell as! DogsRequirementTableViewCell
        castCell.delegate = self
        castCell.setup(requirement: getRequirementManager().requirements[indexPath.row])
        
        return cell
    }
    
    ///Reloads table data when it is updated, if you change the data w/o calling this, the data display to the user will not be updated
    private func reloadTable(){
        
        if self.getRequirementManager().requirements.count == 0 {
            self.tableView.allowsSelection = false
        }
        else {
            self.tableView.allowsSelection = true
        }
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRequirement = getRequirementManager().requirements[indexPath.row]
        self.performSegue(withIdentifier: "dogsNestedRequirementViewController", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let sudoRequirementManager = getRequirementManager()
        if editingStyle == .delete && sudoRequirementManager.requirements.count > 0{
            let deleteConfirmation = GeneralAlertController(title: "Are you sure you want to delete \(sudoRequirementManager.requirements[indexPath.row].displayTypeName)?", message: nil, preferredStyle: .alert)
            
            let alertActionDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
                sudoRequirementManager.requirements.remove(at: indexPath.row)
                self.setRequirementManager(sender: Sender(origin: self, localized: self), newRequirementManager: sudoRequirementManager)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            deleteConfirmation.addAction(alertActionDelete)
            deleteConfirmation.addAction(alertActionCancel)
            AlertPresenter.shared.enqueueAlertForPresentation(deleteConfirmation)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.getRequirementManager().requirements.count == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Links delegate to NestedRequirement
        if segue.identifier == "dogsNestedRequirementViewController" {
            dogsNestedRequirementViewController = segue.destination as! DogsNestedRequirementViewController
            dogsNestedRequirementViewController.delegate = self
            
            if selectedRequirement != nil {
                dogsNestedRequirementViewController.targetRequirement = selectedRequirement!
                selectedRequirement = nil
            }
            
        }
    }
    
    
}
