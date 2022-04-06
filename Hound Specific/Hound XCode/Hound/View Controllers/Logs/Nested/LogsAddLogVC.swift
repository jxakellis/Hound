//
//  LogsAddLogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
import CryptoKit

protocol LogsAddLogViewControllerDelegate: AnyObject {
    func didRemoveLog(sender: Sender, parentDogId: Int, logId: Int)
    func didAddLog(sender: Sender, parentDogId: Int, newLog: Log)
    func didUpdateLog(sender: Sender, parentDogId: Int, updatedLog: Log)
}

class LogsAddLogViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, DropDownUIViewDataSource {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    // MARK: - UITextViewDelegate
    // if extra space is added, removes it and ends editing, makes done button function like done instead of adding new line
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.contains("\n") {
            textView.text = textView.text.trimmingCharacters(in: .newlines)
            self.view.endEditing(true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - DropDownUIViewDataSource
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == "dropDownParentDogNameSelector"{
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForBorderedUILabel)
            
            if selectedParentDogIndexPath == indexPath {
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
            customCell.label.text = dogManager.dogs[indexPath.row].dogName
        }
        else if dropDownUIViewIdentifier == "dropDownLogAction"{
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: 8.0)
            
            if selectedLogActionIndexPath == indexPath {
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
            customCell.label.text = LogAction.allCases[indexPath.row].rawValue
        }
        else {
            fatalError()
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == "dropDownParentDogNameSelector"{
            return dogManager.dogs.count
        }
        else if dropDownUIViewIdentifier == "dropDownLogAction"{
            return LogAction.allCases.count
        }
        else {
            fatalError()
        }
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == "dropDownParentDogNameSelector"{
            let selectedCell = dropDownParentDogNameSelector.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            self.selectedParentDogIndexPath = indexPath
            
             parentDogNameSelector.text = dogManager.dogs[indexPath.row].dogName
            parentDogNameSelector.tag = dogManager.dogs[indexPath.row].dogId
            self.dropDownParentDogNameSelector.hideDropDown()
        }
        else if dropDownUIViewIdentifier == "dropDownLogAction"{
            let selectedCell = dropDownLogAction.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            self.selectedLogActionIndexPath = indexPath
            
            logAction.text = LogAction.allCases[indexPath.row].rawValue
            self.dropDownLogAction.hideDropDown()
            
            // if log type is custom, then it doesn't hide the special input fields. == -> true -> isHidden: false.
            toggleCustomLogActionName(isHidden: !(logAction.text == LogAction.custom.rawValue))
        }
        else {
            fatalError()
        }
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var containerForAll: UIView!
    @IBOutlet private weak var pageTitle: UINavigationItem!
    
    @IBOutlet weak var parentDogNameSelector: BorderedUILabel!
    
    @IBOutlet private weak var logAction: BorderedUILabel!
    
    /// Text input for customLogActionName
    @IBOutlet private weak var customLogAction: BorderedUITextField!
    @IBOutlet private weak var customLogActionHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var customLogActionBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logNote: BorderedUITextView!
    
    @IBOutlet private weak var addLogButton: ScaledUIButton!
    @IBOutlet private weak var addLogButtonBackground: ScaledUIButton!
    @IBAction private func willAddLog(_ sender: Any) {
        self.dismissKeyboard()
        
        var trimmedCustomLogActionName: String? {
            if customLogAction.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                return nil
            }
            else {
                return customLogAction.text
            }
        }
        
        // updating log
        if parentDogIdToUpdate != nil && logToUpdate != nil {
            logToUpdate!.logDate = logDate.date
            logToUpdate!.logNote = logNote.text ?? LogConstant.defaultLogNote
            logToUpdate!.logAction = LogAction(rawValue: logAction.text!)!
            
            if logAction.text == LogAction.custom.rawValue {
                logToUpdate!.customActionName = trimmedCustomLogActionName
            }
            
            addLogButton.beginQuerying()
            addLogButtonBackground.beginQuerying(isBackgroundButton: true)
            LogsRequest.update(forDogId: parentDogIdToUpdate!, forLog: logToUpdate!) { requestWasSuccessful in
                self.addLogButton.endQuerying()
                self.addLogButtonBackground.endQuerying(isBackgroundButton: true)
                if requestWasSuccessful == true {
                    self.delegate.didUpdateLog(sender: Sender(origin: self, localized: self), parentDogId: self.parentDogIdToUpdate!, updatedLog: self.logToUpdate!)
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            
        }
        // adding log
        else {
            do {
                if logAction.text == nil || logAction.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    throw LogActionError.blankLogAction
                }
                else {
                    let newLog = Log(logDate: logDate.date, logNote: logNote.text ?? LogConstant.defaultLogNote, logAction: LogAction(rawValue: logAction.text!)!, customActionName: trimmedCustomLogActionName)
                    
                    addLogButton.beginQuerying()
                    addLogButtonBackground.beginQuerying(isBackgroundButton: true)
                    LogsRequest.create(forDogId: parentDogNameSelector.tag, forLog: newLog) { logId in
                        self.addLogButton.endQuerying()
                        self.addLogButtonBackground.endQuerying(isBackgroundButton: true)
                        if logId != nil {
                            newLog.logId = logId!
                            self.delegate.didAddLog(sender: Sender(origin: self, localized: self), parentDogId: self.parentDogNameSelector.tag, newLog: newLog)
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                }
            }
            catch {
                ErrorManager.alert(forError: error)
            }
            
        }
        
    }
    
    @IBOutlet private weak var trashIcon: UIBarButtonItem!
    @IBAction private func willRemoveLog(_ sender: Any) {
        let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete this log?", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            // the user decided to delete so we must query server
                LogsRequest.delete(forDogId: self.parentDogIdToUpdate!, forLogId: self.logToUpdate!.logId) { requestWasSuccessful in
                    if requestWasSuccessful == true {
                        self.delegate.didRemoveLog(sender: Sender(origin: self, localized: self),
                                                   parentDogId: self.parentDogIdToUpdate!,
                                                   logId: self.logToUpdate!.logId)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(alertActionRemove)
        removeDogConfirmation.addAction(alertActionCancel)
        
        AlertManager.enqueueAlertForPresentation(removeDogConfirmation)
    }
    
    @IBOutlet private weak var cancelAddLogButton: ScaledUIButton!
    @IBOutlet private weak var cancelAddLogButtonBackground: ScaledUIButton!
    @IBAction private func willCancel(_ sender: Any) {
        
        // removed canceling, everything autosaves now
        
        self.dismissKeyboard()
        
        if initalValuesChanged == true {
            let unsavedInformationConfirmation = GeneralUIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
            
            let alertActionExit = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            unsavedInformationConfirmation.addAction(alertActionExit)
            unsavedInformationConfirmation.addAction(alertActionCancel)
            
            AlertManager.enqueueAlertForPresentation(unsavedInformationConfirmation)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBOutlet private weak var logDate: UIDatePicker!
    @IBAction private func didUpdateDatePicker(_ sender: Any) {
        self.dismissKeyboard()
    }
    
    // MARK: - Properties
    
    var dogManager: DogManager! = nil
    
    /// This is the information of a log if the user is updating an existing log instead of creating a new one
    var logToUpdate: Log?
    /// This is the parentDogId of a log if the user is updating an existing log instead of creating a new one
    var parentDogIdToUpdate: Int?
    
    weak var delegate: LogsAddLogViewControllerDelegate! = nil
    
    private var initalParentDogId: Int!
    private var initalCustomLogAction: String?
    private var initalLogNote: String!
    private var initalDate: Date!
    
    var initalValuesChanged: Bool {
        // updating
        if parentDogIdToUpdate != nil && logToUpdate != nil {
            // not equal it inital
            if logAction.text != logToUpdate!.logAction.rawValue {
                return true
            }
        }
        // new
        else {
            // starts blank by default
            if logAction.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                return true
            }
        }
        
        // not equal it inital
        if logAction.text == LogAction.custom.rawValue && initalCustomLogAction != customLogAction.text {
            return true
        }
        else if logNote.text != initalLogNote {
            return true
        }
        else if initalDate != logDate.date {
            return true
        }
        else if initalParentDogId != parentDogNameSelector.tag {
            return true
        }
        else {
            return false
        }
    }
    
    /// drop down for changing the parent dog name
    private let dropDownParentDogNameSelector = DropDownUIView()
    
    /// index path of selected parent dog name in drop down
    private var selectedParentDogIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    /// drop down for changing the log type
    private let dropDownLogAction = DropDownUIView()
    
    /// index path of selected log type in drop down
    private var selectedLogActionIndexPath: IndexPath?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(logNote)
        
        setupViews()
        setupValues()
        setUpGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
        self.view.addSubview(logNote)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDowns()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDownLogAction.hideDropDown(removeFromSuperview: true)
        dropDownParentDogNameSelector.hideDropDown(removeFromSuperview: true)
    }
    
    /// Requires log information to be present. Sets up gestureRecognizer for dog selector drop down
    private func setUpGestures() {
        // updating a log
        if parentDogIdToUpdate != nil && logToUpdate != nil {
            // cannot edit the parent dog
            self.parentDogNameSelector.isUserInteractionEnabled = false
            self.parentDogNameSelector.isEnabled = false
       }
        // adding a log
        else {
            // can edit the parent dog
            self.parentDogNameSelector.isUserInteractionEnabled = true
            let parentDogNameSelectorTapGesture = UITapGestureRecognizer(target: self, action: #selector(parentDogNameSelectorTapped))
            parentDogNameSelectorTapGesture.delegate = self
            parentDogNameSelectorTapGesture.cancelsTouchesInView = false
            self.parentDogNameSelector.addGestureRecognizer(parentDogNameSelectorTapGesture)
        }
        
        self.logAction.isUserInteractionEnabled = true
        let logActionTapGesture = UITapGestureRecognizer(target: self, action: #selector(logActionTapped))
        logActionTapGesture.delegate = self
        logActionTapGesture.cancelsTouchesInView = false
        self.logAction.addGestureRecognizer(logActionTapGesture)
        
        let dismissAllTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAll))
        dismissAllTapGesture.delegate = self
        dismissAllTapGesture.cancelsTouchesInView = false
        containerForAll.addGestureRecognizer(dismissAllTapGesture)
        
        let logNoteTapGesture = UITapGestureRecognizer(target: self, action: #selector(logNoteTapped))
        logNoteTapGesture.delegate = self
        logNoteTapGesture.cancelsTouchesInView = false
        self.logNote.addGestureRecognizer(logNoteTapGesture)
    }
    
    /// Requires log information to be present. Sets up the values of different variables that is found out from information passed
    private func setupValues() {
        
        // updating log
        if parentDogIdToUpdate != nil && logToUpdate != nil {
            pageTitle!.title = "Edit Log"
            trashIcon.isEnabled = true
            let dog = try! dogManager.findDog(forDogId: parentDogIdToUpdate!)
            parentDogNameSelector.text = dog.dogName
            parentDogNameSelector.tag = dog.dogId
            
            logAction.text = logToUpdate!.logAction.rawValue
            logAction.isEnabled = true
            customLogAction.text = logToUpdate!.customActionName
            // if == is true, that means it is custom, which means it shouldn't hide so ! reverses to input isHidden: false, reverse for if type is not custom. This is because this text input field is only used for custom types.
            toggleCustomLogActionName(isHidden: !(logToUpdate!.logAction == .custom))
            
            selectedLogActionIndexPath = IndexPath(row: LogAction.allCases.firstIndex(of: LogAction(rawValue: logAction.text!)!)!, section: 0)
            
            logDate.date = logToUpdate!.logDate
            logNote.text = logToUpdate!.logNote
            
        }
        // not updating
        else {
            parentDogNameSelector.text = dogManager.dogs[0].dogName
            parentDogNameSelector.tag = dogManager.dogs[0].dogId
            parentDogNameSelector.isEnabled = true
            
            trashIcon.isEnabled = false
            
            logAction.text = LogConstant.defaultLogNote
            logAction.isEnabled = true
            
            customLogAction.text = ""
            initalCustomLogAction = customLogAction.text
            
            toggleCustomLogActionName(isHidden: true)
            
            selectedLogActionIndexPath = nil
            
            logDate.date = Date()
        }
        
        logAction.placeholder = "Select an action..."
        // spaces to align with bordered label
        
        customLogAction.placeholder = " Enter a custom action name..."
        logNote.placeholder = " Enter a note..."
        
        initalParentDogId = parentDogNameSelector.tag
        initalCustomLogAction = customLogAction.text
        initalDate = logDate.date
        initalLogNote = logNote.text
        
    }
    
    /// Doesn't require log information to be present.
    private func setupViews() {
        view.sendSubviewToBack(containerForAll)
        
        containerForAll.bringSubviewToFront(cancelAddLogButton)
        containerForAll.bringSubviewToFront(addLogButton)
        
        customLogAction.delegate = self
        
        logNote.delegate = self
        
        setupToHideKeyboardOnTapOnView()
    }
    
    // MARK: Extra Functions
    
    /// Dismisses the keyboard and any dropdowns
    @objc private func dismissAll() {
        self.dismissKeyboard()
        self.dropDownParentDogNameSelector.hideDropDown()
        self.dropDownLogAction.hideDropDown()
    }
    
    /// Dismisses the keyboard and other dropdowns to show parentDogNameSelector
    @objc private func parentDogNameSelectorTapped() {
        self.dismissKeyboard()
        self.dropDownLogAction.hideDropDown()
        
        var numDogToShow: CGFloat {
            if dogManager.dogs.count > 5 {
                return 5.5
            }
            else {
                return CGFloat(dogManager.dogs.count)
            }
        }
        self.dropDownParentDogNameSelector.showDropDown(numberOfRowsToShow: CGFloat(numDogToShow))
    }
    
    /// Dismisses the keyboard and other dropdowns to show logAction
    @objc private func logActionTapped() {
        self.dismissKeyboard()
        self.dropDownParentDogNameSelector.hideDropDown()
        
        self.dropDownLogAction.showDropDown(numberOfRowsToShow: 6.5)
    }
    
    @objc private func logNoteTapped() {
        self.dropDownParentDogNameSelector.hideDropDown()
        self.dropDownLogAction.hideDropDown()
    }
    
    /// Toggles visability of optional custom log type components, used for a custom name for it
    private func toggleCustomLogActionName(isHidden: Bool) {
        if isHidden == false {
            customLogAction.isHidden = false
            customLogActionHeightConstraint.constant = 40.0
            customLogActionBottomConstraint.constant = 10.0
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
        else {
            customLogAction.isHidden = true
            customLogActionHeightConstraint.constant = 0.0
            customLogActionBottomConstraint.constant = 0.0
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
    }
    
    // MARK: - Drop Down Functions
    
    private func setUpDropDowns() {
        dropDownParentDogNameSelector.dropDownUIViewIdentifier = "dropDownParentDogNameSelector"
        dropDownParentDogNameSelector.cellReusableIdentifier = "dropDownCell"
        dropDownParentDogNameSelector.dataSource = self
        dropDownParentDogNameSelector.setUpDropDown(viewPositionReference: parentDogNameSelector.frame, offset: 2.0)
        dropDownParentDogNameSelector.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDownParentDogNameSelector.setRowHeight(height: DropDownUIView.rowHeightForBorderedUILabel)
        self.view.addSubview(dropDownParentDogNameSelector)
        
        dropDownLogAction.dropDownUIViewIdentifier = "dropDownLogAction"
        dropDownLogAction.cellReusableIdentifier = "dropDownCell"
        dropDownLogAction.dataSource = self
        dropDownLogAction.setUpDropDown(viewPositionReference: logAction.frame, offset: 2.0)
        dropDownLogAction.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDownLogAction.setRowHeight(height: DropDownUIView.rowHeightForBorderedUILabel)
        self.view.addSubview(dropDownLogAction)
    }
    
}
