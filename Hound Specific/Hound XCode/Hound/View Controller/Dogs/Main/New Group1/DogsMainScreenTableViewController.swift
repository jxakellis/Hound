//
//  DogsMainScreenTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewControllerDelegate{
    func willEditDog(dogName: String)
    func willEditReminder(parentDogName: String, reminderUUID: String?)
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
    func didLogReminder()
    func didUnlogReminder()
}

class DogsMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol, DogsMainScreenTableViewCellReminderDisplayDelegate {
    
    //MARK: - DogsMainScreenTableViewCellReminderDelegate
    
    ///Reminder switch is toggled in DogsMainScreenTableViewCellReminder
    func didToggleReminderSwitch(sender: Sender, parentDogName: String, reminderUUID: String, isEnabled: Bool) {
        
        let sudoDogManager = getDogManager()
        try! sudoDogManager.findDog(forName: parentDogName).dogReminders.findReminder(forUUID: reminderUUID).setEnable(newEnableStatus: isEnabled)
        
        setDogManager(sender: sender, newDogManager: sudoDogManager)
        
        //This is so the cell animates the changing of the switch properly, if this code wasnt implemented then when the table view is reloaded a new batch of cells is produced and that cell has the new switch state, bypassing the animation as the instantant the old one is switched it produces and shows the new switch
        //let indexPath = try! IndexPath(row: getDogManager().findDog(forName: parentDogName).dogReminders.findIndex(forUUID: reminderUUID)+1, section: getDogManager().findIndex(forName: parentDogName))
        
       //let cell = tableView.cellForRow(at: indexPath) as! DogsMainScreenTableViewCellReminderDisplay
        //cell.reloadCell()
        //cell.reminderToggleSwitch.isOn = !isEnabled
        //cell.reminderToggleSwitch.setOn(isEnabled, animated: true)
    }
    
    //MARK: - DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager){
        dogManager = newDogManager
        
        //possible senders
        //DogsReminderTableViewCell
        //DogsMainScreenTableViewCellDogDisplay
        //DogsViewController
        if !(sender.localized is DogsViewController){
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        if !(sender.localized is DogsMainScreenTableViewCellReminderDisplay) && !(sender.origin is DogsMainScreenTableViewController){
            self.updateDogManagerDependents()
        }
        if sender.localized is DogsMainScreenTableViewCellReminderDisplay {
            self.reloadVisibleCellsTimeLeftLabel()
        }
        
        //start up loop timer, normally done in view will appear but sometimes view has appeared and doesn't need a loop but then it can get a dogManager update which requires a loop. This happens due to reminder added in DogsIntroduction page.
        if viewIsBeingViewed == true && loopTimer == nil {
            guard  getDogManager().hasEnabledReminder else {
                return
            }
            loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.loopReload), userInfo: nil, repeats: true)
            
