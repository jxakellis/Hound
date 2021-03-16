//
//  DogsMainScreenTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewControllerDelegate{
    func didSelectDog(indexPathSection dogIndex: Int)
    func didSelectRequirement(indexPathSection dogIndex: Int, indexPathRow requirementIndex: Int)
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class DogsMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol, DogsMainScreenTableViewCellDogDisplayDelegate, DogsMainScreenTableViewCellDogRequirementDisplayDelegate {
    
    //MARK: DogsMainScreenTableViewCellDogDisplayDelegate
    
    ///Dog switch is toggled in DogsMainScreenTableViewCellDogDisplay
    func didToggleDogSwitch(sender: Sender, dogName: String, isEnabled: Bool) {
        
        let sudoDogManager = getDogManager()
        try! sudoDogManager.findDog(dogName: dogName).setEnable(newEnableStatus: isEnabled)
        
        if isEnabled == true {
            for r in try! 0..<sudoDogManager.findDog(dogName: dogName).dogRequirments.requirements.count {
                if try! sudoDogManager.findDog(dogName: dogName).dogRequirments.requirements[r].getEnable() == true {
                    try! sudoDogManager.findDog(dogName: dogName).dogRequirments.requirements[r].lastExecution = Date()
                    try! sudoDogManager.findDog(dogName: dogName).dogRequirments.requirements[r].changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
                }
            }
        }
        
        setDogManager(sender: sender, newDogManager: sudoDogManager)
        
        //This is so the cell animates the changing of the switch properly, if this code wasnt implemented then when the table view is reloaded a new batch of cells is produced and that cell has the new switch state, bypassing the animation as the instantant the old one is switched it produces and shows the new switch
        let indexPath = try! IndexPath(row: 0, section: getDogManager().findIndex(dogName: dogName))
        
        let cell = tableView.cellForRow(at: indexPath) as! DogsMainScreenTableViewCellDogDisplay
        cell.dogToggleSwitch.isOn = !isEnabled
        cell.dogToggleSwitch.setOn(isEnabled, animated: true)
    }
    
    ///If the trash button was clicked in the Dog Display cell, this function is called using a delegate from the cell class to handle the press
    func didClickTrash(sender: Sender, dogName: String) {
        
        var sudoDogManager = getDogManager()
        
        try! sudoDogManager.removeDog(name: dogName)
        
        setDogManager(sender: sender, newDogManager: sudoDogManager)
        
    }
    
    //MARK: DogsMainScreenTableViewCellDogRequirementDelegate
    
    ///Requirement switch is toggled in DogsMainScreenTableViewCellDogRequirement
    func didToggleRequirementSwitch(sender: Sender, parentDogName: String, requirementName: String, isEnabled: Bool) {
        
        let sudoDogManager = getDogManager()
        try! sudoDogManager.findDog(dogName: parentDogName).dogRequirments.findRequirement(requirementName: requirementName).setEnable(newEnableStatus: isEnabled)
        
        if isEnabled == true {
            try! sudoDogManager.findDog(dogName: parentDogName).dogRequirments.findRequirement(requirementName: requirementName).lastExecution = Date()
            var sudoRequirement = try! sudoDogManager.findDog(dogName: parentDogName).dogRequirments.findRequirement(requirementName: requirementName)
            sudoRequirement.changeIntervalElapsed(newIntervalElapsed: TimeInterval(0))
        }
        
        setDogManager(sender: sender, newDogManager: sudoDogManager)
        
        //This is so the cell animates the changing of the switch properly, if this code wasnt implemented then when the table view is reloaded a new batch of cells is produced and that cell has the new switch state, bypassing the animation as the instantant the old one is switched it produces and shows the new switch
        let indexPath = try! IndexPath(row: getDogManager().findDog(dogName: parentDogName).dogRequirments.findIndex(requirementName: requirementName)+1, section: getDogManager().findIndex(dogName: parentDogName))
        
        let cell = tableView.cellForRow(at: indexPath) as! DogsMainScreenTableViewCellDogRequirementDisplay
        cell.requirementToggleSwitch.isOn = !isEnabled
        cell.requirementToggleSwitch.setOn(isEnabled, animated: true)
    }
    
    ///If the trash button was clicked in the Dog Requirement cell, this function is called using a delegate from the cell class to handle the press
    func didClickTrash(sender: Sender, parentDogName: String, requirementName: String) {
        
        let sudoDogManager = getDogManager()
        try! sudoDogManager.findDog(dogName: parentDogName).dogRequirments.removeRequirement(requirementName: requirementName)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
        updateTable()
        
    }
    
    
    //MARK: Properties
    
    var delegate: DogsMainScreenTableViewControllerDelegate! = nil
    
    var updatingSwitch: Bool = false
    
    //MARK: Dog Manager
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager){
        dogManager = newDogManager.copy() as! DogManager
        
        //possible senders
        //DogsRequirementTableViewCell
        //DogsMainScreenTableViewCellDogDisplay
        //DogsViewController
        if !(sender.localized is DogsViewController){
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
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
        
        updateTable()
    }
    
    override func viewDidLoad() {
        self.dogManager = MainTabBarViewController.staticDogManager
        super.viewDidLoad()
        
        if getDogManager().dogs.count == 0 {
            tableView.allowsSelection = false
        }
        
        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTable()
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
            testCell.setup(dogPassed: getDogManager().dogs[indexPath.section])
            testCell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsMainScreenTableViewCellDogRequirementDisplay", for: indexPath)
            
            let testCell = cell as! DogsMainScreenTableViewCellDogRequirementDisplay
            try! testCell.setup(parentDogName: getDogManager().dogs[indexPath.section].dogSpecifications.getDogSpecification(key: "name"), requirementPassed: getDogManager().dogs[indexPath.section].dogRequirments.requirements[indexPath.row-1])
            testCell.delegate = self
            
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if getDogManager().dogs.count > 0 {
            if indexPath.row == 0{
                delegate.didSelectDog(indexPathSection: indexPath.section)
                
            }
            else if indexPath.row > 0 {
                delegate.didSelectRequirement(indexPathSection: indexPath.section, indexPathRow: indexPath.row-1)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && getDogManager().dogs.count > 0 {
            let sudoDogManager = getDogManager()
            if indexPath.row > 0 {
                sudoDogManager.dogs[indexPath.section].dogRequirments.requirements.remove(at: indexPath.row-1)
            }
            else {
                sudoDogManager.dogs.remove(at: indexPath.section)
            }
            setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.getDogManager().dogs.count == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    /*
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             objects.remove(at: indexPath.row)
             tableView.deleteRows(at: [indexPath], with: .fade)
         } else if editingStyle == .insert {
             // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
         }
     }
     */
    
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
