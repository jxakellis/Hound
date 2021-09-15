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
    func willEditRequirement(parentDogName: String, requirementUUID: String?)
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
    func didLogReminder()
    func didUnlogReminder()
}

class DogsMainScreenTableViewController: UITableViewController, DogManagerControlFlowProtocol, DogsMainScreenTableViewCellRequirementDisplayDelegate {
    
    //MARK: - DogsMainScreenTableViewCellRequirementDelegate
    
    ///Requirement switch is toggled in DogsMainScreenTableViewCellRequirement
    func didToggleRequirementSwitch(sender: Sender, parentDogName: String, requirementUUID: String, isEnabled: Bool) {
        
        let sudoDogManager = getDogManager()
        try! sudoDogManager.findDog(dogName: parentDogName).dogRequirments.findRequirement(forUUID: requirementUUID).setEnable(newEnableStatus: isEnabled)
        
        setDogManager(sender: sender, newDogManager: sudoDogManager)
        
        //This is so the cell animates the changing of the switch properly, if this code wasnt implemented then when the table view is reloaded a new batch of cells is produced and that cell has the new switch state, bypassing the animation as the instantant the old one is switched it produces and shows the new switch
        let indexPath = try! IndexPath(row: getDogManager().findDog(dogName: parentDogName).dogRequirments.findIndex(forUUID: requirementUUID)+1, section: getDogManager().findIndex(dogName: parentDogName))
        
        let cell = tableView.cellForRow(at: indexPath) as! DogsMainScreenTableViewCellRequirementDisplay
        cell.requirementToggleSwitch.isOn = !isEnabled
        cell.requirementToggleSwitch.setOn(isEnabled, animated: true)
    }
    
    //MARK: - DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager){
        dogManager = newDogManager
        
