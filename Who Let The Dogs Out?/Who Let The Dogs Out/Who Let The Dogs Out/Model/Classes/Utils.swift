//
//  Utils.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Utils
{
    static var sender: UIViewController = UIViewController.init()
    
    static func willShowAlert(sender: AnyObject = sender, title: String, message: String)
    {
        
        let targetViewController: UIViewController
        
        if !(sender is UIViewController) {
            targetViewController = Utils.sender
        }
        else{
            targetViewController = sender as! UIViewController
        }
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let alertAction = UIAlertAction(
            title:"OK",
            style: .default,
            handler:
                {
                    (alert: UIAlertAction!)  in
                })
        alertController.addAction(alertAction)
        
        if targetViewController.presentedViewController?.isViewLoaded == true{
            targetViewController.presentedViewController?.dismiss(animated: true, completion: {
                    targetViewController.present(alertController, animated: true, completion: nil)
                
            })
        }
        else{
            targetViewController.present(alertController, animated: true, completion: nil)
        }
    }
}

class ErrorProcessor{
    
    static func alertForError(sender: AnyObject = Utils.sender, message: String){
        
        Utils.willShowAlert(sender: sender, title: "Error", message: message)
        /*
        let targetViewController: UIViewController
        
        if !(sender is UIViewController) {
            targetViewController = Utils.sender
        }
        else{
            targetViewController = sender as! UIViewController
        }
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        
        if targetViewController.presentedViewController?.isViewLoaded == true{
            targetViewController.presentedViewController?.dismiss(animated: true, completion: {
                targetViewController.present(alertController, animated: true, completion: nil)
            })
        }
        else{
            targetViewController.present(alertController, animated: true, completion: nil)
        }
         */
        
    }
    
    static func handleError(error: Error, sender: AnyObject){
        
        //print name of class, e.g. Who_Let_The_Dogs_Out.DogsViewController
        //print(NSStringFromClass(classCalledFrom.classForCoder))
        
        let errorProcessorInstance = ErrorProcessor()
        
        if errorProcessorInstance.handleDogSpecificationManagerError(error: error, sender: sender) == true {
            return
        }
        else if errorProcessorInstance.handleDogRequirementError(error: error, sender: sender) == true {
            return
        }
        else if errorProcessorInstance.handleDogRequirementManagerError(error: error, sender: sender) == true {
            return
        }
        else if errorProcessorInstance.handleDogManagerError(error: error, sender: sender) == true{
            return
        }
        else {
            ErrorProcessor.alertForError(message: "Unable to handle error from \(NSStringFromClass(sender.classForCoder)) with ErrorProcessor of error type: \(error.localizedDescription)")
        }
    }
    
