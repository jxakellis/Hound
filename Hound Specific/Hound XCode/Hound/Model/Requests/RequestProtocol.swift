//
//  RequestProtocol.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

protocol RequestProtocol {
    /// base path for given endpoint where all the requests will be sent
    static var basePathWithoutParams: URL { get }
    
    // MARK: - HTTP Methods
    
    /*
     Two Types of Response Format
     
     
     Type 1 - Success:
     {
     "result":
     [
     {"propertyOne":"data",
     "propertyTwo":"data
     ]
     }
     
     Type 2 - Failure:
     {
     "message":"failure message",
     "error":"error code"
     }
     */
    
    /**
     If a path parameter is required for request, then it MUST be provided.  Note: The final path parameter can be omitted if you want to recieve all entries for dogs, logs, or reminders.
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     Throws if necessary path parameter is missing
     */
    // static func get(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId logId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) throws
    
    /**
     If a path parameter is required for request, then it MUST be provided.
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     Throws if necessary path parameter is missing or if the body component provided is invalid
     */
    // static func create(forDogId dogId: Int?, body: [String: Any]?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) throws
    
    /**
     If a path parameter is required for request, then it MUST be provided.
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     Throws if necessary path parameter is missing or if the body component provided is invalid
     */
    // static func update(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId logId: Int?, body: [String: Any]?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) throws
    
    /**
     If a path parameter is required for request, then it MUST be provided.
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     Throws if necessary path parameter is missing
     */
    // static func delete(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId logId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) throws
}
