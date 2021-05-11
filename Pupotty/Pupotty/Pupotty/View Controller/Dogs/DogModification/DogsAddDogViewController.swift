//
//  DogsAddDogViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogViewControllerDelegate{
    func didAddDog(sender: Sender, newDog: Dog) throws
    func didUpdateDog(sender: Sender, formerName: String, updatedDog: Dog) throws
    func didRemoveDog(sender: Sender, removedDogName: String)
}

class DogsAddDogViewController: UIViewController, DogsRequirementNavigationViewControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate{
    
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image: UIImage!
        let scaledImageSize = CGSize(width: 90.0, height: 90.0)
    
        if let possibleImage = info[.editedImage] as? UIImage {
            image = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            image = possibleImage
        } else {
            return
        }
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        dogIcon.image = scaledImage

        dismiss(animated: true)
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - Requirement Table VC Delegate
    
    //assume all requirements are valid due to the fact that they are all checked and validated through DogsRequirementTableViewController
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        shouldPromptSaveWarning = true
        updatedRequirements = newRequirementList
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - IB
    
    
    @IBOutlet weak var dogIcon: UIImageView!
    
    @IBOutlet private weak var dogName: UITextField!
    
    @IBOutlet private weak var embeddedTableView: UIView!
    
    @IBOutlet private weak var addDogButtonBackground: UIButton!
    @IBOutlet private weak var addDogButton: UIButton!
    //When the add button is clicked, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction private func willAddDog(_ sender: Any) {
        
        let updatedDog = targetDog.copy() as! Dog
        
        do{
            try updatedDog.dogTraits.changeDogName(newDogName: dogName.text)
            if dogIcon.image != DogConstant.chooseIcon{
                updatedDog.dogTraits.icon = dogIcon.image ?? DogConstant.defaultIcon
            }
            
            
            if updatedRequirements != nil {
                updatedDog.dogRequirments.requirements.removeAll()
                try! updatedDog.dogRequirments.addRequirement(newRequirements: self.updatedRequirements!)
            }
            
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
            return
        }
        
        
        do{
            if isUpdating == true{
                try delegate.didUpdateDog(sender: Sender(origin: self, localized: self), formerName: targetDog.dogTraits.dogName, updatedDog: updatedDog)
                //self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
                self.navigationController?.popViewController(animated: true)
            }
            else{
                try delegate.didAddDog(sender: Sender(origin: self, localized: self), newDog: updatedDog)
                //self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
                self.navigationController?.popViewController(animated: true)
            }
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
        
    }
    
    @IBOutlet weak var dogRemoveButton: UIBarButtonItem!
    
    @IBAction func willRemoveDog(_ sender: Any) {
        let removeDogConfirmation = GeneralAlertController(title: "Are you sure you want to delete \"\(dogName.text ?? targetDog.dogTraits.dogName)\"", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            self.delegate.didRemoveDog(sender: Sender(origin: self, localized: self), removedDogName: self.targetDog.dogTraits.dogName)
            //self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
            self.navigationController?.popViewController(animated: true)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(alertActionRemove)
        removeDogConfirmation.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueAlertForPresentation(removeDogConfirmation)
    }
    
    @IBOutlet private weak var cancelAddDogButton: UIButton!
    @IBOutlet private weak var cancelAddDogButtonBackground: UIButton!
    
    @IBAction private func cancelAddDogButton(_ sender: Any) {
        if dogName.text != targetDog.dogTraits.dogName{
            shouldPromptSaveWarning = true
        }
        
        if shouldPromptSaveWarning == true {
            //"Any changes you have made won't be saved"
            let unsavedInformationConfirmation = GeneralAlertController(title: "Are you sure you want to exit?", message: nil, preferredStyle: .alert)
            
            let alertActionExit = UIAlertAction(title: "Yes, I don't want to save my new changes", style: .default) { (UIAlertAction) in
                //self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
                self.navigationController?.popViewController(animated: true)
            }
            
            let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            unsavedInformationConfirmation.addAction(alertActionExit)
            unsavedInformationConfirmation.addAction(alertActionCancel)
            
            AlertPresenter.shared.enqueueAlertForPresentation(unsavedInformationConfirmation)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }

    //MARK: - Properties
    
    var dogsRequirementNavigationViewController: DogsRequirementNavigationViewController! = nil
    
    var targetDog = Dog()
    
    var delegate: DogsAddDogViewControllerDelegate! = nil
    
    var isUpdating: Bool = false
    
    var isAddingRequirement: Bool = false
    
    private var updatedRequirements: [Requirement]? = nil
    
    ///Auto save warning will show if true
    private var shouldPromptSaveWarning: Bool = false
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupToHideKeyboardOnTapOnView()
        
        let iconTap = UITapGestureRecognizer(target: self, action: #selector(didClickIcon))
        iconTap.delegate = self
        iconTap.cancelsTouchesInView = false
        dogIcon.isUserInteractionEnabled = true
        dogIcon.addGestureRecognizer(iconTap)
        
        self.view.bringSubviewToFront(addDogButtonBackground)
        self.view.bringSubviewToFront(addDogButton)

        self.view.bringSubviewToFront(cancelAddDogButtonBackground)
        self.view.bringSubviewToFront(cancelAddDogButton)
        
        dogName.delegate = self
        
        willInitalize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    ///Called to initalize all data, if a dog is passed then it uses that, otherwise uses default
    private func willInitalize(){
        if targetDog.dogTraits.icon == DogConstant.defaultIcon {
            dogIcon.image = DogConstant.chooseIcon
        }
        else {
            dogIcon.image = targetDog.dogTraits.icon
        }
        dogIcon.layer.masksToBounds = true
        dogIcon.layer.cornerRadius = dogIcon.frame.width/2
        
        dogName.text = targetDog.dogTraits.dogName
        //has to copy requirements so changed that arent saved don't use reference data property to make actual modification
        dogsRequirementNavigationViewController.didPassRequirements(sender: Sender(origin: self, localized: self), passedRequirements: targetDog.dogRequirments.copy() as! RequirementManager)
        
        //changes text and performs certain actions if adding a new dog vs updating one
        if isUpdating == true {
            dogRemoveButton.isEnabled = true
            self.navigationItem.title = "Edit Dog"
            if isAddingRequirement == true {
                dogsRequirementNavigationViewController.dogsRequirementTableViewController.performSegue(withIdentifier: "dogsNestedRequirementViewController", sender: self)
            }
        }
        else {
            dogRemoveButton.isEnabled = false
            self.navigationItem.title = "Create Dog"
        }
 
    }
    
    @objc private func didClickIcon(){
        let alert = GeneralAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        func openCamera() {
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                imagePicker.cameraCaptureMode = .photo
                imagePicker.cameraDevice = .rear
                self.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                let warningAlert  = GeneralAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                warningAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                AlertPresenter.shared.enqueueAlertForPresentation(warningAlert)
            }
        }

        func openGallary() {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = dogIcon
            alert.popoverPresentationController?.sourceRect = dogIcon.bounds
            alert.popoverPresentationController?.permittedArrowDirections = [.up,.down]
        default:
            break
        }
        
        AlertPresenter.shared.enqueueAlertForPresentation(alert)
    }

    
    
    ///Hides the big gray back button and big blue checkmark, don't want access to them while editting a requirement.
    func willHideButtons(isHidden: Bool){
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
        if segue.identifier == "dogRequirementNavigationController"{
            dogsRequirementNavigationViewController = segue.destination as? DogsRequirementNavigationViewController
            dogsRequirementNavigationViewController.passThroughDelegate = self
        }
        
        
    }
}
