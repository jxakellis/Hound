//
//  HoundError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/22/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum HoundErrorType {
    case familyRequestError
    case generalRequestError
    case familyResponseError
    case generalResponseError
    case dogError
    case inAppPurchaseError
    case logError
    case monthlyComponentsError
    case reminderError
    case signInWithAppleError
    case unknownError
    case weeklyComponentsError
}

class HoundError: Error {
    init(forName: String, forDescription: String, forType: HoundErrorType) {
        self.name = forName
        self.description = forDescription
        self.type = forType
    }
    
    /// Constant name of error. When HoundErrors are accessed from the Error Constant enum, they calculated properties. That means each time a HoundError is accessed, it's description might have changed. However, it's name and type will always be the same.
    private(set) var name: String
    /// Dynamic descripton of error. When HoundErrors are accessed from the Error Constant enum, they calculated properties. That means each time a HoundError is accessed, it's description might have changed. However, it's name and type will always be the same.
    private(set) var description: String
    /// Constant type of error. When HoundErrors are accessed from the Error Constant enum, they calculated properties. That means each time a HoundError is accessed, it's description might have changed. However, it's name and type will always be the same.
    private(set) var type: HoundErrorType
    
    func alert() {
        AppDelegate.generalLogger.error("Alerting user for error: \(self.description)")
        
        guard name != ErrorConstant.GeneralResponseError.appBuildOutdatedName else {
            // Create an alert controller that blocks everything, as it has no alert actions to dismiss
            let outdatedAppBuildAlertController = GeneralUIAlertController(title: VisualConstant.BannerTextConstant.alertForErrorTitle, message: description, preferredStyle: .alert)
            AlertManager.enqueueAlertForPresentation(outdatedAppBuildAlertController)
            return
        }
        
        AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.alertForErrorTitle, forSubtitle: description, forStyle: .danger)
    }
}