        //possible senders
        //DogsRequirementTableViewCell
        //DogsMainScreenTableViewCellDogDisplay
        //DogsViewController
        if !(sender.localized is DogsViewController){
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        if !(sender.origin is DogsMainScreenTableViewController){
            self.updateDogManagerDependents()
        }
        
        //start up loop timer, normally done in view will appear but sometimes view has appeared and doesn't need a loop but then it can get a dogManager update which requires a loop. This happens due to requirement added in DogsIntroduction page.
        if viewIsBeingViewed == true && loopTimer == nil {
            guard  getDogManager().hasEnabledDog && getDogManager().hasEnabledRequirement else {
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
        
        if getDogManager().hasEnabledDog && getDogManager().hasEnabledRequirement{
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
            for cell in tableView.visibleCells{
                if cell is DogsMainScreenTableViewCellDogDisplay{
                    let sudoCell = cell as! DogsMainScreenTableViewCellDogDisplay
                    sudoCell.reloadCell()
                }
                else {
                    let sudoCell = cell as! DogsMainScreenTableViewCellRequirementDisplay
                    sudoCell.reloadCell()
                }
            }
        }
    }
    
    ///Shows action sheet of possible optiosn to do to dog
    private func willShowDogActionSheet(sender: UIView, dogName: String){
        let alertController = GeneralUIAlertController(title: "You Selected: \(dogName)", message: nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        var sudoDogManager = self.getDogManager()
        let dog = try! sudoDogManager.findDog(dogName: dogName)
        let section = try! self.dogManager.findIndex(dogName: dogName)
        
        let alertActionAdd = UIAlertAction(title: "Add Reminder", style: .default) { UIAlertAction in
            self.delegate.willEditRequirement(parentDogName: dog.dogTraits.dogName, requirementUUID: nil)
        }
        
        var hasEnabledReminder: Bool {
            for requirement in dog.dogRequirments.requirements{
                if requirement.getEnable() == true {
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
                        for requirement in dog.dogRequirments.requirements{
                            requirement.setEnable(newEnableStatus: false)
                            
                            let requirementCell = self.tableView.cellForRow(at: IndexPath(row: try! dog.dogRequirments.findIndex(forUUID: requirement.uuid)+1, section: section)) as! DogsMainScreenTableViewCellRequirementDisplay
                            requirementCell.requirementToggleSwitch.setOn(false, animated: true)
                        }
                        
                        
                    }
                    //enabling all
                    else {
                        for requirement in dog.dogRequirments.requirements{
                            requirement.setEnable(newEnableStatus: true)
                            
                            let requirementCell = self.tableView.cellForRow(at: IndexPath(row: try! dog.dogRequirments.findIndex(forUUID: requirement.uuid)+1, section: try! self.dogManager.findIndex(dogName: dogName))) as! DogsMainScreenTableViewCellRequirementDisplay
                            requirementCell.requirementToggleSwitch.setOn(true, animated: true)
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
        
        let alertActionDelete = UIAlertAction(title: "Delete Dog", style: .destructive) { (alert) in
            
            //DELETE CONFIRMATION
            let deleteDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogName)?", message: nil, preferredStyle: .alert)
            
            let deleteDogConfirmationDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
                try! sudoDogManager.removeDog(name: dogName)
                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                self.tableView.deleteSections([section], with: .automatic)
            }
            
            let deleteDogConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            deleteDogConfirmation.addAction(deleteDogConfirmationDelete)
            deleteDogConfirmation.addAction(deleteDogConfirmationCancel)

            AlertPresenter.shared.enqueueAlertForPresentation(deleteDogConfirmation)
        }
        
        alertController.addAction(alertActionAdd)
        
        alertController.addAction(alertActionEdit)
        
        if dog.dogRequirments.requirements.count != 0 {
            alertController.addAction(alertActionDisable)
        }
        
        alertController.addAction(alertActionDelete)
        
        alertController.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueActionSheetForPresentation(alertController, sourceView: sender, permittedArrowDirections: [.up,.down])
    }
    
    ///Called when a requirement is clicked by the user, display an action sheet of possible modifcations to the alarm/requirement.
    private func willShowRequirementActionSheet(sender: UIView, parentDogName: String, requirement: Requirement){
        
        let selectedRequirementAlertController = GeneralUIAlertController(title: "You Selected: \(requirement.displayTypeName) for \(parentDogName)", message: nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        let alertActionEdit = UIAlertAction(title: "Edit Reminder", style: .default) { (UIAlertAction) in
            self.delegate.willEditRequirement(parentDogName: parentDogName, requirementUUID: requirement.uuid)
        }
        
        //DELETE BUTTON
        let alertActionDelete = UIAlertAction(title: "Delete Reminder", style: .destructive) { (action) in
            
            //DELETE CONFIRMATION
            let deleteRequirementConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(requirement.displayTypeName)?", message: nil, preferredStyle: .alert)
            
            let deleteRequirementConfirmationDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
                let sudoDogManager = self.getDogManager()
                let dog = try! sudoDogManager.findDog(dogName: parentDogName)
                let indexPath = IndexPath(row: try! dog.dogRequirments.findIndex(forUUID: requirement.uuid)+1, section: try! sudoDogManager.findIndex(dogName: parentDogName))
                
                try! dog.dogRequirments.removeRequirement(forUUID: requirement.uuid)
                self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            let deleteRequirementConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            deleteRequirementConfirmation.addAction(deleteRequirementConfirmationDelete)
            deleteRequirementConfirmation.addAction(deleteRequirementConfirmationCancel)

            AlertPresenter.shared.enqueueAlertForPresentation(deleteRequirementConfirmation)
            
            
        }
        
        //DETERMINES IF ITS A LOG BUTTON OR UNDO LOG BUTTON
        var shouldUndoLog: Bool {
            //Yes I know these if statements are redundent and terrible coding but it's whatever, used to do something different but has to modify
            if requirement.isActive == false {
                return false
            }
            else if requirement.timerMode == .snooze || requirement.timerMode == .countDown {
                return false
            }
            else {
                if requirement.timeOfDayComponents.isSkipping == true {
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
                title: "Undo Log for \(requirement.displayTypeName)",
            style: .default,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //knownLogType not needed as unskipping alarm does not require that component
                    TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, requirementUUID: requirement.uuid, knownLogType: nil)
                    self.delegate.didUnlogReminder()
                    
                })
            alertActionsForLog.append(alertActionLog)
        }
        else {
            switch requirement.requirementType {
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
                                TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, requirementUUID: requirement.uuid, knownLogType: pottyKnownType)
                                self.delegate.didLogReminder()
                            })
                    alertActionsForLog.append(alertActionLog)
                }
            default:
                let alertActionLog = UIAlertAction(
                    title:"Log \(requirement.displayTypeName)",
                    style: .default,
                    handler:
                        {
                            (_)  in
                            //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                            TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: parentDogName, requirementUUID: requirement.uuid, knownLogType: KnownLogType(rawValue: requirement.requirementType.rawValue)!)
                            self.delegate.didLogReminder()
                        })
                alertActionsForLog.append(alertActionLog)
            }
        }
        
        if requirement.getEnable() == true {
            for alertActionLog in alertActionsForLog{
                selectedRequirementAlertController.addAction(alertActionLog)
            }
        }
        
        selectedRequirementAlertController.addAction(alertActionEdit)
        
        selectedRequirementAlertController.addAction(alertActionDelete)
        
        selectedRequirementAlertController.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueActionSheetForPresentation(selectedRequirementAlertController, sourceView: sender, permittedArrowDirections: [.up,.down])
        
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
        
        return getDogManager().dogs[section].dogRequirments.requirements.count+1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsMainScreenTableViewCellDogDisplay", for: indexPath)
            
            let customCell = cell as! DogsMainScreenTableViewCellDogDisplay
            customCell.setup(dogPassed: getDogManager().dogs[indexPath.section])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogsMainScreenTableViewCellRequirementDisplay", for: indexPath)
            
            let customCell = cell as! DogsMainScreenTableViewCellRequirementDisplay
            customCell.setup(parentDogName: getDogManager().dogs[indexPath.section].dogTraits.dogName, requirementPassed: getDogManager().dogs[indexPath.section].dogRequirments.requirements[indexPath.row-1])
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
                
                willShowRequirementActionSheet(sender: tableView.cellForRow(at: indexPath)!, parentDogName: dog.dogTraits.dogName, requirement: dog.dogRequirments.requirements[indexPath.row-1])
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && getDogManager().dogs.count > 0 {
            let deleteConfirmation: GeneralUIAlertController!
            let sudoDogManager = getDogManager()
            if indexPath.row > 0 {
                deleteConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(sudoDogManager.dogs[indexPath.section].dogRequirments.requirements[indexPath.row-1].displayTypeName)?", message: nil, preferredStyle: .alert)
                
                let alertActionDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    sudoDogManager.dogs[indexPath.section].dogRequirments.removeRequirement(forIndex: indexPath.row-1)
                    self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                deleteConfirmation.addAction(alertActionDelete)
                deleteConfirmation.addAction(alertActionCancel)
            }
            else {
                deleteConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(sudoDogManager.dogs[indexPath.section].dogTraits.dogName)?", message: nil, preferredStyle: .alert)
                
                let alertActionDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    sudoDogManager.dogs.remove(at: indexPath.section)
                    self.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: sudoDogManager)
                    self.tableView.deleteSections([indexPath.section], with: .automatic)
                }
                let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                deleteConfirmation.addAction(alertActionDelete)
                deleteConfirmation.addAction(alertActionCancel)
            }
            AlertPresenter.shared.enqueueAlertForPresentation(deleteConfirmation)
            
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
