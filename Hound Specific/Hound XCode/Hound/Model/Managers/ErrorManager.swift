//
//  ErrorManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ErrorManager {
    
    /// Alerts for an unspecified error. Title is default with a parameter specified message
    static func alert(forMessage message: String, hasOKAlertAction: Bool = true, serverRelated: Bool = false) {
        
        AlertManager.willShowAlert(title: "Uh oh! There seems to be an issue.", message: message, hasOKAlertAction: hasOKAlertAction, serverRelated: serverRelated)
        
        AppDelegate.generalLogger.error("Known error: \(message)")
        
    }
    
    /// Alerts for a unspecified error from a specified location. Title is extracted from sender with a parameter specified message
    static private func alertForUnknown(error: Error) {
        
        AlertManager.willShowAlert(title: "Bizzare, there seems to be an unknown issue occuring!", message: "Please restart and/or reinstall Hound if issues persist. Issue description: \(error.localizedDescription)")
        
        AppDelegate.generalLogger.error("Unknown error: \(error.localizedDescription)")
        
    }
    
    /// Handles a given error, uses helper functions to compare against all known (custom) error types
    static func alert(forError error: Error, forErrorCode errorCode: String? = nil) {
        
        func createErrorMessage(forErrorRawValue errorRawValue: String) -> String {
            guard let errorCode = errorCode else {
                return errorRawValue
            }
            
            // TO DO disable for production, error message isn't clean with this on
            // blah blah some message ("ER_SOME_MESSAGE")
            return errorRawValue.appending(" (\"\(errorCode)\")")
        }
        
        // Request Related
        if let castError = error as? RequestError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else if let castError = error as? FamilyRequestError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        // Response Related
        else if let castError = error as? GeneralResponseError {
            guard castError != .appBuildOutdated else {
                ErrorManager.alert(
                    forMessage: createErrorMessage(forErrorRawValue: castError.rawValue),
                    hasOKAlertAction: false,
                    serverRelated: true)
                return
            }
            ErrorManager.alert(forMessage: createErrorMessage(forErrorRawValue: castError.rawValue), serverRelated: true)
        }
        else if let castError = error as? FamilyResponseError {
            ErrorManager.alert(forMessage: createErrorMessage(forErrorRawValue: castError.rawValue), serverRelated: true)
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
        else if let castError = error as? SignInWithAppleError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else {
            alertForUnknown(error: error)
        }
    }
    
}
