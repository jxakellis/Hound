//
//  DogsRequirementTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementTableViewControllerDelegate {
    //When the requirement list is updated, the whole list is pushed through to the DogsAddDogVC, this is much simplier than updating one item at a time, easier for consistant arrays
    func didUpdateRequirements(newRequirementList: [Requirement])
}

class DogsRequirementTableViewController: UITableViewController, DogsInstantiateRequirementViewControllerDelegate, DogsRequirementTableViewCellDelegate {
    
    
    //MARK: Dogs Requirement Table View Cell
    
    //When the trash button is clicked on a cell, triggered through a delegate, this function is called to delete the corrosponding info
    func didClickTrash(dogName: String) {
        do{
            try requirementManager.removeRequirement(requirementName: dogName)
            updateTable()
        }
        catch {
            print("\(requirementManager.requirements.count)" + requirementManager.requirements[0].name)
        }
    }
    
    //MARK: Dogs Instantiate Requirement
    
    var dogsInstantiateRequirementViewController = DogsInstantiateRequirementViewController()
    
    //When this function is called through a delegate, it adds the information to the list of requirements and updates the cells to display it
    func didAddRequirement(newRequirement: Requirement) throws{
        try requirementManager.addRequirement(newRequirement: newRequirement)
        updateTable()
    }
    
    func didUpdateRequirement(formerName: String, updatedRequirement: Requirement) throws {
        try requirementManager.changeRequirement(requirementToBeChanged: formerName, newRequirement: updatedRequirement)
        updateTable()
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue){
        
    }
    
    //MARK: Properties
    
    var requirementManager = RequirementManager()
    
    var delegate: DogsRequirementTableViewControllerDelegate! = nil
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.requirementManager.requirements.count == 0 {
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
    // MARK: - Table View Data Source
    
    //Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //Returns the number of cells present in section (currently only 1 section)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if requirementManager.requirements.count == 0{
            return 1
        }
        return requirementManager.requirements.count
    }
    
    //Configures cells at the given index path, pulls from requirement manager requirements to get configuration parameters for each cell, corrosponding cell goes to corrosponding index of requirement manager requirement e.g. cell 1 at [0]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if requirementManager.requirements.count == 0{
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            return emptyCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogsRequirementTableViewCell", for: indexPath)
        
        let castCell = cell as! DogsRequirementTableViewCell
        castCell.delegate = self
        castCell.setName(initName: requirementManager.requirements[indexPath.row].name)
        castCell.setTimeInterval(initTimeInterval: requirementManager.requirements[indexPath.row].executionInterval)
        // Configure the cell...
        
        return cell
    }
    
    //Reloads table data when it is updated, if you change the data w/o calling this, the data display to the user will not be updated
    func updateTable(){
        
        if self.requirementManager.requirements.count == 0 {
            self.tableView.allowsSelection = false
        }
        else {
            self.tableView.allowsSelection = true
        }
        
        self.tableView.reloadData()
        delegate.didUpdateRequirements(newRequirementList: requirementManager.requirements)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedTuple = (requirementManager.requirements[indexPath.row].name, requirementManager.requirements[indexPath.row].description, requirementManager.requirements[indexPath.row].executionInterval, true)
        
        self.performSegue(withIdentifier: "dogsInstantiateRequirementViewController", sender: self)
        
    }
    
    private var selectedTuple: (String, String, TimeInterval, Bool)? = nil
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Links delegate to instantiateRequirement
        if segue.identifier == "dogsInstantiateRequirementViewController" {
            dogsInstantiateRequirementViewController = segue.destination as! DogsInstantiateRequirementViewController
            dogsInstantiateRequirementViewController.delegate = self
            
            if self.selectedTuple != nil {
                dogsInstantiateRequirementViewController.setupTuple = self.selectedTuple!
                self.selectedTuple = nil
            }
            
        }
    }
    
    
}
