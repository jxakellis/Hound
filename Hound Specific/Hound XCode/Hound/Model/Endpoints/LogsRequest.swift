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

    /**
        logId optional, providing it only returns the single log (if found) otherwise returns all logs
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func get(forDogId dogId: Int, forLogId logId: Int?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        RequestUtils.checkId(dogId: dogId, logId: logId)
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
        InternalRequestUtils.genericGetRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

}

    /**
        logId optional, providing it only returns the single log (if found) otherwise returns all logs
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func get(forDogId dogId: Int, forLogId logId: Int?, completionHandler: @escaping ([Log]?) -> Void) {

        RequestUtils.checkId(dogId: dogId, logId: logId)
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
        InternalRequestUtils.genericGetRequest(path: pathWithParams) { responseBody, _, _ in
            var logArray: [Log]?
            if responseBody != nil {
                // Array of log JSON [{log1:'foo'},{log2:'bar'}]
                if let result = responseBody!["result"] as? [[String: Any]] {
                    logArray = []
                    for logBody in result {
                        let log = Log(fromBody: logBody)
                        logArray!.append(log)
                    }

                }
            }
            completionHandler(logArray)
        }

}

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func create(forDogId dogId: Int, forLog log: Log, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        RequestUtils.checkId(dogId: dogId)
        let body = InternalRequestUtils.createLogBody(log: log)

        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/logs/")

        // make post request, assume body valid as constructed with method
        try! InternalRequestUtils.genericPostRequest(path: pathWithParams, body: body) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
        /*
        do {
            try InternalRequestUtils.genericPostRequest(path: pathWithParams, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw LogsRequestError.bodyInvalid
        }
         */
    }
    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func update(forDogId dogId: Int, forLog log: Log, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        RequestUtils.checkId(dogId: dogId, logId: log.logId)
        let body = InternalRequestUtils.createLogBody(log: log)

        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/logs/\(log.logId)")

        // make put request, assume body valid as constructed with method
        try! InternalRequestUtils.genericPutRequest(path: pathWithParams, body: body) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
        /*
        do {
            try InternalRequestUtils.genericPutRequest(path: pathWithParams, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw LogsRequestError.bodyInvalid
        }
         */
    }

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func delete(forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        RequestUtils.checkId(dogId: dogId, logId: logId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/logs/\(logId)")

        // make delete request
        InternalRequestUtils.genericDeleteRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
