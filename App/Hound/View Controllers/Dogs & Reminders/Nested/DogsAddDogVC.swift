//
//  DogsAddDogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogViewControllerDelegate: AnyObject {
    func didAddDog(sender: Sender, newDog: Dog)
    func didUpdateDog(sender: Sender, updatedDog: Dog)
    func didRemoveDog(sender: Sender, dogId: Int)
    /// Reinitalizes timers that were possibly destroyed
    func didCancel(sender: Sender)
}

final class DogsAddDogViewController: UIViewController, DogsReminderNavigationViewControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let dogIcon = ImageManager.processImage(forDogIcon: dogIcon, forInfo: info) {
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
        shouldPromptSaveWarning = true
        modifiableDogReminders.addReminder(forReminder: reminder)
    }
    
    func didUpdateReminder(forReminder reminder: Reminder) {
        shouldPromptSaveWarning = true
        modifiableDogReminders.updateReminder(forReminder: reminder)
    }
    
    func didRemoveReminder(reminderId: Int) {
        shouldPromptSaveWarning = true
        modifiableDogReminders.removeReminder(forReminderId: reminderId)
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
            if let image = dogIcon.imageView?.image, image != ClassConstant.DogConstant.chooseImageForDog {
                dog.dogIcon = image
            }
        }
        catch {
            (error as? HoundError)?.alert() ?? ErrorConstant.UnknownError.unknown.alert()
            return
        }
        
        if dogToUpdate != nil {
            let reminderDifference = dog.dogReminders.groupReminders(newReminders: modifiableDogReminders.reminders)
            // same reminders, not used currently
            _ = reminderDifference.0
            let createdReminders = reminderDifference.1
            // If the user created countdown reminder(s) and then sat on the create a dog page, those countdown reminders will be 'counting down' as time has passed from their reminderExecutionBasis's. Therefore we must reset their executionBasis so they are fresh.
            createdReminders.forEach { reminder in
                guard reminder.reminderType == .countdown else {
                    return
                }
                reminder.prepareForNextAlarm()
            }
            
            let updatedReminders = reminderDifference.2
            let deletedReminders = reminderDifference.3
            
            // do nothing with reminders that are the same
            // add created reminders when they are created and assigned their id
            // add updated reminders as they already have their reminderId
            dog.dogReminders.updateReminders(forReminders: updatedReminders)
            for deletedReminder in deletedReminders {
                dog.dogReminders.removeReminder(forReminderId: deletedReminder.reminderId)
            }
            
            addDogButton.beginQuerying()
            addDogButtonBackground.beginQuerying(isBackgroundButton: true)
            // first query to update the dog itself (independent of any reminders)
            DogsRequest.update(invokeErrorManager: true, forDog: dog) { requestWasSuccessful1, _ in
                guard requestWasSuccessful1 else {
                    self.addDogButton.endQuerying()
                    self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                    return
                }
                // the dog was successfully updated, so we attempt to take actions for the reminders
                var queryFailure = false
                var queriedCreatedReminders = false
                var queriedUpdatedReminders = false
                var queriedDeletedReminders = false
                
                // check to see if we need to create any reminders on the server
                if createdReminders.count > 0 {
                    // we have reminders created that need to be created on the server
                    RemindersRequest.create(invokeErrorManager: true, forDogId: dog.dogId, forReminders: createdReminders) { reminders, _ in
                        if let reminders = reminders {
                            dog.dogReminders.addReminders(forReminders: reminders)
                            queriedCreatedReminders = true
                        }
                        else {
                            queryFailure = true
                        }
                        checkForCompletion()
                    }
                }
                // no reminders to be created on the server
                else {
                    queriedCreatedReminders = true
                    checkForCompletion()
                }
                // check to see if we need to update any reminders on the server
                if updatedReminders.count > 0 {
                    RemindersRequest.update(invokeErrorManager: true, forDogId: dog.dogId, forReminders: updatedReminders) { requestWasSuccessful2, _ in
                        if requestWasSuccessful2 == true {
                            queriedUpdatedReminders = true
                        }
                        else {
                            queryFailure = true
                        }
                        checkForCompletion()
                    }
                }
                // no reminders to be updated on the server
                else {
                    queriedUpdatedReminders = true
                    checkForCompletion()
                }
                // check to see if we need to delete any reminders on the server
                if deletedReminders.count > 0 {
                    
                    RemindersRequest.delete(invokeErrorManager: true, forDogId: dog.dogId, forReminders: deletedReminders) { requestWasSuccessful2, _ in
                        if requestWasSuccessful2 == true {
                            queriedDeletedReminders = true
                        }
                        else {
                            queryFailure = true
                        }
                        checkForCompletion()
                    }
                }
                // no reminders to be deleted on the server
                else {
                    queriedDeletedReminders = true
                    checkForCompletion()
                }
                
                // we want to send a message about updating the dog if everything compelted
                func checkForCompletion() {
                    guard queryFailure == false else {
                        self.addDogButton.endQuerying()
                        self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                        return
                    }
                    if queriedCreatedReminders == true && queriedUpdatedReminders == true && queriedDeletedReminders == true {
                        self.addDogButton.endQuerying()
                        self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                        self.delegate.didUpdateDog(sender: Sender(origin: self, localized: self), updatedDog: dog)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            }
        }
        else {
            // not updating, therefore the dog is being created new and the reminders are too
            
            addDogButton.beginQuerying()
            addDogButtonBackground.beginQuerying(isBackgroundButton: true)
            DogsRequest.create(invokeErrorManager: true, forDog: dog) { dogId, _ in
                guard let dogId = dogId else {
                    self.addDogButton.endQuerying()
                    self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                    return
                }
                
                // dog was successfully created
                dog.dogId = dogId
                
                // If the user created countdown reminder(s) and then sat on the create a dog page, those countdown reminders will be 'counting down' as time has passed from their reminderExecutionBasis's. Therefore we must reset their executionBasis so they are fresh.
                let createdReminders = self.modifiableDogReminders.reminders
                createdReminders.forEach { reminder in
                    guard reminder.reminderType == .countdown else {
                        return
                    }
                    reminder.prepareForNextAlarm()
                }
                
                RemindersRequest.create(invokeErrorManager: true, forDogId: dog.dogId, forReminders: createdReminders) { reminders, _ in
                    self.addDogButton.endQuerying()
                    self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                    if let reminders = reminders {
                        // dog and reminders successfully created, so we can proceed
                        dog.dogReminders.addReminders(forReminders: reminders)
                        self.delegate.didAddDog(sender: Sender(origin: self, localized: self), newDog: dog)
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
                    self.delegate.didRemoveDog(sender: Sender(origin: self, localized: self), dogId: dogToUpdate.dogId)
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
        // removed cancelling, everything autosaves now
        
        if initalValuesChanged == true {
            // "Any changes you have made won't be saved"
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
        else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: - Properties
    
    var dogsReminderNavigationViewController: DogsReminderNavigationViewController! = nil
    
    weak var delegate: DogsAddDogViewControllerDelegate! = nil
    
    /// If updating a dog, then is a .copy() of that dogs reminder manager otherwise its a blank remidner manager. You can edit this all you want and it won't affect anything else. Use this to save any reminder changes then persist them all upon a save.
    var modifiableDogReminders: ReminderManager!
    
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
        else if shouldPromptSaveWarning == true {
            return true
        }
        else {
            return false
        }
    }
    var imagePickMethodAlertController: GeneralUIAlertController!
    
    /// Auto save warning will show if true
    private var shouldPromptSaveWarning: Bool = false
    
    // MARK: - Main
    
    // TO DO BUG after deleting reminders in the dogs page, they still appear in the data. only disappears after refreshing from server
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
        
        self.setupToHideKeyboardOnTapOnView()
        
        self.view.bringSubviewToFront(addDogButtonBackground)
        self.view.bringSubviewToFront(addDogButton)
        
        self.view.bringSubviewToFront(cancelAddDogButtonBackground)
        self.view.bringSubviewToFront(cancelAddDogButton)
        
        dogName.delegate = self
        
        // buttons
        dogIcon.layer.masksToBounds = true
        dogIcon.layer.cornerRadius = dogIcon.frame.width / 2
        
        if let dogToUpdate = dogToUpdate {
            // Updating a dog
            dogRemoveButton.isEnabled = true
            self.navigationItem.title = "Edit Dog"
            
            dogName.text = dogToUpdate.dogName
            if dogToUpdate.dogIcon.isEqualToImage(image: ClassConstant.DogConstant.defaultDogIcon) {
                dogIcon.setImage(ClassConstant.DogConstant.chooseImageForDog, for: .normal)
            }
            else {
                dogIcon.setImage(dogToUpdate.dogIcon, for: .normal)
            }
            // has to copy reminders so changed that arent saved don't use reference data property to make actual modification
            if let modifiableDogReminders = dogToUpdate.dogReminders.copy() as? ReminderManager {
                self.modifiableDogReminders = modifiableDogReminders
                if let copyOfModifiableDogReminders = modifiableDogReminders.copy() as? ReminderManager {
                    dogsReminderNavigationViewController.didPassReminders(sender: Sender(origin: self, localized: self), passedReminders: copyOfModifiableDogReminders)
                }
                
            }
        }
        else {
            // New dog
            dogRemoveButton.isEnabled = false
            self.navigationItem.title = "Create Dog"
            
            dogName.text = ""
            dogIcon.setImage(ClassConstant.DogConstant.chooseImageForDog, for: .normal)
            modifiableDogReminders = ReminderManager(initReminders: ClassConstant.ReminderConstant.defaultReminders)
            if let copyOfModifiableDogReminders = modifiableDogReminders.copy() as? ReminderManager {
                dogsReminderNavigationViewController.didPassReminders(sender: Sender(origin: self, localized: self), passedReminders: copyOfModifiableDogReminders)
            }
        }
        
        initalDogName = dogName.text
        initalDogIcon = dogIcon.imageView?.image
        
        // Setup AlertController for dogIcon button now, increases responsiveness
        let (picker, viewController) = ImageManager.setupDogIconImagePicker(forViewController: self)
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
        }
        
    }
}
