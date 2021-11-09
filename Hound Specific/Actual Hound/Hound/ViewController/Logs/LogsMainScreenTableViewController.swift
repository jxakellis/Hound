//
//  LogsMainScreenTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsMainScreenTableViewControllerDelegate{
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
    func didSelectLog(parentDogName: String, reminder: Reminder?, log: KnownLog)
    func didRemoveLastFilterLog()
}

class LogsMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol {
    
    //MARK: - DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
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
        
        ///Sorts all dates of every time a reminder was logged into a tuple, containing the actual date, the parent dog name, and the reminder, theb sorts is chronologically from last (closet to present) to first (the first event that happened, so it is the oldest).
        var calculatedConsolidatedLogs: [(String, Reminder?, KnownLog)] {
            let dogManager = getDogManager()
            var consolidatedLogs: [(String, Reminder?, KnownLog)] = []
            
            //not filtering
            if filterIndexPath == nil {
                for dogIndex in 0..<dogManager.dogs.count{
                    //adds dog logs
                    let dog = dogManager.dogs[dogIndex]
                    for dogLog in dog.dogTraits.logs{
                        consolidatedLogs.append((dog.dogTraits.dogName, nil, dogLog))
                    }
                    
                    /*
                     //REQ UPDATE
                     //adds all reminder logs from dog
                     for reminderIndex in 0..<dogManager.dogs[dogIndex].dogReminders.reminders.count{
                         let reminder = dogManager.dogs[dogIndex].dogReminders.reminders[reminderIndex]
                         
                         for reminderLog in reminder.logs {
                             consolidatedLogs.append((dog.dogTraits.dogName, reminder, reminderLog))
                         }
                     }
                     */
                    
                }
            }
            //row in zero that that means filtering by every known log types
            else if filterIndexPath!.row == 0{
                let dog = dogManager.dogs[filterIndexPath!.section]
                
                //adds dog logs
                for dogLog in dog.dogTraits.logs{
                    consolidatedLogs.append((dog.dogTraits.dogName, nil, dogLog))
                }
                
                /*
                 //REQ UPDATE
                 //adds all reminder logs from dog
                 for reminder in dog.dogReminders.reminders{
                     for reminderLog in reminder.logs {
                         consolidatedLogs.append((dog.dogTraits.dogName, reminder, reminderLog))
                     }
                 }
                 */
                
            }
            //row is not zero so filtering by a specific known log type
            else{
                let dog = dogManager.dogs[filterIndexPath!.section]
                
                //checks to see if filter type still present
                if dog.catagorizedLogTypes.contains(where: { (arg1) in
                    let knownType = arg1.0
                    if knownType == filterType{
                        return true
                    }
                    else {
                        return false
                    }
                }) == true {//apennds all known logs to consolidated list, some have reminder and some dont as varies depending on source (i.e. was nested under doglogs or reminder logs)
                    for knownLog in dog.catagorizedLogTypes[filterIndexPath!.row-1].1{
                        consolidatedLogs.append((dog.dogTraits.dogName, knownLog.0, knownLog.1))
                    }
                }
                else {
                    delegate.didRemoveLastFilterLog()
                }
                
                
            }
            
            
            //sorts from earlist in time (e.g. 1970) to most recent (e.g. 2021)
            consolidatedLogs.sort { (var1, var2) -> Bool in
                let log1: KnownLog = var1.2
                let log2: KnownLog = var2.2
                
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
            
            return consolidatedLogs
        }
        
        ///Makes an array of unique days (of a given year) which a logging event occured, for every log that happened on a given unique day/year combo, its information (Date, parentDogName, Reminder) is appeneded to the array attached to the unique pair.
        var calculatedUniqueLogs: [(Int, Int, [(String, Reminder?, KnownLog)])] {
            var uniqueLogs: [(Int, Int, Int, [(String, Reminder?, KnownLog)])] = []
            
            //goes through all dates present where a log happened
            for consolidatedLogsIndex in 0..<consolidatedLogs.count{
                
                let yearMonthDayComponents = Calendar.current.dateComponents([.year,.month,.day,], from: consolidatedLogs[consolidatedLogsIndex].2.date)
                
                //Checks to make sure the day and year are valid
                
                if yearMonthDayComponents.day == nil || yearMonthDayComponents.month == nil || yearMonthDayComponents.year == nil {
                    fatalError("year, month, or day nil for calculatedUniqueLogs")
                }
                //Checks to see if the uniqueLogs contains the day & year pair already, if it doesnt then adds it and the corresponding dateLog for that day, if there is more than one they will be added in further recursion
                else if uniqueLogs.contains(where: { (arg1) -> Bool in
                    
                    let (day, month, year, _) = arg1
                    if yearMonthDayComponents.day == day && yearMonthDayComponents.month == month && yearMonthDayComponents.year == year {
                        return true
                    }
                    else {
                        return false
                    }
                }) == false {
                    uniqueLogs.append((yearMonthDayComponents.day!, yearMonthDayComponents.month!, yearMonthDayComponents.year!, [consolidatedLogs[consolidatedLogsIndex]]))
                }
                //if a day and year pair is already present, then just appends to their corresponding array that stores all logs that happened on that given pair of day & year
                else {
                    uniqueLogs[uniqueLogs.count-1].3.append(consolidatedLogs[consolidatedLogsIndex])
                }
            }
            
            uniqueLogs.sort { (arg1, arg2) -> Bool in
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
            
            var converted: [(Int, Int, [(String, Reminder?, KnownLog)])] = []
            for uniqueLogDate in uniqueLogs{
                converted.append((uniqueLogDate.0, uniqueLogDate.2, uniqueLogDate.3))
            }
            
            return converted
        }
        
        self.consolidatedLogs = calculatedConsolidatedLogs
        self.uniqueLogs = calculatedUniqueLogs
        
        if uniqueLogs.count == 0 {
            tableView.separatorStyle = .none
        }
        else {
            tableView.separatorStyle = .singleLine
        }
    }
    
    //MARK: - Properties
    
    ///Stores all dates of every time a reminder was logged into a tuple, containing the actual date, the parent dog name, and the reminder,  sorted chronologically, first to last.
    var consolidatedLogs: [(String, Reminder?, KnownLog)] = []
    
    ///Stores an array of unique days (of a given year) which a logging event occured. E.g. you logged twice on january 1st 2020& once on january 4th 2020, so the array would be [(1,2020),(4,2020)]
    private var uniqueLogs: [(Int, Int, [(String, Reminder?, KnownLog)])] = []
    
    ///IndexPath of current filtering scheme
    private var filterIndexPath: IndexPath? = nil
    private var filterType: KnownLogType? = nil
    
    ///used for determining if overview mode was changed and if the table view needs reloaded
    private var storedIsCompactView: Bool = AppearanceConstant.isCompactView
    
    var delegate: LogsMainScreenTableViewControllerDelegate! = nil
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        if UIApplication.previousAppBuild <= 1228 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.reloadTable()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.reloadTable()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if storedIsCompactView != AppearanceConstant.isCompactView{
            storedIsCompactView = AppearanceConstant.isCompactView
            self.reloadTable()
        }
        
    }
    
