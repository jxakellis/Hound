//
//  HomeMainScreenTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HomeMainScreenTableViewControllerDelegate {
    func didSelectOption(sender: Sender)
}

class HomeMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol, HomeMainScreenTableViewCellRequirementLogDelegate {
    
    //MARK: HomeMainScreenTableViewCellRequirementLogDelegate
    
    func didDisable(sender: Sender, dogName: String, requirementName: String) {
        logState = false
        TimingManager.willDisableTimer(sender: Sender(origin: sender, localized: self), dogName: dogName, requirementName: requirementName, dogManager: getDogManager())
        delegate.didSelectOption(sender: Sender(origin: sender, localized: self))
        updateDogManagerDependents()
    }
    
    func didSnooze(sender: Sender, dogName: String, requirementName: String) {
        logState = false
        TimingManager.willSnoozeTimer(sender: Sender(origin: sender, localized: self), dogName: dogName, requirementName: requirementName, dogManager: getDogManager())
        delegate.didSelectOption(sender: Sender(origin: sender, localized: self))
        updateDogManagerDependents()
    }
    
    func didReset(sender: Sender, dogName: String, requirementName: String) {
        logState = false
        TimingManager.willResetTimer(sender: Sender(origin: sender, localized: self), dogName: dogName, requirementName: requirementName, dogManager: getDogManager())
        delegate.didSelectOption(sender: Sender(origin: sender, localized: self))
        updateDogManagerDependents()
    }
    
    //MARK: DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        self.dogManager = newDogManager.copy() as! DogManager
        
