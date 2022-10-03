//
//  LogsAddLogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddLogViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
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
            
            let dog = dogManager.dogs[indexPath.row]
            
            customCell.willToggleDropDownSelection(forSelected: (parentDogIdsSelected ?? []).contains(dog.dogId))
            
            customCell.label.text = dog.dogName
            
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction", let customCell = cell as? DropDownTableViewCell {
            
            customCell.adjustLeadingTrailing(newConstant: DropDownUIView.insetForBorderedUILabel)
            
            customCell.willToggleDropDownSelection(forSelected: false)
            
            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                customCell.label.text = LogAction.allCases[indexPath.row].displayActionName(
                    logCustomActionName: nil,
                    isShowingAbreviatedCustomActionName: false
                )
                
                if let logActionSelected = logActionSelected {
                    // if the user has a logActionSelected and that matches the index of the current cell, indicating that the current cell is the log action selected, then toggle the dropdown to on.
                    customCell.willToggleDropDownSelection(
                        forSelected: LogAction.allCases.firstIndex(of: logActionSelected) == indexPath.row)
                }
            }
            // a user generated custom name
            else {
                customCell.label.text = LogAction.custom.displayActionName(
                    logCustomActionName: LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count],
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
            return LogAction.allCases.count + LocalConfiguration.localPreviousLogCustomActionNames.count
        }
        else {
            return 0
        }
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        if dropDownUIViewIdentifier == "DropDownParentDog"{
            return 1
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction"{
            return 1
        }
        else {
            return 0
        }
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        if dropDownUIViewIdentifier == "DropDownParentDog", let selectedCell = dropDownParentDog.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            
            let dogSelected = dogManager.dogs[indexPath.row]
            let initalParentDogIdsSelected = parentDogIdsSelected
            
            // check if the dog the user clicked on was already part of the parent dogs selected, if so then we remove its selection
            let isAlreadySelected = parentDogIdsSelected?.contains(dogSelected.dogId) ?? false
            
            // Since we are flipping the selection state of the cell, that means if the dogId isn't in the array, we need to add it and if is in the array we remove it
            if isAlreadySelected {
                parentDogIdsSelected?.removeAll { dogId in
                    return dogId == dogSelected.dogId
                }
            }
            else {
                // since the user has selected a parent dog, make sure we give them an array to append to
                parentDogIdsSelected = parentDogIdsSelected ?? []
                parentDogIdsSelected?.append(dogSelected.dogId)
            }
            
            // Flip is selected state
            selectedCell.willToggleDropDownSelection(forSelected: !isAlreadySelected)
            
            parentDogLabel.text = {
                guard let parentDogIdsSelected = parentDogIdsSelected, parentDogIdsSelected.count >= 1 else {
                    // If no parentDogIdsSelected.count == 0, we leave the text blank so that the placeholder text will display
                    return nil
                }
                
                // dogSelected is the dog clicked and now that dog is removed, we need to find the name of the remaining dog
                if parentDogIdsSelected.count == 1, let singularRemainingDog = dogManager.findDog(forDogId: parentDogIdsSelected[0]) {
                    return singularRemainingDog.dogName
                }
                // parentDogIdsSelected.count >= 2
                else if parentDogIdsSelected.count == dogManager.dogs.count {
                    return nameForAllParentDogs
                }
                else {
                    return nameForMultipleParentDogs
                }
            }()
            
            // If its the first time of a user selecting a dog, assume they only want to create a log for one dog. We therefore hide the drop down immediately after.
            // However, if the user opens this dropdown again, initalParentDogIdsSelected won't be nil and the dropdown will stay open for multiple selections. This allows the user to easily leave the dropdown open for selecting multiple parent dogs
            if initalParentDogIdsSelected == nil {
                dropDownParentDog.hideDropDown()
                // Since its the first time a user is selecting a dog, go through the normal flow of creating a log. next open the log action drop down for them
                dropDownLogAction.showDropDown(numberOfRowsToShow: dropDownLogActionNumberOfRows, animated: true)
            }
        }
        else if dropDownUIViewIdentifier == "DropDownLogAction", let selectedCell = dropDownLogAction.dropDownTableView?.cellForRow(at: indexPath) as? DropDownTableViewCell {
            selectedCell.willToggleDropDownSelection(forSelected: true)
            
            // inside of the predefined LogAction
            if indexPath.row < LogAction.allCases.count {
                logActionLabel.text = LogAction.allCases[indexPath.row].displayActionName(
                    logCustomActionName: nil,
                    isShowingAbreviatedCustomActionName: false
                )
                logActionSelected = LogAction.allCases[indexPath.row]
            }
            // a user generated custom name
            else {
                logActionLabel.text = LogAction.custom.displayActionName(
                    logCustomActionName: LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count],
                    isShowingAbreviatedCustomActionName: false
                )
                logActionSelected = LogAction.custom
                logCustomActionNameTextField.text = LocalConfiguration.localPreviousLogCustomActionNames[indexPath.row - LogAction.allCases.count]
            }
            
            // set logActionSelected to correct value
            
            dropDownLogAction.hideDropDown()
            
            checkLogCustomActionNameTextField()
        }
        
        checkResetCorrespondingReminders()
    }
    
    // MARK: - IB
    
    // TO DO NOW remove containerForAll. put all element just in common, default view. handle hiding a drop down by putting a blank view behind all of elements, then touching this blank view closes the drop downs. additionally, for each ibaction of all the elements, make sure those close the drop downs.
    
    @IBOutlet private weak var containerForAll: UIView!
    @IBOutlet private weak var pageTitle: UINavigationItem!
    
    @IBOutlet private weak var parentDogLabel: BorderedUILabel!
    
    @IBOutlet private weak var logActionLabel: BorderedUILabel!
    
    /// Text input for logCustomActionNameName
    @IBOutlet private weak var logCustomActionNameTextField: BorderedUITextField!
    @IBOutlet private weak var logCustomActionNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logCustomActionNameBottomConstraint: NSLayoutConstraint!
    @IBAction private func didUpdateLogCustomActionName(_ sender: Any) {
        checkResetCorrespondingReminders()
    }
    
    @IBOutlet private weak var resetCorrespondingRemindersLabel: BorderedUILabel!
    @IBOutlet private weak var resetCorrespondingRemindersSwitch: UISwitch!
    @IBOutlet private weak var resetCorrespondingRemindersHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var resetCorrespondingRemindersBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logNoteTextView: BorderedUITextView!
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under logNoteCharacterLimit
        return updatedText.count <= ClassConstant.LogConstant.logNoteCharacterLimit
    }
    
    @IBOutlet private weak var addLogButton: ScaledUIButton!
    @IBOutlet private weak var addLogButtonBackground: ScaledUIButton!
    @IBAction private func willAddLog(_ sender: Any) {
        dismissKeyboard()
        
        do {
            guard let parentDogIdsSelected = parentDogIdsSelected, parentDogIdsSelected.count >= 1 else {
                throw ErrorConstant.LogError.parentDogNotSelected
            }
            guard let logActionSelected = logActionSelected else {
                throw ErrorConstant.LogError.logActionBlank
            }
            
            // Check to see if we are updating or adding a log
            guard let parentDogIdToUpdate = parentDogIdToUpdate, let logToUpdate = logToUpdate else {
                // Adding a log
                addLogButton.beginQuerying()
                addLogButtonBackground.beginQuerying(isBackgroundButton: true)
                
                // Only retrieve correspondingReminders if switch is on. The switch can only be on if the correspondingReminders array isn't empty and the user turned it on themselves. The switch is hidden when correspondingReminders.count == 0.
                let correspondingReminders = resetCorrespondingRemindersSwitch.isOn ? self.correspondingReminders : []
                
                let completionTracker = CompletionTracker(numberOfTasks: parentDogIdsSelected.count + correspondingReminders.count) {
                    self.addLogButton.endQuerying()
                    self.addLogButtonBackground.endQuerying(isBackgroundButton: true)
                    self.navigationController?.popViewController(animated: true)
                } failureCompletionHandler: {
                    self.addLogButton.endQuerying()
                    self.addLogButtonBackground.endQuerying(isBackgroundButton: true)
                }
                
                correspondingReminders.forEach { (dogId, reminder) in
                    reminder.changeIsSkipping(forIsSkipping: true)
                    
                    RemindersRequest.update(invokeErrorManager: true, forDogId: dogId, forReminder: reminder) { requestWasSuccessful, _ in
                        if requestWasSuccessful {
                            completionTracker.completedTask()
                            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                        }
                        else {
                            completionTracker.failedTask()
                        }
                    }
                }

                parentDogIdsSelected.forEach { dogId in
                    // Each dog needs it's own newLog object.
                    let newLog = Log(logAction: logActionSelected, logCustomActionName: logCustomActionNameTextField.text, logDate: logDateDatePicker.date, logNote: logNoteTextView.text ?? ClassConstant.LogConstant.defaultLogNote)
                    
                    LogsRequest.create(invokeErrorManager: true, forDogId: dogId, forLog: newLog) { logId, _ in
                        guard let logId = logId else {
                            completionTracker.failedTask()
                            return
                        }
                        
                        // request was successful so we can now add the new logCustomActionName (if present)
                        if let logCustomActionName = newLog.logCustomActionName, logCustomActionName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                            LocalConfiguration.addLogCustomAction(forName: logCustomActionName)
                        }
                        newLog.logId = logId
                        
                        self.dogManager.findDog(forDogId: dogId)?.dogLogs.addLog(forLog: newLog)
                        
                        self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                        
                        completionTracker.completedTask()
                    }
                    
                }
                
                return
            }
            
            // Updating a log
            logToUpdate.logDate = logDateDatePicker.date
            logToUpdate.logAction = logActionSelected
            try logToUpdate.changeLogCustomActionName(forLogCustomActionName:
                                                        logActionSelected == LogAction.custom
                                                      ? logCustomActionNameTextField.text
                                                      : nil)
            try logToUpdate.changeLogNote(forLogNote: logNoteTextView.text ?? ClassConstant.LogConstant.defaultLogNote)
            
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
                    
                    self.dogManager.findDog(forDogId: parentDogIdToUpdate)?.dogLogs.addLog(forLog: logToUpdate)
                    
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
        catch {
            (error as? HoundError)?.alert() ?? ErrorConstant.UnknownError.unknown.alert()
        }
    }
    
    @IBOutlet private weak var removeLogBarButton: UIBarButtonItem!
    @IBAction private func willRemoveLog(_ sender: Any) {
        
        guard let parentDogIdToUpdate = parentDogIdToUpdate, let logToUpdate = logToUpdate else {
            return
        }
        
        let removeLogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete this log?", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            // the user decided to delete so we must query server
            LogsRequest.delete(invokeErrorManager: true, forDogId: parentDogIdToUpdate, forLogId: logToUpdate.logId) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    if let dog = self.dogManager.findDog(forDogId: parentDogIdToUpdate) {
                        for dogLog in dog.dogLogs.logs where dogLog.logId == logToUpdate.logId {
                            dog.dogLogs.removeLog(forLogId: dogLog.logId)
                        }
                    }
                    
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeLogConfirmation.addAction(alertActionRemove)
        removeLogConfirmation.addAction(alertActionCancel)
        
        AlertManager.enqueueAlertForPresentation(removeLogConfirmation)
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
    
    // MARK: - Dog Manager
    
    private(set) var dogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        if !(sender.localized is LogsViewController) {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
    }
    
    // MARK: - Properties
    
    /// This is the parentDogId of a log if the user is updating an existing log instead of creating a new one
    var parentDogIdToUpdate: Int?
    /// This is the information of a log if the user is updating an existing log instead of creating a new one
    var logToUpdate: Log?
    
    weak var delegate: LogsAddLogViewControllerDelegate! = nil
    
    // MARK: INITAL VALUE TRACKING
    
    private var initalParentDogIdsSelected: [Int]!
    private var initalLogAction: LogAction?
    private var initalLogCustomActionName: String?
    private var initalLogNote: String!
    private var initalLogDate: Date!
    
    var initalValuesChanged: Bool {
        if initalLogAction != logActionSelected {
            return true
        }
        else if logActionSelected == LogAction.custom && initalLogCustomActionName != logCustomActionNameTextField.text {
            return true
        }
        else if initalLogNote != logNoteTextView.text {
            return true
        }
        else if initalLogDate != logDateDatePicker.date {
            return true
        }
        else if initalParentDogIdsSelected != parentDogIdsSelected {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: Parent Dog Drop Down
    
    /// drop down for changing the parent dog name
    private let dropDownParentDog = DropDownUIView()
    private var dropDownParentDogNumberOfRows: Double {
        return dogManager.dogs.count > 5 ? 5.5 : CGFloat(dogManager.dogs.count)
    }
    
    private var parentDogIdsSelected: [Int]?
    private let nameForMultipleParentDogs = "Multiple"
    private let nameForAllParentDogs = "All"
    
    // MARK: Log Action Drop Down
    
    /// drop down for changing the log type
    private let dropDownLogAction = DropDownUIView()
    private let dropDownLogActionNumberOfRows = 6.5
    
    /// the name of the selected log action in drop down
    private var logActionSelected: LogAction?
    
    // MARK: OTHER
    
    /// Iterates through all of the dogs currently selected in the create logs page. Returns any of those dogs' reminders where the reminder's reminderAction and reminderCustomActionName match the logActionSelected and logCustomActionNameTextField.text. This means that the log the user wants to create has a corresponding reminder of the same type under one of the dogs selected.
    private var correspondingReminders: [(Int, Reminder)] {
        var correspondingReminders: [(Int, Reminder)] = []
        guard logToUpdate == nil else {
            // Only eligible to reset corresponding reminders if creating a log
            return correspondingReminders
        }
        
        guard let logActionSelected = logActionSelected else {
            // Can't find a corresponding reminder if no logAction selected
            return correspondingReminders
        }
        
        // Attempt to translate logAction back into a reminderAction
        guard let selectedReminderAction = {
            for reminderAction in ReminderAction.allCases where logActionSelected.rawValue.contains(reminderAction.rawValue) {
                return reminderAction
            }
            return nil
        }() else {
            // couldn't translate logAction into reminderAction
            return correspondingReminders
        }
        
        // logAction could successfully be translated back into a reminder action (some logAction types, like treat, can't be a reminder action)
        
        // Find the dogs that are currently selected
        let selectedDogs = dogManager.dogs.filter { dog in
            return (parentDogIdsSelected ?? []).contains(dog.dogId)
        }
        
        // Search through all of the dogs currently selected. For each dog, find any reminders where the reminderAction and reminderCustomActionName match the logAction and logCustomActionName currently selected on the create log page.
        for selectedDog in selectedDogs {
            correspondingReminders += selectedDog.dogReminders.reminders.filter { selectedDogReminder in
                guard selectedDogReminder.reminderIsEnabled == true else {
                    // Reminder needs to be enabled to be considered
                    return false
                }
                
                guard selectedDogReminder.reminderAction == selectedReminderAction else {
                    // Both reminderActions need to match
                    return false
                }
                
                // If the reminderAction is .custom, then the customActionName need to also match.
                return (selectedDogReminder.reminderAction != .custom)
                || (selectedDogReminder.reminderAction == .custom && selectedDogReminder.reminderCustomActionName == logCustomActionNameTextField.text)
            }
            .map { selectedDogCorrespondingReminder in
                return (selectedDog.dogId, selectedDogCorrespondingReminder)
            }
        }
        
        return correspondingReminders
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            setupViews()
            setupValues()
            setupGestures()
            
            /// Requires log information to be present. Sets up the values of different variables that is found out from information passed
            func setupValues() {
                if let parentDogIdToUpdate = parentDogIdToUpdate, logToUpdate != nil {
                    pageTitle?.title = "Edit Log"
                    removeLogBarButton.isEnabled = true
                    
                    if let dog = dogManager.findDog(forDogId: parentDogIdToUpdate) {
                        parentDogLabel.text = dog.dogName
                        parentDogIdsSelected = [dog.dogId]
                    }
                    
                    parentDogLabel.isUserInteractionEnabled = false
                    parentDogLabel.isEnabled = false
                }
                else {
                    pageTitle?.title = "Create Log"
                    removeLogBarButton.isEnabled = false
                    
                    // If the family only has one dog, then force the parent dog selected to be that single dog. otherwise, make the parent dog selected none and force the user to select parent dog(s)
                    parentDogIdsSelected = dogManager.dogs.count == 1
                    ? [dogManager.dogs[0].dogId]
                    : nil
                    
                    parentDogLabel.text = dogManager.dogs.count == 1
                    ? dogManager.dogs[0].dogName
                    : nil
                    
                    // If there is only one dog in the family, then disable the label
                    parentDogLabel.isUserInteractionEnabled = dogManager.dogs.count == 1 ? false : true
                    parentDogLabel.isEnabled = dogManager.dogs.count == 1 ? false : true
                }
                parentDogLabel.placeholder = dogManager.dogs.count <= 1 ? "Select a dog..." : "Select a dog (or dogs)..."
                
                // this is for the label for the logAction dropdown, so we only want the names to be the defaults. I.e. if our log is "Custom" with "someCustomActionName", the logActionLabel should only show "Custom" and then the logCustomActionNameTextField should be "someCustomActionName".
                logActionLabel.text = logToUpdate?.logAction.displayActionName(logCustomActionName: nil, isShowingAbreviatedCustomActionName: false)
                logActionSelected = logToUpdate?.logAction
                logActionLabel.placeholder = "Select an action..."
                
                logCustomActionNameTextField.text = logToUpdate?.logCustomActionName
                checkResetCorrespondingReminders()
                
                // Only make the logCustomActionName input visible for custom log actions
                checkLogCustomActionNameTextField()
                // spaces to align with bordered label
                logCustomActionNameTextField.placeholder = " Enter a custom action name..."
                
                logNoteTextView.text = logToUpdate?.logNote
                // spaces to align with bordered label
                logNoteTextView.placeholder = " Enter a note..."
                
                // Have to set text property manually for bordered label space adjustment to work properly
                resetCorrespondingRemindersLabel.text = "Reset Corresponding Reminders"
                
                logDateDatePicker.date = logToUpdate?.logDate ?? Date()
                
                // configure inital values so we can track if anything gets updated
                initalParentDogIdsSelected = parentDogIdsSelected
                initalLogAction = logActionSelected
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
    
    /// viewDidLayoutSubviews is called repeatedly whenever views inside the viewcontroller are added or shifted. This causes the code inside viewDidLayoutSubviews to be repeatedly called. However, we use viewDidLayoutSubviews instead of viewDidAppear. Both of these functions are called when the view is already layed out, meaning we can perform accurate changes to the view (like adding and showing a drop down), though viewDidAppear has the downside of performing these changes once the user can see the view, meaning they will see views shift in front of them. Therefore, viewDidLayoutSubviews is the superior choice and we just need to limit it calling the code below once.
    private var didLayoutSubviews: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard didLayoutSubviews == false else {
            return
        }
        
        didLayoutSubviews = true
        
        // MARK: Setup Drop Down
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
        
        // MARK: Show Drop Down
        
        // if the user hasn't selected a parent dog, indicating that this is the first time the logsaddlogvc is appearing, then show the drop down. this functionality will make it so when the user clicks the plus button to add a new log, we automatically present the parent dog dropdown to them
        if parentDogIdsSelected == nil {
            dropDownParentDog.showDropDown(numberOfRowsToShow: dropDownParentDogNumberOfRows, animated: false)
        }
        // if the user has selected a parent dog (clicking the create log plus button while only having one dog), then show the drop down for log action. this functionality will make it so when the user clicks the pluss button to add a new log, and they only have one parent dog to choose from so we automatically select the parent dog, we automatically present the log action drop down to them
        else if logActionSelected == nil {
            dropDownLogAction.showDropDown(numberOfRowsToShow: dropDownLogActionNumberOfRows, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDownLogAction.hideDropDown(removeFromSuperview: true)
        dropDownParentDog.hideDropDown(removeFromSuperview: true)
    }
    
    // MARK: - Functions
    
    /// Toggles visability of optional custom log type components, used for a custom name for it
    private func checkLogCustomActionNameTextField() {
        
        let isHidden = logActionSelected != .custom
        
        logCustomActionNameTextField.isHidden = isHidden
        logCustomActionNameHeightConstraint.constant = isHidden ? 0.0 : 35.0
        logCustomActionNameBottomConstraint.constant = isHidden ? 0.0 : 10.0
        
        containerForAll.setNeedsLayout()
        containerForAll.layoutIfNeeded()
    }
    
    /// If correspondingReminders.count == 0, hides the label and switch for reset corresponding remiders should be hidden
    private func checkResetCorrespondingReminders() {
        let shouldHideResetCorrespondingReminders = correspondingReminders.count == 0
        
        // Check to make sure that the values have changed and need updated
        guard resetCorrespondingRemindersLabel.isHidden != shouldHideResetCorrespondingReminders || resetCorrespondingRemindersSwitch.isHidden != shouldHideResetCorrespondingReminders else {
            return
        }
        
        resetCorrespondingRemindersLabel.isHidden = shouldHideResetCorrespondingReminders
        resetCorrespondingRemindersSwitch.isHidden = shouldHideResetCorrespondingReminders
        resetCorrespondingRemindersHeightConstraint.constant = shouldHideResetCorrespondingReminders ? 0.0 : 35.0
        resetCorrespondingRemindersBottomConstraint.constant = shouldHideResetCorrespondingReminders ? 0.0 : 10.0
        
        containerForAll.setNeedsLayout()
        containerForAll.layoutIfNeeded()
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
        
        dropDownParentDog.showDropDown(numberOfRowsToShow: dropDownParentDogNumberOfRows, animated: true)
    }
    
    /// Dismisses the keyboard and other dropdowns to show logAction
    @objc private func logActionLabelTapped() {
        dismissKeyboard()
        dropDownParentDog.hideDropDown()
        
        dropDownLogAction.showDropDown(numberOfRowsToShow: dropDownLogActionNumberOfRows, animated: true)
    }
    
    @objc private func logNoteTextViewTapped() {
        dropDownParentDog.hideDropDown()
        dropDownLogAction.hideDropDown()
    }
    
}
