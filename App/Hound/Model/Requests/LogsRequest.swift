//
//  LogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogsRequest: RequestProtocol {
    
    /// Need dogId for any request so we can't append '/logs' until we have dogId
    static var baseURLWithoutParams: URL { return DogsRequest.baseURLWithoutParams}
    
    // MARK: - Private Functions
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalGet(invokeErrorManager: Bool, forDogId dogId: Int, forLogId logId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL
        
        // looking for single log
        if let logId = logId {
            URLWithParams = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/\(logId)")
        }
        // don't necessarily need a logId, no logId specifys that you want all logs for a dog
        else {
            URLWithParams = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs")
        }
        
        // make get request
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: logId for the created log and the ResponseStatus
     */
    private static func internalCreate(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let body = log.createBody()
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/")
        
        // make post request, assume body valid as constructed with method
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalUpdate(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let body = log.createBody()
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/\(log.logId)")
        
        // make put request, assume body valid as constructed with method
        return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalDelete(invokeErrorManager: Bool, forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/\(logId)")
        
        // make delete request
        return InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
}

extension LogsRequest {
    
    // MARK: - Public Functions
    
    /**
     completionHandler returns a possible log and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func get(invokeErrorManager: Bool, forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping (Log?, ResponseStatus) -> Void) {
        
        _ = LogsRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: dogId, forLogId: logId) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [String: Any] {
                    completionHandler(Log(fromBody: result), responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a possible array of logs and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func get(invokeErrorManager: Bool, forDogId dogId: Int, completionHandler: @escaping ([Log]?, ResponseStatus) -> Void) {
        
        _ = LogsRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: dogId, forLogId: nil) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Array of log JSON [{log1:'foo'},{log2:'bar'}]
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [[String: Any]] {
                    var logArray: [Log] = []
                    for logBody in result {
                        let log = Log(fromBody: logBody)
                        logArray.append(log)
                    }
                    completionHandler(logArray, responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a possible logId and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func create(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        
        _ = LogsRequest.internalCreate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forLog: log) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let logId = responseBody?[ServerDefaultKeys.result.rawValue] as? Int {
                    completionHandler(logId, responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func update(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        
        _ = LogsRequest.internalUpdate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forLog: log) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        _ = LogsRequest.internalDelete(invokeErrorManager: invokeErrorManager, forDogId: dogId, forLogId: logId) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
}
