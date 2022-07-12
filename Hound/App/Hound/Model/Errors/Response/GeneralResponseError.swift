//
//  GeneralResponseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum GeneralResponseError: String, Error {
    
    init?(rawValue: String) {
        if rawValue == "ER_GENERAL_APP_BUILD_OUTDATED" {
            self = .appBuildOutdated
        }
        /*
        else if rawValue == "ER_GENERAL_PARSE_FORM_DATA_FAILED" {
            self = .parseFormDataFailed
        }
        else if rawValue == "ER_GENERAL_PARSE_JSON_FAILED" {
            self = .parseJSONFailed
        }
        else if rawValue == "ER_GENERAL_POOL_CONNECTION_FAILED" {
            self = .poolConnectionFailed
        }
        else if rawValue == "ER_GENERAL_POOL_TRANSACTION_FAILED" {
            self = .poolTransactionFailed
        }
         */
        else if rawValue == "ER_GENERAL_APPLE_SERVER_FAILED" {
            self = .appleServerFailed
        }
        else {
            return nil
        }
    }
    
    /// The app build that the user is using is out dated
    case appBuildOutdated = "Your version of Hound is outdated. Please update to the latest version to continue."
    // case parseFormDataFailed = "Hound was unable to parse the form data sent and complete your request. Please restart and retry. If this issue persists, please contact Hound support."
    // case parseJSONFailed = "Hound was unable to parse the JSON sent and complete your request. Please restart and retry. If this issue persists, please contact Hound support."
    // case poolConnectionFailed = "Hound was unable to create a pool connection and complete your request. Please restart and retry. If this issue persists, please contact Hound support."
    // case poolTransactionFailed = "Hound was unable to create a pool transaction and complete your request. Please restart and retry. If this issue persists, please contact Hound support."
    case appleServerFailed = "Hound was unable to contact Apple's iTunes server and complete your request. Please restart and retry. If this issue persists, please contact Hound support."
    
    /// GET: != 200...299, e.g. 400, 404, 500
    case getFailureResponse = "We experienced an issue while retrieving your data Hound's server. Please restart and re-login to Hound if the issue persists."
    
    /// GET: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case getNoResponse = "We were unable to reach Hound's server and retrieve your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    /// CREATE/POST:  != 200...299, e.g. 400, 404, 500
    case postFailureResponse = "Hound's server experienced an issue in saving your new data. Please restart and re-login to Hound if the issue persists."
    /// CREATE/POST: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case postNoResponse = "We were unable to reach Hound's server and save your new data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    /// UPDATE/PUT:  != 200...299, e.g. 400, 404, 500
    case putFailureResponse = "Hound's server experienced an issue in updating your data. Please restart and re-login to Hound if the issue persists."
    /// UPDATE/PUT: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case putNoResponse = "We were unable to reach Hound's server and update your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    /// DELETE:  != 200...299, e.g. 400, 404, 500
    case deleteFailureResponse = "Hound's server experienced an issue in deleting your data. Please restart and re-login to Hound if the issue persists."
    /// DELETE: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case deleteNoResponse = "We were unable to reach Hound's server to delete your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
}
