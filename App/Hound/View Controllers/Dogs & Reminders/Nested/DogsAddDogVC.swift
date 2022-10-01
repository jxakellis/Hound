//
//  DogsAddDogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
    /// Reinitalizes timers that were possibly destroyed
    func didCancel(sender: Sender)
}

final class DogsAddDogViewController: UIViewController, DogsReminderNavigationViewControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let dogIcon = DogIconManager.processDogIcon(forDogIconButton: dogIcon, forInfo: info) {
            self.dogIcon.setImage(dogIcon, for: .normal)
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - DogsReminderNavigationViewControllerDelegate
    
    func didAddReminder(forReminder reminder: Reminder) {
        createdReminders.append(reminder)
    }
    
    func didUpdateReminder(forReminder reminder: Reminder) {
        updatedReminders.append(reminder)
    }
    
    func didRemoveReminder(forReminder reminder: Reminder) {
        deletedReminders.append(reminder)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under dogNameCharacterLimit
        return updatedText.count <= ClassConstant.DogConstant.dogNameCharacterLimit
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var dogName: BorderedUITextField!
    
    @IBOutlet private weak var dogIcon: ScaledUIButton!
    
    @IBAction private func didClickIcon(_ sender: Any) {
        AlertManager.enqueueActionSheetForPresentation(imagePickMethodAlertController, sourceView: dogIcon, permittedArrowDirections: [.up, .down])
    }
    
    @IBOutlet private weak var addDogButtonBackground: ScaledUIButton!
    @IBOutlet private weak var addDogButton: ScaledUIButton!
    // When the add button is clicked, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction private func willAddDog(_ sender: Any) {
        // could be new dog or updated one
        var dog: Dog!
        do {
            // try to initalize from a passed dog, if non exists, then we make a new one
            dog = try dogToUpdate ?? Dog(dogName: dogName.text)
            try dog.changeDogName(forDogName: dogName.text)
            if let image = self.dogIcon.imageView?.image, image != ClassConstant.DogConstant.chooseImageForDog {
                // DogsRequest handles .addIcon and .removeIcon. It will remove the dogIcon saved under the placeholder id (if creating an dog) and it will save the new dogIcon under the offical dogId
                dog.dogIcon = image
            }
        }
        catch {
            (error as? HoundError)?.alert() ?? ErrorConstant.UnknownError.unknown.alert()
            return
        }
        
        addDogButton.beginQuerying()
        addDogButtonBackground.beginQuerying(isBackgroundButton: true)
        
        if dogToUpdate != nil {
            
            // dog + created reminders + updated reminders + deleted reminders
            let numberOfTasks = {
                // first task is dog update
                var numberOfTasks = 1
                if createdReminders.count >= 1 {
                    numberOfTasks += 1
                }
                if updatedReminders.count >= 1 {
                    numberOfTasks += 1
                }
                if deletedReminders.count >= 1 {
                    numberOfTasks += 1
                }
                return numberOfTasks
            }()
            
            let completionTracker = CompletionTracker(numberOfTasks: numberOfTasks) {
                // all tasks completed successfully
                self.addDogButton.endQuerying()
                self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                self.dogManager.updateDog(forDog: dog)
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                self.navigationController?.popViewController(animated: true)
            } failureCompletionHandler: {
                // something failed
                self.addDogButton.endQuerying()
                self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
            }
            
            // first query to update the dog itself (independent of any reminders)
            DogsRequest.update(invokeErrorManager: true, forDog: dog) { requestWasSuccessful1, _ in
                guard requestWasSuccessful1 else {
                    completionTracker.failedTask()
                    return
                }
                
                // Updated dog
                completionTracker.completedTask()
                
                if self.createdReminders.count >= 1 {
                    RemindersRequest.create(invokeErrorManager: true, forDogId: dog.dogId, forReminders: self.createdReminders) { reminders, _ in
                        if let reminders = reminders {
                            dog.dogReminders.addReminders(forReminders: reminders)
                            completionTracker.completedTask()
                        }
                        else {
                            completionTracker.failedTask()
                        }
                    }
                }
                
                if self.updatedReminders.count >= 1 {
                    RemindersRequest.update(invokeErrorManager: true, forDogId: dog.dogId, forReminders: self.updatedReminders) { requestWasSuccessful2, _ in
                        if requestWasSuccessful2 == true {
                            // add updated reminders as they already have their reminderId
                            dog.dogReminders.updateReminders(forReminders: self.updatedReminders)
                            completionTracker.completedTask()
                        }
                        else {
                            completionTracker.failedTask()
                        }
                    }
                }
                
                if self.deletedReminders.count >= 1 {
                    RemindersRequest.delete(invokeErrorManager: true, forDogId: dog.dogId, forReminders: self.deletedReminders) { requestWasSuccessful2, _ in
                        if requestWasSuccessful2 == true {
                            for deletedReminder in self.deletedReminders {
                                dog.dogReminders.removeReminder(forReminderId: deletedReminder.reminderId)
                            }
                            completionTracker.completedTask()
                        }
                        else {
                            completionTracker.failedTask()
                        }
                    }
                }
                
            }
        }
        else {
            // not updating, therefore the dog is being created new and the reminders are too
            DogsRequest.create(invokeErrorManager: true, forDog: dog) { dogId, _ in
                guard let dogId = dogId else {
                    self.addDogButton.endQuerying()
                    self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                    return
                }
                
                // dog was successfully created
                dog.dogId = dogId
                
                self.createdReminders.forEach { reminder in
                    // If the user created countdown reminder(s) and then sat on the create a dog page, those countdown reminders will be 'counting down' as time has passed from their reminderExecutionBasis's. Therefore we must reset their executionBasis so they are fresh.
                    guard reminder.reminderType == .countdown else {
                        return
                    }
                    reminder.prepareForNextAlarm()
                }
                
                RemindersRequest.create(invokeErrorManager: true, forDogId: dog.dogId, forReminders: self.createdReminders) { reminders, _ in
                    self.addDogButton.endQuerying()
                    self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                    if let reminders = reminders {
                        // dog and reminders successfully created, so we can proceed
                        dog.dogReminders.addReminders(forReminders: reminders)
                        
                        self.dogManager.addDog(forDog: dog)
                        self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        // reminders were unable to be created so we delete the dog to remove everything.
                        DogsRequest.delete(invokeErrorManager: false, forDogId: dog.dogId) { _, _ in
                            // do nothing, we can't do more even if it fails.
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet private weak var dogRemoveButton: UIBarButtonItem!
    
    @IBAction private func willRemoveDog(_ sender: Any) {
        // button should only be able to be clicked if targetDog != nil but always good to double check
        guard let dogToUpdate = dogToUpdate else {
            return
        }
        let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogName.text ?? dogToUpdate.dogName)?", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DogsRequest.delete(invokeErrorManager: true, forDogId: dogToUpdate.dogId) { requestWasSuccessful, _ in
                if requestWasSuccessful == true {
                    
                    self.dogManager.removeDog(forDogId: dogToUpdate.dogId)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(alertActionRemove)
        removeDogConfirmation.addAction(alertActionCancel)
        
        AlertManager.enqueueAlertForPresentation(removeDogConfirmation)
    }
    
    @IBOutlet private weak var cancelAddDogButton: ScaledUIButton!
    @IBOutlet private weak var cancelAddDogButtonBackground: ScaledUIButton!
    
    @IBAction private func cancelAddDogButton(_ sender: Any) {
        // If the user changed any values on the page, then ask them to confirm to discarding those changes
        guard initalValuesChanged == true else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let unsavedInformationConfirmation = GeneralUIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
        
        let alertActionExit = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
            self.delegate.didCancel(sender: Sender(origin: self, localized: self))
            self.navigationController?.popViewController(animated: true)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        unsavedInformationConfirmation.addAction(alertActionExit)
        unsavedInformationConfirmation.addAction(alertActionCancel)
        
        AlertManager.enqueueAlertForPresentation(unsavedInformationConfirmation)
    }
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        if !(sender.localized is DogsViewController) {
            delegate.didUpdateDogManager(sender: sender, forDogManager: dogManager)
        }
    }
    
    // MARK: - Properties
    
    var dogsReminderNavigationViewController: DogsReminderNavigationViewController?
    
    weak var delegate: DogsAddDogViewControllerDelegate! = nil
    
    /// This keeps track of the reminders added to a dog. This could be a new dog being created or an existing dog being updated
    var createdReminders: [Reminder] = []
    
    /// This keeps track of the reminders updated to the dog. This can only be for an existing dog being updated
    var updatedReminders: [Reminder] = []
    
    /// This keeps track of the reminders deleted from a dog. This can only be for an existing dog being updated
    var deletedReminders: [Reminder] = []
    
    /// VC uses this to initalize its values, its absense or presense indicates whether or not we are editing or creating a dog
    var dogToUpdate: Dog?
    
    var initalDogName: String?
    var initalDogIcon: UIImage?
    
    var initalValuesChanged: Bool {
        if dogName.text != initalDogName {
            return true
        }
        else if let image = dogIcon.imageView?.image, image != ClassConstant.DogConstant.chooseImageForDog && image != initalDogIcon {
            return true
        }
        else if createdReminders.count > 0 {
            return true
        }
        else if updatedReminders.count > 0 {
            return true
        }
        else if deletedReminders.count > 0 {
            return true
        }
        else {
            return false
        }
    }
    var imagePickMethodAlertController: GeneralUIAlertController!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneTimeSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    /// Called to initalize all data, if a dog is passed then it uses that, otherwise uses default
    private func oneTimeSetup() {
        
        // gestures
        self.setupToHideKeyboardOnTapOnView()
        
        // views
        self.view.bringSubviewToFront(addDogButtonBackground)
        self.view.bringSubviewToFront(addDogButton)
        
        self.view.bringSubviewToFront(cancelAddDogButtonBackground)
        self.view.bringSubviewToFront(cancelAddDogButton)
        
        // values
        navigationItem.title = dogToUpdate == nil ? "Create Dog" : "Edit Dog"
        
        dogName.text = dogToUpdate?.dogName ?? ""
        dogName.delegate = self
        
        let icon = {
            // If the dog has a icon that was set by the user, an icon that is different than the default dog icon, then we display that icon. Otherwise, we display an an icon that tells the to choose an icon for their dog
            guard let dogToUpdate = dogToUpdate else {
                return ClassConstant.DogConstant.chooseImageForDog
            }
            
            return dogToUpdate.dogIcon.isEqualToImage(image: ClassConstant.DogConstant.defaultDogIcon)
            ? ClassConstant.DogConstant.chooseImageForDog
            : dogToUpdate.dogIcon
        }()
        
        dogIcon.setImage(icon, for: .normal)
        
        // if we have a dogToUpdate available, then we pass a copy of its reminders, otherwise we pass a reminder manager filled with just default reminders
        dogsReminderNavigationViewController?.didPassReminders(sender: Sender(origin: self, localized: self), passedReminders: dogToUpdate?.dogReminders.copy() as? ReminderManager ?? ReminderManager(initReminders: ClassConstant.ReminderConstant.defaultReminders))
        
        // buttons
        dogIcon.layer.masksToBounds = true
        dogIcon.layer.cornerRadius = dogIcon.frame.width / 2
        
        dogRemoveButton.isEnabled = dogToUpdate != nil
        
        initalDogName = dogName.text
        initalDogIcon = dogIcon.imageView?.image
        
        // Setup AlertController for dogIcon button now, increases responsiveness
        let (picker, viewController) = DogIconManager.setupDogIconImagePicker(forViewController: self)
        picker.delegate = self
        imagePickMethodAlertController = viewController
    }
    
    /// Hides the big gray back button and big blue checkmark, don't want access to them while editting a reminder.
    func willHideButtons(isHidden: Bool) {
        addDogButton.isHidden = isHidden
        addDogButtonBackground.isHidden = isHidden
        cancelAddDogButton.isHidden = isHidden
        cancelAddDogButtonBackground.isHidden = isHidden
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsReminderNavigationViewController = segue.destination as? DogsReminderNavigationViewController {
            self.dogsReminderNavigationViewController = dogsReminderNavigationViewController
            dogsReminderNavigationViewController.passThroughDelegate = self
            
            dogsReminderNavigationViewController.didPassReminders(sender: Sender(origin: self, localized: self), passedReminders: dogToUpdate?.dogReminders.copy() as? ReminderManager ?? ReminderManager(initReminders: ClassConstant.ReminderConstant.defaultReminders))
        }
        
    }
}
