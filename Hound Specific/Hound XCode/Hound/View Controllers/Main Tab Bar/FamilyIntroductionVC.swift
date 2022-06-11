//
//  IntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class FamilyIntroductionViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
       
        if let dogIcon = ImageManager.processImage(forDogIcon: dogIcon, forInfo: info) {
            self.dogIcon.setImage(dogIcon, for: .normal)
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var dogsTitle: ScaledUILabel!
    
    @IBOutlet private weak var dogNameHeader: ScaledUILabel!
    
    @IBOutlet private weak var dogNameDescription: ScaledUILabel!
    
    @IBOutlet private weak var dogIcon: ScaledUIButton!
    @IBAction private func didClickIcon(_ sender: Any) {
        AlertManager.enqueueActionSheetForPresentation(imagePickMethodAlertController, sourceView: dogIcon, permittedArrowDirections: [.up, .down])
    }
    
    @IBOutlet private weak var dogName: UITextField!
    
    @IBOutlet private weak var interfaceStyleSegmentedControl: UISegmentedControl!
    @IBAction private func didUpdateInterfaceStyle(_ sender: Any) {
        (sender as! UISegmentedControl).updateInterfaceStyle()
    }
    
    @IBOutlet private weak var continueButton: UIButton!
    /// Clicked continues button at the bottom to dismiss
    @IBAction private func willContinue(_ sender: Any) {
        
        continueButton.isEnabled = false
        // data passage handled in view will disappear as the view can also be swiped down instead of hitting the continue button.
        
        // synchronizes data when setup is done (aka disappearing)
        var dogName: String? {
            if self.dogName.text != nil && self.dogName.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                return self.dogName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
            }
            else {
                return nil
            }
        }
        
        var dogIcon: UIImage? {
            if self.dogIcon.imageView!.image != DogConstant.chooseIconForDog {
                return self.dogIcon.imageView!.image
            }
            else {
                return nil
            }
            
        }
        
        // no dogs so we create a new one for the user
        if dogManager.hasCreatedDog == false {
            // can only fail if dogName == "", but already checked for that and corrected if there was a problem
            let dog = try! Dog(dogName: dogName ?? DogConstant.defaultDogName, dogIcon: dogIcon ?? DogConstant.defaultDogIcon)
            
            // contact server to make their dog
            DogsRequest.create(invokeErrorManager: true, forDog: dog) { dogId, _ in
                if dogId != nil {
                    // go to next page if dog good
                    dog.dogId = dogId!
                    self.dogManager.addDog(newDog: dog)
                    LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = true
                }
                self.continueButton.isEnabled = true
            }
        }
        // updating the icon of an existing dog
        else {
            // if the user chose a dogIcon, then we apply
            if let icon = dogIcon {
                dogManager.dogs[0].dogIcon = icon
                LocalDogIcon.addIcon(forDogId: dogManager.dogs[0].dogId, forDogIcon: icon)
            }
            // close page because updated
            LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = true
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "mainTabBarViewController")
            continueButton.isEnabled = true
        }
        
    }
    
    // MARK: - Properties
    
    var imagePickMethodAlertController: GeneralUIAlertController!
    
    /// The existing dogManager of the user. If they are a new family, then the dogManager will have no dogs.
    var dogManager: DogManager!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dogNameHeader.text = (dogManager.hasCreatedDog == false) ? "What Is Your Dog's Name?" : "Your Dog"
        
        dogNameDescription.text = (dogManager.hasCreatedDog == false) ? "We will generate a basic dog for you. Reminders will come later." : "It looks like your family has already created a dog. Although, if you want, you can add your own custom icon to it."
        
        // Dog Name
        dogName.text = ""
        if dogManager.hasCreatedDog == false {
            dogName.placeholder = "Bella"
            dogName.delegate = self
            dogName.isEnabled = true
            setupToHideKeyboardOnTapOnView()
        }
        else {
            dogName.placeholder = dogManager.dogs[0].dogName
            dogName.isEnabled = false
        }
        
        // Dog Icon
        
        dogIcon.setImage(DogConstant.chooseIconForDog, for: .normal)
        dogIcon.imageView!.layer.masksToBounds = true
        dogIcon.imageView!.layer.cornerRadius = dogIcon.frame.width/2
        
        // Setup AlertController for dogIcon button now, increases responsiveness
        let (picker, viewController) = ImageManager.setupDogIconImagePicker(forViewController: self)
        picker.delegate = self
        imagePickMethodAlertController = viewController
        
        // Theme
        
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        interfaceStyleSegmentedControl.selectedSegmentIndex = 2
        interfaceStyleSegmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white], for: .normal)
        interfaceStyleSegmentedControl.backgroundColor = .systemGray4
        
        // Other
        
        continueButton.layer.cornerRadius = 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainTabBarViewController"{
            let mainTabBarViewController: MainTabBarViewController = segue.destination as! MainTabBarViewController
            mainTabBarViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
        }
    }
}
