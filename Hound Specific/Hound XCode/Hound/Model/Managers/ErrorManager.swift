//
//  ErrorManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ErrorManager {
    
    /// Alerts for an unspecified error. Title is default with a parameter specified message
    static func alert(forMessage message: String) {
        
        AlertManager.willShowAlert(title: "Uh oh! There seems to be an error.", message: message)
        
    }
    
    /// Alerts for a unspecified error from a specified location. Title is extracted from sender with a parameter specified message
    static private func alertForUnknown(error: Error) {
        
        AlertManager.willShowAlert(title: "Uh oh! There seems to be an error.", message: "Bizarre, there seems to be an unknown problem occuring! Please restart and/or reinstall Hound if issues persist.")
        
        AppDelegate.generalLogger.error("Unknown error: \(error.localizedDescription)")
        
    }
    
    /// Handles a given error, uses helper functions to compare against all known (custom) error types
    static func alert(forError error: Error) {
        
        let errorManagerInstance = ErrorManager()
        
        if errorManagerInstance.handleTimingManagerError(error: error) == true {
            return
        }
        else if errorManagerInstance.handleDogManagerError(error: error) == true {
            return
        }
        else if errorManagerInstance.handleDogError(error: error) == true {
            return
        }
        else  if errorManagerInstance.handleLogManagerError(error: error) == true {
            return
        }
        else if errorManagerInstance.handleLogTypeError(error: error) == true {
            return
        }
        else if errorManagerInstance.handleReminderManagerError(error: error) == true {
            return
        }
        else if errorManagerInstance.handleReminderError(error: error) == true {
            return
        }
        else if errorManagerInstance.handleWeeklyComponentsError(error: error) == true {
            return
        }
        else if errorManagerInstance.handleMonthlyComponentsError(error: error) == true {
            return
        }
        else if errorManagerInstance.handleStringExtensionError(error: error) == true {
            return
        }
        else if errorManagerInstance.handleGeneralResponseError(error: error ) == true {
            return
        }
        else {
            ErrorManager.alertForUnknown(error: error)
        }
    }
    
    /// Returns true if able to find a match in enum TimingManagerError to the error provided
    private func handleTimingManagerError(error: Error) -> Bool {
        /*
         enum TimingManagerError: Error{
         case parseSenderInfoFailed
         case invalidateFailed
         }
         */
        if case TimingManagerError.invalidateFailed = error {
            ErrorManager.alert(forMessage: "Something went wrong. Please reload and try again! (TME.iF)")
            return true
        }
        else if case TimingManagerError.parseSenderInfoFailed = error {
            ErrorManager.alert(forMessage: "Something went wrong. Please reload and try again! (TME.pSIF)")
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum DogManagerError to the error provided
    private func handleDogManagerError(error: Error) -> Bool {
        /*
         enum DogManagerError: Error {
         case dogIdNotPresent
         }
         */
        if case DogManagerError.dogIdNotPresent = error {
            ErrorManager.alert(forMessage: "Couldn't find a match for a dog with that name. Please reload and try again!")
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum DogError to the error provided
    private func handleDogError(error: Error) -> Bool {
        /*
         enum DogError: Error {
         case nilName
         case blankName
         }
         */
        if case DogError.dogNameNil = error {
            ErrorManager.alert(forMessage: "Your dog's name is invalid, please try a different one.")
            return true
        }
        else if case DogError.dogNameBlank = error {
            ErrorManager.alert(forMessage: "Your dog's name is blank, try typing something in.")
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum TraitManagerError to the error provided
    private func handleLogManagerError(error: Error) -> Bool {
        /*
         enum LogManagerError: Error {
         case logIdPresent
         case logIdNotPresent
         }
         */
        if case LogManagerError.logIdPresent = error {
            ErrorManager.alert(forMessage: "Something went wrong when trying modify your log, please try again! (LME.lIP)")
            return true
        }
        else if case LogManagerError.logIdNotPresent = error {
            ErrorManager.alert(forMessage: "Something went wrong when trying modify your log, please try again! (LME.lINP)")
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum LogTypeError to the error provided
    private func handleLogTypeError(error: Error) -> Bool {
        /*
         enum LogTypeError: Error {
         case nilLogType
         case blankLogType
         }
         */
        if case LogTypeError.nilLogType = error {
            ErrorManager.alert(forMessage: "Your log has no type, try selecting one!")
            return true
        }
        else if case LogTypeError.blankLogType = error {
            ErrorManager.alert(forMessage: "Your log has no type, try selecting one!")
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum ReminderManagerError to the error provided
    private func handleReminderManagerError(error: Error) -> Bool {
        /*
         enum ReminderManagerError: Error {
         case reminderAlreadyPresent
         case reminderNotPresent
         case reminderInvalid
         case reminderNameNotPresent
         }
         */
        if case ReminderManagerError.reminderIdAlreadyPresent = error {
            ErrorManager.alert(forMessage: "Your reminder seems to already exist. Please reload and try again! (RME.rIAP)")
            return true
        }
        else if case ReminderManagerError.reminderIdNotPresent = error {
            ErrorManager.alert(forMessage: "Something went wrong when trying to modify your reminder. Please reload and try again! (RME.rINP)")
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum ReminderError to the error provided
    private func handleReminderError(error: Error) -> Bool {
        /*
         enum ReminderError: Error {
         case nameBlank
         case nameInvalid
         case descriptionInvalid
         case intervalInvalid
         }
         */
        if case ReminderError.nameInvalid = error {
            ErrorManager.alert(forMessage: "Your dog's reminder name is invalid, please try a different one.")
            return true
        }
        else if case ReminderError.nameBlank = error {
            ErrorManager.alert(forMessage: "Your reminder's name is blank, try typing something in.")
            return true
        }
        else if case ReminderError.descriptionInvalid = error {
            ErrorManager.alert(forMessage: "Your dog's reminder description is invalid, please try a different one.")
            return true
        }
        else if case ReminderError.intervalInvalid = error {
            ErrorManager.alert(forMessage: "Your dog's reminder countdown time is invalid, please try a different one.")
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum TimeOfDayComponentsError to the error provided
    private func handleWeeklyComponentsError(error: Error) -> Bool {
        /*
         enum TimeOfDayComponentsError: Error {
         case weekdayArrayInvalid
         }
         */
        if case WeeklyComponentsError.weekdayArrayInvalid = error {
            ErrorManager.alert(forMessage: "Please select at least one day of the week for your reminder. You can do this by clicking on the grey S, M, T, W, T, F, or S. A blue letter means that your reminder will be enabled on that day.")
            return true
        }
        else {
            return false
        }
    }
    
    private func handleMonthlyComponentsError(error: Error) -> Bool {
        /*
         enum MonthlyComponentsError: Error {
         case dayOfMonthInvalid
         }
         */
        
        if case MonthlyComponentsError.dayOfMonthInvalid = error {
            ErrorManager.alert(forMessage: "Please select a day of month for your reminder.")
            return true
        }
        else {
            return false
        }
    }
    
    private func handleStringExtensionError(error: Error) -> Bool {
        /*
         enum StringExtensionError: Error {
         case invalidDateComponents
         }
         */
        if case StringExtensionError.dateComponentsInvalid = error {
            ErrorManager.alert(forMessage: "Something went wrong. Please reload and try again! (SEE.iDC)")
            return true
        }
        else {
            return false
        }
    }
    
    private func handleGeneralResponseError(error: Error) -> Bool {
        /*
         enum GeneralResponseError: Error {
         case failureResponse
         case noResponse
         }
         */
        // MARK: GET
        if case GeneralResponseError.failureGetResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseErrorMessages.failureGetResponse)
            return true
        }
        else if case GeneralResponseError.noGetResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseErrorMessages.noGetResponse)
            return true
        }
        // MARK: POST
        else if case GeneralResponseError.failurePostResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseErrorMessages.failurePostResponse)
            return true
        }
        else if case GeneralResponseError.noPostResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseErrorMessages.noPostResponse)
            return true
        }
        // MARK: PUT
        else if case GeneralResponseError.failurePutResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseErrorMessages.failurePutResponse)
            return true
        }
        else if case GeneralResponseError.noPutResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseErrorMessages.noPutResponse)
            return true
        }
        // MARK: DELETE
        else if case GeneralResponseError.failureDeleteResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseErrorMessages.failureDeleteResponse)
            return true
        }
        else if case GeneralResponseError.noDeleteResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseErrorMessages.noDeleteResponse)
            return true
        }
        else {
            return false
        }
    }
    
}
