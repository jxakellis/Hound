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
    static func alert(forMessage message: String) {
        
        AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.alertForErrorTitle, forSubtitle: message, forStyle: .danger)
        
        AppDelegate.generalLogger.error("Alerted user for error: \(message)")
        
    }
    
    /// Handles a given error, uses helper functions to compare against all known (custom) error types
    static func alert(forError error: Error, forErrorCode errorCode: String? = nil) {
        
        func createErrorMessage(forErrorRawValue errorRawValue: String) -> String {
            guard errorCode != nil else {
                return errorRawValue
            }
            
            // foo bar some message ("ER_SOME_MESSAGE")
            // return errorRawValue.appending(" (\"\(errorCode)\")")
            return errorRawValue
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
                // Create an alert controller that blocks everything, as it has no alert actions to dismiss
                let outdatedAppVersionAlertController = GeneralUIAlertController(title: VisualConstant.BannerTextConstant.alertForErrorTitle, message: castError.rawValue, preferredStyle: .alert)
                AlertManager.enqueueAlertForPresentation(outdatedAppVersionAlertController)
                return
            }
            ErrorManager.alert(forMessage: createErrorMessage(forErrorRawValue: castError.rawValue))
        }
        else if let castError = error as? FamilyResponseError {
            ErrorManager.alert(forMessage: createErrorMessage(forErrorRawValue: castError.rawValue))
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
        else if let castError = error as? LogError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        // Reminder Object Related
        else if let castError = error as? ReminderManagerError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else if let castError = error as? ReminderError {
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
        else if let castError = error as? InAppPurchaseError {
            ErrorManager.alert(forMessage: castError.rawValue)
        }
        else {
            ErrorManager.alert(forMessage: error.localizedDescription)
        }
    }
    
}
