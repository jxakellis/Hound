//
//  ImageManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/12/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ImageManager {
    
    /// Processes the information returned by the UIImagePickerController, attempts to create an image from it. In the process it scales the image to the point size of the ScaledUiButton of the dogIcon multiplied by the scale factor of the local screen. For Retina displays, the scale factor may be 3.0 or 2.0 and one point can represented by nine or four pixels, respectively. For standard-resolution displays, the scale factor is 1.0 and one point equals one pixel.
    static func processImage(forDogIcon dogIcon: ScaledUIButton, forInfo info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        
        let scaleFactor = UIScreen.main.scale
        
        let image: UIImage!
        let scaledImageSize = CGSize(width: dogIcon.frame.width * scaleFactor, height: dogIcon.frame.width * scaleFactor)
        
        if let possibleImage = info[.editedImage] as? UIImage {
            image = possibleImage
        }
        else if let possibleImage = info[.originalImage] as? UIImage {
            image = possibleImage
        }
        else {
            return nil
        }
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
    
    /// Creates a GeneralUIAlertController that will prompt the user in the different methods they can choose their dog's Icon (e.g. choose from library or take a new picture) and then creates a UIImagePickerController to facilitate this. Returns a UIImagePickerController which you MUST set its delegate in order to get the image the user picked and returns a GeneralUIAlertController which you must present in order for the user to choose their method of choosing an image
    static func setupDogIconImagePicker(forViewController viewController: UIViewController) -> (UIImagePickerController, GeneralUIAlertController) {
        let imagePicker = UIImagePickerController()
        
        let imagePickMethodAlertController = GeneralUIAlertController(title: "Choose Image", message: "Other family members aren't able to see your personal dog icons", preferredStyle: .actionSheet)
        
        imagePickMethodAlertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                imagePicker.cameraCaptureMode = .photo
                imagePicker.cameraDevice = .rear
                viewController.present(imagePicker, animated: true, completion: nil)
            }
            else {
                let warningAlert  = GeneralUIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                warningAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                AlertManager.enqueueAlertForPresentation(warningAlert)
            }
        }))
        
        imagePickMethodAlertController.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            viewController.present(imagePicker, animated: true, completion: nil)
        }))
        
        imagePickMethodAlertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        return (imagePicker, imagePickMethodAlertController)
    }
}
