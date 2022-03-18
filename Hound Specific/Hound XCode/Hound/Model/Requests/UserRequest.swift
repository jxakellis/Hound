//
//  UserRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum UserRequestError: Error {
    case bodyInvalid
}

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum UserRequest: RequestProtocol {

    static let basePathWithoutParams: URL = InternalRequestUtils.basePathWithoutParams.appendingPathComponent("/user")
    // UserRequest basePath with the userId path param appended on
    static var basePathWithUserId: URL { return UserRequest.basePathWithoutParams.appendingPathComponent("/\(UserInformation.userId)") }

    /**
    Uses userId to retrieve information
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func get(completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {
        RequestUtils.checkId()
        // at this point in time, an error can only occur if there is a invalid body provided. Since there is no body, there is no risk of an error.
    InternalRequestUtils.genericGetRequest(path: basePathWithUserId) { dictionary, status, error in
        completionHandler(dictionary, status, error)
    }

}
    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func get(forUserEmail: String, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {
        InternalRequestUtils.genericGetRequest(path: basePathWithoutParams.appendingPathComponent("/\(forUserEmail)")) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func create(completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        // make post request, assume body valid as constructed with method
        try! InternalRequestUtils.genericPostRequest(path: basePathWithoutParams, body: InternalRequestUtils.createFullUserBody()) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

        /*
        do {
            try InternalRequestUtils.genericPostRequest(path: basePathWithoutParams, body: InternalRequestUtils.createFullUserBody()) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body, body is provided by a static inside source so it should never fail
            throw UserRequestError.bodyInvalid
        }
         */

    }

    /**
    Lazy update, sends all configuration and information
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func updateAll(completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {
        RequestUtils.checkId()
        let body = InternalRequestUtils.createFullUserBody()

        // make put request, assume body valid as constructed with method
        try! InternalRequestUtils.genericPutRequest(path: basePathWithUserId, body: body) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
        /*
        
        do {
            try InternalRequestUtils.genericPutRequest(path: basePathWithUserId, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw UserRequestError.bodyInvalid
        }
         */

    }

    /**
    Target update. Specifically updates user information or configuration. Body is constructed from known good values so can assume no failures as all pre determiend.
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func update(body: [String: Any], completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {
        RequestUtils.checkId()

        // make put request, assume body valid as constructed with method
        try! InternalRequestUtils.genericPutRequest(path: basePathWithUserId, body: body) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
        /*
        
        do {
            try InternalRequestUtils.genericPutRequest(path: basePathWithUserId, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw UserRequestError.bodyInvalid
        }
         */

    }

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func delete(completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {
        RequestUtils.checkId()
        InternalRequestUtils.genericDeleteRequest(path: basePathWithUserId) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
