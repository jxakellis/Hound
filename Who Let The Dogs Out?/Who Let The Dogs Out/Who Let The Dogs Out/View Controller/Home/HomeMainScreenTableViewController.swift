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

class HomeMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol{
    
    /*
    //MARK: HomeMainScreenTableViewCellRequirementLogDelegate
    
    func didDisable(sender: Sender, dogName: String, requirementName: String) {
        //logState = false
        TimingManager.willDisableTimer(sender: Sender(origin: sender, localized: self), dogName: dogName, requirementName: requirementName, dogManager: getDogManager())
        delegate.didSelectOption(sender: Sender(origin: sender, localized: self))
        updateDogManagerDependents()
    }
    
    func didSnooze(sender: Sender, dogName: String, requirementName: String) {
        //logState = false
        TimingManager.willSnoozeTimer(sender: Sender(origin: sender, localized: self), dogName: dogName, requirementName: requirementName, dogManager: getDogManager())
        delegate.didSelectOption(sender: Sender(origin: sender, localized: self))
        updateDogManagerDependents()
    }
    
    func didReset(sender: Sender, dogName: String, requirementName: String) {
        //logState = false
        TimingManager.willResetTimer(sender: Sender(origin: sender, localized: self), dogName: dogName, requirementName: requirementName, dogManager: getDogManager())
        delegate.didSelectOption(sender: Sender(origin: sender, localized: self))
        updateDogManagerDependents()
    }
     */
    
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
    
    /*
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
                self.reloadTable()
            
        }
    }
     */
    
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
        
        for _ in 0..<TimingManager.currentlyActiveTimersCount! {
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
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.reloadTable()
        
        loopTimer = Timer(fireAt: Date(), interval: TimeInterval(1), target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: true)
        
        RunLoop.main.add(loopTimer!, forMode: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loopTimer!.invalidate()
    }
    
    ///Reloads the tableViews data, has to persist any selected rows so tableView.reloadData() is not sufficent as it tosses the information
    @objc func reloadTable(){
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
        let alertController = CustomAlertController(title: "\(requirement.requirementName) for \(parentDogName)", message: nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(
            title:"Cancel",
            style: .cancel,
            handler:
                {
                    (alert: UIAlertAction!)  in
                })
        
        let alertActionDisable = UIAlertAction(
            title:"Disable",
            style: .destructive,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    TimingManager.willDisableTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, requirementName: requirement.requirementName)
                })
        
        var logTitle: String {
            if requirement.timerMode == .snooze || requirement.timerMode == .countDown {
                return "Did it!"
            }
            else {
                if requirement.timeOfDayComponents.isSkipping == true {
                    return "Unskip Next Reminder"
                }
                else {
                    return "Skip Next Reminder"
                }
            }
        }
        
        let alertActionLog = UIAlertAction(
        title: logTitle,
        style: .default,
        handler:
            {
                (alert: UIAlertAction!)  in
                if requirement.timerMode == .timeOfDay {
                    TimingManager.willToggleSkipTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, requirementName: requirement.requirementName)
                }
                else {
                    TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, requirementName: requirement.requirementName)
                }
                
            })
        
        let alertActionSnooze = UIAlertAction(
            title: "Cancel Snooze",
            style: .default,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    
                    TimingManager.willSnoozeTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, requirementName: requirement.requirementName, isCancellingSnooze: true)
                })
        
       
        
        alertController.addAction(alertActionCancel)
        
        alertController.addAction(alertActionLog)
        
        if requirement.snoozeComponents.isSnoozed == true {
            alertController.addAction(alertActionSnooze)
        }
        
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
            
            let testCell = cell as! HomeMainScreenTableViewCellEmpty
            testCell.label.text = "All Reminders Paused"
            
            return cell
            
        }
        else if TimingManager.currentlyActiveTimersCount == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            
            let testCell = cell as! HomeMainScreenTableViewCellEmpty
            
            if getDogManager().hasCreatedDog == false{
                testCell.label.text = "No Dogs Or Reminders Created"
            }
            else if getDogManager().hasCreatedRequirement == false {
                testCell.label.text = "No Reminders Created"
            }
            else if getDogManager().hasEnabledDog == false && getDogManager().hasEnabledRequirement == false {
                testCell.label.text = "All Dogs and Reminders Disabled"
            }
            else if getDogManager().hasEnabledDog == false {
                testCell.label.text = "All Dogs Disabled"
            }
            else if getDogManager().hasCreatedRequirement == true{
                testCell.label.text = "All Reminders Disabled"
            }
            else {
                testCell.label.text = "HomeMainScreenTableViewController Decipher Error"
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let priorityPosition = timerPriority(priorityIndex: indexPath.row)
        let parentDogName = priorityPosition.0
        let requirement = priorityPosition.1
        
        willShowSelectedActionSheet(parentDogName: parentDogName, requirement: requirement)
    }
    
}
