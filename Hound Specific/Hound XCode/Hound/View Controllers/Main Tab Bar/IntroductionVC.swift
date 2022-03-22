//
//  IntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol IntroductionViewControllerDelegate: AnyObject {
    func didSetDogName(sender: Sender, dogName: String)
    func didSetDogIcon(sender: Sender, dogIcon: UIImage)
}

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
    
    @IBOutlet private weak var interfaceSegmentedControl: UISegmentedControl!
    
    @IBAction private func segmentedControl(_ sender: Any) {
        switch interfaceSegmentedControl.selectedSegmentIndex {
        case 0:
            UIApplication.keyWindow?.overrideUserInterfaceStyle = .light
            UserConfiguration.interfaceStyle = .light
        case 1:
            UIApplication.keyWindow?.overrideUserInterfaceStyle = .dark
            UserConfiguration.interfaceStyle = .dark
        default:
            UIApplication.keyWindow?.overrideUserInterfaceStyle = .unspecified
            UserConfiguration.interfaceStyle = .unspecified
        }
    }
    
    @IBOutlet private weak var continueButton: UIButton!
    
    /// Clicked continues button at the bottom to dismiss
    @IBAction private func willContinue(_ sender: Any) {
        // data passage handled in view will disappear as the view can also be swiped down instead of hitting the continue button.
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didClickIcon(_ sender: Any) {
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
                let warningAlert  = GeneralUIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                warningAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                AlertManager.shared.enqueueAlertForPresentation(warningAlert)
            }
        }
        
        func openGallary() {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        
        AlertManager.shared.enqueueActionSheetForPresentation(imagePickMethodAlertController, sourceView: dogIcon, permittedArrowDirections: [.up, .down])
    }
    
    // MARK: - Properties
    
    weak var delegate: IntroductionViewControllerDelegate! = nil
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.layer.cornerRadius = 8.0
        
        /*
         dogIcon.image = DogConstant.chooseIcon
         dogIcon.layer.masksToBounds = true
         dogIcon.layer.cornerRadius = dogIcon.frame.width/2
         
         dogIcon.isUserInteractionEnabled = true
         let iconTap = UITapGestureRecognizer(target: self, action: #selector(didClickIcon))
         iconTap.delegate = self
         iconTap.cancelsTouchesInView = false
         dogIcon.isUserInteractionEnabled = true
         dogIcon.addGestureRecognizer(iconTap)
         */
        
        dogIcon.setImage(DogConstant.chooseIcon, for: .normal)
        dogIcon.imageView!.layer.masksToBounds = true
        dogIcon.imageView!.layer.cornerRadius = dogIcon.frame.width/2
        
        dogName.delegate = self
        
        UIApplication.keyWindow?.overrideUserInterfaceStyle = .unspecified
        UserConfiguration.interfaceStyle = .unspecified
        
        interfaceSegmentedControl.selectedSegmentIndex = 2
        interfaceSegmentedControl.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white], for: .normal)
        interfaceSegmentedControl.backgroundColor = .systemGray4
        
        self.setupToHideKeyboardOnTapOnView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // setupConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // synchronizes data when setup is done (aka disappearing)
        if dogName.text != nil && dogName.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            delegate.didSetDogName(sender: Sender(origin: self, localized: self), dogName: dogName.text!)
            
        }
        if dogIcon.imageView!.image != DogConstant.chooseIcon {
            delegate.didSetDogIcon(sender: Sender(origin: self, localized: self), dogIcon: dogIcon.imageView!.image!)
        }
        
        // once this view has completed (user swiped it away or hit continue) then we can say its been compelete.
        LocalConfiguration.hasLoadedIntroductionViewControllerBefore = true
    }
}
