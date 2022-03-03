//
//  UserEndpoint.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum UserEndpointError: Error {
    case userIdMissing
    case bodyInvalid
}

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum UserEndpoint: EndpointProtocol {

    static let basePathWithoutParams: URL = InternalEndpointUtils.basePathWithoutParams.appendingPathComponent("/user")
    // UserEndpoint basePath with the userId path param appended on
    static var basePathWithUserId: URL { return UserEndpoint.basePathWithoutParams.appendingPathComponent("/\(userId)") }
    static let userId: Int = -1

    static func get(forDogId dogId: Int? = nil, forReminderId reminderId: Int? = nil, forLogId logId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        // let pathWithParams: URL

        // need userId to get a specific user
        // if userId != nil {
        //    pathWithParams = basePathWithoutParams.appendingPathComponent("/\(userId!)")
        // }
        // else {
        //    throw UserEndpointError.userIdMissing
        // }

    InternalEndpointUtils.genericGetRequest(path: basePathWithUserId) { dictionary, status, error in
        completionHandler(dictionary, status, error)
    }

}

    static func create(forDogId dogId: Int? = nil, body: [String: Any]? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        // make post request
        do {
            try InternalEndpointUtils.genericPostRequest(path: basePathWithoutParams, body: InternalEndpointUtils.createFullUserBody()) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw UserEndpointError.bodyInvalid
        }

    }

    static func update(forDogId dogId: Int? = nil, forReminderId reminderId: Int? = nil, forLogId logId: Int? = nil, body: [String: Any]?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        // let pathWithParams: URL

        // need userId to get a specific user
        // if userId != nil {
        //    pathWithParams = basePathWithoutParams.appendingPathComponent("/\(userId!)")
        // }
        // else {
        //    throw UserEndpointError.userIdMissing
        // }

        guard body != nil else {
            throw UserEndpointError.bodyInvalid
        }

        // make put request
        do {
            try InternalEndpointUtils.genericPutRequest(path: basePathWithUserId, body: body!) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw UserEndpointError.bodyInvalid
        }

    }

    static func delete(forDogId dogId: Int? = nil, forReminderId reminderId: Int? = nil, forLogId logId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        // let pathWithParams: URL

        // need userId to get a specific user
        // if userId != nil {
        //    pathWithParams = basePathWithoutParams.appendingPathComponent("/\(userId!)")
        // }
        // else {
        //    throw UserEndpointError.userIdMissing
        // }

        InternalEndpointUtils.genericDeleteRequest(path: basePathWithUserId) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
