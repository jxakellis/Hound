//
//  IntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
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
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var dogNameDescription: ScaledUILabel!
    
    @IBOutlet private weak var dogIcon: ScaledUIButton!
    
    @IBOutlet private weak var dogName: UITextField!
    
    @IBOutlet private weak var interfaceStyleSegmentedControl: UISegmentedControl!
    
    @IBAction private func segmentedControl(_ sender: Any) {
        var convertedInterfaceStyleRawValue: Int?
        let beforeUpdateInterfaceStyle = UserConfiguration.interfaceStyle
        
        switch interfaceStyleSegmentedControl.selectedSegmentIndex {
        case 0:
            convertedInterfaceStyleRawValue = 1
            UIApplication.keyWindow?.overrideUserInterfaceStyle = .light
            UserConfiguration.interfaceStyle = .light
        case 1:
            convertedInterfaceStyleRawValue = 2
            UIApplication.keyWindow?.overrideUserInterfaceStyle = .dark
            UserConfiguration.interfaceStyle = .dark
        default:
            convertedInterfaceStyleRawValue = 0
            UIApplication.keyWindow?.overrideUserInterfaceStyle = .unspecified
            UserConfiguration.interfaceStyle = .unspecified
        }
        
        let body = [UserDefaultsKeys.interfaceStyle.rawValue: convertedInterfaceStyleRawValue!]
        UserRequest.update(body: body) { requestWasSuccessful in
            if requestWasSuccessful == false {
                // error, revert to previous
                UIApplication.keyWindow?.overrideUserInterfaceStyle = beforeUpdateInterfaceStyle
                UserConfiguration.interfaceStyle = beforeUpdateInterfaceStyle
                switch UserConfiguration.interfaceStyle.rawValue {
                    // system/unspecified
                case 0:
                    self.interfaceStyleSegmentedControl.selectedSegmentIndex = 2
                    // light
                case 1:
                    self.interfaceStyleSegmentedControl.selectedSegmentIndex = 0
                    // dark
                case 2:
                    self.interfaceStyleSegmentedControl.selectedSegmentIndex = 1
                default:
                    self.interfaceStyleSegmentedControl.selectedSegmentIndex = 2
                }
            }
        }
    }
    
    @IBOutlet private weak var continueButton: UIButton!
    
    /// Clicked continues button at the bottom to dismiss
    @IBAction private func willContinue(_ sender: Any) {
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
            if self.dogIcon.imageView!.image != DogConstant.chooseIcon {
                return self.dogIcon.imageView!.image
            }
            else {
                return nil
            }
            
        }
        
        // can only fail if dogName == "", but already checked for that and corrected if there was a problem
        let dog = try! Dog(dogName: dogName ?? DogConstant.defaultDogName, dogIcon: dogIcon ?? DogConstant.defaultIcon)
        
        // contact server to make their dog
        DogsRequest.create(forDog: dog) { dogId in
            if dogId != nil {
                // go to next page if dog good
                dog.dogId = dogId!
                self.dog = dog
                LocalConfiguration.hasLoadedIntroductionViewControllerBefore = true
                Utils.performSegueOnceInWindowHierarchy(segueIdentifier: "mainTabBarViewController", viewController: self)
            }
        }
    }
    
    @IBAction private func didClickIcon(_ sender: Any) {
        AlertManager.enqueueActionSheetForPresentation(imagePickMethodAlertController, sourceView: dogIcon, permittedArrowDirections: [.up, .down])
    }
    
    // MARK: - Properties
    
    let imagePickMethodAlertController = GeneralUIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    
    private var dog: Dog!
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.layer.cornerRadius = 8.0
        
        dogIcon.setImage(DogConstant.chooseIcon, for: .normal)
        dogIcon.imageView!.layer.masksToBounds = true
        dogIcon.imageView!.layer.cornerRadius = dogIcon.frame.width/2
        
        dogName.delegate = self
        
        UIApplication.keyWindow?.overrideUserInterfaceStyle = .unspecified
        UserConfiguration.interfaceStyle = .unspecified
        
        interfaceStyleSegmentedControl.selectedSegmentIndex = 2
        interfaceStyleSegmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white], for: .normal)
        interfaceStyleSegmentedControl.backgroundColor = .systemGray4
        
        self.setupToHideKeyboardOnTapOnView()
        
        // Setup AlertController for icon button now, increases responsiveness
        setupDogIconImagePicker()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        if segue.identifier == "mainTabBarViewController"{
            let mainTabBarViewController: MainTabBarViewController = segue.destination as! MainTabBarViewController
            let dogManager = DogManager(forDogs: [dog])
            mainTabBarViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
        }
    }
}
