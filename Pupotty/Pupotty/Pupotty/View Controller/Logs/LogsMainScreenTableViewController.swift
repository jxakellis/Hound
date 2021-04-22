//
//  LogsMainScreenTableViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol {
    
    //MARK: DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        //DogManagerEfficencyImprovement return dogManager.copy() as! DogManager
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        //DogManagerEfficencyImprovement dogManager = newDogManager.copy() as! DogManager
        dogManager = newDogManager
        
        ///Sorts all dates of every time a requirement was logged into a tuple, containing the actual date, the parent dog name, and the requirement, theb sorts is chronologically from last (closet to present) to first (the first event that happened, so it is the oldest).
        var calculatedConsolidatedLogDates: [(Date, String, Requirement)] {
            let dogManager = getDogManager()
            var consolidatedLogDates: [(Date, String, Requirement)] = []
            
            for dogIndex in 0..<dogManager.dogs.count{
                for requirementIndex in 0..<dogManager.dogs[dogIndex].dogRequirments.requirements.count{
                    let requirement = dogManager.dogs[dogIndex].dogRequirments.requirements[requirementIndex]
                    for logDate in requirement.logDates {
                        consolidatedLogDates.append((logDate, dogManager.dogs[dogIndex].dogTraits.dogName, requirement))
                    }
                }
            }
            
            consolidatedLogDates.sort { (var1, var2) -> Bool in
                let (date1, _, _) = var1
                let (date2, _, _) = var2
                
                //If date1's distance to date2 is positive, i.e. date2 is later in time, returns false as date2 should be ordered first (most recent (to current Date()) dates first)
                if date1.distance(to: date2) > 0 {
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
        var calculatedUniqueLogDates: [(Int, Int, [(Date, String, Requirement)])] {
            var uniqueLogDates: [(Int, Int, [(Date, String, Requirement)])] = []
            
            //goes through all dates present where a log happened
            for dateIndex in 0..<consolidatedLogDates.count{
                let yearAndDayComponents = Calendar.current.dateComponents([.year,.day], from: consolidatedLogDates[dateIndex].0)
                
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
                    uniqueLogDates.append((yearAndDayComponents.day!, yearAndDayComponents.year!, [consolidatedLogDates[dateIndex]]))
                }
                //if a day and year pair is already present, then just appends to their corresponding array that stores all logs that happened on that given pair of day & year
                else {
                    uniqueLogDates[uniqueLogDates.count-1].2.append(consolidatedLogDates[dateIndex])
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
        
        if !(sender.localized is LogsMainScreenTableViewController) {
            self.consolidatedLogDates = calculatedConsolidatedLogDates
            self.uniqueLogDates = calculatedUniqueLogDates
            self.reloadTable()
        }
        
    }
    
    func updateDogManagerDependents() {
        //
    }
    
    //MARK: Properties
    
    ///Stores all dates of every time a requirement was logged into a tuple, containing the actual date, the parent dog name, and the requirement,  sorted chronologically, first to last.
    private var consolidatedLogDates: [(Date, String, Requirement)] = []
    
    ///Stores an array of unique days (of a given year) which a logging event occured. E.g. you logged twice on january 1st 2020& once on january 4th 2020, so the array would be [(1,2020),(4,2020)]
    private var uniqueLogDates: [(Int, Int, [(Date, String, Requirement)])] = []
    
    //MARK: Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        self.tableView.separatorInset = UIEdgeInsets.zero

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func reloadTable(){
        
        if uniqueLogDates.count == 0 {
            tableView.separatorStyle = .none
        }
        else {
            tableView.separatorStyle = .singleLine
        }
        
        tableView.reloadData()
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
            
            let testCell = cell as! LogsMainScreenTableViewCellHeader
            testCell.setup(dateSource: nil)
            
            return cell
        }
        else if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellHeader", for: indexPath)
            
            let testCell = cell as! LogsMainScreenTableViewCellHeader
            testCell.setup(dateSource: uniqueLogDates[indexPath.section].2[0].0)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logsMainScreenTableViewCellBody", for: indexPath)
            
            let testCell = cell as! LogsMainScreenTableViewCellBody
            let infoTuple = uniqueLogDates[indexPath.section].2[indexPath.row-1]
            testCell.setup(date: infoTuple.0, parentDogName: infoTuple.1, requirement: infoTuple.2)

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
