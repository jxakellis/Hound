//
//  RequestUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/25/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum RequestUtils {
    
    /**
     First refreshes the FamilyConfiguration of the user to make sure everything is synced up (e.g. isPaused). completionHandler returns a dogManager. If the query returned a 200 status and is successful, then the dogManager is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func getDogManager(invokeErrorManager: Bool, completionHandler: @escaping (DogManager?, ResponseStatus) -> Void) {
        
        // We want to sync the isPaused status before getting the newDogManager. Otherwise, reminder could be up to date but alarms could be going off locally since the local app doesn't realized that the app was paused (the opposite with an unpause could also be possible
        FamilyRequest.get(invokeErrorManager: invokeErrorManager) { requestWasSuccessful, responseStatus in
            guard requestWasSuccessful == true else {
                return completionHandler(nil, responseStatus)
            }
            
            // Now can get the dogManager
            // Retrieve any dogs the user may have
            DogsRequest.getAll(invokeErrorManager: invokeErrorManager, reminders: true, logs: true) { dogArray, responseStatus in
                guard dogArray != nil else {
                    return completionHandler(nil, responseStatus)
                }
                // successful sync, so we can update value
                LocalConfiguration.lastDogManagerSync = Date()
                // we have an array of dogs that we made sure has all the reminders and logs, so therefore we have complete dogmanager
                let dogManager = DogManager(forDogs: dogArray!)
                completionHandler(dogManager, responseStatus)
            }
        }
        
    }
    
    /**
     Invoke function when the user is terminating the app. Sends a query to the server to send an APN to the user, warning against terminating the app
     */
    static func createTerminationNotification() {
        InternalRequestUtils.genericPostRequest(invokeErrorManager: false, forURL: UserRequest.baseURLWithUserId.appendingPathComponent("/alert/terminate"), forBody: [:]) { _, _ in
        }
    }
    
    /// Presents a custom made loadingAlertController on the global presentor that blocks everything until endAlertControllerQueryIndictator is called
    static func beginAlertControllerQueryIndictator() {
        AlertManager.enqueueAlertForPresentation(AlertManager.shared.loadingAlertController)
    }
    
    /// Dismisses the custom made loadingAlertController. Allow the app to resume normal execution once the completion handler is called (as that indicates the loadingAlertController was dismissed and new things can be presented/segued to).
    static func endAlertControllerQueryIndictator(completionHandler: @escaping () -> Void) {
        AlertManager.shared.loadingAlertController.dismiss(animated: false) {
            completionHandler()
        }
    }
}
