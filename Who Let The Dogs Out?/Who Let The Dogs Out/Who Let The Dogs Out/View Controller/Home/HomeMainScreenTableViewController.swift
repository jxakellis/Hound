//
//  HomeMainScreenTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HomeMainScreenTableViewControllerDelegate {
    func didSelectRow(sender: AnyObject)
    func didDeselectAllRows(sender: AnyObject)
}

class HomeMainScreenTableViewController: UITableViewController {
    
    //MARK: Calculated Properties
    
    ///MainTabBarViewController's dogManager copied and transformed to have only active requirements of active dogs present
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
    
    ///Returns number of active timers
    var activeTimers: Int{
        
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
    
    ///Returns parentDogName and Requirement for a given index of priority sorted version of activeDogManager, timer to execute soonest is index 0
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
    
    //MARK: Properties
    
    ///Timer that repeats every second to update tableView data, needed due to the fact the timers countdown every second
    private var loopTimer: Timer?
    
    var delegate: HomeMainScreenTableViewControllerDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        tableView.dataSource = self
        tableView.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.activeTimers == 0 {
            self.tableView.separatorStyle = .none
            self.tableView.allowsSelection = false
        }
        else if self.activeTimers > 0 {
            self.tableView.separatorStyle = .singleLine
            self.tableView.allowsMultipleSelection = true
        }
        
        self.reloadTable()
        
        loopTimer = Timer.init(fireAt: Date(), interval: TimeInterval(1), target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: true)
        
        RunLoop.main.add(loopTimer!, forMode: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loopTimer!.invalidate()
    }
    
    ///Reloads the tableViews data, has to persist any selected rows so tableView.reloadData() is not sufficent as it tosses the information
    @objc func reloadTable(){
        let selectedIndexPaths = self.tableView.indexPathsForSelectedRows
        
        self.tableView.reloadData()
        
        //if timer is not implemented, constant alerts about symbolic breakpoint at UITableViewAlertForCellForRowAtIndexPathAccessDuringUpdate due to the tableView.reloadData() above
        if selectedIndexPaths != nil{
            let timer = Timer(fireAt: Date(), interval: 0, target: self, selector: #selector(selectIndexPaths(sender:)), userInfo: ["selectedIndexPaths" : selectedIndexPaths!], repeats: false)
            
            RunLoop.main.add(timer, forMode: .default)
        }
    }
    
    ///Visually selects rows that were selected before the tableView was reloaded, done in a timer format due to weird bug as without the delay an error break things
    @objc private func selectIndexPaths(sender: Timer){
        
        guard let parsedDictionary = sender.userInfo as? [String: [IndexPath]]
        else{
            print("error HMCTVC selectIndexPaths")
            return
        }
        
        let selectedIndexPaths: [IndexPath] = parsedDictionary["selectedIndexPaths"]!
        
        for selectedIndexPath in selectedIndexPaths{
            self.tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
        }
        
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
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if self.tableView.indexPathsForSelectedRows == nil {
            delegate.didDeselectAllRows(sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tableView.indexPathsForSelectedRows?.count == 1 {
            delegate.didSelectRow(sender: self)
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