    ///Updates dogManagerDependents then reloads table
    private func reloadTable(){
        
        updateDogManagerDependents()
        
        tableView.reloadData()
    }
    
    ///Will apply a filtering scheme dependent on indexPath, nil means going to no filtering.
    func willApplyFiltering(associatedToIndexPath indexPath: IndexPath?, filterType: KnownLogType?){
        
        filterIndexPath = indexPath
        self.filterType = filterType
        
        reloadTable()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if uniqueLogs.count == 0 {
            return 1
        }
        else {
            return uniqueLogs.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if uniqueLogs.count == 0 {
            return 1
            
        }
        else {
            return uniqueLogs[section].2.count + 1
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var shouldShowFilterIndicator: Bool {
            if indexPath.section == 0 && self.filterIndexPath != nil {
                return true
            }
            else {
                return false
            }
        }
        //no logs present
        if uniqueLogs.count == 0 {
            if AppearanceConstant.isCompactView == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellHeaderCompact", for: indexPath)
                
                let customCell = cell as! LogsMainScreenTableViewCellHeaderCompact
                customCell.setup(log: nil, showFilterIndicator: shouldShowFilterIndicator)
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellHeaderRegular", for: indexPath)
                
                let customCell = cell as! LogsMainScreenTableViewCellHeaderRegular
                customCell.setup(log: nil, showFilterIndicator: shouldShowFilterIndicator)
                
                return cell
            }
            
        }
        //logs present but header
        else if indexPath.row == 0{
            if AppearanceConstant.isCompactView == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellHeaderCompact", for: indexPath)
                
                let customCell = cell as! LogsMainScreenTableViewCellHeaderCompact
                customCell.setup(log: uniqueLogs[indexPath.section].2[0].2, showFilterIndicator: shouldShowFilterIndicator)
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellHeaderRegular", for: indexPath)
                
                let customCell = cell as! LogsMainScreenTableViewCellHeaderRegular
                customCell.setup(log: uniqueLogs[indexPath.section].2[0].2, showFilterIndicator: shouldShowFilterIndicator)
                
                return cell
            }
        }
        //log
        else {
            let logDisplay = uniqueLogs[indexPath.section].2[indexPath.row-1]
            let dog = try! getDogManager().findDog(forName: logDisplay.0)
            let icon = dog.dogTraits.icon
            
            if AppearanceConstant.isCompactView == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellBodyCompact", for: indexPath)
                
                let customCell = cell as! LogsMainScreenTableViewCellBodyCompact
                
                
                customCell.setup(parentDogName: logDisplay.0, reminder: logDisplay.1, log: logDisplay.2)
                
                return cell
            }
            //has icon
            else if !(icon.isEqualToImage(image: DogConstant.defaultIcon)){
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellBodyRegularWithIcon", for: indexPath)
                
                let customCell = cell as! LogsMainScreenTableViewCellBodyRegularWithIcon
                
                customCell.setup(parentDogName: logDisplay.0, reminder: logDisplay.1, log: logDisplay.2)
                
                return cell
            }
            //no icon
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellBodyRegularWithoutIcon", for: indexPath)
                
                let customCell = cell as! LogsMainScreenTableViewCellBodyRegularWithoutIcon
                
                
                customCell.setup(parentDogName: logDisplay.0, reminder: logDisplay.1, log: logDisplay.2)
                
                return cell
            }
            
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
                // Remove the row from the data source
                let newDogManager = getDogManager()
                
