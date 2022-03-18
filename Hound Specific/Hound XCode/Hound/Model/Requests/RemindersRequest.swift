//
//  RemindersRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum RemindersRequestError: Error {
    case dogIdMissing
    case reminderIdMissing
    case bodyInvalid
}

enum RemindersRequest: RequestProtocol {

    static let basePathWithoutParams: URL = UserRequest.basePathWithUserId.appendingPathComponent("/dogs")

    /**
     reminderId optional, providing it only returns the single reminder (if found) otherwise returns all reminders
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func get(forDogId dogId: Int, forReminderId reminderId: Int?, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        RequestUtils.checkId(dogId: dogId, reminderId: reminderId)
        let pathWithParams: URL

        if reminderId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders/\(reminderId!)")
        }
        // don't necessarily need a reminderId, no reminderId specifys that you want all reminders for a dog
        else {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders")
        }

        // make get request
        InternalRequestUtils.genericGetRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

}

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func create(forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {

        RequestUtils.checkId(dogId: dogId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders/")

        let body = InternalRequestUtils.createReminderBody(reminder: reminder)

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
            throw RemindersRequestError.bodyInvalid
        }
         */

    }

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func update(forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        RequestUtils.checkId(dogId: dogId, reminderId: reminder.reminderId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders/\(reminder.reminderId)")

        let body = InternalRequestUtils.createReminderBody(reminder: reminder)

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
            throw RemindersRequestError.bodyInvalid
        }
         */
    }

    /**
     completionHandler returns response data: dictionary of the body, status code, and errors that occured when request sent.
     */
    static func delete(forDogId dogId: Int, forReminderId reminderId: Int, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {

        RequestUtils.checkId(dogId: dogId, reminderId: reminderId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders/\(reminderId)")

        // make delete request
        InternalRequestUtils.genericDeleteRequest(path: pathWithParams) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }
}
