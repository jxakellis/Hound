//
//  ResponseStatus.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//
import Foundation

/*
class ResponseInformation {
    var status: ResponseStatus
    var errorCode: String?
    var error: Error?
    
    init (forStatus status: ResponseStatus, forErrorCode errorCode: String?, forError error: Error?) {
        self.status = status
        self.errorCode = errorCode
        self.error = error
    }
}
 */

enum ResponseStatus {
    /// 200...299
    case successResponse
    /// != 200...299, e.g. 400, 404, 500
    case failureResponse
    /// Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noResponse
}
