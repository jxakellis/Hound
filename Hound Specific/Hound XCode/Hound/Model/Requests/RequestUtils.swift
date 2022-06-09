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