            RunLoop.main.add(loopTimer!, forMode: .default)
        }
        
        reloadTableConstraints()
    }
    
    private func reloadTableConstraints(){
        if getDogManager().dogs.count > 0 {
            tableView.allowsSelection = true
            self.tableView.rowHeight = -1.0
        }
        else{
            tableView.allowsSelection = false
            self.tableView.rowHeight = 65.5
        }
    }
    
    //Updates different visual aspects to reflect data change of dogManager
    func updateDogManagerDependents(){
        self.reloadTable()
    }
    
    //MARK: - Properties
    
    var delegate: DogsMainScreenTableViewControllerDelegate! = nil
    
    var updatingSwitch: Bool = false
    
    private var loopTimer: Timer?
    
    
    //MARK: - Main
    
    override func viewDidLoad() {
        self.dogManager = MainTabBarViewController.staticDogManager
        super.viewDidLoad()
        
        if getDogManager().dogs.count == 0 {
            tableView.allowsSelection = false
        }
        
        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    private var viewIsBeingViewed: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewIsBeingViewed = true
        
        self.reloadTable()
        
        if getDogManager().hasEnabledReminder{
            loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.loopReload), userInfo: nil, repeats: true)
            
            RunLoop.main.add(loopTimer!, forMode: .default)
        }
        
    }
    
    private func reloadTable(){
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewIsBeingViewed = false
        
        if loopTimer != nil {
            loopTimer!.invalidate()
            loopTimer = nil
        }
    }
    
    @objc private func loopReload(){
        if tableView.visibleCells.count == 0 {
            if loopTimer != nil {
                loopTimer!.invalidate()
                loopTimer = nil
            }
        }
        else{
            reloadVisibleCellsTimeLeftLabel()
        }
    }
    
    private func reloadVisibleCellsTimeLeftLabel(){
        for cell in tableView.visibleCells{
            if cell is DogsMainScreenTableViewCellDogDisplay{
                let sudoCell = cell as! DogsMainScreenTableViewCellDogDisplay
                sudoCell.reloadCell()
            }
            else {
                let sudoCell = cell as! DogsMainScreenTableViewCellReminderDisplay
                sudoCell.reloadCell()
            }
        }
    }
    
    ///Shows action sheet of possible optiosn to do to dog
    private func willShowDogActionSheet(sender: UIView, dogName: String){
        let alertController = GeneralUIAlertController(title: "You Selected: \(dogName)", message: nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        let sudoDogManager = self.getDogManager()
        let dog = try! sudoDogManager.findDog(forName: dogName)
        let section = try! self.dogManager.findIndex(forName: dogName)
        
        let alertActionAdd = UIAlertAction(title: "Add Reminder", style: .default) { UIAlertAction in
            self.delegate.willEditReminder(parentDogName: dog.dogTraits.dogName, reminderUUID: nil)
        }
        
        var hasEnabledReminder: Bool {
            for reminder in dog.dogReminders.reminders{
                if reminder.getEnable() == true {
                    return true
                }
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
            handler:
                {
                    (alert: UIAlertAction!)  in
                    
                    //disabling all
                    if hasEnabledReminder == true {
                        for reminder in dog.dogReminders.reminders{
                            reminder.setEnable(newEnableStatus: false)
                            
                            let reminderCell = self.tableView.cellForRow(at: IndexPath(row: try! dog.dogReminders.findIndex(forUUID: reminder.uuid)+1, section: section)) as! DogsMainScreenTableViewCellReminderDisplay
                            reminderCell.reminderToggleSwitch.setOn(false, animated: true)
                        }
                        
                        
                    }
                    //enabling all
                    else {
                        for reminder in dog.dogReminders.reminders{
                            reminder.setEnable(newEnableStatus: true)
                            
                            let reminderCell = self.tableView.cellForRow(at: IndexPath(row: try! dog.dogReminders.findIndex(forUUID: reminder.uuid)+1, section: try! self.dogManager.findIndex(forName: dogName))) as! DogsMainScreenTableViewCellReminderDisplay
                            reminderCell.reminderToggleSwitch.setOn(true, animated: true)
                        }
                    }
                    
                    self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                    //self.reloadTable()
                })
        
        let alertActionEdit = UIAlertAction(
        title: "Edit Dog",
        style: .default,
        handler:
            {
                (alert: UIAlertAction!)  in
                self.delegate.willEditDog(dogName: dogName)
            })
        
        let alertActionRemove = UIAlertAction(title: "Delete Dog", style: .destructive) { (alert) in
            
            //REMOVE CONFIRMATION
            let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogName)?", message: nil, preferredStyle: .alert)
            
            let removeDogConfirmationRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                try! sudoDogManager.removeDog(forName: dogName)
                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                self.tableView.deleteSections([section], with: .automatic)
            }
            
            let removeDogConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            removeDogConfirmation.addAction(removeDogConfirmationRemove)
            removeDogConfirmation.addAction(removeDogConfirmationCancel)

            AlertManager.shared.enqueueAlertForPresentation(removeDogConfirmation)
        }
        
        alertController.addAction(alertActionAdd)
        
        alertController.addAction(alertActionEdit)
        
        if dog.dogReminders.reminders.count != 0 {
            alertController.addAction(alertActionDisable)
        }
        
        alertController.addAction(alertActionRemove)
        
        alertController.addAction(alertActionCancel)
        
        AlertManager.shared.enqueueActionSheetForPresentation(alertController, sourceView: sender, permittedArrowDirections: [.up,.down])
    }
    
    ///Called when a reminder is clicked by the user, display an action sheet of possible modifcations to the alarm/reminder.
    private func willShowReminderActionSheet(sender: UIView, parentDogName: String, reminder: Reminder){
        
        let selectedReminderAlertController = GeneralUIAlertController(title: "You Selected: \(reminder.displayTypeName) for \(parentDogName)", message: nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        let alertActionEdit = UIAlertAction(title: "Edit Reminder", style: .default) { _ in
            self.delegate.willEditReminder(parentDogName: parentDogName, reminderUUID: reminder.uuid)
        }
        
        //REMOVE BUTTON
        let alertActionRemove = UIAlertAction(title: "Delete Reminder", style: .destructive) { (action) in
            
            //REMOVE CONFIRMATION
            let removeReminderConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(reminder.displayTypeName)?", message: nil, preferredStyle: .alert)
            
            let removeReminderConfirmationRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                let sudoDogManager = self.getDogManager()
                let dog = try! sudoDogManager.findDog(forName: parentDogName)
                let indexPath = IndexPath(row: try! dog.dogReminders.findIndex(forUUID: reminder.uuid)+1, section: try! sudoDogManager.findIndex(forName: parentDogName))
                
                try! dog.dogReminders.removeReminder(forUUID: reminder.uuid)
                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            let removeReminderConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            removeReminderConfirmation.addAction(removeReminderConfirmationRemove)
            removeReminderConfirmation.addAction(removeReminderConfirmationCancel)

            AlertManager.shared.enqueueAlertForPresentation(removeReminderConfirmation)
            
            
        }
        
        //DETERMINES IF ITS A LOG BUTTON OR UNDO LOG BUTTON
        var shouldUndoLog: Bool {
            //Yes I know these if statements are redundent and terrible coding but it's whatever, used to do something different but has to modify
            if reminder.timerMode == .snooze || reminder.timerMode == .countDown {
                return false
            }
            else {
                if reminder.timeOfDayComponents.isSkipping == true {
                    return true
                }
                else {
                    return false
                }
            }
        }
        
        //STORES LOG BUTTON(S)
        var alertActionsForLog: [UIAlertAction] = []
        
        //ADD LOG BUTTONS (MULTIPLE IF POTTY OR OTHER SPECIAL CASE)
        if shouldUndoLog == true {
            let alertActionLog = UIAlertAction(
                title: "Undo Log for \(reminder.displayTypeName)",
            style: .default,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //knownLogType not needed as unskipping alarm does not require that component
                    TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, reminderUUID: reminder.uuid, knownLogType: nil)
                    self.delegate.didUnlogReminder()
                    
                })
            alertActionsForLog.append(alertActionLog)
        }
        else {
            switch reminder.reminderType {
            case .potty:
                let pottyKnownTypes: [KnownLogType] = [.pee, .poo, .both, .neither, .accident]
                for pottyKnownType in pottyKnownTypes {
                    let alertActionLog = UIAlertAction(
                        title:"Log \(pottyKnownType.rawValue)",
                        style: .default,
                        handler:
                            {
                                (_)  in
                                //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                                TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, reminderUUID: reminder.uuid, knownLogType: pottyKnownType)
                                self.delegate.didLogReminder()
                            })
                    alertActionsForLog.append(alertActionLog)
                }
            default:
                let alertActionLog = UIAlertAction(
                    title:"Log \(reminder.displayTypeName)",
                    style: .default,
                    handler:
                        {
                            (_)  in
                            //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                            TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, reminderUUID: reminder.uuid, knownLogType: KnownLogType(rawValue: reminder.reminderType.rawValue)!)
                            self.delegate.didLogReminder()
                        })
                alertActionsForLog.append(alertActionLog)
            }
        }
        
        if reminder.getEnable() == true {
            for alertActionLog in alertActionsForLog{
                selectedReminderAlertController.addAction(alertActionLog)
            }
        }
        
        selectedReminderAlertController.addAction(alertActionEdit)
        
        selectedReminderAlertController.addAction(alertActionRemove)
        
        selectedReminderAlertController.addAction(alertActionCancel)
        
        AlertManager.shared.enqueueActionSheetForPresentation(selectedReminderAlertController, sourceView: sender, permittedArrowDirections: [.up,.down])
        
    }
    
    
    // MARK: Table View Management
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //if getDogManager().dogs.count == 0 {
        //    return 1
        //}
        return getDogManager().dogs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getDogManager().dogs.count == 0 {
            return 1
        }
        
        return getDogManager().dogs[section].dogReminders.reminders.count+1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsMainScreenTableViewCellDogDisplay", for: indexPath)
            
            let customCell = cell as! DogsMainScreenTableViewCellDogDisplay
            customCell.setup(dogPassed: getDogManager().dogs[indexPath.section])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsMainScreenTableViewCellReminderDisplay", for: indexPath)
            
            let customCell = cell as! DogsMainScreenTableViewCellReminderDisplay
            customCell.setup(parentDogName: getDogManager().dogs[indexPath.section].dogTraits.dogName, reminderPassed: getDogManager().dogs[indexPath.section].dogReminders.reminders[indexPath.row-1])
            customCell.delegate = self
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if getDogManager().dogs.count > 0 {
            let dog = getDogManager().dogs[indexPath.section]
            if indexPath.row == 0{
                willShowDogActionSheet(sender: tableView.cellForRow(at: indexPath)!, dogName: dog.dogTraits.dogName)
            }
            else if indexPath.row > 0 {
                
                willShowReminderActionSheet(sender: tableView.cellForRow(at: indexPath)!, parentDogName: dog.dogTraits.dogName, reminder: dog.dogReminders.reminders[indexPath.row-1])
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && getDogManager().dogs.count > 0 {
            let removeConfirmation: GeneralUIAlertController!
            let sudoDogManager = getDogManager()
            if indexPath.row > 0 {
                removeConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(sudoDogManager.dogs[indexPath.section].dogReminders.reminders[indexPath.row-1].displayTypeName)?", message: nil, preferredStyle: .alert)
                
                let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    sudoDogManager.dogs[indexPath.section].dogReminders.removeReminder(forIndex: indexPath.row-1)
                    self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                removeConfirmation.addAction(alertActionRemove)
                removeConfirmation.addAction(alertActionCancel)
            }
            else {
                removeConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(sudoDogManager.dogs[indexPath.section].dogTraits.dogName)?", message: nil, preferredStyle: .alert)
                
                let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    sudoDogManager.removeDog(forIndex: indexPath.section)
                    self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                    self.tableView.deleteSections([indexPath.section], with: .automatic)
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
