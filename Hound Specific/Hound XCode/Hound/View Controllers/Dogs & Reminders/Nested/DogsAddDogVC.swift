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

class DogsAddDogViewController: UIViewController, DogsReminderNavigationViewControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let image: UIImage!
        let scaledImageSize = CGSize(width: 90.0, height: 90.0)

        if let possibleImage = info[.editedImage] as? UIImage {
            image = possibleImage
        }
        else if let possibleImage = info[.originalImage] as? UIImage {
            image = possibleImage
        }
        else {
            return
        }

        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }

        dogIcon.setImage(scaledImage, for: .normal)

        dismiss(animated: true)
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - DogsReminderNavigationViewControllerDelegate
    
    func didAddReminder(forReminder reminder: Reminder) {
        shouldPromptSaveWarning = true
        modifiableDogReminders.addReminder(newReminder: reminder)
    }
    
    func didUpdateReminder(forReminder reminder: Reminder) {
        shouldPromptSaveWarning = true
        modifiableDogReminders.updateReminder(updatedReminder: reminder)
    }
    
    func didRemoveReminder(reminderId: Int) {
        shouldPromptSaveWarning = true
        try! modifiableDogReminders.removeReminder(forReminderId: reminderId)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    // MARK: - IB

    @IBOutlet private weak var dogName: BorderedUITextField!

    @IBOutlet private weak var embeddedTableView: UIView!

    @IBOutlet weak var dogIcon: ScaledUIButton!

    @IBAction func didClickIcon(_ sender: Any) {
        AlertManager.enqueueActionSheetForPresentation(imagePickMethodAlertController, sourceView: dogIcon, permittedArrowDirections: [.up, .down])
    }
    
    @IBOutlet private weak var addDogButtonBackground: ScaledUIButton!
    @IBOutlet private weak var addDogButton: ScaledUIButton!
    // When the add button is clicked, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction private func willAddDog(_ sender: Any) {
        // could be new dog or updated one
        var dog: Dog!
        do {
            dog = try Dog(dogName: dogName.text)
            if dogIcon.imageView?.image != nil && dogIcon.imageView!.image != DogConstant.chooseIcon {
                dog.icon = dogIcon.imageView!.image!
            }
        }
        catch {
            ErrorManager.alert(forError: error)
            return
        }
        
        // not updating, therefore the dog is being created new and the reminders are too
        if isUpdating == false {
            
            addDogButton.beginQuerying()
            addDogButtonBackground.beginQuerying(isBackgroundButton: true)
            DogsRequest.create(forDog: dog) { dogId in
                if dogId != nil {
                    // dog was successfully created
                    dog.dogId = dogId!
                    
                    // if dog succeeded then high change of reminders succeeding too
                    RemindersRequest.create(forDogId: dog.dogId, forReminders: self.modifiableDogReminders.reminders) { reminders in
                        // TO DO review this section. Possible better way to do it as no/failure respmse messages can be duplicated (RemindersRequest.create error then try DogsRequest.delete error)
                        self.addDogButton.endQuerying()
                        self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                        if reminders != nil {
                            // dog and reminders successfully created, so we can proceed
                            dog.dogReminders.addReminder(newReminders: reminders!)
                            self.delegate.didAddDog(sender: Sender(origin: self, localized: self), newDog: dog)
                            self.navigationController?.popViewController(animated: true)
                        }
                        else {
                            // reminders were unable to be created so we delete the dog to remove everything.
                            DogsRequest.delete(forDogId: dog.dogId) { _ in
                            }
                        }
                    }
                }
                else {
                    self.addDogButton.endQuerying()
                    self.addDogButtonBackground.endQuerying(isBackgroundButton: true)
                }
            }
        }
        else {
            // TO DO review this section. Lots of spaghetti code. There will be duplicate error messages from create, update, and delete if network or other error.
            let reminderDifference = dogForInitalizer!.dogReminders.groupReminders(newReminders: modifiableDogReminders.reminders)
            let sameReminders = reminderDifference.0
            let createdReminders = reminderDifference.1
            let updatedReminders = reminderDifference.2
            let deletedReminders = reminderDifference.3
            
            dog.dogId = dogForInitalizer!.dogId
            // for reminders that already have their reminderId, we can add them to our dog.
            dog.dogReminders.addReminder(newReminders: sameReminders)
            // add created reminders when they are created and assigned their id
            dog.dogReminders.updateReminder(updatedReminders: updatedReminders)
            addDogButton.beginQuerying()
            addDogButtonBackground.beginQuerying(isBackgroundButton: true)
            // first query to update the dog itself (independent of any reminders)
            DogsRequest.update(forDog: dog) { requestWasSuccessful1 in
                if requestWasSuccessful1 == true {
                    // the dog was successfully updated, so we attempt to take actions for the reminders
                    var queryFailure = false
                    var queriedCreatedReminders = false
                    var queriedUpdatedReminders = false
                    var queriedDeletedReminders = false
                    if createdReminders.count > 0 {
                        // we have reminders created that need to be created on the server
                        RemindersRequest.create(forDogId: dog.dogId, forReminders: createdReminders) { reminders in
                            if reminders != nil {
                                dog.dogReminders.addReminder(newReminders: reminders!)
                                queriedCreatedReminders = true
                            }
                            else {
                                queryFailure = true
                            }
                            checkForCompletion()
                        }
                    }
                    else {
                        queriedCreatedReminders = true
                        checkForCompletion()
                    }
                    if updatedReminders.count > 0 {
                        RemindersRequest.update(forDogId: dog.dogId, forReminders: updatedReminders) { requestWasSuccessful2 in
                            if requestWasSuccessful2 == true {
                                queriedUpdatedReminders = true
                            }
                            else {
                                queryFailure = true
                            }
                            checkForCompletion()
                        }
                    }
                    else {
                        queriedUpdatedReminders = true
                        checkForCompletion()
                    }
                    if deletedReminders.count > 0 {
                        // find all the ids of the reminders to delete
                        var deletedReminderIds: [Int] = []
                        for deletedReminder in deletedReminders {
                            deletedReminderIds.append(deletedReminder.reminderId)
                        }
                        
                        RemindersRequest.delete(forDogId: dog.dogId, forReminderIds: deletedReminderIds) { requestWasSuccessful2 in
                            if requestWasSuccessful2 == true {
                                queriedDeletedReminders = true
                            }
                            else {
                                queryFailure = true
                            }
                            checkForCompletion()
                        }
                    }
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
            
        }

    }

    @IBOutlet weak var dogRemoveButton: UIBarButtonItem!

    @IBAction func willRemoveDog(_ sender: Any) {
        // button should only be able to be clicked if targetDog != nil but always good to double check
        guard dogForInitalizer != nil else {
            return
        }
        let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogName.text ?? dogForInitalizer!.dogName)?", message: nil, preferredStyle: .alert)

        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
           DogsRequest.delete(forDogId: self.dogForInitalizer!.dogId) { requestWasSuccessful in
                if requestWasSuccessful == true {
                        self.delegate.didRemoveDog(sender: Sender(origin: self, localized: self), dogId: self.dogForInitalizer!.dogId)
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
    var dogForInitalizer: Dog?
    var isUpdating: Bool {
        if dogForInitalizer == nil {
            return false
        }
        else {
            return true
        }}
    
    var initalDogName: String?
    var initalDogIcon: UIImage?

    var initalValuesChanged: Bool {
        if dogName.text != initalDogName {
            return true
        }
        else if dogIcon.imageView!.image != DogConstant.chooseIcon && dogIcon.imageView!.image != initalDogIcon {
            return true
        }
        else if shouldPromptSaveWarning == true {
            return true
        }
        else {
            return false
        }
    }
    let imagePickMethodAlertController = GeneralUIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)

    /// Auto save warning will show if true
    private var shouldPromptSaveWarning: Bool = false

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupToHideKeyboardOnTapOnView()

        self.view.bringSubviewToFront(addDogButtonBackground)
        self.view.bringSubviewToFront(addDogButton)

        self.view.bringSubviewToFront(cancelAddDogButtonBackground)
        self.view.bringSubviewToFront(cancelAddDogButton)

        dogName.delegate = self

        willInitalize()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    /// Called to initalize all data, if a dog is passed then it uses that, otherwise uses default
    private func willInitalize() {
        
        // buttons
        dogIcon.layer.masksToBounds = true
        dogIcon.layer.cornerRadius = dogIcon.frame.width/2
        
        // new dog
        if dogForInitalizer == nil {
            dogRemoveButton.isEnabled = false
            self.navigationItem.title = "Create Dog"
            
            dogName.text = ""
            dogIcon.setImage(DogConstant.chooseIcon, for: .normal)
            modifiableDogReminders = ReminderManager(initReminders: ReminderConstant.defaultReminders)
            dogsReminderNavigationViewController.didPassReminders(sender: Sender(origin: self, localized: self), passedReminders: modifiableDogReminders.copy() as! ReminderManager)
            // no need to pass reminders to dogsReminderNavigationViewController as reminders are empty
        }
        // updating dog
        else {
            dogRemoveButton.isEnabled = true
            self.navigationItem.title = "Edit Dog"
            
            dogName.text = dogForInitalizer!.dogName
            if dogForInitalizer!.icon.isEqualToImage(image: DogConstant.defaultIcon) {
                dogIcon.setImage(DogConstant.chooseIcon, for: .normal)
            }
            else {
                dogIcon.setImage(dogForInitalizer!.icon, for: .normal)
            }
            // has to copy reminders so changed that arent saved don't use reference data property to make actual modification
        modifiableDogReminders = dogForInitalizer!.dogReminders.copy() as? ReminderManager
            dogsReminderNavigationViewController.didPassReminders(sender: Sender(origin: self, localized: self), passedReminders: modifiableDogReminders.copy() as! ReminderManager)
        }

        initalDogName = dogName.text
        initalDogIcon = dogIcon.imageView!.image
        
        // Setup AlertController for icon button now, increases responsiveness
        setupDogIconImagePicker()
        
    }

    /// Hides the big gray back button and big blue checkmark, don't want access to them while editting a reminder.
    func willHideButtons(isHidden: Bool) {
        if isHidden == false {
            addDogButton.isHidden = false
            addDogButtonBackground.isHidden = false
            cancelAddDogButton.isHidden = false
            cancelAddDogButtonBackground.isHidden = false
        }
        else {
            addDogButton.isHidden = true
            addDogButtonBackground.isHidden = true
            cancelAddDogButton.isHidden = true
            cancelAddDogButtonBackground.isHidden = true
        }
    }
    
    /// Sets up the UIAlertController that prompts the user in the different ways that they can add an icon to their dog (e.g. take a picture of choose an existing one
    private func setupDogIconImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePickMethodAlertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            openCamera()
        }))
        
        imagePickMethodAlertController.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            openGallary()
        }))
        
        imagePickMethodAlertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        func openCamera() {
            if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                imagePicker.cameraCaptureMode = .photo
                imagePicker.cameraDevice = .rear
                self.present(imagePicker, animated: true, completion: nil)
                
            }
            else {
                let warningAlert  = GeneralUIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                warningAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                AlertManager.enqueueAlertForPresentation(warningAlert)
            }
        }
        
        func openGallary() {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogReminderNavigationController"{
            dogsReminderNavigationViewController = segue.destination as? DogsReminderNavigationViewController
            dogsReminderNavigationViewController.passThroughDelegate = self
        }

    }
}
