//
//  HomeMainScreenTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HomeMainScreenTableViewController: UITableViewController {
    
    private var activeDogManager: DogManager {
        var dogManager = DogManager()
        
        for d in 0..<MainTabBarViewController.staticDogManager.dogs.count {
            guard MainTabBarViewController.staticDogManager.dogs[d].getEnable() == true else{
                continue
            }
            
            let dogAdd = MainTabBarViewController.staticDogManager.dogs[d].copy() as! Dog
            dogAdd.dogRequirments.clearRequirements()
            
            for r in 0..<MainTabBarViewController.staticDogManager.dogs[d].dogRequirments.requirements.count {
                guard MainTabBarViewController.staticDogManager.dogs[d].dogRequirments.requirements[r].getEnable() == true else{
                    continue
                }
                
                try! dogAdd.dogRequirments.addRequirement(newRequirement: MainTabBarViewController.staticDogManager.dogs[d].dogRequirments.requirements[r].copy() as! Requirement)
            }
            try! dogManager.addDog(dogAdded: dogAdd)
        }
        
        return dogManager
    }
    
    private var activeTimers: Int{
        var count = 0
        for d in 0..<MainTabBarViewController.staticDogManager.dogs.count {
            guard MainTabBarViewController.staticDogManager.dogs[d].getEnable() == true else{
                continue
            }
            
            for r in 0..<MainTabBarViewController.staticDogManager.dogs[d].dogRequirments.requirements.count {
                guard MainTabBarViewController.staticDogManager.dogs[d].dogRequirments.requirements[r].getEnable() == true else{
                    continue
                }
                
                count = count + 1
            }
        }
        return count
    }
    
    private func timerPriority(priorityIndex: Int) -> (String, Requirement) {
        var assortedTimers: [(String, Requirement)] = []
        
        let activeDogManagerCopy: DogManager = self.activeDogManager.copy() as! DogManager
        
        for _ in 0..<self.activeTimers {
            var lowestTimeInterval: TimeInterval = .infinity
            var lowestRequirement: (String, Requirement)?
            
            for d in 0..<activeDogManagerCopy.dogs.count {
                for r in 0..<activeDogManagerCopy.dogs[d].dogRequirments.requirements.count {
                    let currentTimeInterval = try! Date().distance(to: TimingManager.timerDictionary[activeDogManagerCopy.dogs[d].dogSpecifications.getDogSpecification(key: "name")]![activeDogManagerCopy.dogs[d].dogRequirments.requirements[r].label]!.fireDate)
                    
                    if currentTimeInterval < lowestTimeInterval
                    {
                        lowestTimeInterval = currentTimeInterval
                        lowestRequirement = try! (activeDogManagerCopy.dogs[d].dogSpecifications.getDogSpecification(key: "name"), activeDogManagerCopy.dogs[d].dogRequirments.requirements[r])
                    }
                }
            }
            assortedTimers.append(lowestRequirement!)
            try! activeDogManagerCopy.findDog(dogName: lowestRequirement!.0).dogRequirments.removeRequirement(requirementName: lowestRequirement!.1.label)
        }
        
        return assortedTimers[priorityIndex]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        self.tableView.separatorInset = UIEdgeInsets.zero
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    var loopTimer: Timer?
    
    override func viewDidAppear(_ animated: Bool) {
        loopTimer = Timer.init(fireAt: Date(), interval: TimeInterval(1), target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: true)
        
        RunLoop.main.add(loopTimer!, forMode: .default)
        
        if self.activeTimers == 0 {
            self.tableView.separatorStyle = .none
        }
        else if self.activeTimers > 0 {
            self.tableView.separatorStyle = .singleLine
        }
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        loopTimer?.invalidate()
    }
    
    @objc private func reloadTable(){
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.activeTimers == 0 {
            return 1
        }
        return self.activeTimers
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.activeTimers == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeMainScreenTableViewCellDogRequirementDisplay", for: indexPath)
            
            let cellPriority = self.timerPriority(priorityIndex: indexPath.row)
            
            let testCell = cell as! HomeMainScreenTableViewCellDogRequirementDisplay
            testCell.setup(parentDogName: cellPriority.0, requirementPassed: cellPriority.1)
            
            return cell
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
