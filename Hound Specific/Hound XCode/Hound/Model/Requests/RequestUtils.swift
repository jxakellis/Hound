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
    static func getDogManager(completionHandler: @escaping (DogManager?) -> Void) {
        // assume userId valid as it was retrieved when the app started. Later on with familyId, if a user was removed from the family, then this refresh could fail.
        
        // Retrieve any dogs the user may have
        DogsRequest.getAll(reminders: true, logs: true) { dogArray in
            if dogArray != nil {
                let dogManager = DogManager(forDogs: dogArray!)
                DispatchQueue.main.async {
                    completionHandler(dogManager)
                }
            }
            else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
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
