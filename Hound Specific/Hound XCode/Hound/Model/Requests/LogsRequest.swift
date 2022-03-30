//
//  LogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogsRequestError: Error {
    case dogIdMissing
    case logIdMissing
    case bodyInvalid
}

enum LogsRequest: RequestProtocol {
    
    static let basePathWithoutParams: URL = UserRequest.basePathWithUserId.appendingPathComponent("/dogs")
    
    // MARK: - Private Functions
    
    /**
     logId optional, providing it only returns the single log (if found) otherwise returns all logs
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func get(forDogId dogId: Int, forLogId logId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId, logId: logId)
        let pathWithParams: URL
        
        // looking for single log
        if logId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId)/logs/\(logId!)")
        }
        // don't necessarily need a logId, no logId specifys that you want all logs for a dog
        else {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId)/logs")
        }
        
        // make get request
        InternalRequestUtils.genericGetRequest(path: pathWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: logId for the created log and the ResponseStatus
     */
    private static func create(forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId)
        let body = InternalRequestUtils.createLogBody(log: log)
        
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/logs/")
        
        // make post request, assume body valid as constructed with method
        InternalRequestUtils.genericPostRequest(path: pathWithParams, body: body) { responseBody, responseStatus in
            
            if responseBody != nil, let logId = responseBody!["result"] as? Int {
                completionHandler(logId, responseStatus)
            }
            else {
                completionHandler(nil, responseStatus)
            }
            
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func update(forDogId dogId: Int, forLog log: Log, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId, logId: log.logId)
        let body = InternalRequestUtils.createLogBody(log: log)
        
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/logs/\(log.logId)")
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPutRequest(path: pathWithParams, body: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func delete(forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId, logId: logId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/logs/\(logId)")
        
        // make delete request
        InternalRequestUtils.genericDeleteRequest(path: pathWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
}

extension LogsRequest {
    
    // MARK: - Public Functions
    
    /**
     completionHandler returns a log. If the query returned a 200 status and is successful, then the log is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func get(forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping (Log?) -> Void) {
        
        // make get request
        get(forDogId: dogId, forLogId: logId) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Array of log JSON [{log1:'foo'},{log2:'bar'}]
                if let result = responseBody!["result"] as? [[String: Any]] {
                    let log = Log(fromBody: result[0])
                    // able to add all
                    DispatchQueue.main.async {
                        completionHandler(log)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                    }
                }
            case .failureResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                }
                
            case .noResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns an array of logs. If the query returned a 200 status and is successful, then the array of logs is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func getAll(forDogId dogId: Int, completionHandler: @escaping ([Log]?) -> Void) {
        
        // make get request
        get(forDogId: dogId, forLogId: nil) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Array of log JSON [{log1:'foo'},{log2:'bar'}]
                if let result = responseBody!["result"] as? [[String: Any]] {
                    var logArray: [Log] = []
                    for logBody in result {
                        let log = Log(fromBody: logBody)
                        logArray.append(log)
                    }
                    // able to add all
                    DispatchQueue.main.async {
                        completionHandler(logArray)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                    }
                }
            case .failureResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                }
                
            case .noResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns a Int. If the query returned a 200 status and is successful, then logId is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func create(forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Int?) -> Void) {
        
        LogsRequest.create(forDogId: dogId, forLog: log) { logId, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    if logId != nil {
                        completionHandler(logId!)
                    }
                    else {
                        ErrorManager.alert(forError: GeneralResponseError.failurePostResponse)
                    }
                case .failureResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failurePostResponse)
                case .noResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noPostResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns a Bool. If the query returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked.
     */
    static func update(forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Bool) -> Void) {
        
        LogsRequest.update(forDogId: dogId, forLog: log) { _, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    completionHandler(true)
                case .failureResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.failurePutResponse)
                case .noResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.noPutResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns a Bool. If the query returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked.
     */
    static func delete(forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping (Bool) -> Void) {
        LogsRequest.delete(forDogId: dogId, forLogId: logId) { _, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    completionHandler(true)
                case .failureResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.failureDeleteResponse)
                case .noResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.noDeleteResponse)
                }
            }
        }
    }
}
