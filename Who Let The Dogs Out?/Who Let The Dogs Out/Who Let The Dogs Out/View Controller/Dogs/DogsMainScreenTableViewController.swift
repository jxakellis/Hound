//
//  DogsMainScreenTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsMainScreenTableViewController: UITableViewController, DogsMainScreenTableViewCellDogDisplayDelegate, DogsMainScreenTableViewCellDogRequirementDelegate {
    
    
    
    //MARK: Delegate implementation
    
    //Dog switch is toggled in DogsMainScreenTableViewCellDogDisplay
    func dogSwitchToggled(dogName: String, isEnabled: Bool) {
        //no redundancy built in
        for i in 0..<dogManagerDisplay.dogs.count{
            if try! dogManagerDisplay.dogs[i].dogSpecifications.getDogSpecification(key: "name") == dogName{
                dogManagerDisplay.dogs[i].isEnabled = isEnabled
                return
            }
        }
    }
    
    //Requirement switch is toggled in DogsMainScreenTableViewCellDogRequirement
    func requirementSwitchToggled(parentDogName: String, requirementName: String, isEnabled: Bool) {
        //no redundancy built in
        for i in 0..<dogManagerDisplay.dogs.count{
            if try! dogManagerDisplay.dogs[i].dogSpecifications.getDogSpecification(key: "name") == parentDogName{
                for x in 0..<dogManagerDisplay.dogs[i].dogRequirments.requirements.count {
                    if dogManagerDisplay.dogs[i].dogRequirments.requirements[x].label == requirementName{
                        dogManagerDisplay.dogs[i].dogRequirments.requirements[x].isEnabled = isEnabled
                        return
                    }
                }
            }
        }
    }
    
    //MARK: Properties
    
    var superDogsViewController: DogsViewController = DogsViewController()
    
    private var dogManagerDisplay: DogManager = DogManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //MARK: Class Functions
    
    func updateDogManager(newDogManager: DogManager){
        dogManagerDisplay = newDogManager
        self.tableView.reloadData()
    }
    
    private func updateTable(){
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dogManagerDisplay.dogs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dogManagerDisplay.dogs[section].dogRequirments.requirements.count+1
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsMainScreenTableViewCellDogDisplay", for: indexPath)
            let testCell = cell as! DogsMainScreenTableViewCellDogDisplay
            testCell.dogSetup(dogPassed: dogManagerDisplay.dogs[indexPath.section])
            testCell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsMainScreenTableViewCellDogRequirement", for: indexPath)
            let testCell = cell as! DogsMainScreenTableViewCellDogRequirement
            try! testCell.requirementSetup(parentDogName: dogManagerDisplay.dogs[indexPath.section].dogSpecifications.getDogSpecification(key: "name"), requirementPassed: dogManagerDisplay.dogs[indexPath.section].dogRequirments.requirements[indexPath.row-1])
            testCell.delegate = self
            return cell
        }
     }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            superDogsViewController.performSegue(withIdentifier: "dogsAddDogViewController", sender: self)
            superDogsViewController.dogsAddDogViewController.addDogButton.backgroundColor = .green
            superDogsViewController.dogsAddDogViewController.addDogButton.setTitle("Update", for: .normal)
            try! superDogsViewController.dogsAddDogViewController.updateDogTuple = (true, dogManagerDisplay.dogs[indexPath.section].dogSpecifications.getDogSpecification(key: "name"))
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
