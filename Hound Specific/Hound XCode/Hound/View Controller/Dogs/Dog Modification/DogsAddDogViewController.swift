//
//  DogsAddDogViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogViewControllerDelegate: AnyObject {
    func didAddDog(sender: Sender, newDog: Dog) throws
    func didUpdateDog(sender: Sender, dogId: Int, updatedDog: Dog) throws
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

    // MARK: - Reminder Table VC Delegate

    func didAddReminder(newReminder: Reminder) {
        shouldPromptSaveWarning = true
        try! targetDog.dogReminders.addReminder(newReminder: newReminder)
    }

    func didUpdateReminder(updatedReminder: Reminder) {
        shouldPromptSaveWarning = true
        try! targetDog.dogReminders.addReminder(newReminder: updatedReminder)
    }

    func didRemoveReminder(reminderId: Int) {
        shouldPromptSaveWarning = true
        try! targetDog.dogReminders.removeReminder(forReminderId: reminderId)
    }

    // assume all reminders are valid due to the fact that they are all checked and validated through DogsReminderTableViewController
    // func didUpdateReminders(newReminderList: [Reminder]) {
   //     shouldPromptSaveWarning = true
   //     updatedReminders = newReminderList
   // }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    // MARK: - IB

    @IBOutlet weak var dogIcon: ScaledUIButton!

    @IBOutlet private weak var dogName: UITextField!

    @IBOutlet private weak var embeddedTableView: UIView!

    @IBOutlet private weak var addDogButtonBackground: UIButton!
    @IBOutlet private weak var addDogButton: UIButton!

    @IBAction func didClickIcon(_ sender: Any) {
        let imagePickMethodAlertController = GeneralUIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
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
                let noCameraAlertController  = GeneralUIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                noCameraAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                AlertManager.shared.enqueueAlertForPresentation(noCameraAlertController)
            }
        }

        func openGallary() {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }

        AlertManager.shared.enqueueActionSheetForPresentation(imagePickMethodAlertController, sourceView: dogIcon, permittedArrowDirections: [.up, .down])
    }

    // When the add button is clicked, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction private func willAddDog(_ sender: Any) {
        let updatedDog = targetDog.copy() as! Dog
        // updatedDog.dogReminders.parentDog = updatedDog
        do {
            try updatedDog.dogTraits.changeDogName(newDogName: dogName.text)
            if dogIcon.imageView!.image != DogConstant.chooseIcon {
                updatedDog.dogTraits.icon = dogIcon.imageView?.image ?? DogConstant.defaultIcon
            }

           // if updatedReminders != nil {
           //     try! updatedDog.dogReminders.addReminder(newReminders: //self.updatedReminders!)
           // }

        }
        catch {
            ErrorManager.handleError(sender: Sender(origin: self, localized: self), error: error)
            return
        }

        do {
            if isUpdating == true {
                try delegate.didUpdateDog(sender: Sender(origin: self, localized: self), dogId: targetDog.dogId, updatedDog: updatedDog)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                try delegate.didAddDog(sender: Sender(origin: self, localized: self), newDog: updatedDog)
                self.navigationController?.popViewController(animated: true)
            }
        }
        catch {
            ErrorManager.handleError(sender: Sender(origin: self, localized: self), error: error)
        }

    }

    @IBOutlet weak var dogRemoveButton: UIBarButtonItem!

    @IBAction func willRemoveDog(_ sender: Any) {
        let removeDogConfirmation = GeneralUIAlertController(title: "Are you sure you want to delete \(dogName.text ?? targetDog.dogTraits.dogName)?", message: nil, preferredStyle: .alert)

        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delegate.didRemoveDog(sender: Sender(origin: self, localized: self), dogId: self.targetDog.dogId)
            // self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
            self.navigationController?.popViewController(animated: true)
        }

        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        removeDogConfirmation.addAction(alertActionRemove)
        removeDogConfirmation.addAction(alertActionCancel)

        AlertManager.shared.enqueueAlertForPresentation(removeDogConfirmation)
    }

    @IBOutlet private weak var cancelAddDogButton: UIButton!
    @IBOutlet private weak var cancelAddDogButtonBackground: UIButton!

    @IBAction private func cancelAddDogButton(_ sender: Any) {
        // removed cancelling, everything autosaves now

        if initalValuesChanged == true {
            // "Any changes you have made won't be saved"
            let unsavedInformationConfirmation = GeneralUIAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)

            let alertActionExit = UIAlertAction(title: "Yes, I don't want to save changes", style: .default) { _ in
                // self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
                self.delegate.didCancel(sender: Sender(origin: self, localized: self))
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

    // MARK: - Properties

    var dogsReminderNavigationViewController: DogsReminderNavigationViewController! = nil

    var targetDog: Dog!

    weak var delegate: DogsAddDogViewControllerDelegate! = nil

    var isUpdating: Bool = false

    var isAddingReminder: Bool = false

    // private var updatedReminders: [Reminder]? = nil

    /// Auto save warning will show if true
    private var shouldPromptSaveWarning: Bool = false

    var initalValuesChanged: Bool {
        if dogName.text != targetDog.dogTraits.dogName {
            return true
        }
        else if dogIcon.imageView!.image != DogConstant.chooseIcon && dogIcon.imageView!.image != targetDog.dogTraits.icon {
            return true
        }
        else if shouldPromptSaveWarning == true {
            return true
        }
        else {
            return false
        }
    }

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

    /// Called to initalize all data, if a dog is passed then it uses that, otherwise uses default
    private func willInitalize() {
        // new dog
        if targetDog == nil {
            targetDog = Dog(defaultReminders: true)
        }

        if targetDog.dogTraits.icon.isEqualToImage(image: DogConstant.defaultIcon) {
            dogIcon.setImage(DogConstant.chooseIcon, for: .normal)
        }
        else {
            dogIcon.setImage(targetDog.dogTraits.icon, for: .normal)
        }
        dogIcon.layer.masksToBounds = true
        dogIcon.layer.cornerRadius = dogIcon.frame.width/2

        dogName.text = targetDog.dogTraits.dogName
        // has to copy reminders so changed that arent saved don't use reference data property to make actual modification
        dogsReminderNavigationViewController.didPassReminders(sender: Sender(origin: self, localized: self), passedReminders: targetDog.dogReminders.copy() as! ReminderManager)

        // changes text and performs certain actions if adding a new dog vs updating one
        if isUpdating == true {
            dogRemoveButton.isEnabled = true
            self.navigationItem.title = "Edit Dog"
            if isAddingReminder == true {
                dogsReminderNavigationViewController.dogsReminderTableViewController.performSegue(withIdentifier: "dogsNestedReminderViewController", sender: self)
            }
        }
        else {
            dogRemoveButton.isEnabled = false
            self.navigationItem.title = "Create Dog"
        }
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogReminderNavigationController"{
            dogsReminderNavigationViewController = segue.destination as? DogsReminderNavigationViewController
            dogsReminderNavigationViewController.passThroughDelegate = self
        }

    }
}
