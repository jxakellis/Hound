//
//  AppBuildResponseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/11/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum AppBuildResponseError: String, Error {
    
    init?(rawValue: String) {
        if rawValue == "ER_APP_BUILD_OUTDATED" {
            self = .appBuildOutdated
            return
        }
        else {
            return nil
        }
    }
    
    /*
     ER_APP_BUILD_OUTDATED
     */
    
    /// The app build that the user is using is out dated
    case appBuildOutdated = "Your version of Hound is outdated. Please update to the latest version to continue."
}
