//
//  GeneralResponseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum GeneralResponseError: String, Error {
    
    /// GET: != 200...299, e.g. 400, 404, 500
    case failureGetResponse = "We experienced an issue while retrieving your data Hound's server. Please restart and re-login to Hound if the issue persists."
    
    /// GET: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noGetResponse = "We were unable to reach Hound's server and retrieve your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    /// CREATE/POST:  != 200...299, e.g. 400, 404, 500
    case failurePostResponse = "Hound's server experienced an issue in saving your new data. Please restart and re-login to Hound if the issue persists."
    /// CREATE/POST: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noPostResponse = "We were unable to reach Hound's server and save your new data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    /// UPDATE/PUT:  != 200...299, e.g. 400, 404, 500
    case failurePutResponse = "Hound's server experienced an issue in updating your data. Please restart and re-login to Hound if the issue persists."
    /// UPDATE/PUT: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noPutResponse = "We were unable to reach Hound's server and update your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
    /// DELETE:  != 200...299, e.g. 400, 404, 500
    case failureDeleteResponse = "Hound's server experienced an issue in deleting your data. Please restart and re-login to Hound if the issue persists."
    /// DELETE: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noDeleteResponse = "We were unable to reach Hound's server to delete your data. Please verify that you are connected to the internet and retry. If the issue persists, Hound's server may be experiencing an outage."
    
}
