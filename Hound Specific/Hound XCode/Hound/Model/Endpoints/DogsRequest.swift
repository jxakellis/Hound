//
//  DogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogsRequestError: Error {
    case dogIdMissing
    case bodyInvalid
}

enum DogsRequest: RequestProtocol {
    static let basePathWithoutParams: URL = UserRequest.basePathWithUserId.appendingPathComponent("/dogs")

    /**
     dogId optional, providing it only returns the single dog (if found) otherwise returns all dogs
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func get(forDogId dogId: Int?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        let pathWithParams: URL

        // special case where we append the query parameter of all. Its value doesn't matter but it just tells the server that we want the logs and reminders of the dog too.
        if dogId != nil {
            RequestUtils.checkId(dogId: dogId!)
            var path = URLComponents(url: basePathWithoutParams.appendingPathComponent("/\(dogId!)"), resolvingAgainstBaseURL: false)!
            path.queryItems = [URLQueryItem(name: "reminders", value: "true"), URLQueryItem(name: "logs", value: "true")]
            pathWithParams = path.url!
        }
        else {
            var path = URLComponents(url: basePathWithoutParams.appendingPathComponent(""), resolvingAgainstBaseURL: false)!
            path.queryItems = [URLQueryItem(name: "reminders", value: "true"), URLQueryItem(name: "logs", value: "true")]
            pathWithParams = path.url!
        }

        // make get request
    InternalRequestUtils.genericGetRequest(path: pathWithParams) { dictionary, status, error in
        completionHandler(dictionary, status, error)
    }

}

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func create(forDog dog: Dog, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        let body = InternalRequestUtils.createDogBody(dog: dog)

        // make put request, assume body valid as constructed with method
        try! InternalRequestUtils.genericPostRequest(path: basePathWithoutParams, body: body) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

        /*
        do {
            try InternalRequestUtils.genericPostRequest(path: basePathWithoutParams, body: body) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw DogsRequestError.bodyInvalid
        }
         */
    }

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func update(forDog dog: Dog, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        RequestUtils.checkId(dogId: dog.dogId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dog.dogId)")

        let body = InternalRequestUtils.createDogBody(dog: dog)

        // make put request, assume body valid as constructed with method
        try! InternalRequestUtils.genericPutRequest(path: pathWithParams, body: body) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
        /*
         do {
             try InternalRequestUtils.genericPutRequest(path: pathWithParams, body: body) { dictionary, status, error in
                 completionHandler(dictionary, status, error)
         }
         catch {
             // only reason to fail immediately is if there was an invalid body
             throw DogsRequestError.bodyInvalid
         }
         */

    }

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func delete(forDogId dogId: Int, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        RequestUtils.checkId(dogId: dogId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)")

        // make delete request
        InternalRequestUtils.genericDeleteRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
