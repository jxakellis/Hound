//
//  RemindersEndpoint.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum RemindersEndpointError: Error {
    case dogIdMissing
    case reminderIdMissing
    case bodyInvalid
}

enum RemindersEndpoint: EndpointObjectProtocol {

    static let basePathWithoutParams: URL = UserEndpoint.basePathWithUserId.appendingPathComponent("/dogs")

    static func get(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId logId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        let pathWithParams: URL

        // we need dogId to find the reminders for a given dog
        if dogId != nil && reminderId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/reminders/\(reminderId!)")
        }
        // don't necessarily need a reminderId, no reminderId specifys that you want all reminders for a dog
        else if dogId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/reminders")
        }
        else {
            throw RemindersEndpointError.dogIdMissing
        }

        // make get request
        InternalEndpointUtils.genericGetRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

}

    static func create(forDogId dogId: Int?, body: [String: Any]?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        guard body != nil else {
            throw RemindersEndpointError.bodyInvalid
        }

        let pathWithParams: URL

        // we need dogId to create a reminder for a given dog
        if dogId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/reminders/")
        }
        else {
            throw RemindersEndpointError.dogIdMissing
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
    }

    static func update(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId logId: Int? = nil, body: [String: Any]?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        guard body != nil else {
            throw RemindersEndpointError.bodyInvalid
        }

        let pathWithParams: URL

        // we need dogId and reminderId to update a reminder for a given dog
        if dogId != nil && reminderId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/reminders/\(reminderId!)")
        }
        else if dogId == nil {
            throw RemindersEndpointError.dogIdMissing
        }
        else {
            throw RemindersEndpointError.reminderIdMissing
        }

        // make put request
        do {
            try InternalEndpointUtils.genericPutRequest(path: pathWithParams, body: body!) { dictionary, status, error in
                completionHandler(dictionary, status, error)
            }
        }
        catch {
            // only reason to fail immediately is if there was an invalid body
            throw RemindersEndpointError.bodyInvalid
        }

    }

    static func update(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId logId: Int?, objectForBody: NSObject, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {
        //
    }

    static func delete(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId logId: Int? = nil, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        let pathWithParams: URL

        // we need dogId and reminderId to delete a reminder for a given dog
        if dogId != nil && reminderId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId!)/reminders/\(reminderId!)")
        }
        else if dogId == nil {
            throw RemindersEndpointError.dogIdMissing
        }
        else {
            throw RemindersEndpointError.reminderIdMissing
        }

        // make delete request
        InternalEndpointUtils.genericDeleteRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
