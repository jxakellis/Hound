//
//  DogsRequirementTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementTableViewControllerDelegate {
    func didUpdateRequirements(newRequirementList: [Requirement])
}

class DogsRequirementTableViewController: UITableViewController, DogsInstantiateRequirementViewControllerDelegate, DogsRequirementTableViewCellDelegate {
    
    var delegate: DogsRequirementTableViewControllerDelegate! = nil
    
    
    //MARK: Dogs Requirement Table View Cell
    
    
    //When the trash button is clicked on a cell, triggered through a delegate, this function is called to delete the corrosponding info
    func trashClicked(dogName: String) {
        do{
            try requirementManager.removeRequirement(requirementName: dogName)
            updateTable()
        }
        catch {
            print("\(requirementManager.requirements.count)" + requirementManager.requirements[0].label)
        }
    }
    
    //MARK: Dogs Instantiate Requirement
    
    var instantiateRequirementVC = DogsInstantiateRequirementViewController()
    
    //When this function is called through a delegate, it adds the information to the list of requirements and updates the cells to display it
    func didAddToList(requirement: Requirement) throws{
        try requirementManager.addRequirement(newRequirement: requirement)
        updateTable()
        print(requirementManager.requirements[0])
        delegate.didUpdateRequirements(newRequirementList: requirementManager.requirements)
    }
    
    //MARK: Main
    
    var requirementManager = RequirementManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var tempRequirement = Requirement()
        do{
            try tempRequirement.changeLabel(newLabel: RequirementConstant.defaultLabel)
            try tempRequirement.changeDescription(newDescription: RequirementConstant.defaultDescription)
            try tempRequirement.changeInterval(newInterval: RequirementConstant.defaultTimeInterval)
        }
        catch{
            print("Error in DogsRequirementTableViewController with temp requirement \(error)")
        }
        
        do {
            try requirementManager.addRequirement(newRequirement: tempRequirement)
        }
        catch {
            print("Error in adding tempRequirement to requirementManager in DogsRequirementTableViewController \(error)")
        }
        
    }

    // MARK: - Table view data source

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
        castCell.setLabel(initLabel: requirementManager.requirements[indexPath.row].label)
        castCell.setTimeInterval(initTimeInterval: requirementManager.requirements[indexPath.row].interval)
        // Configure the cell...

        return cell
    }
    
    //Reloads table data when it is updated, if you change the data w/o calling this, the data display to the user will not be updated
    func updateTable(){
        self.tableView.reloadData()
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Links delegate to instantiateRequirement
        if segue.identifier == "dogsInstantiateRequirementViewController" {
            instantiateRequirementVC = segue.destination as! DogsInstantiateRequirementViewController
            instantiateRequirementVC.delegate = self
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
