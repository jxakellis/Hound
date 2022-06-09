//
//  LogsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class LogsViewController: UIViewController, UIGestureRecognizerDelegate, DogManagerControlFlowProtocol, LogsTableViewControllerDelegate, DropDownUIViewDataSource, LogsAddLogViewControllerDelegate {

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - LogsAddLogViewControllerDelegate

    func didAddLog(sender: Sender, parentDogId: Int, newLog: Log) {
        let sudoDogManager = getDogManager()
        if sudoDogManager.dogs.isEmpty == false {
            do {
                try sudoDogManager.findDog(forDogId: parentDogId).dogLogs.addLog(newLog: newLog)
            }
            catch {
                ErrorManager.alert(forError: error)
            }

        }
        setDogManager(sender: sender, newDogManager: sudoDogManager)

        CheckManager.checkForReview()
    }

    func didUpdateLog(sender: Sender, parentDogId: Int, updatedLog: Log) {

         let sudoDogManager = getDogManager()

         if sudoDogManager.dogs.isEmpty == false {
                let dog = try! sudoDogManager.findDog(forDogId: parentDogId)
             dog.dogLogs.addLog(newLog: updatedLog)

         }

         setDogManager(sender: sender, newDogManager: sudoDogManager)

        CheckManager.checkForReview()

    }

    func didRemoveLog(sender: Sender, parentDogId: Int, logId: Int) {
        let sudoDogManager = getDogManager()
        let dog = try! sudoDogManager.findDog(forDogId: parentDogId)

        for dogLogIndex in 0..<dog.dogLogs.logs.count where dog.dogLogs.logs[dogLogIndex].logId == logId {
            dog.dogLogs.removeLog(forIndex: dogLogIndex)
            break
        }

        setDogManager(sender: sender, newDogManager: sudoDogManager)

        CheckManager.checkForReview()
    }

    // MARK: - LogsTableViewControllerDelegate

    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }

    /// Log selected in the main table view of the logs of care page. This log object has JUST been retrieved and constructed from data from the server.
    private var selectedLog: Log?
    /// Parent dog id of the log selected in the main table view of the logs of care page.
    private var parentDogIdOfSelectedLog: Int?

    func didSelectLog(parentDogId: Int, log: Log) {
        selectedLog = log
        parentDogIdOfSelectedLog = parentDogId
        ViewControllerUtils.performSegueOnceInWindowHierarchy(segueIdentifier: "logsAddLogViewController", viewController: self)
        selectedLog = nil
        parentDogIdOfSelectedLog = nil
    }

    /// If the last log under a dog for a given type was removed while filtering by that type, updates the drop down to reflect this. Does not update table view as it is trigger by the table view.
    func didRemoveLastFilterLog() {
        filterIndexPath = nil
        filterDogId = nil
        filterLogAction = nil
    }

    // MARK: - DropDownUIViewDataSource

    private let filterByDogFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    private let filterByLogFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)

    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {

            let sudoDogManager = getDogManager()

            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForLogFilter)

            // clear filter
            if indexPath.section == sudoDogManager.dogs.count {
                customCell.label.attributedText = NSAttributedString(string: "Clear Filter", attributes: [.font: filterByDogFont])
            }
            else {
                let dog = sudoDogManager.dogs[indexPath.section]
                // header
                if indexPath.row == 0 {
                    customCell.label.attributedText = NSAttributedString(string: dog.dogName, attributes: [.font: filterByDogFont])
                }
                // dog log filter
                else {
                    customCell.label.attributedText = NSAttributedString(string: dog.dogLogs.catagorizedLogActions[indexPath.row-1].0.rawValue, attributes: [.font: filterByLogFont])
                }
            }

            if indexPath == filterIndexPath {
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }

    }

    func numberOfRows(forSection section: Int, dropDownUIViewIdentifier: String) -> Int {
        let sudoDogManager = getDogManager()
        guard sudoDogManager.dogs.isEmpty == false else {
            return 1
        }
        // on additional section used for clear filter
        if section == sudoDogManager.dogs.count {
            return 1
        }
        else {
            return sudoDogManager.dogs[section].dogLogs.catagorizedLogActions.count + 1
        }

    }

    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        let sudoDogManager = getDogManager()
        var count = 0
        for _ in sudoDogManager.dogs {
            count += 1
        }
        if count == 0 {
            return 1
        }
        else {
            return count + 1
        }
    }

    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell

        // reset the filter values to nothing and assign their value below if needed
        // cannot assign filterIndexPath to nil as need it for logic below, the other two filters are just trackers not used for logic here so can set them to nil
        filterDogId = nil
        filterLogAction = nil
        
        // clear filter
        if indexPath.section == getDogManager().dogs.count {
            selectedCell.didToggleSelect(newSelectionStatus: true)
            filterIndexPath = nil
        }
        // already filtering, now not filtering
        else if filterIndexPath == indexPath {
            selectedCell.didToggleSelect(newSelectionStatus: false)
            filterIndexPath = nil
        }
        // not filtering, now will filter
        else if filterIndexPath == nil {
            selectedCell.didToggleSelect(newSelectionStatus: true)

            filterIndexPath = indexPath
            let dog = getDogManager().dogs[indexPath.section]
            filterDogId = dog.dogId

            if indexPath.row != 0 {
                filterLogAction = dog.dogLogs.catagorizedLogActions[indexPath.row-1].0
            }
        }
        // switching from one filter to another
        else {
            let unselectedCell = dropDown.dropDownTableView!.cellForRow(at: filterIndexPath!) as! DropDownDefaultTableViewCell
            unselectedCell.didToggleSelect(newSelectionStatus: false)
            selectedCell.didToggleSelect(newSelectionStatus: true)

            filterIndexPath = indexPath
            let dog = getDogManager().dogs[indexPath.section]
            filterDogId = dog.dogId
            
            if indexPath.row != 0 {
                filterLogAction = dog.dogLogs.catagorizedLogActions[indexPath.row-1].0
            }
        }
        logsTableViewController.willApplyFiltering(forFilterDogId: filterDogId, forFilterLogAction: filterLogAction)

        dropDown.hideDropDown()
    }

    // MARK: - DogManagerControlFlowProtocol

    private var dogManager: DogManager = DogManager()

    func getDogManager() -> DogManager {
        return dogManager
    }

    func setDogManager(sender: Sender, newDogManager: DogManager) {
         dogManager = newDogManager

        // we dont want to update LogsTableViewController if its the one providing the update
        if (sender.localized is LogsTableViewController) == false {
            // need to update table view
            logsTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            
            // logs modified have been added so we need to reset the filter
            filterIndexPath = nil
            filterDogId = nil
            filterLogAction = nil
            logsTableViewController?.willApplyFiltering(forFilterDogId: filterDogId, forFilterLogAction: filterLogAction)
        }
        // we dont want to update MainTabBarViewController with the delegate if its the one providing the update
        if (sender.localized is MainTabBarViewController) == false {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
        }
        if (sender.localized is MainTabBarViewController) == true {
            // pop add log vc as the dog it could have been adding to is now deleted
            logsAddLogViewController?.navigationController?.popViewController(animated: false)
        }
    }

    // MARK: - IB

    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var filterButton: UIBarButtonItem!

    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    
    @IBAction private func willRefresh(_ sender: Any) {
        self.refreshButton.isEnabled = false
        ActivityIndicator.shared.beginAnimating(title: navigationItem.title ?? "", view: self.view, navigationItem: navigationItem)
        
        DogsRequest.get(invokeErrorManager: true, dogManager: getDogManager()) { newDogManager, _ in
            self.refreshButton.isEnabled = true
            ActivityIndicator.shared.stopAnimating(navigationItem: self.navigationItem)
            if newDogManager != nil {
                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: newDogManager!)
            }
        }
        
    }
    @IBOutlet private weak var willAddLog: ScaledUIButton!
    @IBOutlet private weak var willAddLogBackground: ScaledUIButton!

    @IBAction private func willShowFilter(_ sender: Any) {

        var numRowsDisplayed: Int {

            // finds the total count of rows needed
            var totalCount: Int {
                var count = 0
                for dog in getDogManager().dogs {
                    count += dog.dogLogs.catagorizedLogActions.count + 1
                }

                if count == 0 {
                    return 1
                }
                return count + 1
            }

            // finds the total number of rows that can be displayed and makes sure that the needed does not exceed that
            let maximumHeight = self.view.safeAreaLayoutGuide.layoutFrame.size.height
            let neededHeight = DropDownUIView.rowHeightForLogFilter * CGFloat(totalCount)

            if neededHeight < maximumHeight {
                return totalCount
            }
            else {
                return Int((maximumHeight / DropDownUIView.rowHeightForLogFilter).rounded(.down))
            }

        }
        self.dropDown.showDropDown(numberOfRowsToShow: CGFloat(numRowsDisplayed), selectedIndexPath: self.filterIndexPath)

    }

    // MARK: - Properties

    private let dropDown = DropDownUIView()

    // IndexPath of a filter selected in the dropDown menu, nil if not filtering
    private var filterIndexPath: IndexPath?
    /// the dogId of the current dog that the logs are being filted by
    private var filterDogId: Int?
    /// the current log action that the logs are being filtered by
    private var filterLogAction: LogAction?

    var logsTableViewController: LogsTableViewController! = nil

    var logsAddLogViewController: LogsAddLogViewController?

    weak var delegate: LogsViewControllerDelegate! = nil

    // MARK: - Main

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
        AlertManager.globalPresenter = self

        filterButton.isEnabled = !dogManager.dogs.isEmpty
        willAddLog?.isHidden = dogManager.dogs.isEmpty
        willAddLogBackground?.isHidden = dogManager.dogs.isEmpty
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDown()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDown.hideDropDown(removeFromSuperview: true)
    }

    // MARK: - Drop Down Functions

    private func setUpDropDown() {

        /// Finds the widthNeeded by the largest label, has a minimum and maximum possible along with subtracting the space taken by leading and trailing constraints.
        var neededWidthForLabel: CGFloat {
            let maximumWidth: CGFloat = view.safeAreaLayoutGuide.layoutFrame.width - 24.0
            let minimumWidth: CGFloat = 100.0 - 24.0

            /// Finds the largestWidth taken up by any label, later compared to constraint sizes of min and max. Leading and trailing constraints not considered here, that will be adjusted later
            var largestLabelWidth: CGFloat {

                let sudoDogManager = getDogManager()
                var largest: CGFloat = "Clear Filter".boundingFrom(font: filterByDogFont, height: DropDownUIView.rowHeightForLogFilter).width

                for dogIndex in 0..<sudoDogManager.dogs.count {
                    let dog = sudoDogManager.dogs[dogIndex]
                    let dogNameWidth = dog.dogName.boundingFrom(font: filterByDogFont, height: DropDownUIView.rowHeightForLogFilter).width

                    if dogNameWidth > largest {
                        largest = dogNameWidth
                    }

                    let catagorizedLogActions = dog.dogLogs.catagorizedLogActions
                    for logIndex in 0..<catagorizedLogActions.count {
                        let logAction = catagorizedLogActions[logIndex].0
                        let logActionWidth = logAction.rawValue.boundingFrom(font: filterByLogFont, height: DropDownUIView.rowHeightForLogFilter).width

                        if logActionWidth > largest {
                            largest = logActionWidth
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

        /// only one dropdown used on the dropdown instance so no identifier needed
        dropDown.dropDownUIViewIdentifier = ""
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.dataSource = self
        dropDown.setUpDropDown(viewPositionReference: (CGRect(origin: self.view.safeAreaLayoutGuide.layoutFrame.origin, size: CGSize(width: neededWidthForLabel + (DropDownUIView.insetForLogFilter * 2), height: 0.0))), offset: 0.0)
        dropDown.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: DropDownUIView.rowHeightForLogFilter)
        self.view.addSubview(dropDown)
    }

    @objc private func hideDropDown() {
        dropDown.hideDropDown()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logsTableViewController"{
            logsTableViewController = segue.destination as? LogsTableViewController
            logsTableViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
            logsTableViewController.delegate = self
        }
        else if segue.identifier == "logsAddLogViewController"{
            logsAddLogViewController = segue.destination as? LogsAddLogViewController

            logsAddLogViewController!.parentDogIdToUpdate = parentDogIdOfSelectedLog
            logsAddLogViewController!.logToUpdate = selectedLog
            logsAddLogViewController!.dogManager = getDogManager()
            logsAddLogViewController!.delegate = self
        }
    }

}
