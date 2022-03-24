//
//  DogsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsTableViewControllerDelegate: AnyObject {
    func willOpenEditDog(dogId: Int)
    func willOpenEditReminder(parentDogId: Int, reminderId: Int?)
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
    func logReminderAnimation()
    func unlogReminderAnimation()
}

class DogsTableViewController: UITableViewController, DogManagerControlFlowProtocol, DogsReminderDisplayTableViewCellDelegate {
    
    // MARK: - DogsReminderDisplayTableViewCellDelegate
    
    func didUpdateReminderEnable(sender: Sender, parentDogId: Int, reminder: Reminder) {
        let sudoDogManager = getDogManager()
        try! sudoDogManager.findDog(forDogId: parentDogId).dogReminders.findReminder(forReminderId: reminder.reminderId).isEnabled = reminder.isEnabled
        setDogManager(sender: sender, newDogManager: sudoDogManager)
        
        // This is so the cell animates the changing of the switch properly, if this code wasnt implemented then when the table view is reloaded a new batch of cells is produced and that cell has the new switch state, bypassing the animation as the instantant the old one is switched it produces and shows the new switch
        // let indexPath = try! IndexPath(row: getDogManager().findDog(forDogId: parentDogName).dogReminders.findIndex(forReminderId: reminderId)+1, section: getDogManager().findIndex(forDogId: parentDogName))
        
        // let cell = tableView.cellForRow(at: indexPath) as! DogsReminderDisplayTableViewCell
        // cell.reloadCell()
        // cell.reminderToggleSwitch.isOn = !isEnabled
        // cell.reminderToggleSwitch.setOn(isEnabled, animated: true)
    }

    // MARK: - DogManagerControlFlowProtocol

    private var dogManager: DogManager = DogManager()

    func getDogManager() -> DogManager {
        return dogManager
    }

    func setDogManager(sender: Sender, newDogManager: DogManager) {
        dogManager = newDogManager

        // possible senders
        // DogsReminderTableViewCell
        // DogsDogDisplayTableViewCell
        // DogsViewController
        if !(sender.localized is DogsViewController) {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        if !(sender.localized is DogsReminderDisplayTableViewCell) && !(sender.origin is DogsTableViewController) {
            self.updateDogManagerDependents()
        }
        if sender.localized is DogsReminderDisplayTableViewCell {
            self.reloadVisibleCellsTimeLeftLabel()
        }

        // start up loop timer, normally done in view will appear but sometimes view has appeared and doesn't need a loop but then it can get a dogManager update which requires a loop. This happens due to reminder added in DogsIntroduction page.
        if viewIsBeingViewed == true && loopTimer == nil {
            guard  getDogManager().hasEnabledReminder else {
                return
            }
            loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.loopReload), userInfo: nil, repeats: true)

            RunLoop.main.add(loopTimer!, forMode: .default)
        }

