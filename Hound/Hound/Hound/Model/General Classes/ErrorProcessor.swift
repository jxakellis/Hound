//
//  ErrorProcessor.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ErrorProcessor{
    
    ///Alerts for an error, just calls Utils.willShowAlert currently with a specified title of "Error"
    static func alertForError(message: String){
        
        Utils.willShowAlert(title: "🚨Error🚨", message: message)
        
    }
    
    private static func alertForErrorProcessor(sender: Sender, message: String){
        let originTest = sender.origin
        if originTest != nil{
            Utils.willShowAlert(title: "🚨Error from \(NSStringFromClass(originTest!.classForCoder))🚨", message: message)
        }
        else {
            Utils.willShowAlert(title: "🚨Error from unknown class🚨", message: message)
        }
        
    }
    
    ///Handles a given error, uses helper functions to compare against all known (custom) error types
    static func handleError(sender: Sender, error: Error){
        
        let errorProcessorInstance = ErrorProcessor()
        
        if errorProcessorInstance.handleTimingManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleDogManagerError(sender: sender, error: error) == true{
            return
        }
        else if errorProcessorInstance.handleDogError(sender: sender, error: error) == true{
            return
        }
        else  if errorProcessorInstance.handleTraitManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleKnownLogTypeError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleRequirementManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleRequirementError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleTimeOfDayComponentsError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleOneTimeComponentsError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleStringExtensionError(sender: sender, error: error) == true {
            return
        }
        else {
            ErrorProcessor.alertForErrorProcessor(sender: sender, message: "Unable to desifer error of description: \(error.localizedDescription)")
        }
    }
    
    ///Returns true if able to find a match in enum TimingManagerError to the error provided
    private func handleTimingManagerError(sender: Sender, error: Error) -> Bool{
        /*
         enum TimingManagerError: Error{
             case parseSenderInfoFailed
             case invalidateFailed
         }
         */
        if case TimingManagerError.invalidateFailed = error {
            ErrorProcessor.alertForError(message: "Unable to invalidate the timer handling a certain reminder")
            return true
        }
        else if case TimingManagerError.parseSenderInfoFailed = error {
            ErrorProcessor.alertForError(message: "Unable to parse sender info in TimingManager")
            return true
        }
        else {
            return false
        }
    }
    
    ///Returns true if able to find a match in enum DogManagerError to the error provided
    private func handleDogManagerError(sender: Sender, error: Error) -> Bool{
        /*
         enum DogManagerError: Error{
             case dogNameBlank
             case dogNameInvalid
             case dogNameNotPresent
             case dogNameAlreadyPresent
         }
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
    
    ///Returns true if able to find a match in enum DogError to the error provided
    private func handleDogError(sender: Sender, error: Error) -> Bool{
        /*
         enum DogError: Error {
             case noRequirementsPresent
         }
         */
        if case DogError.noRequirementsPresent = error {
            ErrorProcessor.alertForError(message: "Your dog has no reminders, please try adding one.")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum TraitManagerError to the error provided
    private func handleTraitManagerError(sender: Sender, error: Error) -> Bool{
        /*
         enum TraitManagerError: Error{
             case nilName
             case blankName
             case invalidName
         }
         */
        if case TraitManagerError.nilName = error {
            ErrorProcessor.alertForError(message: "Your dog has an invalid name, try typing something else in!")
            return true
        }
        else if case TraitManagerError.blankName = error {
            ErrorProcessor.alertForError(message: "Your dog has a blank name, try typing something in!")
            return true
        }
        else if case TraitManagerError.invalidName = error {
            ErrorProcessor.alertForError(message: "Your dog has a invalid name, try typing something else in!")
            return true
        }
        else {
            return false
        }
    }
    
    ///Returns true if able to find a match in enum KnownLogTypeError to the error provided
    private func handleKnownLogTypeError(sender: Sender, error: Error) -> Bool {
        /*
         enum KnownLogTypeError: Error {
             case nilLogType
             case blankLogType
         }
         */
        if case KnownLogTypeError.nilLogType = error {
            ErrorProcessor.alertForError(message: "Your log has no type, try selecting one!")
            return true
        }
        else if case KnownLogTypeError.blankLogType = error {
            ErrorProcessor.alertForError(message: "Your log has no type, try selecting one!")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum RequirementManagerError to the error provided
    private func handleRequirementManagerError(sender: Sender, error: Error) -> Bool{
        /*
         enum RequirementManagerError: Error {
            case requirementAlreadyPresent
             case requirementNotPresent
             case requirementInvalid
             case requirementNameNotPresent
         }
         */
        if case RequirementManagerError.requirementAlreadyPresent = error {
            ErrorProcessor.alertForError(message: "Your reminder's name is already present, please try a different one.")
            return true
        }
        else if case RequirementManagerError.requirementNotPresent = error{
            ErrorProcessor.alertForError(message: "Could not find a match for your reminder!")
            return true
        }
        else if case RequirementManagerError.requirementInvalid = error {
            ErrorProcessor.alertForError(message: "Your reminder is invalid, please try something different.")
            return true
        }
        else if case RequirementManagerError.requirementUUIDNotPresent = error {
            ErrorProcessor.alertForError(message: "Your reminder couldn't be located while attempting to modify its data")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum RequirementError to the error provided
    private func handleRequirementError(sender: Sender, error: Error) -> Bool{
        /*
         enum RequirementError: Error {
             case nameBlank
             case nameInvalid
             case descriptionInvalid
             case intervalInvalid
         }
         */
        if case RequirementError.nameInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder name is invalid, please try a different one.")
            return true
        }
        else if case RequirementError.nameBlank = error {
            ErrorProcessor.alertForError(message: "Your reminder's name is blank, try typing something in.")
            return true
        }
        else if case RequirementError.descriptionInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder description is invalid, please try a different one.")
            return true
        }
        else if case RequirementError.intervalInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder countdown time is invalid, please try a different one.")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum TimeOfDayComponentsError to the error provided
    private func handleTimeOfDayComponentsError(sender: Sender, error: Error) -> Bool{
        /*
         enum TimeOfDayComponentsError: Error {
             case invalidCalendarComponent
             case invalidWeekdayArray
            case invalidDayOfMonth
            case bothDayIndicatorsNil
         }
         */
        if case TimeOfDayComponentsError.invalidCalendarComponent = error {
            ErrorProcessor.alertForError(message: "Invalid Calendar Components for TimeOfDayComponents")
            return true
        }
        else if case TimeOfDayComponentsError.invalidWeekdayArray = error {
            ErrorProcessor.alertForError(message: "Please select atleast one weekday for the reminder to go off on.")
            return true
        }
        else if case TimeOfDayComponentsError.invalidDayOfMonth = error {
            ErrorProcessor.alertForError(message: "Please select a valid day of month.")
            return true
        }
        else if case TimeOfDayComponentsError.bothDayIndicatorsNil = error {
            ErrorProcessor.alertForError(message: "Please select either atleast one weekday or select once a month.")
            return true
        }
        else if case TimeOfDayComponentsError.bothDayIndicatorsActive = error {
            ErrorProcessor.alertForError(message: "Please select either weekdays or once a month for your reminder.")
            return true
        }
        else {
            return false
        }
    }
    
    
    private func handleOneTimeComponentsError(sender: Sender, error: Error) -> Bool{
        /*
         enum OneTimeComponentsError: Error {
             case invalidDateComponents
             case invalidCalendarComponent
             case requirementAlreadyCreated
         }
         */
        if case OneTimeComponentsError.invalidDateComponents = error {
            ErrorProcessor.alertForError(message: "Invalid Date Components for OneTimeComponents")
            return true
        }
        else if case OneTimeComponentsError.invalidCalendarComponent = error {
            ErrorProcessor.alertForError(message: "Invalid Calendar Component for TimeOfDayComponents")
            return true
        }
        else if case OneTimeComponentsError.requirementAlreadyCreated = error {
            ErrorProcessor.alertForError(message: "Your reminder cannot be in \"Once\" mode. If you would like to use this mode, please create a new reminder.")
            return true
        }
        else {
            return false
        }
    }
    
    
    
    private func handleStringExtensionError(sender: Sender, error: Error) -> Bool{
        /*
         enum StringExtensionError: Error {
             case invalidDateComponents
         }
         */
        if case StringExtensionError.invalidDateComponents = error {
            ErrorProcessor.alertForError(message: "Invalid dateComponent passed to String extension.")
            return true
        }
        else {
            return false
        }
    }
    
}