                let originalNumberOfSections = uniqueLogs.count
                
                let cellToRemove = uniqueLogs[indexPath.section].2[indexPath.row-1]
                
                let dog = try! newDogManager.findDog(forName: cellToRemove.0)
                for dogLogIndex in 0..<dog.dogTraits.logs.count {
                    if dog.dogTraits.logs[dogLogIndex].uuid == cellToRemove.2.uuid{
                        dog.dogTraits.removeLog(forIndex: dogLogIndex)
                        break
                    }
                }
                
                
                setDogManager(sender: Sender(origin: self, localized: self), newDogManager: newDogManager)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                var shouldShowFilterIndicator: Bool {
                    if indexPath.section == 0 && self.filterIndexPath != nil {
                        return true
                    }
                    else {
                        return false
                    }
                }
                
                //removed final log and must update header (no logs are left at all)
                if uniqueLogs.count == 0 {
                    
                    if AppearanceConstant.isCompactView == true {
                        let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogsMainScreenTableViewCellHeaderCompact
                        headerCell.setup(log: nil, showFilterIndicator: shouldShowFilterIndicator)
                    }
                    else {
                        let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogsMainScreenTableViewCellHeaderRegular
                        headerCell.setup(log: nil, showFilterIndicator: shouldShowFilterIndicator)
                    }
                    
                }
                //removed final log of a given section and must remove all headers and body in that now gone-from-the-data section
                else if originalNumberOfSections != uniqueLogs.count{
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    
                    //removed section that has filter indicator
                    if indexPath.section == 0 && uniqueLogs.count >= 1{
                        //for whatever header will be at the top (section 1 currently but will soon be section 0) the filter indicator will be shown if calculated shouldShowFilterIndicator returnd true (! converts to proper isHidden:)
                        if AppearanceConstant.isCompactView == true {
                            let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! LogsMainScreenTableViewCellHeaderCompact
                            headerCell.willShowFilterIndicator(isHidden: !shouldShowFilterIndicator)
                        }
                        else {
                            let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! LogsMainScreenTableViewCellHeaderRegular
                            headerCell.willShowFilterIndicator(isHidden: !shouldShowFilterIndicator)
                        }
                    }
                    
                }
            } completion: { (completed) in
            }
            
            
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedLogDisplay = uniqueLogs[indexPath.section].2[indexPath.row-1]
        
        delegate.didSelectLog(parentDogName: selectedLogDisplay.0, reminder: selectedLogDisplay.1, log: selectedLogDisplay.2)
        
    }
    
    
}