    //Returns true if able to find a match in enum DogSpecificationManagerError to the error provided
    private func handleDogSpecificationManagerError(error: Error, sender: AnyObject) -> Bool{
        /*
         case nilKey
         case blankKey
         case invalidKey
         case keyNotPresentInGlobalConstantList
         // the strings are the key that the value used
         case nilNewValue(String)
         case blankNewValue(String)
         case invalidNewValue(String)
         */
        if case DogSpecificationManagerError.nilKey = error {
            ErrorProcessor.alertForError(message: "Big Time Error! Nil Key from \(NSStringFromClass(sender.classForCoder))")
            return true
        }
        else if case DogSpecificationManagerError.blankKey = error {
            ErrorProcessor.alertForError(message: "Big Time Error! Blank Key from \(NSStringFromClass(sender.classForCoder))")
            return true
        }
        else if case DogSpecificationManagerError.invalidKey = error{
            ErrorProcessor.alertForError(message: "Big Time Error! Invalid Key from \(NSStringFromClass(sender.classForCoder))")
            return true
        }
        else if case DogSpecificationManagerError.nilNewValue("name") = error {
            ErrorProcessor.alertForError(message: "Your dog has an invalid name, try typing something else in!")
            return true
        }
        else if case DogSpecificationManagerError.blankNewValue("name") = error {
            ErrorProcessor.alertForError(message: "Your dog has a blank name, try typing something in!")
            return true
        }
        //Do not punish for an empty description or breed, theoretically possible to happen though so added
        else if case DogSpecificationManagerError.nilNewValue("description") = error {
            ErrorProcessor.alertForError(message: "Your dog has a invalid description, try typing something else in!")
            return true
        }
        else if case DogSpecificationManagerError.nilNewValue("breed") = error {
            ErrorProcessor.alertForError(message: "Your dog has a invalid breed, try typing something else in!")
            return true
        }
        //These should not be needed but are here as they are theoretically possible
        else if case DogSpecificationManagerError.blankNewValue("description") = error {
            ErrorProcessor.alertForError(message: "Your dog has a blank description, try typing something in!")
            return true
        }
        else if case DogSpecificationManagerError.blankNewValue("breed") = error {
            ErrorProcessor.alertForError(message: "Your dog has a blank breed, try typing something in!")
            return true
        }
        //These should not be needed but are here as they are theoretically possible
        else if case DogSpecificationManagerError.invalidNewValue("description") = error {
            ErrorProcessor.alertForError(message: "Your dog has an invalid description, try typing something else in!")
            return true
        }
        else if case DogSpecificationManagerError.invalidNewValue("breed") = error {
            ErrorProcessor.alertForError(message: "Your dog has an invalid breed, try typing something else in!")
            return true
        }
        else{
            return false
        }
    }
    
    //Returns true if able to find a match in enum DogManagerError to the error provided
    private func handleDogManagerError(error: Error, sender: AnyObject) -> Bool{
        /*
         case dogNameNotPresent
         case dogNameAlreadyPresent
         case dogNameInvalid
         case dogNameBlank
         */
        if case DogManagerError.dogNameNotPresent = error {
            ErrorProcessor.alertForError(message: "Could not find a match for a dog matching your name!")
            return true
        }
        else if case DogManagerError.dogNameAlreadyPresent = error {
            ErrorProcessor.alertForError(message: "Your dog's name is already present, please try a different one.")
            return true
        }
        else if case DogManagerError.dogNameInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's name is invalid, please try a different one.")
            return true
        }
        else if case DogManagerError.dogNameBlank = error {
            ErrorProcessor.alertForError(message: "Your dog's name is blank, try typing something in.")
            return true
        }
        else{
            return false
        }
    }
    
    //Returns true if able to find a match in enum DogRequirementError to the error provided
    private func handleDogRequirementError(error: Error, sender: AnyObject) -> Bool{
        /*
         case labelInvalid
         case descriptionInvalid
         case intervalInvalid
         */
        if case DogRequirementError.labelInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's requirement name is invalid, please try a different one.")
            return true
        }
        else if case DogRequirementError.descriptionInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's requirement description is invalid, please try a different one.")
            return true
        }
        else if case DogRequirementError.intervalInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's countdown time is invalid, please try a different one.")
            return true
        }
        else{
            return false
        }
    }
    
    //Returns true if able to find a match in enum DogRequirementManagerError to the error provided
    private func handleDogRequirementManagerError(error: Error, sender: AnyObject) -> Bool{
        /*
         case requirementAlreadyPresent
         case requirementNotPresent
         case requirementInvalid
         */
        if case DogRequirementManagerError.requirementAlreadyPresent = error {
            ErrorProcessor.alertForError(message: "Your requirement's name is already present, please try a different one.")
            return true
        }
        else if case DogRequirementManagerError.requirementNotPresent = error{
            ErrorProcessor.alertForError(message: "Could not find a match for your requirement!")
            return true
        }
        else if case DogRequirementManagerError.requirementInvalid = error {
            ErrorProcessor.alertForError(message: "Your requirement is invalid, please try something different.")
            return true
        }
        else{
            return false
        }
    }
}

