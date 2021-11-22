//
//  LogsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsViewControllerDelegate{
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class LogsViewController: UIViewController, UIGestureRecognizerDelegate, DogManagerControlFlowProtocol, LogsMainScreenTableViewControllerDelegate, DropDownUIViewDataSourceProtocol, LogsAddLogViewControllerDelegate {
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - LogsAddLogViewControllerDelegate
    
    func didAddKnownLog(sender: Sender, parentDogName: String, newKnownLog: KnownLog) {
        let sudoDogManager = getDogManager()
        if sudoDogManager.dogs.isEmpty == false {
            do {
                try sudoDogManager.findDog(forName: parentDogName).dogTraits.addLog(newLog: newKnownLog)
            }
            catch {
                ErrorProcessor.alertForError(message: "Unable to add log.")
            }
            
        }
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    func didUpdateKnownLog(sender: Sender, parentDogName: String, reminderUUID: String?, updatedKnownLog: KnownLog) {
        
         let sudoDogManager = getDogManager()
         if sudoDogManager.dogs.isEmpty == false {
                let dog = try! sudoDogManager.findDog(forName: parentDogName)
             try! dog.dogTraits.addLog(newLog: updatedKnownLog)
             //try! dog.dogTraits.changeLog(forUUID: updatedKnownLog.uuid, newLog: updatedKnownLog)
                    
             /*
                    for dogLogIndex in 0..<dog.dogTraits.logs.count {
                        dog.dogTraits.changeLog(forUUID: dog.dogTraits.logs[dogLogIndex].uuid, newLog: updatedKnownLog)
                        if dog.dogTraits.logs[dogLogIndex].uuid == updatedKnownLog.uuid{
                            //match
                            dog.dogTraits.logs[dogLogIndex] = updatedKnownLog
                            break
                        }
                    }
              */
             
         }
        
         setDogManager(sender: sender, newDogManager: sudoDogManager)
         
    }
    
    func didRemoveKnownLog(sender: Sender, parentDogName: String, reminderUUID: String?, logUUID: String) {
        let sudoDogManager = getDogManager()
        let dog = try! sudoDogManager.findDog(forName: parentDogName)
        
        for dogLogIndex in 0..<dog.dogTraits.logs.count{
            if dog.dogTraits.logs[dogLogIndex].uuid == logUUID{
                dog.dogTraits.removeLog(forIndex: dogLogIndex)
                break
            }
        }
        
        /*
         //dog log
         if reminderUUID == nil {
             for dogLogIndex in 0..<dog.dogTraits.logs.count{
                 if dog.dogTraits.logs[dogLogIndex].uuid == logUUID{
                     dog.dogTraits.logs.remove(at: dogLogIndex)
                     break
                 }
             }
         }
         //reminder log
         else {
             var logFound = false
             
             for reminder in dog.dogReminders.reminders{
                 guard logFound == false else {
                     break
                 }
                 for reminderLogIndex in 0..<reminder.logs.count{
                     guard logFound == false else {
                         break
                     }
                     if reminder.logs[reminderLogIndex].uuid == logUUID{
                         reminder.logs.remove(at: reminderLogIndex)
                         logFound = true
                     }
                 }
             }
         }
         */
        
        
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    //MARK: - LogsMainScreenTableViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    private var selectedLog: (String, Reminder?, KnownLog)? = nil
    func didSelectLog(parentDogName: String, reminder: Reminder?, log: KnownLog) {
        selectedLog = (parentDogName, reminder, log)
        performSegue(withIdentifier: "logsAddLogViewController", sender: self)
        selectedLog = nil
    }
    
    ///If the last log under a dog for a given type was removed while filtering by that type, updates the drop down to reflect this. Does not update table view as it is trigger by the table view.
    func didRemoveLastFilterLog(){
        filterIndexPath = nil
        filterType = nil
    }
    
    //MARK: - DropDownUIViewDataSourceProtocol
    
    private var dropDownRowHeight: CGFloat = 30
    
    private let filterByDogFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    private let filterByLogFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, DropDownUIViewIdentifier: String) {
        if DropDownUIViewIdentifier == "DROP_DOWN_NEW"{
            
            let sudoDogManager = getDogManager()
            
            
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: 12.0)
            
            //clear filter
            if indexPath.section == sudoDogManager.dogs.count{
                customCell.label.attributedText = NSAttributedString(string: "Clear Filter", attributes: [.font: filterByDogFont])
            }
            else {
                let dog = sudoDogManager.dogs[indexPath.section]
                //header
                if indexPath.row == 0 {
                    customCell.label.attributedText = NSAttributedString(string: dog.dogTraits.dogName, attributes: [.font: filterByDogFont])
                }
                //dog log filter
                else {
                    customCell.label.attributedText = NSAttributedString(string: dog.catagorizedLogTypes[indexPath.row-1].0.rawValue, attributes: [.font: filterByLogFont])
                }
            }
            
            
            if indexPath == filterIndexPath{
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
        }
    }
    
    func numberOfRows(forSection: Int, DropDownUIViewIdentifier: String) -> Int {
        let sudoDogManager = getDogManager()
        guard sudoDogManager.dogs.isEmpty == false else {
            return 1
        }
        //on additional section used for clear filter
        if forSection == sudoDogManager.dogs.count{
            return 1
        }
        else {
            return sudoDogManager.dogs[forSection].catagorizedLogTypes.count + 1
        }
        
    }
    
    func numberOfSections(DropDownUIViewIdentifier: String) -> Int {
        let sudoDogManager = getDogManager()
        var count = 0
        for _ in sudoDogManager.dogs{
            count = count + 1
        }
        if count == 0{
            return 1
        }
        else {
            return count + 1
        }
    }
    
    func selectItemInDropDown(indexPath: IndexPath, DropDownUIViewIdentifier: String) {
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
        
        //clear filter
        if indexPath.section == getDogManager().dogs.count{
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            filterIndexPath = nil
            filterType = nil
        }
        //already filtering, now not filtering
        else if filterIndexPath == indexPath {
            selectedCell.didToggleSelect(newSelectionStatus: false)
            
            filterIndexPath = nil
            filterType = nil
        }
        
        
        //not filtering, now will filter
        else if filterIndexPath == nil{
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            filterIndexPath = indexPath
            
            if indexPath.row != 0 {
                let dog = getDogManager().dogs[indexPath.section]
                filterType = dog.catagorizedLogTypes[indexPath.row-1].0
            }
        }
        //switching from one filter to another
        else {
            let unselectedCell = dropDown.dropDownTableView!.cellForRow(at: filterIndexPath!) as! DropDownDefaultTableViewCell
            unselectedCell.didToggleSelect(newSelectionStatus: false)
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            filterIndexPath = indexPath
            if indexPath.row != 0 {
                let dog = getDogManager().dogs[indexPath.section]
                filterType = dog.catagorizedLogTypes[indexPath.row-1].0
            }
        }
        logsMainScreenTableViewController?.willApplyFiltering(associatedToIndexPath: filterIndexPath, filterType: filterType)
        
        self.dropDown.hideDropDown()
    }
    
    //MARK: - DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
         dogManager = newDogManager
       
        
        if sender.localized is MainTabBarViewController{
            logsMainScreenTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            
            //can add logs so needs to remove filter
            filterIndexPath = nil
            filterType = nil
            logsMainScreenTableViewController?.willApplyFiltering(associatedToIndexPath: filterIndexPath, filterType: filterType)
            logsAddLogViewController?.navigationController?.popViewController(animated: false)
        }
        //only removes logs so ok
        if sender.localized is LogsMainScreenTableViewController{
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
        }
        
        if sender.localized is LogsAddLogViewController {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            
            //can remove or add logs so needs to remove filter
            logsMainScreenTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            filterIndexPath = nil
            filterType = nil
            logsMainScreenTableViewController?.willApplyFiltering(associatedToIndexPath: filterIndexPath, filterType: filterType)
        }
        
        updateDogManagerDependents()
    }
    
    func updateDogManagerDependents() {
        
        filterButton.isEnabled = !dogManager.dogs.isEmpty
        willAddLog?.isHidden = dogManager.dogs.isEmpty
        willAddLogBackground?.isHidden = dogManager.dogs.isEmpty
    }
    
    //MARK: - IB
    
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var filterButton: UIBarButtonItem!
    
    @IBOutlet private weak var willAddLog: ScaledUIButton!
    @IBOutlet private weak var willAddLogBackground: ScaledUIButton!
    
    
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
                return count + 1
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
    
    private let dropDown = DropDownUIView()
    
    //IndexPath of a filter selected in the dropDown menu, nil if not filtering
    private var filterIndexPath: IndexPath? = nil
    private var filterType: KnownLogType? = nil
    
    var logsMainScreenTableViewController: LogsMainScreenTableViewController! = nil
    
    var logsAddLogViewController: LogsAddLogViewController? = nil
    
    var delegate: LogsViewControllerDelegate! = nil
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(willAddLog)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideDropDown))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tap)
        
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
            let maximumWidth: CGFloat = view.safeAreaLayoutGuide.layoutFrame.width - 24.0
            let minimumWidth: CGFloat = 100.0 - 24.0
            
            ///Finds the largestWidth taken up by any label, later compared to constraint sizes of min and max. Leading and trailing constraints not considered here, that will be adjusted later
            var largestLabelWidth: CGFloat {
                
                let sudoDogManager = getDogManager()
                var largest: CGFloat = "Clear Filter".boundingFrom(font: filterByDogFont, height: 30.0).width
                
                for dogIndex in 0..<sudoDogManager.dogs.count{
                    let dog = sudoDogManager.dogs[dogIndex]
                    let dogNameWidth = dog.dogTraits.dogName.boundingFrom(font: filterByDogFont, height: 30.0).width
                    
                    if dogNameWidth > largest {
                        largest = dogNameWidth
                    }
                    
                    let catagorizedLogTypes = dog.catagorizedLogTypes
                    for logIndex in 0..<catagorizedLogTypes.count{
                        let logType = catagorizedLogTypes[logIndex].0
                        let logTypeWidth = logType.rawValue.boundingFrom(font: filterByLogFont, height: 30.0).width
                        
                        if logTypeWidth > largest {
                            largest = logTypeWidth
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
        
        dropDown.DropDownUIViewIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.DropDownUIViewDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: (CGRect(origin: self.view.safeAreaLayoutGuide.layoutFrame.origin, size: CGSize(width: neededWidthForLabel + 24.0, height: 0.0))), offset: 0.0)
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDown)
    }
    
    @objc private func hideDropDown(){
        dropDown.hideDropDown()
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
