//
//  ErrorProcessor.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit


class ErrorProcessor: UIViewController, AlertError {
    
    static func handleError(error: Error, classCalledFrom: UIViewController){
        
        //print name of class, e.g. Who_Let_The_Dogs_Out.DogsViewController
        //print(NSStringFromClass(classCalledFrom.classForCoder))
        
        let errorProcessorInstance = ErrorProcessor()
        if errorProcessorInstance.handleDogSpecificationManagerError(error: error, classCalledFrom: classCalledFrom) == true {
            return
        }
        else if errorProcessorInstance.handleDogRequirementError(error: error, classCalledFrom: classCalledFrom) == true {
            return
        }
        else if errorProcessorInstance.handleDogRequirementManagerError(error: error, classCalledFrom: classCalledFrom) == true {
            return
        }
        else if errorProcessorInstance.handleDogManagerError(error: error, classCalledFrom: classCalledFrom) == true{
            return
        }
        else {
            errorProcessorInstance.alertForError(message: "Unable to handle error from \(NSStringFromClass(classCalledFrom.classForCoder)) with ErrorProcessor of error: \(error.localizedDescription)", target: classCalledFrom)
        }
    }
    
    //Returns true if able to find a match in enum DogSpecificationManagerError to the error provided
    private func handleDogSpecificationManagerError(error: Error, classCalledFrom: UIViewController) -> Bool{
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
            alertForError(message: "Big Time Error! Nil Key from \(NSStringFromClass(classCalledFrom.classForCoder))", target: classCalledFrom)
            return true
        }
        else if case DogSpecificationManagerError.blankKey = error {
            alertForError(message: "Big Time Error! Blank Key from \(NSStringFromClass(classCalledFrom.classForCoder))", target: classCalledFrom)
            return true
        }
        else if case DogSpecificationManagerError.invalidKey = error{
            alertForError(message: "Big Time Error! Invalid Key from \(NSStringFromClass(classCalledFrom.classForCoder))", target: classCalledFrom)
            return true
        }
        else if case DogSpecificationManagerError.nilNewValue("name") = error {
            alertForError(message: "Your dog has an invalid name, try typing something else in!", target: classCalledFrom)
            return true
        }
        else if case DogSpecificationManagerError.blankNewValue("name") = error {
            alertForError(message: "Your dog has a blank name, try typing something in!", target: classCalledFrom)
            return true
        }
        //Do not punish for an empty description or breed, theoretically possible to happen though so added
        else if case DogSpecificationManagerError.nilNewValue("description") = error {
            alertForError(message: "Your dog has a invalid description, try typing something else in!", target: classCalledFrom)
            return true
        }
        else if case DogSpecificationManagerError.nilNewValue("breed") = error {
            alertForError(message: "Your dog has a invalid breed, try typing something else in!", target: classCalledFrom)
            return true
        }
        //These should not be needed but are here as they are theoretically possible
        else if case DogSpecificationManagerError.blankNewValue("description") = error {
            alertForError(message: "Your dog has a blank description, try typing something in!", target: classCalledFrom)
            return true
        }
        else if case DogSpecificationManagerError.blankNewValue("breed") = error {
            alertForError(message: "Your dog has a blank breed, try typing something in!", target: classCalledFrom)
            return true
        }
        //These should not be needed but are here as they are theoretically possible
        else if case DogSpecificationManagerError.invalidNewValue("description") = error {
            alertForError(message: "Your dog has an invalid description, try typing something else in!", target: classCalledFrom)
            return true
        }
        else if case DogSpecificationManagerError.invalidNewValue("breed") = error {
            alertForError(message: "Your dog has an invalid breed, try typing something else in!", target: classCalledFrom)
            return true
        }
        else{
            return false
        }
    }
    
    //Returns true if able to find a match in enum DogManagerError to the error provided
    private func handleDogManagerError(error: Error, classCalledFrom: UIViewController) -> Bool{
        /*
         case dogNameNotPresent
         case dogNameAlreadyPresent
         case dogNameInvalid
         case dogNameBlank
         */
        if case DogManagerError.dogNameNotPresent = error {
            alertForError(message: "Could not find a match for a dog matching your name!", target: classCalledFrom)
            return true
        }
        else if case DogManagerError.dogNameAlreadyPresent = error {
            alertForError(message: "Your dog's name is already present, please try a different one.", target: classCalledFrom)
            return true
        }
        else if case DogManagerError.dogNameInvalid = error {
            alertForError(message: "Your dog's name is invalid, please try a different one.", target: classCalledFrom)
            return true
        }
        else if case DogManagerError.dogNameBlank = error {
            alertForError(message: "Your dog's name is blank, try typing something in.", target: classCalledFrom)
            return true
        }
        else{
            return false
        }
    }
    
    //Returns true if able to find a match in enum DogRequirementError to the error provided
    private func handleDogRequirementError(error: Error, classCalledFrom: UIViewController) -> Bool{
        /*
         case labelInvalid
         case descriptionInvalid
         case intervalInvalid
         */
        if case DogRequirementError.labelInvalid = error {
            alertForError(message: "Your dog's requirement name is invalid, please try a different one.", target: classCalledFrom)
            return true
        }
        else if case DogRequirementError.descriptionInvalid = error {
            alertForError(message: "Your dog's requirement description is invalid, please try a different one.", target: classCalledFrom)
            return true
        }
        else if case DogRequirementError.intervalInvalid = error {
            alertForError(message: "Your dog's countdown time is invalid, please try a different one.", target: classCalledFrom)
            return true
        }
        else{
            return false
        }
    }
    
    //Returns true if able to find a match in enum DogRequirementManagerError to the error provided
    private func handleDogRequirementManagerError(error: Error, classCalledFrom: UIViewController) -> Bool{
        /*
         case requirementAlreadyPresent
         case requirementNotPresent
         case requirementInvalid
         */
        if case DogRequirementManagerError.requirementAlreadyPresent = error {
            alertForError(message: "Your requirement's name is already present, please try a different one.", target: classCalledFrom)
            return true
        }
        else if case DogRequirementManagerError.requirementNotPresent = error{
            alertForError(message: "Could not find a match for your requirement!", target: classCalledFrom)
            return true
        }
        else if case DogRequirementManagerError.requirementInvalid = error {
            alertForError(message: "Your requirement is invalid, please try something different.", target: classCalledFrom)
            return true
        }
        else{
            return false
        }
    }
}

