//
//  DogsEndpoint.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogsEndpointError: Error {
    case dogIdMissing
    case bodyInvalid
}

enum DogsEndpoint: EndpointObjectProtocol {
    static let basePathWithoutParams: URL = UserEndpoint.basePathWithUserId.appendingPathComponent("/dogs")

    static func get(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId logId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        let pathWithParams: URL

        // special case where we append the query parameter of all. Its value doesn't matter but it just tells the server that we want the logs and reminders of the dog too.
        if dogId != nil {
            var path = URLComponents(url: basePathWithoutParams.appendingPathComponent("/\(dogId!)"), resolvingAgainstBaseURL: false)!
            path.queryItems = [URLQueryItem(name: "all", value: "foo")]
            pathWithParams = path.url!
        }
        else {
            var path = URLComponents(url: basePathWithoutParams.appendingPathComponent(""), resolvingAgainstBaseURL: false)!
            path.queryItems = [URLQueryItem(name: "all", value: "foo")]
            pathWithParams = path.url!
        }

        // make get request, , try statement only fails with invalid body and no body provided means always succeeds
    try! InternalEndpointUtils.genericGetRequest(path: pathWithParams) { dictionary, status, error in
        completionHandler(dictionary, status, error)
    }

}

    static func create(forDogId dogId: Int? = nil, body: [String: Any]?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        guard body != nil else {
            throw DogsEndpointError.bodyInvalid
        }

        // make post request
        do {
            try InternalEndpointUtils.genericPostRequest(path: basePathWithoutParams, body: body!) { dictionary, status, error in
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
    }

    static func update(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId logId: Int? = nil, body: [String: Any]?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        guard body != nil else {
            throw DogsEndpointError.bodyInvalid
        }

        let pathWithParams: URL

        // need dogId to update a given dog
        if dogId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)")
        }
        else {
            throw DogsEndpointError.dogIdMissing
        }

        // make put request
        do {
            try InternalEndpointUtils.genericPutRequest(path: pathWithParams, body: body!) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw DogsEndpointError.bodyInvalid
        }

    }

    static func update(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId logId: Int?, objectForBody: NSObject, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {
        //
    }

    static func delete(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId logId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        let pathWithParams: URL

        // need dogId to delete a given dog
        if dogId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)")
        }
        else {
            throw DogsEndpointError.dogIdMissing
        }

        // make delete request
        InternalEndpointUtils.genericDeleteRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
