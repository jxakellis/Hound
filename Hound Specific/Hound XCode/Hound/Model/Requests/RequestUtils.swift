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
     completionHandler returns a dogManager. If the query returned a 200 status and is successful, then the dogManager is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func getDogManager(invokeErrorManager: Bool, completionHandler: @escaping (DogManager?, ResponseStatus) -> Void) {
        // assume userId valid as it was retrieved when the app started. Later on with familyId, if a user was removed from the family, then this refresh could fail.
        
        // Retrieve any dogs the user may have
        DogsRequest.getAll(invokeErrorManager: invokeErrorManager, reminders: true, logs: true) { dogArray, responseStatus in
            if dogArray != nil {
                // we have an array of dogs that we made sure has all the reminders and logs, so therefore we have complete dogmanager
                let dogManager = DogManager(forDogs: dogArray!)
                completionHandler(dogManager, responseStatus)
            }
            else {
                completionHandler(nil, responseStatus)
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
