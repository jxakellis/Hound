//
//  LogsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsTableViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
    func didSelectLog(parentDogId: Int, log: Log)
    func didRemoveLastFilterLog()
}

class LogsTableViewController: UITableViewController, DogManagerControlFlowProtocol {

    // MARK: - DogManagerControlFlowProtocol

    private var dogManager: DogManager = DogManager()

    func getDogManager() -> DogManager {
        return dogManager
    }

    func setDogManager(sender: Sender, newDogManager: DogManager) {
        dogManager = newDogManager

        if !(sender.localized is LogsTableViewController) {
            self.reloadTable()
        }
        else {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            self.reloadTableDataSource()
        }

    }

    // MARK: - Properties

    /// Stores an array of tuples. Each tuple has a log and the id of the parent dog. Sorted chronologically, first to last.
    var consolidatedLogs: [(Int, Log)] = []

    /// Stores an array of (unique days, unique years, [(parentDogId, logs). Identifies unique day and year combos in which a logging event occured. E.g. you logged twice on january 1st 2020& once on january 4th 2020, so the array would be [(1,2020),(4,2020)] Tuple inside the nested array is (parentDogId, log)
    private var uniqueLogs: [(Int, Int, [(Int, Log)])] = []

    /// IndexPath of current filtering scheme
    private var filterIndexPath: IndexPath?
    private var filterType: LogAction?

    /// used for determining if overview mode was changed and if the table view needs reloaded
    private var storedIsCompactView: Bool = UserConfiguration.isCompactView

