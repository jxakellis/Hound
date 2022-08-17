//
//  RequestUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/25/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum RequestUtils {
    
    enum RequestIndicatorType {
        case apple
        case hound
    }
    
    /// Presents a custom made contactingHoundServerAlertController on the global presentor that blocks everything until endRequestIndictator is called
    static func beginRequestIndictator(forRequestIndicatorType requestIndicatorType: RequestIndicatorType = .hound) {
        switch requestIndicatorType {
        case .hound:
            AlertManager.shared.contactingServerAlertController.title = "Contacting Hound's Server..."
        case .apple:
            AlertManager.shared.contactingServerAlertController.title = "Contacting Apple's Server..."
        }

        AlertManager.enqueueAlertForPresentation(AlertManager.shared.contactingServerAlertController)
    }
    
    /// Dismisses the custom made contactingHoundServerAlertController. Allow the app to resume normal execution once the completion handler is called (as that indicates the contactingHoundServerAlertController was dismissed and new things can be presented/segued to).
    static func endRequestIndictator(completionHandler: @escaping () -> Void) {
        let alertController = AlertManager.shared.contactingServerAlertController
        guard alertController.isBeingDismissed == false else {
            completionHandler()
            return
        }
        
        alertController.dismiss(animated: false) {
            completionHandler()
        }
    }
    
    /**
     Invokes FamilyRequest.get to refresh the FamilyConfiguration, making sure everything is synced up (e.g. isPaused).
     Invokes DogsRequest.get to refresh the DogManager, making sure everything is synced up with the locally stored DogManager
     completionHandler returns a dogManager and responseStatus.
     If the query returned a 200 status and is successful, then the dogManager is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func getFamilyGetDog(invokeErrorManager: Bool, dogManager currentDogManager: DogManager, completionHandler: @escaping (DogManager?, ResponseStatus) -> Void) {
        
        // We want to sync the isPaused status before getting the newDogManager. Otherwise, reminder could be up to date but alarms could be going off locally since the local app doesn't realized that the app was paused (the opposite with an unpause could also be possible
        _ = FamilyRequest.get(invokeErrorManager: invokeErrorManager) { requestWasSuccessful, responseStatus in
            guard requestWasSuccessful == true else {
                return completionHandler(nil, responseStatus)
            }
            
            _ = DogsRequest.get(invokeErrorManager: invokeErrorManager, dogManager: currentDogManager) { newDogManager, responseStatus in
                completionHandler(newDogManager, responseStatus)
            }
        }
        
    }
}
