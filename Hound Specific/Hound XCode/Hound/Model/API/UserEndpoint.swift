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

    static let basePath: URL = EndpointUtils.basePath.appendingPathComponent("/user")
    // UserEndpoint basePath with the userId path param appended on
    static var basePathWithUserId: URL { return UserEndpoint.basePath.appendingPathComponent("/\(userId)") }
    static let userId: Int? = nil

    static func get(forDogId dogId: Int? = nil, forReminderId reminderId: Int? = nil, forLogId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        // cannot do request without path param
        if userId == nil {
            throw UserEndpointError.userIdMissing
        }

    let pathWithParams: URL = basePath.appendingPathComponent("/\(userId!)")

    EndpointUtils.genericGetRequest(path: pathWithParams) { dictionary, status, error in
        completionHandler(dictionary, status, error)
    }

}

    static func create(forDogId dogId: Int? = nil, body: [String: Any], completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        do {
            try EndpointUtils.genericPostRequest(path: basePath, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason for fail is invalid body
            throw UserEndpointError.bodyInvalid
        }

    }

    static func update(forDogId dogId: Int? = nil, forReminderId reminderId: Int? = nil, forLogId: Int? = nil, body: [String: Any], completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        // cannot do request without path param
        if userId == nil {
            throw UserEndpointError.userIdMissing
        }

        let pathWithParams: URL = basePath.appendingPathComponent("/\(userId!)")

        do {
            try EndpointUtils.genericPutRequest(path: pathWithParams, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason for fail is invalid body
            throw UserEndpointError.bodyInvalid
        }

    }

    static func delete(forDogId dogId: Int? = nil, forReminderId reminderId: Int? = nil, forLogId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        // cannot do request without path param
        if userId == nil {
            throw UserEndpointError.userIdMissing
        }

        let pathWithParams: URL = basePath.appendingPathComponent("/\(userId!)")

        EndpointUtils.genericDeleteRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