        reloadTableConstraints()
    }

    private func reloadTableConstraints() {
        if getDogManager().dogs.count > 0 {
            tableView.allowsSelection = true
            self.tableView.rowHeight = -1.0
        }
        else {
            tableView.allowsSelection = false
            self.tableView.rowHeight = 65.5
        }
    }

    // Updates different visual aspects to reflect data change of dogManager
    func updateDogManagerDependents() {
        self.reloadTable()
    }

    // MARK: - Properties

    weak var delegate: DogsTableViewControllerDelegate! = nil

    var updatingSwitch: Bool = false

    private var loopTimer: Timer?

    // MARK: - Main

    override func viewDidLoad() {
        self.dogManager = MainTabBarViewController.staticDogManager
        super.viewDidLoad()

        if getDogManager().dogs.count == 0 {
            tableView.allowsSelection = false
        }

        tableView.separatorInset = UIEdgeInsets.zero
        // allow for refreshing of the information from the server
        self.tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
    }

    private var viewIsBeingViewed: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewIsBeingViewed = true

        self.reloadTable()

        if getDogManager().hasEnabledReminder {
            loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.loopReload), userInfo: nil, repeats: true)

            RunLoop.main.add(loopTimer!, forMode: .default)
        }

    }
    
    /// Makes a query to the server to retrieve new information then refreshed the tableView
    @objc private func refreshTableData() {
        RequestUtils.getDogManager { dogManager in
            // end refresh first otherwise there will be a weird visual issue
            self.tableView.refreshControl?.endRefreshing()
            if dogManager != nil {
                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager!)
                // manually reload table as the self sernder doesn't do that
                self.reloadTable()
            }
        }
    }

    private func reloadTable() {
        self.tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewIsBeingViewed = false

        if loopTimer != nil {
            loopTimer!.invalidate()
            loopTimer = nil
        }
    }

    @objc private func loopReload() {
        if tableView.visibleCells.count == 0 {
            if loopTimer != nil {
                loopTimer!.invalidate()
                loopTimer = nil
            }
        }
        else {
            reloadVisibleCellsTimeLeftLabel()
        }
    }

    private func reloadVisibleCellsTimeLeftLabel() {
        for cell in tableView.visibleCells {
            if cell is DogsDogDisplayTableViewCell {
                let sudoCell = cell as! DogsDogDisplayTableViewCell
                sudoCell.reloadCell()
            }
            else {
                let sudoCell = cell as! DogsReminderDisplayTableViewCell
                sudoCell.reloadCell()
            }
        }
    }

    /// Shows action sheet of possible optiosn to do to dog
    private func willShowDogActionSheet(forCell cell: DogsDogDisplayTableViewCell, forIndexPath indexPath: IndexPath) {
        // properties
        let sudoDogManager = self.getDogManager()
        let dog: Dog = cell.dog
        let dogName = dog.dogName
        let dogId = dog.dogId
        let section = try! self.dogManager.findIndex(forDogId: dogId)
        
        let alertController = GeneralUIAlertController(title: "You Selected: \(dogName)", message: nil, preferredStyle: .actionSheet)

        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let alertActionAdd = UIAlertAction(title: "Add Reminder", style: .default) { _ in
            self.delegate.willOpenEditReminder(parentDogId: dogId, reminderId: nil)
        }

        /*
        var hasEnabledReminder: Bool {
            for reminder in dog.dogReminders.reminders where reminder.isEnabled == true {
                return true
            }

            return false
        }

        var enableStatusString: String {
            if hasEnabledReminder == true {
                return "Disable Reminders"
            }
            else {
                return "Enable Reminders"
            }
        }

        let alertActionDisable = UIAlertAction(
            title: enableStatusString,
            style: .default,
            handler: { (_: UIAlertAction!)  in

                // disabling all reminders
                if hasEnabledReminder == true {
                    for reminder in dog.dogReminders.reminders {

                        reminder.isEnabled = false

                        let reminderCell = self.tableView.cellForRow(
                            at: IndexPath(
                                row: try! dog.dogReminders.findIndex(forReminderId: reminder.reminderId)+1,
                                section: section))
                        as! DogsReminderDisplayTableViewCell

                        reminderCell.reminderToggleSwitch.setOn(false, animated: true)
                    }

                }
                // enabling all
                else {
                    for reminder in dog.dogReminders.reminders {
                        reminder.isEnabled = true

                        let reminderCell = self.tableView.cellForRow(at:
                                                                        IndexPath(
                                                                            row: try! dog.dogReminders.findIndex(forReminderId: reminder.reminderId)+1,
                                                                            section: try! self.dogManager.findIndex(forDogId: dogId)))
                        as! DogsReminderDisplayTableViewCell

                        reminderCell.reminderToggleSwitch.setOn(true, animated: true)
                    }
                }

                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                // self.reloadTable()
            })
         */

        let alertActionEdit = UIAlertAction(
            title: "Edit Dog",
            style: .default,
            handler: { (_: UIAlertAction!)  in
                self.delegate.willOpenEditDog(dogId: dogId)
            })

        let alertActionRemove = UIAlertAction(title: "Delete Dog", style: .destructive) { (alert) in

            // REMOVE CONFIRMATION
            let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogName)?", message: nil, preferredStyle: .alert)

            let removeDogConfirmationRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                DogsRequest.delete(forDogId: dogId) { requestWasSuccessful in
                    DispatchQueue.main.async {
                        if requestWasSuccessful == true {
                            try! sudoDogManager.removeDog(forDogId: dogId)
                            self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                            self.tableView.deleteSections([section], with: .automatic)
                        }
                    }
                }
            }

            let removeDogConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            removeDogConfirmation.addAction(removeDogConfirmationRemove)
            removeDogConfirmation.addAction(removeDogConfirmationCancel)

            AlertManager.shared.enqueueAlertForPresentation(removeDogConfirmation)
        }

        alertController.addAction(alertActionAdd)

        alertController.addAction(alertActionEdit)

        // if dog.dogReminders.reminders.count != 0 {
        //    alertController.addAction(alertActionDisable)
        // }

        alertController.addAction(alertActionRemove)

        alertController.addAction(alertActionCancel)

        AlertManager.shared.enqueueActionSheetForPresentation(alertController, sourceView: cell, permittedArrowDirections: [.up, .down])
    }

    /// Called when a reminder is clicked by the user, display an action sheet of possible modifcations to the alarm/reminder.
    private func willShowReminderActionSheet(forCell cell: DogsReminderDisplayTableViewCell, forIndexPath indexPath: IndexPath) {
        let sudoDogManager = self.getDogManager()
        let dog: Dog = try! sudoDogManager.findDog(forDogId: cell.parentDogId)
        let reminder: Reminder = cell.reminder
       
        let selectedReminderAlertController = GeneralUIAlertController(title: "You Selected: \(reminder.displayTypeName) for \(dog.dogName)", message: nil, preferredStyle: .actionSheet)

        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let alertActionEdit = UIAlertAction(title: "Edit Reminder", style: .default) { _ in
            self.delegate.willOpenEditReminder(parentDogId: cell.parentDogId, reminderId: reminder.reminderId)
        }

        // REMOVE BUTTON
        let alertActionRemove = UIAlertAction(title: "Delete Reminder", style: .destructive) { (_) in

            // REMOVE CONFIRMATION
            let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(reminder.displayTypeName)?", message: nil, preferredStyle: .alert)

            let removeReminderConfirmationRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                RemindersRequest.delete(forDogId: dog.dogId, forReminderId: reminder.reminderId) { requestWasSuccessful in
                    DispatchQueue.main.async {
                        if requestWasSuccessful == true {
                            try! dog.dogReminders.removeReminder(forReminderId: reminder.reminderId)
                            self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)

                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
                
            }

            let removeReminderConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            removeReminderConfirmation.addAction(removeReminderConfirmationRemove)
            removeReminderConfirmation.addAction(removeReminderConfirmationCancel)

            AlertManager.shared.enqueueAlertForPresentation(removeReminderConfirmation)

        }

        // DETERMINES IF ITS A LOG BUTTON OR UNDO LOG BUTTON
        var shouldUndoLog: Bool {
            // Yes I know these if statements are redundent and terrible coding but it's whatever, used to do something different but has to modify
            if reminder.currentReminderMode == .snooze || reminder.currentReminderMode == .countdown {
                return false
            }
            else {
                if reminder.reminderType == .weekly && reminder.weeklyComponents.isSkipping == true {
                    return true
                }
                else if reminder.reminderType == .monthly && reminder.monthlyComponents.isSkipping == true {
                    return true
                }
                else {
                    return false
                }
            }
        }

        // STORES LOG BUTTON(S)
        var alertActionsForLog: [UIAlertAction] = []

        // ADD LOG BUTTONS (MULTIPLE IF POTTY OR OTHER SPECIAL CASE)
        if shouldUndoLog == true {
            let alertActionLog = UIAlertAction(
                title: "Undo Log for \(reminder.displayTypeName)",
                style: .default,
                handler: { (_: UIAlertAction!)  in
                    // logType not needed as unskipping alarm does not require that component
                    AlarmManager.willResetTimer(
                        sender: Sender(origin: self, localized: self),
                        dogId: dog.dogId, reminderId: reminder.reminderId, logType: nil)
                    self.delegate.unlogReminderAnimation()

                })
            alertActionsForLog.append(alertActionLog)
        }
        else {
            switch reminder.reminderAction {
            case .potty:
                let pottyKnownTypes: [LogType] = [.pee, .poo, .both, .neither, .accident]
                for pottyKnownType in pottyKnownTypes {
                    let alertActionLog = UIAlertAction(
                        title: "Log \(pottyKnownType.rawValue)",
                        style: .default,
                        handler: { (_)  in
                            // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                            AlarmManager.willResetTimer(sender: Sender(origin: self, localized: self), dogId: dog.dogId, reminderId: reminder.reminderId, logType: pottyKnownType)
                            self.delegate.logReminderAnimation()
                        })
                    alertActionsForLog.append(alertActionLog)
                }
            default:
                let alertActionLog = UIAlertAction(
                    title: "Log \(reminder.displayTypeName)",
                    style: .default,
                    handler: { (_)  in
                        // Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                        AlarmManager.willResetTimer(sender: Sender(origin: self, localized: self), dogId: dog.dogId, reminderId: reminder.reminderId, logType: LogType(rawValue: reminder.reminderAction.rawValue)!)
                        self.delegate.logReminderAnimation()
                    })
                alertActionsForLog.append(alertActionLog)
            }
        }

        if reminder.isEnabled == true {
            for alertActionLog in alertActionsForLog {
                selectedReminderAlertController.addAction(alertActionLog)
            }
        }

        selectedReminderAlertController.addAction(alertActionEdit)

        selectedReminderAlertController.addAction(alertActionRemove)

        selectedReminderAlertController.addAction(alertActionCancel)

        AlertManager.shared.enqueueActionSheetForPresentation(selectedReminderAlertController, sourceView: cell, permittedArrowDirections: [.up, .down])

    }

    // MARK: Table View Management

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // if getDogManager().dogs.count == 0 {
        //    return 1
        // }
        return getDogManager().dogs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getDogManager().dogs.count == 0 {
            return 1
        }

        return getDogManager().dogs[section].dogReminders.reminders.count+1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsDogDisplayTableViewCell", for: indexPath)

            let customCell = cell as! DogsDogDisplayTableViewCell
            customCell.setup(forDog: getDogManager().dogs[indexPath.section])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsReminderDisplayTableViewCell", for: indexPath)

            let customCell = cell as! DogsReminderDisplayTableViewCell
            customCell.setup(parentDogId: getDogManager().dogs[indexPath.section].dogId,
                             forReminder: getDogManager().dogs[indexPath.section].dogReminders.reminders[indexPath.row-1])
            customCell.delegate = self
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if getDogManager().dogs.count > 0 {
            if indexPath.row == 0 {
                willShowDogActionSheet(forCell: tableView.cellForRow(at: indexPath)! as! DogsDogDisplayTableViewCell, forIndexPath: indexPath)
            }
            else if indexPath.row > 0 {
                willShowReminderActionSheet(forCell: tableView.cellForRow(at: indexPath)! as! DogsReminderDisplayTableViewCell, forIndexPath: indexPath)
            }

        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && getDogManager().dogs.count > 0 {
            let removeConfirmation: GeneralUIAlertController!
            let sudoDogManager = getDogManager()
            // delete reminder
            if indexPath.row > 0 {
                // cell in question
                let reminderCell = tableView.cellForRow(at: indexPath) as! DogsReminderDisplayTableViewCell
                let dogId: Int = reminderCell.parentDogId
                let dog: Dog = try! sudoDogManager.findDog(forDogId: dogId)
                let reminder: Reminder = reminderCell.reminder

                removeConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(reminder.displayTypeName)?", message: nil, preferredStyle: .alert)

                let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    // query server
                    
                    RemindersRequest.delete(forDogId: dogId, forReminderId: reminder.reminderId) { requestWasSuccessful in
                        DispatchQueue.main.async {
                            if requestWasSuccessful == true {
                                try! dog.dogReminders.removeReminder(forReminderId: reminder.reminderId)
                                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            }
                        }
                    }

                }
                let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                removeConfirmation.addAction(alertActionRemove)
                removeConfirmation.addAction(alertActionCancel)
            }
            // delete dog
            else {
                // cell in question
                let dogCell = tableView.cellForRow(at: indexPath) as! DogsDogDisplayTableViewCell
                let dogId: Int = dogCell.dog.dogId

                removeConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogCell.dog.dogName)?", message: nil, preferredStyle: .alert)

                let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    DogsRequest.delete(forDogId: dogId) { requestWasSuccessful in
                        DispatchQueue.main.async {
                            if requestWasSuccessful == true {
                                try! sudoDogManager.removeDog(forDogId: dogId)
                                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                                self.tableView.deleteSections([indexPath.section], with: .automatic)
                            }
                        }
                    }

                }
                let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                removeConfirmation.addAction(alertActionRemove)
                removeConfirmation.addAction(alertActionCancel)
            }
            AlertManager.shared.enqueueAlertForPresentation(removeConfirmation)

        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.getDogManager().dogs.count == 0 {
            return false
        }
        else {
            return true
        }
    }

}
