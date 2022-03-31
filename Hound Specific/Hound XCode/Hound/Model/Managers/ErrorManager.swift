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
    static func alert(forMessage message: String, serverRelated: Bool = false) {
        
        AlertManager.willShowAlert(title: "Uh oh! There seems to be an issue.", message: message, serverRelated: serverRelated)
        
        AppDelegate.generalLogger.error("Known error: \(message)")
        
    }
    
    /// Alerts for a unspecified error from a specified location. Title is extracted from sender with a parameter specified message
    static private func alertForUnknown(error: Error) {
        
        AlertManager.willShowAlert(title: "Bizzare, there seems to be an unknown issue occuring!", message: "Please restart and/or reinstall Hound if issues persist. Issue description: \(error.localizedDescription)")
        
        AppDelegate.generalLogger.error("Unknown error: \(error.localizedDescription)")
        
    }
    
    /// Handles a given error, uses helper functions to compare against all known (custom) error types
    static func alert(forError error: Error) {
        
        // Server Related
        if let castError = error as? GeneralResponseError {
            ErrorManager.alert(forMessage: castError.rawValue, serverRelated: true)
        }
        // Dog Object Related
        else if let castError = error as? DogManagerError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else if let castError = error as? DogError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        // Log Object Related
        else if let castError = error as? LogManagerError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else if let castError = error as? LogActionError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        // Reminder Object Related
        else if let castError = error as? ReminderManagerError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else if let castError = error as? ReminderActionError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else if let castError = error as? WeeklyComponentsError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else if let castError = error as? MonthlyComponentsError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        // Other
        else if let castError = error as? TimingManagerError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else if let castError = error as? StringExtensionError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else if let castError = error as? SignInWithAppleError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else {
            alertForUnknown(error: error)
        }
        
        /*
         Old way of doing it
        if handleTimingManagerError(error: error) == true {
            return
        }
        else if handleDogManagerError(error: error) == true {
            return
        }
        else if handleDogError(error: error) == true {
            return
        }
        else  if handleLogManagerError(error: error) == true {
            return
        }
        else if handleLogActionError(error: error) == true {
            return
        }
        else if handleReminderManagerError(error: error) == true {
            return
        }
        else if handleWeeklyComponentsError(error: error) == true {
            return
        }
        else if handleMonthlyComponentsError(error: error) == true {
            return
        }
        else if handleStringExtensionError(error: error) == true {
            return
        }
        else if handleGeneralResponseError(error: error ) == true {
            return
        }
        else {
            ErrorManager.alertForUnknown(error: error)
        }
         */
    }
    
    /*
    /// Returns true if able to find a match in enum TimingManagerError to the error provided
    static private func handleTimingManagerError(error: Error) -> Bool {
        /*
         enum TimingManagerError: String, Error {
         case parseSenderInfoFailed = "Something went wrong. Please reload and try again! (TME.pSIF)"
         }
         */
        if case TimingManagerError.parseSenderInfoFailed = error {
            ErrorManager.alert(forMessage: TimingManagerError.parseSenderInfoFailed.rawValue)
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum DogManagerError to the error provided
    static private func handleDogManagerError(error: Error) -> Bool {
        /*
         enum DogManagerError: String, Error {
         case dogIdNotPresent = "Couldn't find a match for a dog with that id. Please reload and try again!"
         }
         */
        if case DogManagerError.dogIdNotPresent = error {
            ErrorManager.alert(forMessage: DogManagerError.dogIdNotPresent.rawValue)
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum DogError to the error provided
    static private func handleDogError(error: Error) -> Bool {
        /*
         enum DogError: String, Error {
         case dogNameNil = "Your dog's name is invalid, please try a different one."
         case dogNameBlank = "Your dog's name is blank, try typing something in."
         }
         */
        if case DogError.dogNameNil = error {
            ErrorManager.alert(forMessage: DogError.dogNameNil.rawValue)
            return true
        }
        else if case DogError.dogNameBlank = error {
            ErrorManager.alert(forMessage: DogError.dogNameBlank.rawValue)
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum TraitManagerError to the error provided
    static private func handleLogManagerError(error: Error) -> Bool {
        /*
         enum LogManagerError: String, Error {
         case logIdNotPresent = "Something went wrong when trying modify your log, please try again! (LME.lINP)"
         }
         */
        if case LogManagerError.logIdNotPresent = error {
            ErrorManager.alert(forMessage: LogManagerError.logIdNotPresent.rawValue)
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum LogActionError to the error provided
    static private func handleLogActionError(error: Error) -> Bool {
        /*
         enum LogActionError: String, Error {
         case blankLogAction = "Your log has no type, try selecting one!"
         }
         */
        if case LogActionError.blankLogAction = error {
            ErrorManager.alert(forMessage: LogActionError.blankLogAction.rawValue)
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum ReminderManagerError to the error provided
    static private func handleReminderManagerError(error: Error) -> Bool {
        /*
         enum ReminderManagerError: String, Error {
         case reminderIdNotPresent = "Something went wrong when trying to modify your reminder. Please reload and try again! (RME.rINP)"
         }
         */
        if case ReminderManagerError.reminderIdNotPresent = error {
            ErrorManager.alert(forMessage: ReminderManagerError.reminderIdNotPresent.rawValue)
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns true if able to find a match in enum TimeOfDayComponentsError to the error provided
    static private func handleWeeklyComponentsError(error: Error) -> Bool {
        /*
         enum WeeklyComponentsError: String, Error {
         case weekdayArrayInvalid = "Please select at least one day of the week for your reminder. You can do this by clicking on the grey S, M, T, W, T, F, or S. A blue letter means that your reminder will be enabled on that day."
         }
         */
        if case WeeklyComponentsError.weekdayArrayInvalid = error {
            ErrorManager.alert(forMessage: WeeklyComponentsError.weekdayArrayInvalid.rawValue)
            return true
        }
        else {
            return false
        }
    }
    
    static private func handleMonthlyComponentsError(error: Error) -> Bool {
        /*
         enum MonthlyComponentsError: String, Error {
         case dayOfMonthInvalid = "Please select a day of month for your reminder."
         }
         */
        
        if case MonthlyComponentsError.dayOfMonthInvalid = error {
            ErrorManager.alert(forMessage: MonthlyComponentsError.dayOfMonthInvalid.rawValue)
            return true
        }
        else {
            return false
        }
    }
    
    static private func handleStringExtensionError(error: Error) -> Bool {
        /*
         enum StringExtensionError: String, Error {
         case dateComponentsInvalid = "Something went wrong. Please reload and try again! (SEE.dCI)"
         }
         */
        if case StringExtensionError.dateComponentsInvalid = error {
            ErrorManager.alert(forMessage: StringExtensionError.dateComponentsInvalid.rawValue)
            return true
        }
        else {
            return false
        }
    }
    
    static private func handleGeneralResponseError(error: Error) -> Bool {
        /*
         enum GeneralResponseError: String, Error {
         
         /// GET: != 200...299, e.g. 400, 404, 500
         case failureGetResponse = "We experienced an issue while retrieving your data Hound's server. Please restart and re-login to Hound if the issue persists."
         
         /// GET: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
         case noGetResponse = "We were unable to reach Hound's server and retrieve your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
         
         /// CREATE/POST:  != 200...299, e.g. 400, 404, 500
         case failurePostResponse = "Hound's server experienced an issue in saving your new data. Please restart and re-login to Hound if the issue persists."
         /// CREATE/POST: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
         case noPostResponse = "We were unable to reach Hound's server and save your new data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
         
         /// UPDATE/PUT:  != 200...299, e.g. 400, 404, 500
         case failurePutResponse = "Hound's server experienced an issue in updating your data. Please restart and re-login to Hound if the issue persists."
         /// UPDATE/PUT: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
         case noPutResponse = "We were unable to reach Hound's server and update your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
         
         /// DELETE:  != 200...299, e.g. 400, 404, 500
         case failureDeleteResponse = "Hound's server experienced an issue in deleting your data. Please restart and re-login to Hound if the issue persists."
         /// DELETE: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
         case noDeleteResponse = "We were unable to reach Hound's server to delete your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
         
         }
         */
        // MARK: GET
        if case GeneralResponseError.failureGetResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseError.failureGetResponse.rawValue)
            return true
        }
        else if case GeneralResponseError.noGetResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseError.noGetResponse.rawValue)
            return true
        }
        // MARK: POST
        else if case GeneralResponseError.failurePostResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseError.failurePostResponse.rawValue)
            return true
        }
        else if case GeneralResponseError.noPostResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseError.noPostResponse.rawValue)
            return true
        }
        // MARK: PUT
        else if case GeneralResponseError.failurePutResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseError.failurePutResponse.rawValue)
            return true
        }
        else if case GeneralResponseError.noPutResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseError.noPutResponse.rawValue)
            return true
        }
        // MARK: DELETE
        else if case GeneralResponseError.failureDeleteResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseError.failureDeleteResponse.rawValue)
            return true
        }
        else if case GeneralResponseError.noDeleteResponse = error {
            ErrorManager.alert(forMessage: GeneralResponseError.noDeleteResponse.rawValue)
            return true
        }
        else {
            return false
        }
    }
     */
    
}
