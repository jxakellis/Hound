//
//  HomeMainScreenTableViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HomeMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol{
    
    //MARK: - DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        //DogManagerEfficencyImprovement return dogManager.copy() as! DogManager
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        //DogManagerEfficencyImprovement self.dogManager = newDogManager.copy() as! DogManager
        dogManager = newDogManager
        if sender.localized is HomeViewController {
            self.updateDogManagerDependents()
        }
    }
    
    func updateDogManagerDependents() {
        self.reloadTable()
    }
    
    //MARK: - Properties
    
    ///Timer that repeats every second to update tableView data, needed due to the fact the timers countdown every second
    private var loopTimer: Timer?
    
    ///Returns parentDogName and Requirement for a given index of priority sorted version of activeDogManager, timer to execute soonest is index 0
    private func timerPriority(priorityIndex: Int) -> (String, Requirement) {
        
        var assortedTimers: [(String, Requirement)] = []
        
        //FUTUREEFFICENCY, compact this function as every time this page willAppear and the cells are reloaded, each individual cell calls thing function to figure out its priority. Makes unneccessary copies.
        let activeDogManagerCopy: DogManager = getDogManager().activeDogManager
        
        for _ in 0..<TimingManager.currentlyActiveTimersCount! {
            var lowestTimeInterval: TimeInterval = .infinity
            var lowestRequirement: (String, Requirement)?
            
            for d in 0..<activeDogManagerCopy.dogs.count {
                for r in 0..<activeDogManagerCopy.dogs[d].dogRequirments.requirements.count {
    
                    
                    let fireDate: Date? =  TimingManager.timerDictionary[activeDogManagerCopy.dogs[d].dogTraits.dogName]![activeDogManagerCopy.dogs[d].dogRequirments.requirements[r].requirementName]?.fireDate
                    
                    if fireDate == nil {
                        fatalError("fireDate nil for timerPriority when it should exist, HomeMainScreenTableViewController")
                    }
                    else {
                        let currentTimeInterval = Date().distance(to: fireDate!)
                        
                        if currentTimeInterval < lowestTimeInterval
                        {
                            lowestTimeInterval = currentTimeInterval
                            lowestRequirement = (activeDogManagerCopy.dogs[d].dogTraits.dogName, activeDogManagerCopy.dogs[d].dogRequirments.requirements[r])
                        }
                    }
                    
                }
            }
            assortedTimers.append(lowestRequirement!)
            try! activeDogManagerCopy.findDog(dogName: lowestRequirement!.0).dogRequirments.removeRequirement(requirementName: lowestRequirement!.1.requirementName)
        }
        
        return assortedTimers[priorityIndex]
    }
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.reloadTable()
        
        if getDogManager().hasEnabledDog && getDogManager().hasEnabledRequirement{
            loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.loopReload), userInfo: nil, repeats: true)
            
            RunLoop.main.add(loopTimer!, forMode: .default)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if loopTimer != nil {
            loopTimer!.invalidate()
            loopTimer = nil
        }
    }
    
    @objc private func loopReload(){
        for cell in tableView.visibleCells{
            if cell is HomeMainScreenTableViewCellEmpty{
                loopTimer!.invalidate()
                loopTimer = nil
            }
            else {
                let sudoCell = cell as! HomeMainScreenTableViewCellRequirementDisplay
                sudoCell.reloadCell()
            }
        }
    }
    
    ///Reloads the tableViews data, has to persist any selected rows so tableView.reloadData() is not sufficent as it tosses the information
    func reloadTable(){
        self.tableView.reloadData()
        
        
        if TimingManager.currentlyActiveTimersCount == 0 || TimingManager.currentlyActiveTimersCount == nil{
            self.tableView.separatorStyle = .none
            self.tableView.allowsSelection = false
        }
        else if TimingManager.currentlyActiveTimersCount! > 0 {
            self.tableView.separatorStyle = .singleLine
            self.tableView.allowsSelection = true
        }
    }
    
    ///Called when a requirement is clicked by the user, display an action sheet of possible modifcations to the alarm.
    private func willShowSelectedActionSheet(parentDogName: String, requirement: Requirement){
        
        let alertController = GeneralAlertController(title: "\(requirement.requirementName) for \(parentDogName)", message: nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        let alertActionDisable = UIAlertAction(
            title:"Disable",
            style: .destructive,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    TimingManager.willDisableTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, requirementName: requirement.requirementName)
                })
        
        var logTitle: String {
            //Yes I know these if statements are redundent and terrible coding but it's whatever
            if requirement.isActive == false {
                return "Did it!"
            }
            else if requirement.timerMode == .snooze || requirement.timerMode == .countDown {
                return "Did it!"
            }
            else {
                if requirement.timeOfDayComponents.isSkipping == true {
                    return "Undo it!"
                }
                else {
                    return "Did it!"
                }
            }
        }
        
        let alertActionLog = UIAlertAction(
        title: logTitle,
        style: .default,
        handler:
            {
                (alert: UIAlertAction!)  in
                TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, requirementName: requirement.requirementName)
                
            })
        alertController.addAction(alertActionCancel)
        
        alertController.addAction(alertActionLog)
        
        alertController.addAction(alertActionDisable)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
    }
    
    
    // MARK: - Table View Management
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TimingManager.currentlyActiveTimersCount == 0 || TimingManager.currentlyActiveTimersCount == nil {
            return 1
        }
        return TimingManager.currentlyActiveTimersCount!
    }
    
    private var firstTimeFade: Bool = true
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if TimingManager.currentlyActiveTimersCount == nil {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            
            let customCell = cell as! HomeMainScreenTableViewCellEmpty
            customCell.label.text = "All Reminders Paused"
            
            return cell
            
        }
        else if TimingManager.currentlyActiveTimersCount == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            
            let customCell = cell as! HomeMainScreenTableViewCellEmpty
            
            if getDogManager().hasCreatedDog == false{
                customCell.label.text = "No Dogs Or Reminders Created"
            }
            else if getDogManager().hasCreatedRequirement == false {
                customCell.label.text = "No Reminders Created"
            }
            else if getDogManager().hasEnabledDog == false && getDogManager().hasEnabledRequirement == false {
                customCell.label.text = "All Dogs and Reminders Disabled"
            }
            else if getDogManager().hasEnabledDog == false {
                customCell.label.text = "All Dogs Disabled"
            }
            else if getDogManager().hasCreatedRequirement == true{
                customCell.label.text = "All Reminders Disabled"
            }
            else {
                customCell.label.text = "HomeMainScreenTableViewController Decipher Error"
            }
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeMainScreenTableViewCellRequirementDisplay", for: indexPath)
            
            let cellPriority = self.timerPriority(priorityIndex: indexPath.row)
            
            let customCell = cell as! HomeMainScreenTableViewCellRequirementDisplay
            customCell.setup(parentDogName: cellPriority.0, requirementPassed: cellPriority.1)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let priorityPosition = timerPriority(priorityIndex: indexPath.row)
        let parentDogName = priorityPosition.0
        let requirement = priorityPosition.1
        
        willShowSelectedActionSheet(parentDogName: parentDogName, requirement: requirement)
    }
}
