//
//  GeneralResponseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum GeneralResponseError: Error {
    
    /// GET: != 200...299, e.g. 400, 404, 500
    case failureGetResponse
    
    /// GET: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noGetResponse
    
    /// CREATE/POST:  != 200...299, e.g. 400, 404, 500
    case failurePostResponse
    /// CREATE/POST: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noPostResponse
    
    /// UPDATE/PUT:  != 200...299, e.g. 400, 404, 500
    case failurePutResponse
    /// UPDATE/PUT: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noPutResponse
    
    /// DELETE:  != 200...299, e.g. 400, 404, 500
    case failureDeleteResponse
    /// DELETE: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noDeleteResponse
    
}

enum GeneralResponseErrorMessages {
    
    // MARK: GET
    static let failureGetResponse = "We experienced an issue while retrieving your data Hound's server. Please restart and re-login to Hound if the issue persists."
    static let noGetResponse = "We were unable to reach Hound's server and retrieve your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    // MARK: POST
    static let failurePostResponse = "Hound's server experienced an issue in saving your new data. Please restart and re-login to Hound if the issue persists."
    static let noPostResponse = "We were unable to reach Hound's server and save your new data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    // MARK: PUT
    static let failurePutResponse = "Hound's server experienced an issue in updating your data. Please restart and re-login to Hound if the issue persists."
    static let noPutResponse = "We were unable to reach Hound's server and update your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    // MARK: DELETE
    static let failureDeleteResponse = "Hound's server experienced an issue in deleting your data. Please restart and re-login to Hound if the issue persists."
    static let noDeleteResponse = "We were unable to reach Hound's server to delete your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    /*
     /// Returns a default string about a failureResponse from the server: "Hound's server encountered an error with your request and couldn't save your \(type)'s data. Please restart and re-login to Hound if the issue persists."
     static func failureResponseTemplate(ofType type: String) -> String {
     return "Hound's server encountered an error with your request and couldn't save your \(type)'s data. Please restart and re-login to Hound if the issue persists."
     }
     
     /// Returns a default string about a noResponse from the server: "We were unable to reach Hound's server and save your \(type)'s data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
     static func noResponseTemplate(ofType type: String) -> String {
     return "We were unable to reach Hound's server and save your \(type)'s data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
     }
     
     /// Returns a default string about a failureGetResponse from the server: "We were unable to retrieve your \(type)'s data from Hound's server. Please restart and re-login to Hound if the issue persists."
     static func failureGetResponseTemplate(ofType type: String) -> String {
     return "We were unable to retrieve your \(type)'s data from Hound's server. Please restart and re-login to Hound if the issue persists."
     }
     
     /// Returns a default string about a noGetResponse from the server: "We were unable to reach Hound's server and retrieve your \(type)'s data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
     static func noGetResponseTemplate(ofType type: String) -> String {
     return "We were unable to reach Hound's server and retrieve your \(type)'s data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
     }
     */
    
}

/*
enum UserResponseError: Error {
    /// PUT, POST, DELETE: This invokes the special message for requests from user related data. != 200...299, e.g. 400, 404, 500
    case failureResponse
    /// PUT, POST, DELETE: This invokes the special message for requests from user related data. Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noResponse
    
    /// GET: This invokes the special message for requests from user related data. != 200...299, e.g. 400, 404, 500
    case failureGetResponse
    
    /// GET: This invokes the special message for requests from user related data. Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noGetResponse
}

enum DogsResponseError: Error {
    /// PUT, POST, DELETE: This invokes the special message for requests from dog related data. != 200...299, e.g. 400, 404, 500
    case failureResponse
    /// PUT, POST, DELETE: This invokes the special message for requests from dog related data. Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noResponse
    
    /// GET: This invokes the special message for requests from dog related data. != 200...299, e.g. 400, 404, 500
    case failureGetResponse
    
    /// GET: This invokes the special message for requests from dog related data. Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noGetResponse
}

enum LogsResponseError: Error {
    /// PUT, POST, DELETE: This invokes the special message for requests from log related data. != 200...299, e.g. 400, 404, 500
    case failureResponse
    /// PUT, POST, DELETE: This invokes the special message for requests from log related data. Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noResponse
    
    /// GET: This invokes the special message for requests from log related data. != 200...299, e.g. 400, 404, 500
    case failureGetResponse
    
    /// GET: This invokes the special message for requests from log related data. Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noGetResponse
}

enum RemindersResponseError: Error {
    /// PUT, POST, DELETE: This invokes the special message for requests from reminder related data. != 200...299, e.g. 400, 404, 500
    case failureResponse
    /// PUT, POST, DELETE: This invokes the special message for requests from reminder relata data. Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noResponse
    
    /// GET: This invokes the special message for requests from reminder related data. != 200...299, e.g. 400, 404, 500
    case failureGetResponse
    
    /// GET: This invokes the special message for requests from reminder related data. Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noGetResponse
}

enum AlarmResponseError: Error {
    /// PUT, POST, DELETE: This invokes the special message for requests from alarms. != 200...299, e.g. 400, 404, 500
    case failureResponse
    /// PUT, POST, DELETE: This invokes the special message for requests from alarms. Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noResponse
}
 */
