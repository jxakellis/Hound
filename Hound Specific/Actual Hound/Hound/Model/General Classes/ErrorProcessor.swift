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
        
        Utils.willShowAlert(title: "Uh oh! There seems to be an error.", message: message)
        
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
        else if errorProcessorInstance.handleReminderManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleReminderError(sender: sender, error: error) == true {
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
            ErrorProcessor.alertForError(message: "Something went wrong. Please reload and try again! (TME.iF)")
            return true
        }
        else if case TimingManagerError.parseSenderInfoFailed = error {
            ErrorProcessor.alertForError(message: "Something went wrong. Please reload and try again! (TME.pSIF)")
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
            ErrorProcessor.alertForError(message: "Couldn't find a match for a dog with that name. Please reload and try again!")
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
             case noRemindersPresent
         }
         */
        if case DogError.noRemindersPresent = error {
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
            case logUUIDPresent
            case logUUIDNotPresent
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
        else if case TraitManagerError.logUUIDPresent = error {
            ErrorProcessor.alertForError(message: "Something went wrong when trying modify your log, please try again! (TME.lUP)")
            return true
        }
        else if case TraitManagerError.logUUIDNotPresent = error {
            ErrorProcessor.alertForError(message: "Something went wrong when trying modify your log, please try again! (TME.lUNP)")
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
    
    ///Returns true if able to find a match in enum ReminderManagerError to the error provided
    private func handleReminderManagerError(sender: Sender, error: Error) -> Bool{
        /*
         enum ReminderManagerError: Error {
            case reminderAlreadyPresent
             case reminderNotPresent
             case reminderInvalid
             case reminderNameNotPresent
         }
         */
        if case ReminderManagerError.reminderAlreadyPresent = error {
            ErrorProcessor.alertForError(message: "Your reminder seems to already exist. Please reload and try again! (RME.rAP)")
            return true
        }
        else if case ReminderManagerError.reminderNotPresent = error{
            ErrorProcessor.alertForError(message: "Something went wrong when trying to modify your reminder. Please reload and try again! (RME.rNP)")
            return true
        }
        else if case ReminderManagerError.reminderInvalid = error {
            ErrorProcessor.alertForError(message: "Something went wrong when trying to modify your reminder. Please reload and try again! (RME.rI)")
            return true
        }
        else if case ReminderManagerError.reminderUUIDNotPresent = error {
            ErrorProcessor.alertForError(message: "Something went wrong when trying to modify your reminder. Please reload and try again! (RME.rUNP)")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum ReminderError to the error provided
    private func handleReminderError(sender: Sender, error: Error) -> Bool{
        /*
         enum ReminderError: Error {
             case nameBlank
             case nameInvalid
             case descriptionInvalid
             case intervalInvalid
         }
         */
        if case ReminderError.nameInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder name is invalid, please try a different one.")
            return true
        }
        else if case ReminderError.nameBlank = error {
            ErrorProcessor.alertForError(message: "Your reminder's name is blank, try typing something in.")
            return true
        }
        else if case ReminderError.descriptionInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder description is invalid, please try a different one.")
            return true
        }
        else if case ReminderError.intervalInvalid = error {
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
            ErrorProcessor.alertForError(message: "Something went wrong with your reminder. Please reload and try again! (TODCE.iCC)")
            return true
        }
        else if case TimeOfDayComponentsError.invalidWeekdayArray = error {
            ErrorProcessor.alertForError(message: "Please select at least one day of the week for your reminder. You can do this by clicking on the grey S, M, T, W, T, F, or S. A blue letter means that your reminder will be enabled on that day. You can select all seven or only choose one.")
            return true
        }
        else if case TimeOfDayComponentsError.invalidDayOfMonth = error {
            ErrorProcessor.alertForError(message: "Please select a valid day of month.")
            return true
        }
        else if case TimeOfDayComponentsError.bothDayIndicatorsNil = error {
            ErrorProcessor.alertForError(message: "Please select either at least one weekday or select once a month.")
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
             case reminderAlreadyCreated
         }
         */
        if case OneTimeComponentsError.invalidDateComponents = error {
            ErrorProcessor.alertForError(message: "Something went wrong when trying to modify your reminder. Please reload and try again! (OTCE.iDC)")
            return true
        }
        else if case OneTimeComponentsError.invalidCalendarComponent = error {
            ErrorProcessor.alertForError(message: "Something went wrong when trying to modify your reminder. Please reload and try again! (OTCE.iCC)")
            return true
        }
        else if case OneTimeComponentsError.reminderAlreadyCreated = error {
            //no longer occurs
            ErrorProcessor.alertForError(message: "Your reminder cannot be changed into \"Once\" mode. If you would like to use this mode, please create a new reminder.")
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
            ErrorProcessor.alertForError(message: "Something went wrong. Please reload and try again! (SEE.iDC)")
            return true
        }
        else {
            return false
        }
    }
    
}