        if sender.localized is HomeViewController {
            self.updateDogManagerDependents()
        }
    }
    
    func updateDogManagerDependents() {
        self.reloadTable()
    }
    
    
    
    //MARK: Properties
    
    ///Timer that repeats every second to update tableView data, needed due to the fact the timers countdown every second
    private var loopTimer: Timer?
    
    var delegate: HomeMainScreenTableViewControllerDelegate! = nil
    
    private var storedLogState: Bool = false
    var logState: Bool {
        get {
            return storedLogState
        }
        set(newLogState) {
            if newLogState == false {
                firstTimeFade = true
            }
            storedLogState = newLogState
        }
    }
    
    ///MainTabBarViewController's dogManager copied and transformed to have only active requirements of active dogs present
    private var activeDogManager: DogManager {
        var dogManager = DogManager()
        
        for d in 0..<self.getDogManager().dogs.count {
            guard self.getDogManager().dogs[d].getEnable() == true else{
                continue
            }
            
            let dogAdd = self.getDogManager().dogs[d].copy() as! Dog
            dogAdd.dogRequirments.clearRequirements()
            
            for r in 0..<self.getDogManager().dogs[d].dogRequirments.requirements.count {
                guard self.getDogManager().dogs[d].dogRequirments.requirements[r].getEnable() == true else{
                    continue
                }
                
                try! dogAdd.dogRequirments.addRequirement(newRequirement: self.getDogManager().dogs[d].dogRequirments.requirements[r].copy() as! Requirement)
            }
            try! dogManager.addDog(dogAdded: dogAdd)
        }
        
        return dogManager
    }
    
    ///Returns parentDogName and Requirement for a given index of priority sorted version of activeDogManager, timer to execute soonest is index 0
    private func timerPriority(priorityIndex: Int) -> (String, Requirement) {
        
        var assortedTimers: [(String, Requirement)] = []
        
        let activeDogManagerCopy: DogManager = self.activeDogManager.copy() as! DogManager
        
        for _ in 0..<TimingManager.enabledTimersCount! {
            var lowestTimeInterval: TimeInterval = .infinity
            var lowestRequirement: (String, Requirement)?
            
            for d in 0..<activeDogManagerCopy.dogs.count {
                for r in 0..<activeDogManagerCopy.dogs[d].dogRequirments.requirements.count {
    
                    
                    let fireDate: Date? = try! TimingManager.timerDictionary[activeDogManagerCopy.dogs[d].dogSpecifications.getDogSpecification(key: "name")]![activeDogManagerCopy.dogs[d].dogRequirments.requirements[r].requirementName]?.fireDate
                    
                    if fireDate == nil {
                        fatalError("asdadsad")
                    }
                    else {
                        let currentTimeInterval = Date().distance(to: fireDate!)
                        
                        if currentTimeInterval < lowestTimeInterval
                        {
                            lowestTimeInterval = currentTimeInterval
                            lowestRequirement = try! (activeDogManagerCopy.dogs[d].dogSpecifications.getDogSpecification(key: "name"), activeDogManagerCopy.dogs[d].dogRequirments.requirements[r])
                        }
                    }
                    
                }
            }
            assortedTimers.append(lowestRequirement!)
            try! activeDogManagerCopy.findDog(dogName: lowestRequirement!.0).dogRequirments.removeRequirement(requirementName: lowestRequirement!.1.requirementName)
        }
        
        return assortedTimers[priorityIndex]
    }
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.reloadTable()
        
        loopTimer = Timer.init(fireAt: Date(), interval: TimeInterval(1), target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: true)
        
        RunLoop.main.add(loopTimer!, forMode: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loopTimer!.invalidate()
    }
    
    ///Reloads the tableViews data, has to persist any selected rows so tableView.reloadData() is not sufficent as it tosses the information
    @objc func reloadTable(){
        self.tableView.reloadData()
        
        if TimingManager.enabledTimersCount == 0 || TimingManager.enabledTimersCount == nil{
            self.tableView.separatorStyle = .none
        }
        else if TimingManager.enabledTimersCount! > 0 {
            self.tableView.separatorStyle = .singleLine
        }
    }
    
    /*
     func willFadeAwayLogView(){
     for cellRow in 0..<TimingManager.activeTimers! {
     
     print("willFadeAwayLogView -- cR: \(cellRow)")
     let cell = tableView(self.tableView, cellForRowAt: IndexPath(row: cellRow, section: 0))
     let testCell: HomeMainScreenTableViewCellRequirementLog = cell as! HomeMainScreenTableViewCellRequirementLog
     
     
     testCell.toggleFade(newFadeStatus: false, animated: true) { (fadeCompleted) in
     if cellRow+1 == TimingManager.activeTimers! {
     print("reloaded table")
     //self.reloadTable()
     //self.logState = false
     }
     }
     
     }
     
     }
     */
    
    
    // MARK: - Table View Management
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TimingManager.enabledTimersCount == 0 || TimingManager.enabledTimersCount == nil {
            return 1
        }
        return TimingManager.enabledTimersCount!
    }
    
    private var firstTimeFade: Bool = true
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if TimingManager.enabledTimersCount == nil {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            
            let testCell = cell as! HomeMainScreenTableViewCellEmpty
            testCell.label.text = "All Reminders Paused"
            
            return cell
            
        }
        else if TimingManager.enabledTimersCount == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            
            let testCell = cell as! HomeMainScreenTableViewCellEmpty
            
            var requirementCreated: Bool = false
            for dog in 0..<getDogManager().dogs.count {
                if requirementCreated == true {
                    break
                }
                if getDogManager().dogs[dog].dogRequirments.requirements.count > 0 {
                    requirementCreated = true
                    break
                }
            }
            
            if getDogManager().dogs.count != 0 && requirementCreated == true{
                
                testCell.label.text = "All Reminders Disabled"
            }
            else {
                testCell.label.text = "No Reminders Created"
            }
            
            return cell
        }
        else if logState == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeMainScreenTableViewCellRequirementLog", for: indexPath)
            
            let cellPriority = self.timerPriority(priorityIndex: indexPath.row)
            
            let testCell = cell as! HomeMainScreenTableViewCellRequirementLog
            testCell.setup(parentDogName: cellPriority.0, requirementName: cellPriority.1.requirementName)
            testCell.delegate = self
            
            if firstTimeFade == true{
                testCell.toggleFade(newFadeStatus: true, animated: true)
                
                if indexPath.row + 1 == TimingManager.enabledTimersCount {
                    firstTimeFade = false
                }
            }
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeMainScreenTableViewCellRequirementDisplay", for: indexPath)
            
            let cellPriority = self.timerPriority(priorityIndex: indexPath.row)
            
            let testCell = cell as! HomeMainScreenTableViewCellRequirementDisplay
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
