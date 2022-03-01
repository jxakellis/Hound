//
//  DogEndpoint.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogEndpointError: Error {
    case dogIdMissing
    case bodyInvalid
}

enum DogEndpoint: EndpointProtocol {
    static let basePath: URL = UserEndpoint.basePathWithUserId.appendingPathComponent("/dogs")

    static func get(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        let pathWithParams: URL

        if dogId != nil {
            pathWithParams = basePath.appendingPathComponent("/\(dogId!)")
        }
        else {
            pathWithParams = basePath
        }

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
            throw DogEndpointError.bodyInvalid
        }

    }

    static func update(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId: Int? = nil, body: [String: Any], completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        if dogId == nil {
            throw DogEndpointError.dogIdMissing
        }

        let pathWithParams: URL = basePath.appendingPathComponent("/\(dogId!)")

        do {
            try EndpointUtils.genericPutRequest(path: pathWithParams, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            throw DogEndpointError.bodyInvalid
        }

    }

    static func delete(forDogId dogId: Int?, forReminderId reminderId: Int? = nil, forLogId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        if dogId == nil {
            throw DogEndpointError.dogIdMissing
        }

        let pathWithParams: URL = basePath.appendingPathComponent("/\(dogId!)")

        EndpointUtils.genericDeleteRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
