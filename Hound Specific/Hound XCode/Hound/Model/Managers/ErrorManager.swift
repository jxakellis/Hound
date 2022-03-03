//
//  ErrorManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ErrorManager {

    /// Alerts for an error, just calls AlertManager.willShowAlert currently with a specified title of "Error"
    static func alertForError(message: String) {

        AlertManager.willShowAlert(title: "Uh oh! There seems to be an error.", message: message)

    }

    private static func alertForErrorManager(sender: Sender, message: String) {
        let originTest = sender.origin
        if originTest != nil {
            AlertManager.willShowAlert(title: "🚨Error from \(NSStringFromClass(originTest!.classForCoder))🚨", message: message)
        }
        else {
            AlertManager.willShowAlert(title: "🚨Error from unknown class🚨", message: message)
        }

    }

    /// Handles a given error, uses helper functions to compare against all known (custom) error types
    static func handleError(sender: Sender, error: Error) {

        let errorManagerInstance = ErrorManager()

        if errorManagerInstance.handleTimingManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorManagerInstance.handleDogManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorManagerInstance.handleDogError(sender: sender, error: error) == true {
            return
        }
        else  if errorManagerInstance.handleTraitManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorManagerInstance.handleKnownLogTypeError(sender: sender, error: error) == true {
            return
        }
        else if errorManagerInstance.handleReminderManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorManagerInstance.handleReminderError(sender: sender, error: error) == true {
            return
        }
        else if errorManagerInstance.handleTimeOfDayComponentsError(sender: sender, error: error) == true {
            return
        }
        else if errorManagerInstance.handleOneTimeComponentsError(sender: sender, error: error) == true {
            return
        }
        else if errorManagerInstance.handleStringExtensionError(sender: sender, error: error) == true {
            return
        }
        else {
            ErrorManager.alertForErrorManager(sender: sender, message: "Unable to desifer error of description: \(error.localizedDescription)")
        }
    }

    /// Returns true if able to find a match in enum TimingManagerError to the error provided
    private func handleTimingManagerError(sender: Sender, error: Error) -> Bool {
        /*
         enum TimingManagerError: Error{
             case parseSenderInfoFailed
             case invalidateFailed
         }
         */
        if case TimingManagerError.invalidateFailed = error {
            ErrorManager.alertForError(message: "Something went wrong. Please reload and try again! (TME.iF)")
            return true
        }
        else if case TimingManagerError.parseSenderInfoFailed = error {
            ErrorManager.alertForError(message: "Something went wrong. Please reload and try again! (TME.pSIF)")
            return true
        }
        else {
            return false
        }
    }

    /// Returns true if able to find a match in enum DogManagerError to the error provided
    private func handleDogManagerError(sender: Sender, error: Error) -> Bool {
        /*
         enum DogManagerError: Error{
             case dogNameBlank
             case dogNameInvalid
             case dogNameNotPresent
             case dogIdAlreadyPresent
         }
         */
        if case DogManagerError.dogIdNotPresent = error {
            ErrorManager.alertForError(message: "Couldn't find a match for a dog with that name. Please reload and try again!")
            return true
        }
        else if case DogManagerError.dogIdAlreadyPresent = error {
            ErrorManager.alertForError(message: "Your dog's name is already present, please try a different one.")
            return true
        }
        else if case DogManagerError.dogIdInvalid = error {
            ErrorManager.alertForError(message: "Your dog's name is invalid, please try a different one.")
            return true
        }
        else if case DogManagerError.dogNameBlank = error {
            ErrorManager.alertForError(message: "Your dog's name is blank, try typing something in.")
            return true
        }
        else {
            return false
        }
    }

    /// Returns true if able to find a match in enum DogError to the error provided
    private func handleDogError(sender: Sender, error: Error) -> Bool {
        /*
         enum DogError: Error {
             case noRemindersPresent
         }
         */
        if case DogError.noRemindersPresent = error {
            ErrorManager.alertForError(message: "Your dog has no reminders, please try adding one.")
            return true
        }
        else {
            return false
        }
    }

    /// Returns true if able to find a match in enum TraitManagerError to the error provided
    private func handleTraitManagerError(sender: Sender, error: Error) -> Bool {
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
            ErrorManager.alertForError(message: "Your dog has an invalid name, try typing something else in!")
            return true
        }
        else if case TraitManagerError.blankName = error {
            ErrorManager.alertForError(message: "Your dog has a blank name, try typing something in!")
            return true
        }
        else if case TraitManagerError.invalidName = error {
            ErrorManager.alertForError(message: "Your dog has a invalid name, try typing something else in!")
            return true
        }
        else if case TraitManagerError.logIdPresent = error {
            ErrorManager.alertForError(message: "Something went wrong when trying modify your log, please try again! (TME.lIP)")
            return true
        }
        else if case TraitManagerError.logIdNotPresent = error {
            ErrorManager.alertForError(message: "Something went wrong when trying modify your log, please try again! (TME.lINP)")
            return true
        }
        else {
            return false
        }
    }

    /// Returns true if able to find a match in enum KnownLogTypeError to the error provided
    private func handleKnownLogTypeError(sender: Sender, error: Error) -> Bool {
        /*
         enum KnownLogTypeError: Error {
             case nilLogType
             case blankLogType
         }
         */
        if case KnownLogTypeError.nilLogType = error {
            ErrorManager.alertForError(message: "Your log has no type, try selecting one!")
            return true
        }
        else if case KnownLogTypeError.blankLogType = error {
            ErrorManager.alertForError(message: "Your log has no type, try selecting one!")
            return true
        }
        else {
            return false
        }
    }

    /// Returns true if able to find a match in enum ReminderManagerError to the error provided
    private func handleReminderManagerError(sender: Sender, error: Error) -> Bool {
        /*
         enum ReminderManagerError: Error {
            case reminderAlreadyPresent
             case reminderNotPresent
             case reminderInvalid
             case reminderNameNotPresent
         }
         */
        if case ReminderManagerError.reminderIdAlreadyPresent = error {
            ErrorManager.alertForError(message: "Your reminder seems to already exist. Please reload and try again! (RME.rIAP)")
            return true
        }
        else if case ReminderManagerError.reminderIdNotPresent = error {
            ErrorManager.alertForError(message: "Something went wrong when trying to modify your reminder. Please reload and try again! (RME.rINP)")
            return true
        }
        else {
            return false
        }
    }

    /// Returns true if able to find a match in enum ReminderError to the error provided
    private func handleReminderError(sender: Sender, error: Error) -> Bool {
        /*
         enum ReminderError: Error {
             case nameBlank
             case nameInvalid
             case descriptionInvalid
             case intervalInvalid
         }
         */
        if case ReminderError.nameInvalid = error {
            ErrorManager.alertForError(message: "Your dog's reminder name is invalid, please try a different one.")
            return true
        }
        else if case ReminderError.nameBlank = error {
            ErrorManager.alertForError(message: "Your reminder's name is blank, try typing something in.")
            return true
        }
        else if case ReminderError.descriptionInvalid = error {
            ErrorManager.alertForError(message: "Your dog's reminder description is invalid, please try a different one.")
            return true
        }
        else if case ReminderError.intervalInvalid = error {
            ErrorManager.alertForError(message: "Your dog's reminder countdown time is invalid, please try a different one.")
            return true
        }
        else {
            return false
        }
    }

    /// Returns true if able to find a match in enum TimeOfDayComponentsError to the error provided
    private func handleTimeOfDayComponentsError(sender: Sender, error: Error) -> Bool {
        /*
         enum TimeOfDayComponentsError: Error {
             case invalidCalendarComponent
             case invalidWeekdayArray
            case invalidDayOfMonth
            case bothDayIndicatorsNil
         }
         */
        if case TimeOfDayComponentsError.invalidCalendarComponent = error {
            ErrorManager.alertForError(message: "Something went wrong with your reminder. Please reload and try again! (TODCE.iCC)")
            return true
        }
        else if case TimeOfDayComponentsError.invalidWeekdayArray = error {
            ErrorManager.alertForError(message: "Please select at least one day of the week for your reminder. You can do this by clicking on the grey S, M, T, W, T, F, or S. A blue letter means that your reminder will be enabled on that day. You can select all seven or only choose one.")
            return true
        }
        else if case TimeOfDayComponentsError.invalidDayOfMonth = error {
            ErrorManager.alertForError(message: "Please select a valid day of month.")
            return true
        }
        else if case TimeOfDayComponentsError.bothDayIndicatorsNil = error {
            ErrorManager.alertForError(message: "Please select either at least one weekday or select once a month.")
            return true
        }
        else if case TimeOfDayComponentsError.bothDayIndicatorsActive = error {
            ErrorManager.alertForError(message: "Please select either weekdays or once a month for your reminder.")
            return true
        }
        else {
            return false
        }
    }

    private func handleOneTimeComponentsError(sender: Sender, error: Error) -> Bool {
        /*
         enum OneTimeComponentsError: Error {
             case invalidDateComponents
             case invalidCalendarComponent
             case reminderAlreadyCreated
         }
         */
        if case OneTimeComponentsError.invalidDateComponents = error {
            ErrorManager.alertForError(message: "Something went wrong when trying to modify your reminder. Please reload and try again! (OTCE.iDC)")
            return true
        }
        else if case OneTimeComponentsError.invalidCalendarComponent = error {
            ErrorManager.alertForError(message: "Something went wrong when trying to modify your reminder. Please reload and try again! (OTCE.iCC)")
            return true
        }
        else if case OneTimeComponentsError.reminderAlreadyCreated = error {
            // no longer occurs
            ErrorManager.alertForError(message: "Your reminder cannot be changed into \"Once\" mode. If you would like to use this mode, please create a new reminder.")
            return true
        }
        else {
            return false
        }
    }

    private func handleStringExtensionError(sender: Sender, error: Error) -> Bool {
        /*
         enum StringExtensionError: Error {
             case invalidDateComponents
         }
         */
        if case StringExtensionError.dateComponentsInvalid = error {
            ErrorManager.alertForError(message: "Something went wrong. Please reload and try again! (SEE.iDC)")
            return true
        }
        else {
            return false
        }
    }

}
