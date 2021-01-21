//
//  DogsRequirementTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsRequirementTableViewController: UITableViewController, DogsInstantiateRequirementViewControllerDelegate, DogsRequirementTableViewCellDelegate {
    
    
    //MARK: Dogs Requirement Table View Cell
    
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
    
    func didAddToList(requirement: Requirement) {
        do{
            try requirementManager.addRequirement(newRequirement: requirement)
            updateTable()
        }
        catch {
            print("Error when adding dog instantiated requirement to requirement list in DogsRequirementTableViewController")
        }
    }
    
    //MARK: Main
    
    var requirementManager = RequirementManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var tempRequirement = Requirement()
        do{
            try tempRequirement.changeLabel(newLabel: "abc")
            try  tempRequirement.changeDescription(newDescription: "cde")
            try tempRequirement.changeInterval(newInterval: TimeInterval(3600))
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requirementManager.requirements.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogsRequirementTableViewCell", for: indexPath)

        let castCell = cell as! DogsRequirementTableViewCell
        castCell.delegate = self
        castCell.setLabel(initLabel: requirementManager.requirements[indexPath.row].label)
        castCell.setTimeInterval(initTimeInterval: requirementManager.requirements[indexPath.row].interval)
        // Configure the cell...

        return cell
    }
    
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
        if segue.identifier == "instantiateRequirement" {
            instantiateRequirementVC = segue.destination as! DogsInstantiateRequirementViewController
            instantiateRequirementVC.delegate = self
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
