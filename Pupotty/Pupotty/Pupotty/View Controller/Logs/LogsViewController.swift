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

class LogsViewController: UIViewController, DogManagerControlFlowProtocol, LogsMainScreenTableViewControllerDelegate, MakeDropDownDataSourceProtocol, LogsAddLogViewControllerDelegate {
    
    //MARK: - LogsAddLogViewControllerDelegate
    
    func didAddKnownLog(sender: Sender, parentDogName: String, newKnownLog: KnownLog) {
        let sudoDogManager = getDogManager()
        if sudoDogManager.dogs.isEmpty == false {
            do {
                try sudoDogManager.findDog(dogName: parentDogName).dogTraits.logs.append(newKnownLog)
            }
            catch {
                ErrorProcessor.alertForError(message: "Unable to add log.")
            }
            
        }
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    func didUpdateKnownLog(sender: Sender, parentDogName: String, requirementUUID: String?, updatedKnownLog: KnownLog) {
        
         let sudoDogManager = getDogManager()
         if sudoDogManager.dogs.isEmpty == false {
             do {
                let dog = try! sudoDogManager.findDog(dogName: parentDogName)
                
                //requirement log
                if requirementUUID != nil {
                    let requirement = try! dog.dogRequirments.findRequirement(forUUID: requirementUUID!)
                    
                    for logIndex in 0..<requirement.logs.count{
                        if requirement.logs[logIndex].uuid == updatedKnownLog.uuid{
                            requirement.logs[logIndex] = updatedKnownLog
                            break
                        }
                    }
                }
                //dog log
                else {
                    var dogLogs = try sudoDogManager.findDog(dogName: parentDogName).dogTraits.logs
                    
                    for dogLogIndex in 0..<dogLogs.count {
                        if dogLogs[dogLogIndex].uuid == updatedKnownLog.uuid{
                            //match
                            dogLogs[dogLogIndex] = updatedKnownLog
                            break
                        }
                        else {
                            //no match
                        }
                    }
                }
                 
                 
                 
             }
             catch {
                 ErrorProcessor.alertForError(message: "Unable to update log.")
             }
             
         }
         setDogManager(sender: sender, newDogManager: sudoDogManager)
         
    }
    
    func didDeleteKnownLog(sender: Sender, parentDogName: String, requirementUUID: String?, logUUID: String) {
        let sudoDogManager = getDogManager()
        let dog = try! sudoDogManager.findDog(dogName: parentDogName)
        
        //dog log
        if requirementUUID == nil {
            for dogLogIndex in 0..<dog.dogTraits.logs.count{
                if dog.dogTraits.logs[dogLogIndex].uuid == logUUID{
                    dog.dogTraits.logs.remove(at: dogLogIndex)
                    break
                }
            }
        }
        //requirement log
        else {
            var logFound = false
            
            for requirement in dog.dogRequirments.requirements{
                guard logFound == false else {
                    break
                }
                for requirementLogIndex in 0..<requirement.logs.count{
                    guard logFound == false else {
                        break
                    }
                    if requirement.logs[requirementLogIndex].uuid == logUUID{
                        requirement.logs.remove(at: requirementLogIndex)
                        logFound = true
                    }
                }
            }
        }
        
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    //MARK: - LogsMainScreenTableViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    private var selectedLog: (String, Requirement?, KnownLog)? = nil
    func didSelectLog(parentDogName: String, requirement: Requirement?, log: KnownLog) {
        selectedLog = (parentDogName, requirement, log)
        performSegue(withIdentifier: "logsAddLogViewController", sender: self)
        selectedLog = nil
    }
    
    //MARK: - MakeDropDownDataSourceProtocol
    
    private var dropDownRowHeight: CGFloat = 30
    
    private let filterByDogFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    private let filterByLogFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
            
            let sudoDogManager = getDogManager()
            let dog = sudoDogManager.dogs[indexPath.section]
            
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustConstraints(newValue: 12.0)
            
            //header
            if indexPath.row == 0 {
                customCell.label.attributedText = NSAttributedString(string: dog.dogTraits.dogName, attributes: [.font: filterByDogFont])
            }
            //dog log filter
            else {
                customCell.label.attributedText = NSAttributedString(string: dog.catagorizedLogTypes[indexPath.row-1].0.rawValue, attributes: [.font: filterByLogFont])
            }
            
            if indexPath == filterIndexPath{
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
        }
    }
    
    func numberOfRows(forSection: Int, makeDropDownIdentifier: String) -> Int {
        let sudoDogManager = getDogManager()
        guard sudoDogManager.dogs.isEmpty == false else {
            return 1
        }
        return sudoDogManager.dogs[forSection].catagorizedLogTypes.count + 1
    }
    
    func numberOfSections(makeDropDownIdentifier: String) -> Int {
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
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
        
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
            let unselectedCell = dropDown.dropDownTableView!.cellForRow(at: filterIndexPath!) as! DropDownDefaultTableViewCell
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
        
        if sender.localized is MainTabBarViewController{
            logsMainScreenTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            
            //can add logs so needs to remove filter
            filterIndexPath = nil
            logsMainScreenTableViewController?.willApplyFiltering(associatedToIndexPath: filterIndexPath)
            logsAddLogViewController?.navigationController?.popViewController(animated: false)
        }
        //only deletes logs so ok
        if sender.localized is LogsMainScreenTableViewController{
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
        }
        
        if sender.localized is LogsAddLogViewController {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            
            //can delete or add logs so needs to remove filter
            logsMainScreenTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            filterIndexPath = nil
            logsMainScreenTableViewController?.willApplyFiltering(associatedToIndexPath: filterIndexPath)
        }
        
        updateDogManagerDependents()
    }
    
    func updateDogManagerDependents() {
        willAddLog?.isHidden = dogManager.dogs.isEmpty
        willAddLogBackground?.isHidden = dogManager.dogs.isEmpty
    }
    
    //MARK: - IB
    
    @IBOutlet private weak var willAddLog: ScaledButton!
    @IBOutlet private weak var willAddLogBackground: ScaledButton!
    
    
    @IBAction private func willShowFilter(_ sender: Any) {
        
        var numRowsDisplayed: Int {
            
            //finds the total count of rows needed
            var totalCount: Int {
                var count = 0
                for dog in getDogManager().dogs{
                    count = count + dog.catagorizedLogTypes.count + 1
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
    private var filterIndexPath: IndexPath? = nil
    
    var logsMainScreenTableViewController: LogsMainScreenTableViewController! = nil
    
    var logsAddLogViewController: LogsAddLogViewController? = nil
    
    var delegate: LogsViewControllerDelegate! = nil
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(willAddLog)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
        
        updateDogManagerDependents()
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
                        if dog.dogTraits.logs.isEmpty == false {
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
                        let requirementNameWidth = requirement.requirementType.rawValue.boundingFrom(font: filterByLogFont, height: 30.0).width
                        
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
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDown)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logsMainScreenTableViewController"{
            logsMainScreenTableViewController = segue.destination as? LogsMainScreenTableViewController
            logsMainScreenTableViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
            logsMainScreenTableViewController.delegate = self
        }
        else if segue.identifier == "logsAddLogViewController"{
            logsAddLogViewController = segue.destination as? LogsAddLogViewController
            
            logsAddLogViewController!.updatingKnownLogInformation = selectedLog
            logsAddLogViewController!.dogManager = getDogManager()
            logsAddLogViewController!.delegate = self
        }
    }
    
    
}