    weak var delegate: LogsTableViewControllerDelegate! = nil

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        self.tableView.separatorInset = UIEdgeInsets.zero
        // allow for refreshing of the information from the server
        self.tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshTable), for: .valueChanged)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if storedIsCompactView != UserConfiguration.isCompactView {
            storedIsCompactView = UserConfiguration.isCompactView
            self.reloadTable()
        }

    }
    /// Makes a query to the server to retrieve new information then refreshed the tableView
    @objc private func refreshTable() {
        RequestUtils.getDogManager(invokeErrorManager: true) { dogManager, _ in
            // end refresh first otherwise there will be a weird visual issue
            self.tableView.refreshControl?.endRefreshing()
            if dogManager != nil {
                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager!)
                // manually reload table as the self sernder doesn't do that
                self.reloadTable()
            }
        }
    }

    /// Updates dogManagerDependents then reloads table
    private func reloadTable() {

        reloadTableDataSource()

        tableView.reloadData()
    }
    
    private func reloadTableDataSource() {
        /// Sorts all dates of every time a reminder was logged into a tuple.
        /// This tuple containing the parentDogId and the Log. Dates are then extracted at a later date to sort this whole list chronologically from last (closet to present) to first (the first event that happened, so it is the oldest).
        var calculatedConsolidatedLogs: [(Int, Log)] {
            let dogManager = getDogManager()
            var consolidatedLogs: [(Int, Log)] = []
            
            // not filtering
            if filterIndexPath == nil {
                for dogIndex in 0..<dogManager.dogs.count {
                    // adds dog logs
                    let dog = dogManager.dogs[dogIndex]
                    for dogLog in dog.dogLogs.logs {
                        consolidatedLogs.append((dog.dogId, dogLog))
                    }
                    
                }
            }
            // row in zero that that means filtering by every known log types
            else if filterIndexPath!.row == 0 {
                let dog = dogManager.dogs[filterIndexPath!.section]
                
                // adds dog logs
                for dogLog in dog.dogLogs.logs {
                    consolidatedLogs.append((dog.dogId, dogLog))
                }
                
            }
            // row is not zero so filtering by a specific known log type
            else {
                let dog = dogManager.dogs[filterIndexPath!.section]
                
                // checks to see if filter type still present
                if dog.dogLogs.catagorizedLogActions.contains(where: { (arg1) in
                    let knownType = arg1.0
                    if knownType == filterType {
                        return true
                    }
                    else {
                        return false
                    }
                }) == true {
                    // apennds all known logs to consolidated list, some have reminder and some dont as varies depending on source (i.e. was nested under doglogs or reminder logs)
                    for knownLog in dog.dogLogs.catagorizedLogActions[filterIndexPath!.row-1].1 {
                        consolidatedLogs.append((dog.dogId, knownLog))
                    }
                }
                else {
                    delegate.didRemoveLastFilterLog()
                }
                
            }
            
            // sorts from earlist in time (e.g. 1970) to most recent (e.g. 2021)
            consolidatedLogs.sort { (var1, var2) -> Bool in
                let log1: Log = var1.1
                let log2: Log = var2.1
                
                // returns true if var1's log1 is earlier in time than var2's log2
                
                // If date1's distance to date2 is positive, i.e. date2 is later in time, returns false as date2 should be ordered first (most recent (to current Date()) dates first)
                if log1.logDate.distance(to: log2.logDate) > 0 {
                    return false
                }
                // If date1 is later in time than date2, returns true as it should come before date2
                else {
                    return true
                }
            }
            
            return consolidatedLogs
        }
        
        /// Returns an array tuples which has another array of tuples [month, year, [(parentDogId,Log)].
        var calculatedUniqueLogs: [(Int, Int, [(Int, Log)])] {
            
            // Method finds unique days (of a given year) which a logging event occured
            //  For every log that happened on a given unique day/year combo, its information (parentDogId, Log) is appeneded to the array attached to the unique pair.
            var uniqueLogs: [(Int, Int, Int, [(Int, Log)])] = []
            
            // goes through all dates present where a log happened
            for consolidatedLogsIndex in 0..<consolidatedLogs.count {
                
                let yearMonthDayComponents = Calendar.current.dateComponents([.year, .month, .day ], from: consolidatedLogs[consolidatedLogsIndex].1.logDate)
                
                // Checks to make sure the day and year are valid
                
                if yearMonthDayComponents.day == nil || yearMonthDayComponents.month == nil || yearMonthDayComponents.year == nil {
                    fatalError("year, month, or day nil for calculatedUniqueLogs")
                }
                // Checks to see if the uniqueLogs contains the day & year pair already, if it doesnt then adds it and the corresponding dateLog for that day, if there is more than one they will be added in further recursion
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
                // if a day and year pair is already present, then just appends to their corresponding array that stores all logs that happened on that given pair of day & year
                else {
                    uniqueLogs[uniqueLogs.count-1].3.append(consolidatedLogs[consolidatedLogsIndex])
                }
            }
            
            uniqueLogs.sort { (arg1, arg2) -> Bool in
                let (day1, month1, year1, _) = arg1
                let (day2, month2, year2, _) = arg2
                
                // if the year is bigger and the day is bigger then that comes first (e.g.  (4, 2020) comes first in the array and (2,2020) comes second, so most recent is first)
                if year1 >= year2 {
                    // if month is bigger then it comes first (a bigger month will always be closer to the future)
                    if month1 > month2 {
                        return true
                    }
                    else if month1 == month2 {
                        // if day is bigger then it comes first (a bigger day will always be closer to the future than a smaller one)
                        if day1 >= day2 {
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
            
            // converts from day, month, year, [logs] into day, year, [logs] so it can be returned. month not needed
            var converted: [(Int, Int, [(Int, Log)])] = []
            for uniqueLogDate in uniqueLogs {
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

    /// Will apply a filtering scheme dependent on indexPath, nil means going to no filtering.
    func willApplyFiltering(associatedToIndexPath indexPath: IndexPath?, filterType: LogAction?) {

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

        // no logs present
        if uniqueLogs.count == 0 {
            if UserConfiguration.isCompactView == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsCompactHeaderTableViewCell", for: indexPath)

                let customCell = cell as! LogsCompactHeaderTableViewCell
                customCell.setup(log: nil, showFilterIndicator: shouldShowFilterIndicator)

                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsLargeHeaderTableViewCell", for: indexPath)

                let customCell = cell as! LogsLargeHeaderTableViewCell
                customCell.setup(log: nil, showFilterIndicator: shouldShowFilterIndicator)

                return cell
            }

        }
        // logs are present and need a header (row being zero indicates that the cell is a header)
        else if indexPath.row == 0 {

            // indexPath.section dictates how far into the first array, everything is already sorted so thats all we need to know. Then  we take the .2 entry as that is the nested array of the tuple of logs and parentDogIds
            let targetUniqueLogsNestedArray: [(Int, Log)]! = uniqueLogs[indexPath.section].2

            // For the given parent array, we will take the first log in the nested array. The header will extract the date information from that log. It doesn't matter which log we take as all logs will have the same day, month, and year since they were already sorted to be in that array.

            if UserConfiguration.isCompactView == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsCompactHeaderTableViewCell", for: indexPath)

                let customCell = cell as! LogsCompactHeaderTableViewCell
                customCell.setup(log: targetUniqueLogsNestedArray[0].1, showFilterIndicator: shouldShowFilterIndicator)

                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsLargeHeaderTableViewCell", for: indexPath)

                let customCell = cell as! LogsLargeHeaderTableViewCell
                customCell.setup(log: targetUniqueLogsNestedArray[0].1, showFilterIndicator: shouldShowFilterIndicator)

                return cell
            }
        }
        // log
        else {

            // indexPath.section dictates how far into the first array, everything is already sorted so thats all we need to know. Then  we take the .2 entry as that is the nested array of the tuple of logs and parentDogIds
            let targetUniqueLogsNestedArray: [(Int, Log)]! = uniqueLogs[indexPath.section].2

            // indexPath.row -1 corrects for the first row in the section being the header
            let logToDisplay = targetUniqueLogsNestedArray[indexPath.row-1]
            let dog = try! getDogManager().findDog(forDogId: logToDisplay.0)
            let dogIcon = dog.dogIcon

            if UserConfiguration.isCompactView == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsCompactBodyTableViewCell", for: indexPath)

                let customCell = cell as! LogsCompactBodyTableViewCell

                customCell.setup(parentDogId: logToDisplay.0, log: logToDisplay.1)

                return cell
            }
            // has dogIcon
            else if !(dogIcon.isEqualToImage(image: DogConstant.defaultDogIcon)) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsLargeBodyWithDogIconTableViewCell", for: indexPath)

                let customCell = cell as! LogsLargeBodyWithDogIconTableViewCell

                customCell.setup(parentDogId: logToDisplay.0, log: logToDisplay.1)

                return cell
            }
            // no dogIcon
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsLargeBodyWithoutDogIconTableViewCell", for: indexPath)

                let customCell = cell as! LogsLargeBodyWithoutDogIconTableViewCell

                customCell.setup(parentDogId: logToDisplay.0, log: logToDisplay.1)

                return cell
            }

        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // can rows that aren't header (header at .row == 0)
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

            // identify components needed to remove data
            let newDogManager = getDogManager()
            let originalNumberOfSections = uniqueLogs.count

            let targetUniqueLogsNestedArray = uniqueLogs[indexPath.section].2
            let dogIdOfLog = targetUniqueLogsNestedArray[indexPath.row-1].0
            let logIdOfLog = targetUniqueLogsNestedArray[indexPath.row-1].1.logId

            LogsRequest.delete(invokeErrorManager: true, forDogId: dogIdOfLog, forLogId: logIdOfLog) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    // batch update so doesn't freak out
                    tableView.performBatchUpdates {
                        // Remove the row from the data source
                        
                        let dog = try! newDogManager.findDog(forDogId: dogIdOfLog)
                        // find log in dog and remove
                        for dogLogIndex in 0..<dog.dogLogs.logs.count where dog.dogLogs.logs[dogLogIndex].logId == logIdOfLog {
                            dog.dogLogs.removeLog(forIndex: dogLogIndex)
                            break
                        }
                        
                        self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: newDogManager)
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                        var shouldShowFilterIndicator: Bool {
                            if indexPath.section == 0 && self.filterIndexPath != nil {
                                return true
                            }
                            else {
                                return false
                            }
                        }
                        
                        // removed final log and must update header (no logs are left at all)
                        if self.uniqueLogs.count == 0 {
                            
                            if UserConfiguration.isCompactView == true {
                                let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogsCompactHeaderTableViewCell
                                headerCell.setup(log: nil, showFilterIndicator: shouldShowFilterIndicator)
                            }
                            else {
                                let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogsLargeHeaderTableViewCell
                                headerCell.setup(log: nil, showFilterIndicator: shouldShowFilterIndicator)
                            }
                            
                        }
                        // removed final log of a given section and must remove all headers and body in that now gone-from-the-data section
                        else if originalNumberOfSections != self.uniqueLogs.count {
                            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                            
                            // removed section that has filter indicator
                            if indexPath.section == 0 && self.uniqueLogs.count >= 1 {
                                // for whatever header will be at the top (section 1 currently but will soon be section 0) the filter indicator will be shown if calculated shouldShowFilterIndicator returnd true (! converts to proper isHidden:)
                                if UserConfiguration.isCompactView == true {
                                    let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! LogsCompactHeaderTableViewCell
                                    headerCell.willShowFilterIndicator(isHidden: !shouldShowFilterIndicator)
                                }
                                else {
                                    let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! LogsLargeHeaderTableViewCell
                                    headerCell.willShowFilterIndicator(isHidden: !shouldShowFilterIndicator)
                                }
                            }
                            
                        }
                    } completion: { (_) in
                    }
                }
            }

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > (uniqueLogs.count - 1) || (indexPath.row - 1) > (uniqueLogs[indexPath.section].2.count - 1) || (indexPath.row - 1) < 0 {
            ErrorManager.alert(forMessage: "You selected a row that was unable to be decifered. Please restart Hound to fix.")
        }
        else {
            let targetUniqueLogsNestedArray = uniqueLogs[indexPath.section].2
            let dogId = targetUniqueLogsNestedArray[indexPath.row-1].0
            let logId = targetUniqueLogsNestedArray[indexPath.row-1].1.logId
            RequestUtils.beginAlertControllerQueryIndictator()
            LogsRequest.get(invokeErrorManager: true, forDogId: dogId, forLogId: logId) { log, _ in
                RequestUtils.endAlertControllerQueryIndictator {
                    if log != nil {
                        self.delegate.didSelectLog(parentDogId: dogId, log: log!)
                    }
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            }

        }
    }

}
