//
//  LogsViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsViewControllerDelegate{
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class LogsViewController: UIViewController, DogManagerControlFlowProtocol, LogsMainScreenTableViewControllerDelegate, MakeDropDownDataSourceProtocol, LogsAddArbitraryLogViewControllerDelegate {
    
    
    
    //MARK: - LogsAddArbitraryLogViewControllerDelegate
    
    func didAddArbitraryLog(sender: Sender, parentDogName: String, newArbitraryLog: ArbitraryLog) throws {
        let sudoDogManager = getDogManager()
        if sudoDogManager.dogs.isEmpty == false {
            do {
                try sudoDogManager.findDog(dogName: parentDogName).dogTraits.arbitraryLogDates.append(newArbitraryLog)
            }
            catch {
                ErrorProcessor.alertForError(message: "Unable to add arbitrary log.")
            }
            
        }
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    //MARK: - LogsMainScreenTableViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    //MARK: - MakeDropDownDataSourceProtocol
    
    private var dropDownRowHeight: CGFloat = 30
    
    private let filterByDogFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    private let filterByLogFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    func configureCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
            let sudoDogManager = getDogManager()
            let dog = sudoDogManager.dogs[indexPath.section]
            
            let customCell = cell as! DropDownTableViewCell
            
            //header
            if indexPath.row == 0 {
                customCell.requirementName.attributedText = NSAttributedString(string: dog.dogTraits.dogName, attributes: [.font: filterByDogFont])
            }
            //arbitrary filter neeeded
            else if dog.dogTraits.arbitraryLogDates.isEmpty == false{
                //where arbitrary should be
                if indexPath.row == 1 {
                    customCell.requirementName.attributedText = NSAttributedString(string: "Arbitrary Logs", attributes: [.font: filterByLogFont])
                }
                //where requirement filter should be
                else {
                    customCell.requirementName.attributedText = NSAttributedString(string: dog.dogRequirments.requirements[indexPath.row-2].requirementName, attributes: [.font: filterByLogFont])
                }
            }
            //arbitrary filter not neeeded
            else {
                customCell.requirementName.attributedText = NSAttributedString(string: dog.dogRequirments.requirements[indexPath.row-1].requirementName, attributes: [.font: filterByLogFont])
            }
            
            if indexPath == filterIndexPath{
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
        }
    }
    
    func numberOfRows(forSection: Int) -> Int {
        let sudoDogManager = getDogManager()
        guard sudoDogManager.dogs.isEmpty == false else {
            return 1
        }
        var count = 1
        
            if sudoDogManager.dogs[forSection].dogTraits.arbitraryLogDates.isEmpty == false {
                count = count + 1
            }
            
            for _ in sudoDogManager.dogs[forSection].dogRequirments.requirements{
                count = count + 1
            }
            
            return count
        
    }
    
    func numberOfSections() -> Int {
        let sudoDogManager = getDogManager()
        var count = 0
        for _ in sudoDogManager.dogs{
            count = count + 1
        }
        if count == 0{
            return 1
        }
        else {
            return count
        }
    }
    
    func selectItemInDropDown(indexPath: IndexPath, makeDropDownIdentifier: String) {
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownTableViewCell
        
        //already filtering, now not filtering
        if filterIndexPath == indexPath {
            selectedCell.didToggleSelect(newSelectionStatus: false)
            
            filterIndexPath = nil
        }
        //not filtering, now will filter
        else if filterIndexPath == nil{
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            filterIndexPath = indexPath
        }
        //switching from one filter to another
        else {
            let unselectedCell = dropDown.dropDownTableView!.cellForRow(at: filterIndexPath!) as! DropDownTableViewCell
            unselectedCell.didToggleSelect(newSelectionStatus: false)
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            filterIndexPath = indexPath
        }
        logsMainScreenTableViewController?.willApplyFiltering(associatedToIndexPath: filterIndexPath)
        
        self.dropDown.hideDropDown()
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
        
        synchronizeFilterIndexPath()
        
        if sender.localized is MainTabBarViewController{
            logsMainScreenTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            
            filterIndexPath = nil
            logsMainScreenTableViewController?.willApplyFiltering(associatedToIndexPath: filterIndexPath)
            logsAddArbitraryLogViewController?.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
        }
        if sender.localized is LogsMainScreenTableViewController{
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
        }
        if sender.localized is LogsAddArbitraryLogViewController{
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            
            logsMainScreenTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            filterIndexPath = nil
            logsMainScreenTableViewController?.willApplyFiltering(associatedToIndexPath: filterIndexPath)
        }
        
        updateDogManagerDependents()
    }
    
    func updateDogManagerDependents() {
        willAddArbitraryLog?.isHidden = dogManager.dogs.isEmpty
        willAddArbitraryLogBackground?.isHidden = dogManager.dogs.isEmpty
    }
    
    //MARK: - IB
    
    @IBOutlet private weak var willAddArbitraryLog: ScaledButton!
    @IBOutlet private weak var willAddArbitraryLogBackground: ScaledButton!
    
    
    @IBAction private func willShowFilter(_ sender: Any) {
        
        var numRowsDisplayed: Int {
            
            //finds the total count of rows needed
            var totalCount: Int {
                var count = 0
                for dog in getDogManager().dogs{
                    count = count + 1
                    if dog.dogTraits.arbitraryLogDates.isEmpty == false {
                        count = count + 1
                    }
                    for _ in dog.dogRequirments.requirements{
                        count = count + 1
                    }
                }
                
                if count == 0{
                    return 1
                }
                return count
            }
            
            //finds the total number of rows that can be displayed and makes sure that the needed does not exceed that
                let maximumHeight = self.view.safeAreaLayoutGuide.layoutFrame.size.height
                let neededHeight = self.dropDownRowHeight * CGFloat(totalCount)
                
                if neededHeight < maximumHeight{
                    return totalCount
                }
                else {
                    return Int((maximumHeight / dropDownRowHeight).rounded(.down))
                }
        
        }
        self.dropDown.showDropDown(height: dropDownRowHeight * CGFloat(numRowsDisplayed), selectedIndexPath: self.filterIndexPath)
        
        
    }
    
    //MARK: - Properties
    
    private let dropDown = MakeDropDown()
    
    //IndexPath of a filter selected in the dropDown menu, nil if not filtering
    private var storedFilterIndexPath: IndexPath? = nil
    private var filterIndexPath: IndexPath? {
        get {
            return storedFilterIndexPath
        }
        set(newIndexPath){
            storedFilterIndexPath = newIndexPath
            
             if newIndexPath?.row == 1 && getDogManager().dogs[newIndexPath!.section].dogTraits.arbitraryLogDates.isEmpty == false {
                 filterIsArbitrary = true
             }
             else {
                 filterIsArbitrary = false
             }
             
            
        }
    }
    
    ///True if the filter selected is filtering by arbitrary logs, false if not filtering at all or not filtering by arbitrary
    private var filterIsArbitrary: Bool = false
    
    var logsMainScreenTableViewController: LogsMainScreenTableViewController! = nil
    
    var logsAddArbitraryLogViewController: LogsAddArbitraryLogViewController? = nil
    
    var delegate: LogsViewControllerDelegate! = nil
    
    //MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(willAddArbitraryLog)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDown()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDown.hideDropDown(removeFromSuperview: true)
    }
    
    //MARK: - Drop Down Functions
    
    
    private func setUpDropDown(){
        
        ///Finds the widthNeeded by the largest label, has a minimum and maximum possible along with subtracting the space taken by leading and trailing constraints.
        var neededWidthForLabel: CGFloat{
            let maximumWidth: CGFloat = view.safeAreaLayoutGuide.layoutFrame.width - 20.0
            let minimumWidth: CGFloat = 100.0 - 20.0
            
            ///Finds the largestWidth taken up by any label, later compared to constraint sizes of min and max
            var largestLabelWidth: CGFloat {
                
                let sudoDogManager = getDogManager()
                var largest: CGFloat!
                
                var hasArbitrary: Bool {
                    for dog in sudoDogManager.dogs{
                        if dog.dogTraits.arbitraryLogDates.isEmpty == false {
                            return true
                        }
                    }
                    return false
                }
                if hasArbitrary == true {
                    largest = "Arbitrary Logs".boundingFrom(font: filterByLogFont, height: 30.0).width
                }
                else {
                    largest = 0.0
                }
                
                for dogIndex in 0..<sudoDogManager.dogs.count{
                    let dog = sudoDogManager.dogs[dogIndex]
                    let dogNameWidth = dog.dogTraits.dogName.boundingFrom(font: filterByDogFont, height: 30.0).width
                    
                    if dogNameWidth > largest {
                        largest = dogNameWidth
                    }
                    
                    for requirementIndex in 0..<dog.dogRequirments.requirements.count{
                        let requirement = dog.dogRequirments.requirements[requirementIndex]
                        let requirementNameWidth = requirement.requirementName.boundingFrom(font: filterByLogFont, height: 30.0).width
                        
                        if requirementNameWidth > largest {
                            largest = requirementNameWidth
                        }
                        
                    }
                }
                
                return largest
            }
            
            switch largestLabelWidth {
            case 0..<minimumWidth:
                return minimumWidth
            case minimumWidth...maximumWidth:
                return largestLabelWidth.rounded(.up)
            default:
                return maximumWidth
            }
        }
        
        dropDown.makeDropDownIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.makeDropDownDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: (CGRect(origin: self.view.safeAreaLayoutGuide.layoutFrame.origin, size: CGSize(width: neededWidthForLabel + 20.0, height: 0.0))), offset: 0.0)
        dropDown.nib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDown)
    }
    
    ///If a change was made in the presence of arbitraryLogs, checks to see if there is a disconnect in filterIndexPath and fixes it. If filtering by arbitrary and then all arbitrary logs are deleted, then in the pop down it makes sure that no filters are selected.
    private func synchronizeFilterIndexPath(){
        //filtering by arbitrary and arbitrary is selected
        if filterIsArbitrary && filterIndexPath?.row == 1 {
            
            //arbitrary is no longer possible as all arbitrary deleted, aka disconnect
            if getDogManager().dogs[filterIndexPath!.section].dogTraits.arbitraryLogDates.isEmpty == true {
                filterIsArbitrary = false
                filterIndexPath = nil
            }
        }
    }
    
    // MARK: - Navigation
    
    ///Allows for unwind to this page when back button is clicked in requirement editor
    @IBAction func unwind(_ seg: UIStoryboardSegue){
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logsMainScreenTableViewController"{
            logsMainScreenTableViewController = segue.destination as? LogsMainScreenTableViewController
            logsMainScreenTableViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
            logsMainScreenTableViewController.delegate = self
        }
        else if segue.identifier == "logsAddArbitraryLogViewController"{
            logsAddArbitraryLogViewController = segue.destination as? LogsAddArbitraryLogViewController
            
            //Find the name that is most relevant to the arbitraryLog
            var defaultArbitraryLogName: String?{
                let sudoDogManager = getDogManager()
                var mostRecentArbitraryLog: ArbitraryLog? = nil
                
                //trys to find most recent arbitrary log, mostRecentArbitraryLog is nil if none exist
                for dogIndex in 0..<sudoDogManager.dogs.count{
                    //if mostRecentArbitraryLog is nil then tries to set equal to current dog most recent arbitrary log, nothing happens if that array is empty as mostRecentArbitraryLog is set to nil again
                    if mostRecentArbitraryLog == nil {
                        mostRecentArbitraryLog = sudoDogManager.dogs[dogIndex].dogTraits.arbitraryLogDates.last
                    }
                    //if mostRecentArbitraryLog is not nil, then looks for a dog's arbitrary log that was more recent in time
                    else if sudoDogManager.dogs[dogIndex].dogTraits.arbitraryLogDates.isEmpty == false {
                        let currentDogMostRecentArbitraryLog = sudoDogManager.dogs[dogIndex].dogTraits.arbitraryLogDates.last!
                        
                        if currentDogMostRecentArbitraryLog.creationDate.distance(to: mostRecentArbitraryLog!.creationDate) < 0{
                            mostRecentArbitraryLog = currentDogMostRecentArbitraryLog
                        }
                    }
                    
                }
                
                //mostRecentArbitraryLog not nil then returns the logName as that is most relevant
                if mostRecentArbitraryLog != nil{
                    return mostRecentArbitraryLog!.logName
                }
                //if not arbitraryLogs exsist then trys to find the most recent requirement logged and returns its name
                else if logsMainScreenTableViewController.consolidatedLogDates.isEmpty == false{
                    return logsMainScreenTableViewController.consolidatedLogDates.first!.activeLogName
                }
                //returns nil if no logs of any kind exist
                else {
                    return nil
                }
                
            }
            
            logsAddArbitraryLogViewController!.dogManager = getDogManager()
            logsAddArbitraryLogViewController!.lastArbitraryLogName = defaultArbitraryLogName
            logsAddArbitraryLogViewController!.delegate = self
        }
    }
    

}
