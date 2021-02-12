//
//  DogsMainScreenTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewControllerDelegate{
    func didSelectDog(sectionIndexOfDog: Int)
    func didUpdateDogManager(newDogManager: DogManager, sender: AnyObject?)
}

class DogsMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol, DogsMainScreenTableViewCellDogDisplayDelegate, DogsMainScreenTableViewCellDogRequirementDelegate {
    
    //MARK: DogsMainScreenTableViewCellDogDisplayDelegate
    
    //Dog switch is toggled in DogsMainScreenTableViewCellDogDisplay
    func didToggleDogSwitch(dogName: String, isEnabled: Bool) {
        
        let sudoDogManager = getDogManager()
        try! sudoDogManager.findDog(dogName: dogName).setEnable(newEnableStatus: isEnabled)
        
        if isEnabled == true {
            for r in try! 0..<sudoDogManager.findDog(dogName: dogName).dogRequirments.requirements.count {
                if try! sudoDogManager.findDog(dogName: dogName).dogRequirments.requirements[r].getEnable() == true {
                    try! sudoDogManager.findDog(dogName: dogName).dogRequirments.requirements[r].lastExecution = Date()
                }
            }
        }
        
        setDogManager(newDogManager: sudoDogManager, sender: DogsMainScreenTableViewCellDogDisplay())
        
    }
    
    //If the trash button was clicked in the Dog Display cell, this function is called using a delegate from the cell class to handle the press
    func didClickTrash(dogName: String) {
        
        var sudoDogManager = getDogManager()
        
        try! sudoDogManager.removeDog(name: dogName)
        
        setDogManager(newDogManager: sudoDogManager, sender: DogsMainScreenTableViewCellDogDisplay())
        updateTable()
    }
    
    //MARK: DogsMainScreenTableViewCellDogRequirementDelegate
    
    //Requirement switch is toggled in DogsMainScreenTableViewCellDogRequirement
    func didToggleRequirementSwitch(parentDogName: String, requirementName: String, isEnabled: Bool) {
        
        let sudoDogManager = getDogManager()
        try! sudoDogManager.findDog(dogName: parentDogName).dogRequirments.findRequirement(requirementName: requirementName).setEnable(newEnableStatus: isEnabled)
        
        if isEnabled == true {
            try! sudoDogManager.findDog(dogName: parentDogName).dogRequirments.findRequirement(requirementName: requirementName).lastExecution = Date()
        }
        setDogManager(newDogManager: sudoDogManager, sender: DogsMainScreenTableViewCellDogRequirement())
        
    }
    
    //If the trash button was clicked in the Dog Requirement cell, this function is called using a delegate from the cell class to handle the press
    func didClickTrash(parentDogName: String, requirementName: String) {
        
        let sudoDogManager = getDogManager()
        try! sudoDogManager.findDog(dogName: parentDogName).dogRequirments.removeRequirement(requirementName: requirementName)
        setDogManager(newDogManager: sudoDogManager, sender: DogsMainScreenTableViewCellDogRequirement())
        updateTable()
        
    }
    
    
    //MARK: Properties
    
    var delegate: DogsMainScreenTableViewControllerDelegate! = nil
    
    //MARK: Dog Manager
    
    private var dogManager: DogManager = DogManager()
    
    //Get method, returns a copy of dogManager to remove possible editting of dog manager through class reference type
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    //Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
    func setDogManager(newDogManager: DogManager, sender: AnyObject?){
        dogManager = newDogManager.copy() as! DogManager
        
        //possible senders
        //DogsRequirementTableViewCell
        //DogsMainScreenTableViewCellDogDisplay
        //DogsViewController
        
        if !(sender is DogsViewController){
            delegate.didUpdateDogManager(newDogManager: getDogManager(), sender: self)
        }
        
        self.updateDogManagerDependents()
    }
    
    //Updates different visual aspects to reflect data change of dogManager
    func updateDogManagerDependents(){
        if getDogManager().dogs.count > 0 {
            tableView.allowsSelection = true
        }
        else{
            tableView.allowsSelection = false
        }
        
        //update tableview moved else where
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if getDogManager().dogs.count == 0 {
            tableView.allowsSelection = false
        }
        
        tableView.separatorInset = UIEdgeInsets.zero
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //MARK: Class Functions
    
    private func updateTable(){
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if getDogManager().dogs.count == 0 {
            return 1
        }
        return getDogManager().dogs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getDogManager().dogs.count == 0 {
            return 1
        }
        
        return getDogManager().dogs[section].dogRequirments.requirements.count+1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if getDogManager().dogs.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            return cell
        }
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsMainScreenTableViewCellDogDisplay", for: indexPath)
            
            let testCell = cell as! DogsMainScreenTableViewCellDogDisplay
            testCell.dogSetup(dogPassed: getDogManager().dogs[indexPath.section])
            testCell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsMainScreenTableViewCellDogRequirement", for: indexPath)
            
            let testCell = cell as! DogsMainScreenTableViewCellDogRequirement
            try! testCell.requirementSetup(parentDogName: getDogManager().dogs[indexPath.section].dogSpecifications.getDogSpecification(key: "name"), requirementPassed: getDogManager().dogs[indexPath.section].dogRequirments.requirements[indexPath.row-1])
            testCell.delegate = self
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if getDogManager().dogs.count > 0 {
            if indexPath.row == 0{
                delegate.didSelectDog(sectionIndexOfDog: indexPath.section)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
