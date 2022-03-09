//
//  LogsEndpoint.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogsEndpointError: Error {
    case dogIdMissing
    case logIdMissing
    case bodyInvalid
}

enum LogsEndpoint: EndpointObjectProtocol {

    static let basePathWithoutParams: URL = UserEndpoint.basePathWithUserId.appendingPathComponent("/dogs")

    static func get(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId logId: Int?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        let pathWithParams: URL

        // we need dogId to find the logs for a given dog
        if dogId != nil && logId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/logs/\(logId!)")
        }
        // don't necessarily need a logId, no logId specifys that you want all logs for a dog
        else if dogId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/logs")
        }
        else {
            throw LogsEndpointError.dogIdMissing
        }

        // make get request, try statement only fails with invalid body and no body provided means always succeeds
        try! InternalEndpointUtils.genericGetRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

}

    static func create(forDogId dogId: Int?, body: [String: Any]?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        guard body != nil else {
            throw LogsEndpointError.bodyInvalid
        }

        let pathWithParams: URL

        // we need dogId to create a log for a given dog
        if dogId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/logs/")
        }
        else {
            throw LogsEndpointError.dogIdMissing
        }

        // make post request
        do {
            try InternalEndpointUtils.genericPostRequest(path: pathWithParams, body: body!) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw DogsEndpointError.bodyInvalid
        }

    }

    static func create(forDogId dogId: Int?, objectForBody: NSObject, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {
        //

        guard objectForBody is Log else {
            throw LogsEndpointError.bodyInvalid
        }

        let body = InternalEndpointUtils.createLogBody(log: objectForBody as! Log)

        let pathWithParams: URL

        // we need dogId to create a log for a given dog
        if dogId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/logs/")
        }
        else {
            throw LogsEndpointError.dogIdMissing
        }

        // make post request
        do {
            try InternalEndpointUtils.genericPostRequest(path: pathWithParams, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw LogsEndpointError.bodyInvalid
        }
    }

    static func update(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId logId: Int?, body: [String: Any]?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        guard body != nil else {
            throw LogsEndpointError.bodyInvalid
        }

        let pathWithParams: URL

        // we need dogId and logId to update a log for a given dog
        if dogId != nil && logId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/logs/\(logId!)")
        }
        else if dogId == nil {
            throw LogsEndpointError.dogIdMissing
        }
        else {
            throw LogsEndpointError.logIdMissing
        }

        // make put request
        do {
            try InternalEndpointUtils.genericPutRequest(path: pathWithParams, body: body!) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw LogsEndpointError.bodyInvalid
        }

    }

    static func update(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId logId: Int?, objectForBody: NSObject, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        guard objectForBody is Log else {
            throw LogsEndpointError.bodyInvalid
        }

        let body = InternalEndpointUtils.createLogBody(log: objectForBody as! Log)

        let pathWithParams: URL

        // we need dogId and logId to update a log for a given dog
        if dogId != nil && logId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/logs/\(logId!)")
        }
        else if dogId == nil {
            throw LogsEndpointError.dogIdMissing
        }
        else {
            throw LogsEndpointError.logIdMissing
        }

        // make put request
        do {
            try InternalEndpointUtils.genericPutRequest(path: pathWithParams, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw LogsEndpointError.bodyInvalid
        }
    }

    static func delete(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId logId: Int?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        let pathWithParams: URL

        // we need dogId and logId to delete a log for a given dog
        if dogId != nil && logId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/logs/\(logId!)")
        }
        else if dogId == nil {
            throw LogsEndpointError.dogIdMissing
        }
        else {
            throw LogsEndpointError.logIdMissing
        }

        // make delete request
        InternalEndpointUtils.genericDeleteRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
