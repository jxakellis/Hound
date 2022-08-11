//
//  LogsAddLogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddLogViewControllerDelegate: AnyObject {
    func didRemoveLog(sender: Sender, parentDogId: Int, logId: Int)
    func didAddLog(sender: Sender, parentDogId: Int, newLog: Log)
    func didUpdateLog(sender: Sender, parentDogId: Int, updatedLog: Log)
}

final class LogsAddLogViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, DropDownUIViewDataSource {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is logCustomActionNameCharacterLimit
        return updatedText.count <= ClassConstant.LogConstant.logCustomActionNameCharacterLimit
    }
    
    // MARK: - UITextViewDelegate
    // if extra space is added, removes it and ends editing, makes done button function like done instead of adding new line
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.contains("\n") {
            textView.text = textView.text.trimmingCharacters(in: .newlines)
            view.endEditing(true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - DropDownUIViewDataSource
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == "DropDownParentDog", let customCell = cell as? DropDownTableViewCell {
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForBorderedUILabel)
            
            if selectedParentDogIndexPath == indexPath {
                customCell.willToggleDropDownSelection(forSelected: true)
            }
            else {
                customCell.willToggleDropDownSelection(forSelected: false)
            }
            
            customCell.label.text = dogManager.dogs[indexPath.row].dogName
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction", let customCell = cell as? DropDownTableViewCell {
            
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForBorderedUILabel)
            
            if selectedLogActionIndexPath == indexPath {
                customCell.willToggleDropDownSelection(forSelected: true)
            }
            else {
                customCell.willToggleDropDownSelection(forSelected: false)
            }
            
            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                customCell.label.text = LogAction.allCases[indexPath.row].displayActionName(
                    logCustomActionName: nil,
                    isShowingAbreviatedCustomActionName: false
                )
            }
            // a user generated custom name
            else {
                customCell.label.text = LogAction.custom.displayActionName(
                    logCustomActionName: LocalConfiguration.logCustomActionNames[indexPath.row - LogAction.allCases.count],
                    isShowingAbreviatedCustomActionName: false
                )
            }
        }
    }
    
    func numberOfRows(forSection: Int, dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == "DropDownParentDog"{
            return dogManager.dogs.count
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction"{
            return LogAction.allCases.count + LocalConfiguration.logCustomActionNames.count
        }
        else {
            return 0
        }
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == "DropDownParentDog", let selectedCell = dropDownParentDog.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
           
            selectedCell.willToggleDropDownSelection(forSelected: true)
            
            selectedParentDogIndexPath = indexPath
            
             parentDogLabel.text = dogManager.dogs[indexPath.row].dogName
            parentDogLabel.tag = dogManager.dogs[indexPath.row].dogId
            dropDownParentDog.hideDropDown()
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction", let selectedCell = dropDownLogAction.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            selectedCell.willToggleDropDownSelection(forSelected: true)
            selectedLogActionIndexPath = indexPath
            
            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                logActionLabel.text = LogAction.allCases[indexPath.row].displayActionName(
                    logCustomActionName: nil,
                    isShowingAbreviatedCustomActionName: false
                )
                selectedLogAction = LogAction.allCases[indexPath.row]
            }
            // a user generated custom name
            else {
                logActionLabel.text = LogAction.custom.displayActionName(
                    logCustomActionName: LocalConfiguration.logCustomActionNames[indexPath.row - LogAction.allCases.count],
                    isShowingAbreviatedCustomActionName: false
                )
                selectedLogAction = LogAction.custom
                logCustomActionNameTextField.text = LocalConfiguration.logCustomActionNames[indexPath.row - LogAction.allCases.count]
            }
            
            // set selectedLogAction to correct value
            
            dropDownLogAction.hideDropDown()
            
            // "Custom" is the last item in LogAction
            if indexPath.row < LogAction.allCases.count - 1 {
                toggleLogCustomActionNameTextField(isHidden: true)
            }
            else {
                // if log type is custom, then it doesn't hide the special input fields.
                toggleLogCustomActionNameTextField(isHidden: false)
            }
        }
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var containerForAll: UIView!
    @IBOutlet private weak var pageTitle: UINavigationItem!
    
    @IBOutlet private weak var familyMemberNameLabel: BorderedUILabel!
    
    @IBOutlet private weak var parentDogLabel: BorderedUILabel!
    
    @IBOutlet private weak var logActionLabel: BorderedUILabel!
    
    /// Text input for logCustomActionNameName
    @IBOutlet private weak var logCustomActionNameTextField: BorderedUITextField!
    @IBOutlet private weak var logCustomActionNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logCustomActionNameBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logNoteTextView: BorderedUITextView!
    
    @IBOutlet private weak var addLogButton: ScaledUIButton!
    @IBOutlet private weak var addLogButtonBackground: ScaledUIButton!
    @IBAction private func willAddLog(_ sender: Any) {
        dismissKeyboard()
        
        do {
            guard let selectedLogAction = selectedLogAction else {
                throw LogError.logActionBlank
            }
            
            // Check to see if we are updating or adding a log
            guard let parentDogIdToUpdate = parentDogIdToUpdate, let logToUpdate = logToUpdate else {
                // Adding a log
                let newLog = Log(logAction: selectedLogAction, logCustomActionName: logCustomActionNameTextField.text, logDate: logDateDatePicker.date, logNote: logNoteTextView.text ?? ClassConstant.LogConstant.defaultLogNote)
                
                addLogButton.beginQuerying()
                addLogButtonBackground.beginQuerying(isBackgroundButton: true)
                LogsRequest.create(invokeErrorManager: true, forDogId: parentDogLabel.tag, forLog: newLog) { logId, _ in
                    self.addLogButton.endQuerying()
                    self.addLogButtonBackground.endQuerying(isBackgroundButton: true)
                    
                    guard let logId = logId else {
                        return
                    }
                    
                    // request was successful so we can now add the new logCustomActionName (if present)
                    if let logCustomActionName = newLog.logCustomActionName, logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        LocalConfiguration.addLogCustomAction(forName: logCustomActionName)
                    }
                    newLog.logId = logId
                    
                    self.delegate.didAddLog(sender: Sender(origin: self, localized: self), parentDogId: self.parentDogLabel.tag, newLog: newLog)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            // Updating a log
            logToUpdate.logDate = logDateDatePicker.date
            logToUpdate.logNote = logNoteTextView.text ?? ClassConstant.LogConstant.defaultLogNote
            logToUpdate.logAction = selectedLogAction
            try logToUpdate.changeLogCustomActionName(forLogCustomActionName:
                                                    selectedLogAction == LogAction.custom
                                                  ? logCustomActionNameTextField.text
                                                  : nil)
            
            addLogButton.beginQuerying()
            addLogButtonBackground.beginQuerying(isBackgroundButton: true)
            LogsRequest.update(invokeErrorManager: true, forDogId: parentDogIdToUpdate, forLog: logToUpdate) { requestWasSuccessful, _ in
                self.addLogButton.endQuerying()
                self.addLogButtonBackground.endQuerying(isBackgroundButton: true)
                if requestWasSuccessful == true {
                    // request was successful so we can now add the new logCustomActionName (if present)
                    if let logCustomActionName = logToUpdate.logCustomActionName, logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        LocalConfiguration.addLogCustomAction(forName: logCustomActionName)
                    }
                    self.delegate.didUpdateLog(sender: Sender(origin: self, localized: self), parentDogId: parentDogIdToUpdate, updatedLog: logToUpdate)
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
        catch {
            ErrorManager.alert(forError: error)
        }
    }
    
    @IBOutlet private weak var removeLogBarButton: UIBarButtonItem!
    @IBAction private func willRemoveLog(_ sender: Any) {
        
        guard let parentDogIdToUpdate = parentDogIdToUpdate, let logToUpdate = logToUpdate else {
            return
        }
        
        let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete this log?", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            // the user decided to delete so we must query server
            LogsRequest.delete(invokeErrorManager: true, forDogId: parentDogIdToUpdate, forLogId: logToUpdate.logId) { requestWasSuccessful, _ in
                    if requestWasSuccessful == true {
                        self.delegate.didRemoveLog(sender: Sender(origin: self, localized: self),
                                                   parentDogId: parentDogIdToUpdate,
                                                   logId: logToUpdate.logId)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(alertActionRemove)
        removeDogConfirmation.addAction(alertActionCancel)
        
        AlertManager.enqueueAlertForPresentation(removeDogConfirmation)
    }
    
    @IBOutlet private weak var cancelButton: ScaledUIButton!
    @IBOutlet private weak var cancelButtonBackground: ScaledUIButton!
    @IBAction private func willCancel(_ sender: Any) {
        
        dismissKeyboard()
        
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
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBOutlet private weak var logDateDatePicker: UIDatePicker!
    @IBAction private func didUpdateLogDate(_ sender: Any) {
        dismissKeyboard()
    }
    
    // MARK: - Properties
    
    var dogManager: DogManager! = nil
    
    /// This is the parentDogId of a log if the user is updating an existing log instead of creating a new one
    var parentDogIdToUpdate: Int?
    /// This is the information of a log if the user is updating an existing log instead of creating a new one
    var logToUpdate: Log?
    
    weak var delegate: LogsAddLogViewControllerDelegate! = nil
    
    private var initalParentDogId: Int!
    private var initalLogAction: LogAction?
    private var initalLogCustomActionName: String?
    private var initalLogNote: String!
    private var initalLogDate: Date!
    
    var initalValuesChanged: Bool {
        if initalLogAction != selectedLogAction {
            return true
        }
        else if selectedLogAction == LogAction.custom && initalLogCustomActionName != logCustomActionNameTextField.text {
            return true
        }
        else if initalLogNote != logNoteTextView.text {
            return true
        }
        else if initalLogDate != logDateDatePicker.date {
            return true
        }
        else if initalParentDogId != parentDogLabel.tag {
            return true
        }
        else {
            return false
        }
    }
    
    /// drop down for changing the parent dog name
    private let dropDownParentDog = DropDownUIView()
    
    /// index path of selected parent dog name in drop down
    private var selectedParentDogIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    /// drop down for changing the log type
    private let dropDownLogAction = DropDownUIView()
    
    /// index path of selected log action in drop down
    private var selectedLogActionIndexPath: IndexPath?
    /// the name of the selected log action in drop down
    private var selectedLogAction: LogAction?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logNoteTextView)
        
        oneTimeSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(logNoteTextView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
        
        repeatableSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDownLogAction.hideDropDown(removeFromSuperview: true)
        dropDownParentDog.hideDropDown(removeFromSuperview: true)
    }
    
    // MARK: - Setup
    
    private func oneTimeSetup() {
        setupViews()
        setupValues()
        setupGestures()
        
        /// Requires log information to be present. Sets up the values of different variables that is found out from information passed
        func setupValues() {
             if let parentDogIdToUpdate = parentDogIdToUpdate, let logToUpdate = logToUpdate {
                pageTitle!.title = "Edit Log"
                removeLogBarButton.isEnabled = true
                
                familyMemberNameLabel.text = FamilyMember.findFamilyMember(forUserId: logToUpdate.userId)?.displayFullName ?? VisualConstant.TextConstant.unknownText
                
                 if let dog = try? dogManager.findDog(forDogId: parentDogIdToUpdate) {
                     parentDogLabel.text = dog.dogName
                     parentDogLabel.tag = dog.dogId
                 }
                
                selectedLogActionIndexPath = IndexPath(row: LogAction.allCases.firstIndex(of: logToUpdate.logAction)!, section: 0)
                
                familyMemberNameLabel.isUserInteractionEnabled = false
                familyMemberNameLabel.isEnabled = false
            }
            else {
                pageTitle!.title = "Create Log"
                removeLogBarButton.isEnabled = false
                
                familyMemberNameLabel.text = FamilyMember.findFamilyMember(forUserId: UserInformation.userId)?.displayFullName ?? VisualConstant.TextConstant.unknownText
                
                parentDogLabel.text = dogManager.dogs[0].dogName
                parentDogLabel.tag = dogManager.dogs[0].dogId
                
                selectedLogActionIndexPath = nil
                
                familyMemberNameLabel.isUserInteractionEnabled = true
                familyMemberNameLabel.isEnabled = true
            }
            
            // this is for the label for the logAction dropdown, so we only want the names to be the defaults. I.e. if our log is "Custom" with "someCustomActionName", the logActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
            logActionLabel.text = logToUpdate?.logAction.displayActionName(logCustomActionName: nil, isShowingAbreviatedCustomActionName: false)
            selectedLogAction = logToUpdate?.logAction
            
            logCustomActionNameTextField.text = logToUpdate?.logCustomActionName
            // Only make the logCustomActionName input visible for custom log actions
            // If logToUpdate is nil or logToUpdate.logAction is not custom, then the expression is false. The ! equates that to true, which means it inputs (isHidden: true).
            toggleLogCustomActionNameTextField(isHidden: !(logToUpdate?.logAction == .custom))
            
            logNoteTextView.text = logToUpdate?.logNote
            logDateDatePicker.date = logToUpdate?.logDate ?? Date()
            
            logActionLabel.placeholder = "Select an action..."
            
            // spaces to align with bordered label
            logCustomActionNameTextField.placeholder = " Enter a custom action name..."
            logNoteTextView.placeholder = " Enter a note..."
            
            // configure inital values so we can track if anything gets updated
            initalParentDogId = parentDogLabel.tag
            initalLogAction = selectedLogAction
            initalLogCustomActionName = logCustomActionNameTextField.text
            initalLogDate = logDateDatePicker.date
            initalLogNote = logNoteTextView.text
        }
        
        /// Requires log information to be present. Sets up gestureRecognizer for dog selector drop down
        func setupGestures() {
            // Only allow use of parentDogLabel if they are creating a log, not updating
            parentDogLabel.isUserInteractionEnabled = parentDogIdToUpdate == nil
            parentDogLabel.isEnabled = parentDogIdToUpdate == nil
            
            // adding a log
            if parentDogIdToUpdate == nil && logToUpdate == nil {
                // can edit the parent dog, have to explictly enable isUserInteractionEnabled to be able to click
                let parentDogLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(parentDogLabelTapped))
                parentDogLabelTapGesture.delegate = self
                parentDogLabelTapGesture.cancelsTouchesInView = false
                parentDogLabel.addGestureRecognizer(parentDogLabelTapGesture)
            }
            
            logActionLabel.isUserInteractionEnabled = true
            let logActionLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(logActionLabelTapped))
            logActionLabelTapGesture.delegate = self
            logActionLabelTapGesture.cancelsTouchesInView = false
            logActionLabel.addGestureRecognizer(logActionLabelTapGesture)
            
            let logNoteTextViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(logNoteTextViewTapped))
            logNoteTextViewTapGesture.delegate = self
            logNoteTextViewTapGesture.cancelsTouchesInView = false
            logNoteTextView.addGestureRecognizer(logNoteTextViewTapGesture)
            
            let dismissAllTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAll))
            dismissAllTapGesture.delegate = self
            dismissAllTapGesture.cancelsTouchesInView = false
            containerForAll.addGestureRecognizer(dismissAllTapGesture)
        }
        
        /// Doesn't require log information to be present.
        func setupViews() {
            view.sendSubviewToBack(containerForAll)
            
            containerForAll.bringSubviewToFront(cancelButton)
            containerForAll.bringSubviewToFront(addLogButton)
            
            logCustomActionNameTextField.delegate = self
            
            logNoteTextView.delegate = self
            
            setupToHideKeyboardOnTapOnView()
        }
    }
    
    private func repeatableSetup() {
        setupDropDowns()
        func setupDropDowns() {
            dropDownParentDog.dropDownUIViewIdentifier = "DropDownParentDog"
            dropDownParentDog.cellReusableIdentifier = "DropDownCell"
            dropDownParentDog.dataSource = self
            dropDownParentDog.setupDropDown(viewPositionReference: parentDogLabel.frame, offset: 2.0)
            dropDownParentDog.nib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
            dropDownParentDog.setRowHeight(height: DropDownUIView.rowHeightForBorderedUILabel)
            view.addSubview(dropDownParentDog)
            
            dropDownLogAction.dropDownUIViewIdentifier = "DropDownLogAction"
            dropDownLogAction.cellReusableIdentifier = "DropDownCell"
            dropDownLogAction.dataSource = self
            dropDownLogAction.setupDropDown(viewPositionReference: logActionLabel.frame, offset: 2.0)
            dropDownLogAction.nib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
            dropDownLogAction.setRowHeight(height: DropDownUIView.rowHeightForBorderedUILabel)
            view.addSubview(dropDownLogAction)
        }
    }
    
    // MARK: - Functions
    
    /// Toggles visability of optional custom log type components, used for a custom name for it
    private func toggleLogCustomActionNameTextField(isHidden: Bool) {
        if isHidden == false {
            logCustomActionNameTextField.isHidden = false
            logCustomActionNameHeightConstraint.constant = 40.0
            logCustomActionNameBottomConstraint.constant = 10.0
            containerForAll.setNeedsLayout()
            containerForAll.layoutIfNeeded()
        }
        else {
            logCustomActionNameTextField.isHidden = true
            logCustomActionNameHeightConstraint.constant = 0.0
            logCustomActionNameBottomConstraint.constant = 0.0
            containerForAll.setNeedsLayout()
            containerForAll.layoutIfNeeded()
        }
    }
    
    // MARK: @objc
    
    /// Dismisses the keyboard and any dropdowns
    @objc private func dismissAll() {
        dismissKeyboard()
        dropDownParentDog.hideDropDown()
        dropDownLogAction.hideDropDown()
    }
    
    /// Dismisses the keyboard and other dropdowns to show parentDogLabel
    @objc private func parentDogLabelTapped() {
        dismissKeyboard()
        dropDownLogAction.hideDropDown()
        
        var numDogToShow: CGFloat {
            if dogManager.dogs.count > 5 {
                return 5.5
            }
            else {
                return CGFloat(dogManager.dogs.count)
            }
        }
        dropDownParentDog.showDropDown(numberOfRowsToShow: CGFloat(numDogToShow))
    }
    
    /// Dismisses the keyboard and other dropdowns to show logAction
    @objc private func logActionLabelTapped() {
        dismissKeyboard()
        dropDownParentDog.hideDropDown()
        
        dropDownLogAction.showDropDown(numberOfRowsToShow: 6.5)
    }
    
    @objc private func logNoteTextViewTapped() {
        dropDownParentDog.hideDropDown()
        dropDownLogAction.hideDropDown()
    }
    
}
