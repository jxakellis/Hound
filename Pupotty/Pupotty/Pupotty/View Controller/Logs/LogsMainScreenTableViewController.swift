//
//  LogsMainScreenTableViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsMainScreenTableViewControllerDelegate{
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class LogsMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol {
    
    //MARK: - DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        //DogManagerEfficencyImprovement return dogManager.copy() as! DogManager
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        //DogManagerEfficencyImprovement dogManager = newDogManager.copy() as! DogManager
        dogManager = newDogManager
        
        if !(sender.localized is LogsMainScreenTableViewController) {
            self.reloadTable()
        }
        else {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            updateDogManagerDependents()
        }
        
    }
    
    func updateDogManagerDependents() {
        
        ///Sorts all dates of every time a requirement was logged into a tuple, containing the actual date, the parent dog name, and the requirement, theb sorts is chronologically from last (closet to present) to first (the first event that happened, so it is the oldest).
        var calculatedConsolidatedLogDates: [(RequirementLog, String, Requirement)] {
            let dogManager = getDogManager()
            var consolidatedLogDates: [(RequirementLog, String, Requirement)] = []
            
            //not filtering
            if filterIndexPath == nil {
                for dogIndex in 0..<dogManager.dogs.count{
                    for requirementIndex in 0..<dogManager.dogs[dogIndex].dogRequirments.requirements.count{
                        let requirement = dogManager.dogs[dogIndex].dogRequirments.requirements[requirementIndex]
                        for requirementLog in requirement.logDates {
                            consolidatedLogDates.append((requirementLog, dogManager.dogs[dogIndex].dogTraits.dogName, requirement))
                        }
                    }
                }
            }
            //row in zero that that means filtering by every requirement
            else if filterIndexPath!.row == 0{
                let dog = dogManager.dogs[filterIndexPath!.section]
                
                for requirement in dog.dogRequirments.requirements{
                    for requirementLog in requirement.logDates {
                        consolidatedLogDates.append((requirementLog, dog.dogTraits.dogName, requirement))
                    }
                }
            }
            //row is not zero so filtering by a specific requirement
            else{
                let dog = dogManager.dogs[filterIndexPath!.section]
                let requirement = dog.dogRequirments.requirements[filterIndexPath!.row-1]
                
                for requirementLog in requirement.logDates {
                    consolidatedLogDates.append((requirementLog, dog.dogTraits.dogName, requirement))
                }
            }
            
            
            
            consolidatedLogDates.sort { (var1, var2) -> Bool in
                let (requirementLog1, _, _) = var1
                let (requirementLog2, _, _) = var2
                
                //If date1's distance to date2 is positive, i.e. date2 is later in time, returns false as date2 should be ordered first (most recent (to current Date()) dates first)
                if requirementLog1.date.distance(to: requirementLog2.date) > 0 {
                    return false
                }
                //If date1 is later in time than date2, returns true as it should come before date2
                else {
                    return true
                }
            }
            
            return consolidatedLogDates
        }
        
        ///Makes an array of unique days (of a given year) which a logging event occured, for every log that happened on a given unique day/year combo, its information (Date, parentDogName, Requirement) is appeneded to the array attached to the unique pair.
        var calculatedUniqueLogDates: [(Int, Int, [(RequirementLog, String, Requirement)])] {
            var uniqueLogDates: [(Int, Int, [(RequirementLog, String, Requirement)])] = []
            
            //goes through all dates present where a log happened
            for consolidatedLogDatesIndex in 0..<consolidatedLogDates.count{
                let yearAndDayComponents = Calendar.current.dateComponents([.year,.day], from: consolidatedLogDates[consolidatedLogDatesIndex].0.date)
                
                //Checks to make sure the day and year are valid
                if yearAndDayComponents.day == nil && yearAndDayComponents.year == nil {
                    print("year and/or day nil")
                }
                //Checks to see if the uniqueLogDates contains the day & year pair already, if it doesnt then adds it and the corresponding dateLog for that day, if there is more than one they will be added in further recursion
                else if uniqueLogDates.contains(where: { (arg1) -> Bool in
                    
                    let (day, year, _) = arg1
                    if yearAndDayComponents.day == day && yearAndDayComponents.year == year {
                        return true
                    }
                    else {
                        return false
                    }
                }) == false {
                    uniqueLogDates.append((yearAndDayComponents.day!, yearAndDayComponents.year!, [consolidatedLogDates[consolidatedLogDatesIndex]]))
                }
                //if a day and year pair is already present, then just appends to their corresponding array that stores all logs that happened on that given pair of day & year
                else {
                    uniqueLogDates[uniqueLogDates.count-1].2.append(consolidatedLogDates[consolidatedLogDatesIndex])
                }
            }
            
            uniqueLogDates.sort { (arg1, arg2) -> Bool in
                let (day1, year1, _) = arg1
                let (day2, year2, _) = arg2
                
                //if the year is bigger and the day is bigger then that comes first (e.g.  (4, 2020) comes first in the array and (2,2020) comes second, so most recent is first)
                if year1 >= year2 && day1 > day2{
                    return true
                }
                else {
                    return false
                }
            }
            
            return uniqueLogDates
        }
        
        self.consolidatedLogDates = calculatedConsolidatedLogDates
        self.uniqueLogDates = calculatedUniqueLogDates
        
        
        
        
        if uniqueLogDates.count == 0 {
            tableView.separatorStyle = .none
        }
        else {
            tableView.separatorStyle = .singleLine
        }
    }
    
    //MARK: - Properties
    
    ///Stores all dates of every time a requirement was logged into a tuple, containing the actual date, the parent dog name, and the requirement,  sorted chronologically, first to last.
    private var consolidatedLogDates: [(RequirementLog, String, Requirement)] = []
    
    ///Stores an array of unique days (of a given year) which a logging event occured. E.g. you logged twice on january 1st 2020& once on january 4th 2020, so the array would be [(1,2020),(4,2020)]
    private var uniqueLogDates: [(Int, Int, [(RequirementLog, String, Requirement)])] = []
    
    ///IndexPath of current filtering scheme
    private var filterIndexPath: IndexPath? = nil
    
    var delegate: LogsMainScreenTableViewControllerDelegate! = nil
    
    //MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        self.tableView.separatorInset = UIEdgeInsets.zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    ///Updates dogManagerDependents then reloads table
    private func reloadTable(){
        
        updateDogManagerDependents()
        
        tableView.reloadData()
    }
    
    ///Will apply a filtering scheme dependent on indexPath, nil means going to no filtering.
    func willApplyFiltering(associatedToIndexPath indexPath: IndexPath?){
        
        filterIndexPath = indexPath
        
        reloadTable()
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if uniqueLogDates.count == 0 {
            return 1
        }
        else {
            return uniqueLogDates.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if uniqueLogDates.count == 0 {
            return 1
            
        }
        else {
            return uniqueLogDates[section].2.count + 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if uniqueLogDates.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellHeader", for: indexPath)
            
            let customCell = cell as! LogsMainScreenTableViewCellHeader
            customCell.setup(log: nil)
            
            return cell
        }
        else if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellHeader", for: indexPath)
            
            let customCell = cell as! LogsMainScreenTableViewCellHeader
            customCell.setup(log: uniqueLogDates[indexPath.section].2[0].0)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellBody", for: indexPath)
            
            let customCell = cell as! LogsMainScreenTableViewCellBody
            let infoTuple = uniqueLogDates[indexPath.section].2[indexPath.row-1]
            customCell.setup(log: infoTuple.0, parentDogName: infoTuple.1, requirement: infoTuple.2)

            return cell
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row != 0 {
            return true
        }
        else {
            return false
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates {
                // Delete the row from the data source
                let newDogManager = getDogManager()
                
                let originalNumberOfSections = uniqueLogDates.count
                
                let cellInfo = uniqueLogDates[indexPath.section].2[indexPath.row-1]
                let requirement = try! newDogManager.findDog(dogName: cellInfo.1).dogRequirments.findRequirement(requirementName: cellInfo.2.requirementName)
                
                let firstIndex = requirement.logDates.firstIndex { (arg0) -> Bool in
                    if arg0.date == cellInfo.0.date{
                        return true
                    }
                    else {
                        return false
                    }
                }
                
                requirement.logDates.remove(at: firstIndex!)
                
                setDogManager(sender: Sender(origin: self, localized: self), newDogManager: newDogManager)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                //removed final log and must update header (no logs are left at all)
                if uniqueLogDates.count == 0 {
                    let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogsMainScreenTableViewCellHeader
                    headerCell.setup(log: nil)
                }
                //removed final log of a given section and must delete all headers and body in that now gone-from-the-data section
                else if originalNumberOfSections != uniqueLogDates.count{
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                }
            } completion: { (completed) in
            }

            
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedLog = uniqueLogDates[indexPath.section].2[indexPath.row-1]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        let formattedDate: String = dateFormatter.string(from: selectedLog.0.date)
        
        let alertController = GeneralAlertController(title: "Edit Note", message: "\(selectedLog.1) \(selectedLog.2.requirementName) \(formattedDate)", preferredStyle: .alert)
        
        alertController.addTextField { (UITextField) in
            UITextField.text = selectedLog.0.note
            UITextField.clearButtonMode = .always
            UITextField.autocapitalizationType = .sentences
            UITextField.placeholder = "Note about \(selectedLog.1)'s \(selectedLog.2.requirementName)"
            UITextField.returnKeyType = .done
        }
        //alertController
        
        let alertActionSubmit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            selectedLog.0.changeNote(newNote: alertController.textFields![0].text ?? "")
            self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: self.getDogManager())
            self.reloadTable()
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(alertActionSubmit)
        alertController.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
