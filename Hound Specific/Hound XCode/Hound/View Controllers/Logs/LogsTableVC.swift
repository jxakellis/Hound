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

    /// Array of tuples [(uniqueDay, uniqueMonth, uniqueYear, [(parentDogId, log)])]. This array has all of the logs for all of the dogs grouped what unique day/month/year they occured on, first element is furthest in the future and last element is the oldest. Optionally filters by the dogId and logAction provides
    private var chronologicalLogsGroupedByDate: [(Int, Int, Int, [(Int, Log)])] = []

    /// the dogId of the current dog that the logs are being filted by
    private var filterDogId: Int?
    /// the current log action that the logs are being filtered by
    private var filterLogAction: LogAction?

    /// used for determining if logs interface scale was changed and if the table view needs reloaded
    private var storedLogsInterfaceScale: LogsInterfaceScale = UserConfiguration.logsInterfaceScale

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
        
        if storedLogsInterfaceScale != UserConfiguration.logsInterfaceScale {
            storedLogsInterfaceScale = UserConfiguration.logsInterfaceScale
            self.reloadTable()
        }

    }
    /// Makes a query to the server to retrieve new information then refreshed the tableView
    @objc private func refreshTable() {
        DogsRequest.get(invokeErrorManager: true, dogManager: getDogManager()) { newDogManager, _ in
            // end refresh first otherwise there will be a weird visual issue
            self.tableView.refreshControl?.endRefreshing()
            if newDogManager != nil {
                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: newDogManager!)
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
        
        self.chronologicalLogsGroupedByDate = dogManager.chronologicalLogsGroupedByDate(forDogId: filterDogId, forLogAction: filterLogAction)
        
        if filterDogId != nil && filterLogAction != nil, let dog = try? dogManager.findDog(forDogId: filterDogId!) {
            // checks to see if filter log action still present within the dog, if its not then the user took an action to remove the last log of a certain log action from the dog
            if dog.dogLogs.catagorizedLogActions.contains(where: { (arg1) in
                let knownLogAction = arg1.0
                if knownLogAction == filterLogAction! {
                    return true
                }
                else {
                    return false
                }
            }) == false {
                // user remove the last log for that particular filter type, so we should clear the current active filter 
                delegate.didRemoveLastFilterLog()
            }
        }
        
        if chronologicalLogsGroupedByDate.count == 0 {
            tableView.separatorStyle = .none
        }
        else {
            tableView.separatorStyle = .singleLine
        }
    }

    /// Will apply a filtering scheme dependent on indexPath, nil means going to no filtering.
    func willApplyFiltering(forFilterDogId filterDogId: Int?, forFilterLogAction filterLogAction: LogAction?) {

        self.filterDogId = filterDogId
        self.filterLogAction = filterLogAction

        reloadTable()
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if chronologicalLogsGroupedByDate.count == 0 {
            return 1
        }
        else {
            return chronologicalLogsGroupedByDate.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if chronologicalLogsGroupedByDate.count == 0 {
            return 1

        }
        else {
            // find the number of logs for a given unique day/month/year, then add 1 for the header that says the day/month/year
            return chronologicalLogsGroupedByDate[section].3.count + 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var shouldShowFilterIndicator: Bool {
            if indexPath.section == 0 && (filterDogId != nil || filterLogAction != nil) {
                return true
            }
            else {
                return false
            }
        }

        // no logs present
        if chronologicalLogsGroupedByDate.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logsHeaderTableViewCell", for: indexPath)
            
            let customCell = cell as! LogsHeaderTableViewCell
            customCell.setup(fromDate: nil, shouldShowFilterIndictator: shouldShowFilterIndicator)
            
            return cell
        }
        // logs are present and need a header (row being zero indicates that the cell is a header)
        else if indexPath.row == 0 {

            let nestedLogsArray: [(Int, Log)] = chronologicalLogsGroupedByDate[indexPath.section].3

            // For the given parent array, we will take the first log in the nested array. The header will extract the date information from that log. It doesn't matter which log we take as all logs will have the same day, month, and year since they were already sorted to be in that array.

            let cell = tableView.dequeueReusableCell(withIdentifier: "logsHeaderTableViewCell", for: indexPath)
            
            let customCell = cell as! LogsHeaderTableViewCell
            customCell.setup(fromDate: nestedLogsArray[0].1.logDate, shouldShowFilterIndictator: shouldShowFilterIndicator)
            
            return cell
        }
        // log
        else {

            let nestedLogsArray: [(Int, Log)] =  chronologicalLogsGroupedByDate[indexPath.section].3

            // indexPath.row -1 corrects for the first row in the section being the header
            let targetTuple = nestedLogsArray[indexPath.row-1]
            let dog = try! getDogManager().findDog(forDogId: targetTuple.0)
            let log = targetTuple.1
            
            // has dogIcon
            if dog.dogIcon.isEqualToImage(image: DogConstant.defaultDogIcon) == false {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsBodyWithIconTableViewCell", for: indexPath)

                let customCell = cell as! LogsBodyWithIconTableViewCell
                customCell.setup(forParentDogIcon: dog.dogIcon, forLog: log)

                return cell
            }
            // no dogIcon
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "logsBodyWithoutIconTableViewCell", for: indexPath)

                let customCell = cell as! LogsBodyWithoutIconTableViewCell
                customCell.setup(forParentDogName: dog.dogName, forLog: log)

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
            let sudoDogManager = getDogManager()
            let originalNumberOfSections = chronologicalLogsGroupedByDate.count

            let nestedLogsArray = chronologicalLogsGroupedByDate[indexPath.section].3
            let parentDogId = nestedLogsArray[indexPath.row-1].0
            let logId = nestedLogsArray[indexPath.row-1].1.logId

            LogsRequest.delete(invokeErrorManager: true, forDogId: parentDogId, forLogId: logId) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    // batch update so doesn't freak out
                    tableView.performBatchUpdates {
                        // Remove the row from the data source
                        
                        let dog = try! sudoDogManager.findDog(forDogId: parentDogId)
                        // find log in dog and remove
                        for dogLogIndex in 0..<dog.dogLogs.logs.count where dog.dogLogs.logs[dogLogIndex].logId == logId {
                            dog.dogLogs.removeLog(forIndex: dogLogIndex)
                            break
                        }
                        
                        self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                        var shouldShowFilterIndicator: Bool {
                            if indexPath.section == 0 && (self.filterDogId != nil || self.filterLogAction != nil) {
                                return true
                            }
                            else {
                                return false
                            }
                        }
                        
                        // removed final log and must update header (no logs are left at all)
                        if self.chronologicalLogsGroupedByDate.count == 0 {
                            
                            let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LogsHeaderTableViewCell
                            headerCell.setup(fromDate: nil, shouldShowFilterIndictator: shouldShowFilterIndicator)
                            
                        }
                        // removed final log of a given section and must remove all headers and body in that now gone-from-the-data section
                        else if originalNumberOfSections != self.chronologicalLogsGroupedByDate.count {
                            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                            
                            // removed section that has filter indicator
                            if indexPath.section == 0 && self.chronologicalLogsGroupedByDate.count >= 1 {
                                // for whatever header will be at the top (section 1 currently but will soon be section 0) the filter indicator will be shown if calculated shouldShowFilterIndicator returnd true (! converts to proper isHidden:)
                                
                                let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! LogsHeaderTableViewCell
                                headerCell.filterImageView.isHidden = !shouldShowFilterIndicator
                            }
                            
                        }
                    } completion: { (_) in
                    }
                }
            }

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nestedLogsArray = chronologicalLogsGroupedByDate[indexPath.section].3
        let dogId = nestedLogsArray[indexPath.row-1].0
        let logId = nestedLogsArray[indexPath.row-1].1.logId
        
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
