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
    
    ///Helps to convert between the two competing tuples, one is for a traditional log from an alarm going off (or being done early) and one is from entering an arbitrary log on the logs page
    class LogDisplay{
    
    
    init(){
        
    }
    
    ///If traditionalTuple from a requirement then use this
    convenience init(traditionalTuple: (RequirementLog, String, Requirement)) {
        self.init()
        self.traditionalLog = traditionalTuple
    }
    
    ///if an arbitraryLog from a manually produced method on Logs, use this
    convenience init(arbitraryTuple: (ArbitraryLog, String)) {
        self.init()
        self.arbitraryLog = arbitraryTuple
    }
    
    var traditionalLog: (RequirementLog, String, Requirement)? = nil
    
    var arbitraryLog: (ArbitraryLog, String)? = nil
    
    ///Whether or not the log is arbitrary
    var isArbitrary: Bool {
        if traditionalLog != nil && arbitraryLog == nil {
            return false
        }
        else if traditionalLog == nil && arbitraryLog != nil {
            return true
        }
        else {
            fatalError()
        }
    }
    
    ///Returns either traditionalLog or the arbitraryLog
    var activeLog: RequirementLog {
        if traditionalLog != nil && arbitraryLog == nil {
            return traditionalLog!.0
        }
        else if traditionalLog == nil && arbitraryLog != nil {
            return arbitraryLog!.0
        }
        else {
            fatalError()
        }
    }
    
    ///Finds which log is active then sources the correct name
    var activeLogName: String {
        if traditionalLog != nil && arbitraryLog == nil {
            return traditionalLog!.2.requirementName
        }
        else if traditionalLog == nil && arbitraryLog != nil {
            return arbitraryLog!.0.logName
        }
        else {
            fatalError()
        }
    }
    
    ///Finds the parentDogName of the active log
    var activeDogName: String {
        if traditionalLog != nil && arbitraryLog == nil {
            return traditionalLog!.1
        }
        else if traditionalLog == nil && arbitraryLog != nil {
            return arbitraryLog!.1
        }
        else {
            fatalError()
        }
    }
    
    ///If a traditionalLog is active, then returns its requirement
    var activeRequirement: Requirement? {
        if traditionalLog != nil && arbitraryLog == nil {
            return traditionalLog!.2
        }
        else if traditionalLog == nil && arbitraryLog != nil {
            return nil
        }
        else {
            fatalError()
        }
    }
}
    
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
        var calculatedConsolidatedLogDates: [LogDisplay] {
            let dogManager = getDogManager()
            var consolidatedLogDates: [LogDisplay] = []
            
            //not filtering
            if filterIndexPath == nil {
                for dogIndex in 0..<dogManager.dogs.count{
                    //adds arbitrarylogs
                    let dog = dogManager.dogs[dogIndex]
                    for arbitraryLog in dog.dogTraits.arbitraryLogDates{
                        consolidatedLogDates.append(LogDisplay(arbitraryTuple: (arbitraryLog, dog.dogTraits.dogName)))
                    }
                   
                    //adds all requirement logDates from dog
                    for requirementIndex in 0..<dogManager.dogs[dogIndex].dogRequirments.requirements.count{
                        let requirement = dogManager.dogs[dogIndex].dogRequirments.requirements[requirementIndex]
                        for requirementLog in requirement.logDates {
                            consolidatedLogDates.append(LogDisplay(traditionalTuple: (requirementLog, dogManager.dogs[dogIndex].dogTraits.dogName, requirement)))
                        }
                    }
                }
            }
            //row in zero that that means filtering by every requirement
            else if filterIndexPath!.row == 0{
                let dog = dogManager.dogs[filterIndexPath!.section]
                
                //adds arbitrarylogs
                for arbitraryLog in dog.dogTraits.arbitraryLogDates{
                    consolidatedLogDates.append(LogDisplay(arbitraryTuple: (arbitraryLog, dog.dogTraits.dogName)))
                }
                
                //adds all requirement logDates from dog
                for requirement in dog.dogRequirments.requirements{
                    for requirementLog in requirement.logDates {
                        consolidatedLogDates.append(LogDisplay(traditionalTuple: (requirementLog, dog.dogTraits.dogName, requirement)))
                    }
                }
            }
            //row is not zero so filtering by a specific requirement or arbitrary
            else{
                let dog = dogManager.dogs[filterIndexPath!.section]
                
                //arbitrary filter not possible
                if filterIsArbitrary == false {
                    let requirement = dog.dogRequirments.requirements[filterIndexPath!.row-1]
                    
                    //adds all logs from requirement
                    for requirementLog in requirement.logDates {
                        consolidatedLogDates.append(LogDisplay(traditionalTuple: (requirementLog, dog.dogTraits.dogName, requirement)))
                    }
                }
                //arbitrary filter possible
                else {
                    //arbitrary row
                    if filterIndexPath!.row == 1 {
                        for arbitraryLog in dog.dogTraits.arbitraryLogDates{
                            consolidatedLogDates.append(LogDisplay(arbitraryTuple: (arbitraryLog, dog.dogTraits.dogName)))
                        }
                    }
                    //specific requirement
                    else {
                        let requirement = dog.dogRequirments.requirements[filterIndexPath!.row-2]
                        
                        //adds all logs from requirement
                        for requirementLog in requirement.logDates {
                            consolidatedLogDates.append(LogDisplay(traditionalTuple: (requirementLog, dog.dogTraits.dogName, requirement)))
                        }
                    }
                }
                
            }
            
            
            //sorts from earlist in time (e.g. 1970) to most recent (e.g. 2021)
            consolidatedLogDates.sort { (var1, var2) -> Bool in
                let log1: RequirementLog = var1.activeLog
                let log2: RequirementLog! = var2.activeLog
                
                //returns true if var1's log1 is earlier in time than var2's log2
                
                //If date1's distance to date2 is positive, i.e. date2 is later in time, returns false as date2 should be ordered first (most recent (to current Date()) dates first)
                if log1.date.distance(to: log2.date) > 0 {
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
        var calculatedUniqueLogDates: [(Int, Int, [LogDisplay])] {
            var uniqueLogDates: [(Int, Int, Int, [LogDisplay])] = []
            
            //goes through all dates present where a log happened
            for consolidatedLogDatesIndex in 0..<consolidatedLogDates.count{
                
                let yearMonthDayComponents = Calendar.current.dateComponents([.year,.month,.day,], from: consolidatedLogDates[consolidatedLogDatesIndex].activeLog.date)
                
                //Checks to make sure the day and year are valid
                
                if yearMonthDayComponents.day == nil || yearMonthDayComponents.month == nil || yearMonthDayComponents.year == nil {
                    fatalError("year, month, or day nil for calculatedUniqueLogDates")
                }
                //Checks to see if the uniqueLogDates contains the day & year pair already, if it doesnt then adds it and the corresponding dateLog for that day, if there is more than one they will be added in further recursion
                else if uniqueLogDates.contains(where: { (arg1) -> Bool in
                    
                    let (day, month, year, _) = arg1
                    if yearMonthDayComponents.day == day && yearMonthDayComponents.month == month && yearMonthDayComponents.year == year {
                        return true
                    }
                    else {
                        return false
                    }
                }) == false {
                    uniqueLogDates.append((yearMonthDayComponents.day!, yearMonthDayComponents.month!, yearMonthDayComponents.year!, [consolidatedLogDates[consolidatedLogDatesIndex]]))
                }
                //if a day and year pair is already present, then just appends to their corresponding array that stores all logs that happened on that given pair of day & year
                else {
                    uniqueLogDates[uniqueLogDates.count-1].3.append(consolidatedLogDates[consolidatedLogDatesIndex])
                }
            }
            
            uniqueLogDates.sort { (arg1, arg2) -> Bool in
                let (day1, month1, year1, _) = arg1
                let (day2, month2, year2, _) = arg2
                
                //if the year is bigger and the day is bigger then that comes first (e.g.  (4, 2020) comes first in the array and (2,2020) comes second, so most recent is first)
                if year1 >= year2 {
                    if month1 > month2 {
                        return true
                    }
                    else if month1 == month2 {
                        if day1 >= day2{
                            return true
                        }
                        else {
                            return false
                        }
                    }
                    else {
                        return false
                    }
                    
                }
                else {
                    return false
                }
            }
            
            var converted: [(Int, Int, [LogDisplay])] = []
            for uniqueLogDate in uniqueLogDates{
                converted.append((uniqueLogDate.0, uniqueLogDate.2, uniqueLogDate.3))
            }
            
            return converted
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
    var consolidatedLogDates: [LogDisplay] = []
    
    ///Stores an array of unique days (of a given year) which a logging event occured. E.g. you logged twice on january 1st 2020& once on january 4th 2020, so the array would be [(1,2020),(4,2020)]
    private var uniqueLogDates: [(Int, Int, [LogDisplay])] = []
    
    ///IndexPath of current filtering scheme
    private var filterIndexPath: IndexPath? = nil
    
    private var filterIsArbitrary: Bool = false
    
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
        
        //filtering by arbitraryLogs
        if filterIndexPath?.row == 1 && getDogManager().dogs[indexPath!.section].dogTraits.arbitraryLogDates.isEmpty == false {
            filterIsArbitrary = true
        }
        //not filtering by arbitraryLogs
        else {
            filterIsArbitrary = false
        }
        
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
        //no logs present
        if uniqueLogDates.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellHeader", for: indexPath)
            
            let customCell = cell as! LogsMainScreenTableViewCellHeader
            customCell.setup(log: nil)
            
            return cell
        }
        //logs present but header
        else if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellHeader", for: indexPath)
            
            let customCell = cell as! LogsMainScreenTableViewCellHeader
            customCell.setup(log: uniqueLogDates[indexPath.section].2[0].activeLog)
            
            return cell
        }
        //log
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellBody", for: indexPath)
            
            let customCell = cell as! LogsMainScreenTableViewCellBody
            let logDisplay = uniqueLogDates[indexPath.section].2[indexPath.row-1]
            
            var logName: String {
                if logDisplay.activeLog is ArbitraryLog{
                    return (logDisplay.activeLog as! ArbitraryLog).logName
                }
                else {
                    return logDisplay.traditionalLog!.2.requirementName
                }
            }
            
            customCell.setup(isArbitrary: logDisplay.isArbitrary, log: logDisplay.activeLog, parentDogName: logDisplay.activeDogName, logName: logName)

            return cell
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //can rows that aren't header (header at .row == 0)
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
                
                let cellToDelete = uniqueLogDates[indexPath.section].2[indexPath.row-1]
                
                //if cell is a traditonal log, uses traditonal method
                if cellToDelete.isArbitrary == false {
                    let requirement = try! newDogManager.findDog(dogName: cellToDelete.activeDogName).dogRequirments.findRequirement(requirementName: cellToDelete.activeRequirement!.requirementName)
                    
                    let firstIndex = requirement.logDates.firstIndex { (arg0) -> Bool in
                        if arg0.date == cellToDelete.activeLog.date{
                            return true
                        }
                        else {
                            return false
                        }
                    }
                    
                    requirement.logDates.remove(at: firstIndex!)
                }
                //if cell isArbitrary uses arbitrary method of finding what to delete
                else {
                    let dog = try! newDogManager.findDog(dogName: cellToDelete.activeDogName)
                    for arbitraryLogIndex in 0..<dog.dogTraits.arbitraryLogDates.count {
                        if dog.dogTraits.arbitraryLogDates[arbitraryLogIndex].uuid == cellToDelete.arbitraryLog!.0.uuid{
                            dog.dogTraits.arbitraryLogDates.remove(at: arbitraryLogIndex)
                            break
                        }
                    }
                }
                
                
                
                
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
        
        //shows alertcontroller with a textfield to edit or delete the comment present for a given log
        
        let selectedLog = uniqueLogDates[indexPath.section].2[indexPath.row-1]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        let formattedDate: String = dateFormatter.string(from: selectedLog.activeLog.date)
        
        let alertController = GeneralAlertController(title: "Edit Note", message: "\(selectedLog.activeDogName) \(selectedLog.activeLogName) \(formattedDate)", preferredStyle: .alert)
        
        alertController.addTextField { (UITextField) in
            UITextField.text = selectedLog.activeLog.note
            UITextField.clearButtonMode = .always
            UITextField.autocapitalizationType = .sentences
            UITextField.placeholder = "Note about \(selectedLog.activeDogName)'s \(selectedLog.activeLogName)"
            UITextField.returnKeyType = .done
        }
        //alertController
        
        let alertActionSubmit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            selectedLog.activeLog.changeNote(newNote: alertController.textFields![0].text ?? "")
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
