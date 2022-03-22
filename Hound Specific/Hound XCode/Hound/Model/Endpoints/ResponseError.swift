//
//  GeneralResponseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum GeneralResponseError: Error {
    /// PUT, POST, DELETE:  != 200...299, e.g. 400, 404, 500
    case failureResponse
    /// PUT, POST, DELETE: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noResponse
    
    /// GET: != 200...299, e.g. 400, 404, 500
    case failureGetResponse
    
    /// GET: Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noGetResponse
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
