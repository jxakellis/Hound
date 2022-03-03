//
//  LogsAddLogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddLogViewControllerDelegate: AnyObject {
    func didRemoveKnownLog(sender: Sender, parentDogId: Int, reminderUUID: String?, logUUID: String)
    func didAddKnownLog(sender: Sender, parentDogId: Int, newKnownLog: KnownLog)
    func didUpdateKnownLog(sender: Sender, parentDogId: Int, reminderUUID: String?, updatedKnownLog: KnownLog)
}

class LogsAddLogViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, DropDownUIViewDataSourceProtocol {

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

    // MARK: - DropDownUIViewDataSourceProtocol

    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, DropDownUIViewIdentifier: String) {
        if DropDownUIViewIdentifier == "dropDownParentDogName"{
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: 8.0)

            if selectedParentDogIndexPath == indexPath {
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }

            customCell.label.text = dogManager.dogs[indexPath.row].dogTraits.dogName
        }
        else if DropDownUIViewIdentifier == "dropDownLogType"{
            let customCell = cell as! DropDownDefaultTableViewCell
            customCell.adjustLeadingTrailing(newConstant: 8.0)

            if selectedLogTypeIndexPath == indexPath {
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }

            customCell.label.text = KnownLogType.allCases[indexPath.row].rawValue
        }
        else {
            fatalError()
        }
    }

    func numberOfRows(forSection: Int, DropDownUIViewIdentifier: String) -> Int {
        if DropDownUIViewIdentifier == "dropDownParentDogName"{
            return dogManager.dogs.count
        }
        else if DropDownUIViewIdentifier == "dropDownLogType"{
            return KnownLogType.allCases.count
        }
        else {
            fatalError()
        }
    }

    func numberOfSections(DropDownUIViewIdentifier: String) -> Int {
        if DropDownUIViewIdentifier == "dropDownParentDogName"{
            return 1
        }
        else if DropDownUIViewIdentifier == "dropDownLogType"{
            return 1
        }
        else {
            fatalError()
        }
    }

    func selectItemInDropDown(indexPath: IndexPath, DropDownUIViewIdentifier: String) {
        if DropDownUIViewIdentifier == "dropDownParentDogName"{
            let selectedCell = dropDownParentDogName.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
            selectedCell.didToggleSelect(newSelectionStatus: true)

            self.selectedParentDogIndexPath = indexPath

            parentDogName.text = dogManager.dogs[indexPath.row].dogTraits.dogName
            self.dropDownParentDogName.hideDropDown()
        }
        else if DropDownUIViewIdentifier == "dropDownLogType"{
            let selectedCell = dropDownLogType.dropDownTableView!.cellForRow(at: indexPath) as! DropDownDefaultTableViewCell
            selectedCell.didToggleSelect(newSelectionStatus: true)

            self.selectedLogTypeIndexPath = indexPath

            logType.text = KnownLogType.allCases[indexPath.row].rawValue
            self.dropDownLogType.hideDropDown()

            // if log type is custom, then it doesn't hide the special input fields. == -> true -> isHidden: false.
            toggleCustomLogTypeName(isHidden: !(logType.text == KnownLogType.custom.rawValue))
        }
        else {
            fatalError()
        }
    }

    // MARK: - IB

    @IBOutlet private weak var containerForAll: UIView!
    @IBOutlet private weak var pageTitle: UINavigationItem!
    @IBOutlet private weak var trashIcon: UIBarButtonItem!

    // @IBOutlet private weak var logDisclaimer: ScaledUILabel!

    @IBOutlet weak var parentDogName: BorderedUILabel!

    @IBOutlet private weak var logType: BorderedUILabel!

    /// label for customLogType, not used for input
    @IBOutlet private weak var customLogTypeName: ScaledUILabel!

    /// Used for reconfiguring layout when visability changed
    @IBOutlet private weak var customLogTypeNameBottomConstraint: NSLayoutConstraint!

    /// Text input for customLogTypeName
    @IBOutlet private weak var customLogTypeTextField: UITextField!

    @IBOutlet private weak var logNote: UITextView!

    @IBOutlet private weak var logDate: UIDatePicker!

    @IBOutlet private weak var addLogButton: ScaledUIButton!

    @IBOutlet private weak var addLogButtonBackground: ScaledUIButton!

    @IBOutlet private weak var cancelAddLogButton: ScaledUIButton!

    @IBOutlet private weak var cancelAddLogButtonBackground: ScaledUIButton!

    @IBAction private func willRemoveLog(_ sender: Any) {
        let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete this log?", message: nil, preferredStyle: .alert)

        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delegate.didRemoveKnownLog(sender: Sender(origin: self, localized: self), parentDogName: self.parentDogName.text!, reminderUUID: self.updatingKnownLogInformation!.1?.uuid ?? nil, logUUID: self.updatingKnownLogInformation!.2.uuid)
            self.navigationController?.popViewController(animated: true)
        }

        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        removeDogConfirmation.addAction(alertActionRemove)
        removeDogConfirmation.addAction(alertActionCancel)

        AlertManager.shared.enqueueAlertForPresentation(removeDogConfirmation)
    }

    @IBAction private func willAddLog(_ sender: Any) {
        self.dismissKeyboard()

        var trimmedCustomLogTypeName: String? {
            if customLogTypeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                return nil
            }
            else {
                return customLogTypeTextField.text
            }
        }

        // updating log
        if updatingKnownLogInformation != nil {
            let exsistingLog = updatingKnownLogInformation!.2
            let updatedLog = exsistingLog.copy() as! KnownLog
            updatedLog.date = logDate.date
            updatedLog.note = logNote.text ?? ""
            updatedLog.logType = KnownLogType(rawValue: logType.text!)!

            if logType.text == KnownLogType.custom.rawValue {
                updatedLog.customTypeName = trimmedCustomLogTypeName
            }

            delegate.didUpdateKnownLog(sender: Sender(origin: self, localized: self), parentDogName: parentDogName.text!, reminderUUID: updatingKnownLogInformation?.1?.uuid ?? nil, updatedKnownLog: updatedLog)
            self.navigationController?.popViewController(animated: true)
        }
        // adding log
        else {
            do {
                if logType.text == nil || logType.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                    throw KnownLogTypeError.blankLogType
                }
                else {
                    let newLog = KnownLog(date: logDate.date, note: logNote.text ?? "", logType: KnownLogType(rawValue: logType.text!)!, customTypeName: trimmedCustomLogTypeName)
                    delegate.didAddKnownLog(sender: Sender(origin: self, localized: self), parentDogName: parentDogName.text!, newKnownLog: newLog)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            catch {
                ErrorManager.handleError(sender: Sender(origin: self, localized: self), error: error)
            }

        }

    }

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

             AlertManager.shared.enqueueAlertForPresentation(unsavedInformationConfirmation)
         }
         else {
             self.navigationController?.popViewController(animated: true)
         }

     }

    @IBAction private func didUpdateDatePicker(_ sender: Any) {
        self.dismissKeyboard()
    }

    // MARK: - Properties

    var dogManager: DogManager! = nil

    /// information for updating log, parentDogName, reminder?, knownLog
    var updatingKnownLogInformation: (String, Reminder?, KnownLog)?

    weak var delegate: LogsAddLogViewControllerDelegate! = nil

    private var initalParentDog: String! = nil
    private var initalCustomLogType: String?
    private var initalLogNote: String! = nil
    private var initalDate: Date! = nil

    var initalValuesChanged: Bool {
        // updating
        if updatingKnownLogInformation != nil {
            // not equal it inital
            if logType.text != updatingKnownLogInformation!.2.logType.rawValue {
                return true
            }
        }
        // new
        else {
            // starts blank by default
            if logType.text?.trimmingCharacters(in: .whitespaces) != "" {
                return true
            }
        }

        // not equal it inital
        if logType.text == KnownLogType.custom.rawValue && initalCustomLogType != customLogTypeTextField.text {
            return true
        }
        else if logNote.text != initalLogNote {
            return true
        }
        else if initalDate != logDate.date {
            return true
        }
        else if initalParentDog != parentDogName.text {
            return true
        }
        else {
            return false
        }
    }

    /// drop down for changing the parent dog name
    private let dropDownParentDogName = DropDownUIView()

    /// index path of selected parent dog name in drop down
    private var selectedParentDogIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    /// drop down for changing the log type
    private let dropDownLogType = DropDownUIView()

    /// index path of selected log type in drop down
    private var selectedLogTypeIndexPath: IndexPath?

    /// height of the cells in the drop down table view
    private var dropDownRowHeight: CGFloat = 40

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        guard dogManager != nil && dogManager.dogs.count != 0 else {
            if dogManager == nil {
                AppDelegate.generalLogger.fault("dogManager can't be nil for LogsAddLogViewController")
            }
            else if dogManager.dogs.count == 0 {
                AppDelegate.generalLogger.fault("dogManager has to have a dog for LogsAddLogViewController")
            }
            // self.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
            self.navigationController?.popViewController(animated: true)
            return
        }

        view.sendSubviewToBack(containerForAll)

        containerForAll.bringSubviewToFront(cancelAddLogButton)
        containerForAll.bringSubviewToFront(addLogButton)

        setupToHideKeyboardOnTapOnView()

        setupValues()

        setUpGestures()

        customLogTypeTextField.delegate = self

        logNote.delegate = self
        logNote.layer.borderWidth = 0.2
        // logNote.layer.borderColor = UIColor.lightGray.cgColor
        logNote.layer.borderColor = UIColor.systemGray2.cgColor
        logNote.layer.cornerRadius = 5.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDowns()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDownLogType.hideDropDown(removeFromSuperview: true)
        dropDownParentDogName.hideDropDown(removeFromSuperview: true)
    }

    /// Sets up gestureRecognizer for dog selector drop down
    private func setUpGestures() {
        // adding a log
        if updatingKnownLogInformation == nil {
            self.parentDogName.isUserInteractionEnabled = true
            let parentDogNameTapGesture = UITapGestureRecognizer(target: self, action: #selector(parentDogNameTapped))
            parentDogNameTapGesture.delegate = self
            parentDogNameTapGesture.cancelsTouchesInView = false
            self.parentDogName.addGestureRecognizer(parentDogNameTapGesture)

            self.logType.isUserInteractionEnabled = true
            let logTypeTapGesture = UITapGestureRecognizer(target: self, action: #selector(logTypeTapped))
            logTypeTapGesture.delegate = self
            logTypeTapGesture.cancelsTouchesInView = false
            self.logType.addGestureRecognizer(logTypeTapGesture)
        }
        // updating a rlog
        else {
            self.parentDogName.isUserInteractionEnabled = false
            self.parentDogName.isEnabled = false

            self.logType.isUserInteractionEnabled = true
            let logTypeTapGesture = UITapGestureRecognizer(target: self, action: #selector(logTypeTapped))
            logTypeTapGesture.delegate = self
            logTypeTapGesture.cancelsTouchesInView = false
            self.logType.addGestureRecognizer(logTypeTapGesture)
        }

        let dropDownHideTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAll))
        dropDownHideTap.delegate = self
        dropDownHideTap.cancelsTouchesInView = false
        containerForAll.addGestureRecognizer(dropDownHideTap)
    }

    @objc private func dismissAll() {
        self.dismissKeyboard()
        self.dropDownParentDogName.hideDropDown()
        self.dropDownLogType.hideDropDown()
    }

    @objc private func parentDogNameTapped() {
        self.dismissKeyboard()
        self.dropDownLogType.hideDropDown()

        var numDogToShow: CGFloat {
            if dogManager.dogs.count > 5 {
                return 5.5
            }
            else {
                return CGFloat(dogManager.dogs.count)
            }
        }
        self.dropDownParentDogName.showDropDown(height: self.dropDownRowHeight * CGFloat(numDogToShow))
    }

    @objc private func logTypeTapped() {
        self.dismissKeyboard()
        self.dropDownParentDogName.hideDropDown()

        self.dropDownLogType.showDropDown(height: self.dropDownRowHeight * 6.5)
    }

    /// Toggles visability of optional custom log type components, used for a custom name for it
    private func toggleCustomLogTypeName(isHidden: Bool) {
        if isHidden == false {
            for constraint in customLogTypeName.constraints where constraint.firstAttribute == .height {
                constraint.constant = 40.0
            }
            customLogTypeNameBottomConstraint.constant = 10.0
            customLogTypeName.isHidden = false
            customLogTypeTextField.isHidden = false
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
        else {
            for constraint in customLogTypeName.constraints where constraint.firstAttribute == .height {
                constraint.constant = 0.0
            }
            customLogTypeNameBottomConstraint.constant = 0.0
            customLogTypeName.isHidden = true
            customLogTypeTextField.isHidden = true
            self.containerForAll.setNeedsLayout()
            self.containerForAll.layoutIfNeeded()
        }
    }

    /// Sets up the values of different variables that is found out from information passed
    private func setupValues() {

        func setupInitalValues() {
            initalParentDog = parentDogName.text
            initalCustomLogType = customLogTypeTextField.text
            initalDate = logDate.date
            initalLogNote = logNote.text
        }

        // updating log
        if updatingKnownLogInformation != nil {
            pageTitle!.title = "Edit Log"
            trashIcon.isEnabled = true
            parentDogName.text = updatingKnownLogInformation!.0

            logType.text = updatingKnownLogInformation!.2.logType.rawValue
            logType.isEnabled = true
            customLogTypeTextField.text = updatingKnownLogInformation!.2.customTypeName
            // if == is true, that means it is custom, which means it shouldn't hide so ! reverses to input isHidden: false, reverse for if type is not custom. This is because this text input field is only used for custom types.
            toggleCustomLogTypeName(isHidden: !(updatingKnownLogInformation!.2.logType == .custom))

            selectedLogTypeIndexPath = IndexPath(row: KnownLogType.allCases.firstIndex(of: KnownLogType(rawValue: logType.text!)!)!, section: 0)

            logDate.date = updatingKnownLogInformation!.2.date
            logNote.text = updatingKnownLogInformation!.2.note

        }
        // not updating
        else {
            parentDogName.text = dogManager.dogs[0].dogTraits.dogName
            parentDogName.isEnabled = true

            trashIcon.isEnabled = false

            logType.text = ""
            logType.isEnabled = true

            customLogTypeTextField.text = ""
            initalCustomLogType = customLogTypeTextField.text

            toggleCustomLogTypeName(isHidden: true)

            selectedLogTypeIndexPath = nil

            // logDate.date = Date.roundDate(targetDate: Date(), roundingInterval: 60.0*1, roundingMethod: .up)
            logDate.date = Date()
        }

        setupInitalValues()

    }

    // MARK: - Drop Down Functions

    private func setUpDropDowns() {
        dropDownParentDogName.DropDownUIViewIdentifier = "dropDownParentDogName"
        dropDownParentDogName.cellReusableIdentifier = "dropDownCell"
        dropDownParentDogName.DropDownUIViewDataSourceProtocol = self
        dropDownParentDogName.setUpDropDown(viewPositionReference: parentDogName.frame, offset: 2.0)
        dropDownParentDogName.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDownParentDogName.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDownParentDogName)

        dropDownLogType.DropDownUIViewIdentifier = "dropDownLogType"
        dropDownLogType.cellReusableIdentifier = "dropDownCell"
        dropDownLogType.DropDownUIViewDataSourceProtocol = self
        dropDownLogType.setUpDropDown(viewPositionReference: logType.frame, offset: 2.0)
        dropDownLogType.nib = UINib(nibName: "DropDownDefaultTableViewCell", bundle: nil)
        dropDownLogType.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDownLogType)
    }

}
