//
//  RemindersRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum RemindersRequest: RequestProtocol {
    
    /// Need dog id for any request so we can't append '/reminders' until we have dogId
    static var baseURLWithoutParams: URL { return DogsRequest.baseURLWithoutParams }
    
    // MARK: - Private Functions
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalGet(invokeErrorManager: Bool, forDogId dogId: Int, forReminderId reminderId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL
        
        if let reminderId = reminderId {
            URLWithParams = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders/\(reminderId)")
        }
        // don't necessarily need a reminderId, no reminderId specifys that you want all reminders for a dog
        else {
            URLWithParams = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders")
        }
        
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /// Returns an array of reminder bodies under the key "reminders". E.g. { reminders : [{reminder1}, {reminder2}] }
    private static func createRemindersBody(reminders: [Reminder]) -> [String: [[String: Any]]] {
        var remindersArray: [[String: Any]] = []
        for reminder in reminders {
            remindersArray.append(reminder.createBody())
        }
        let body: [String: [[String: Any]]] = [ServerDefaultKeys.reminders.rawValue: remindersArray]
        return body
    }
    
    /**
     completionHandler returns response data: created reminder with reminderId and the ResponseStatus
     */
    private static func internalCreate(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders/")
        
        let body = createRemindersBody(reminders: reminders)
        
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: created reminder with reminderId and the ResponseStatus
     */
    private static func internalCreate(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders/")
        
        let body = reminder.createBody()
        
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalUpdate(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders/")
        
        let body = createRemindersBody(reminders: reminders)
        
        return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /// Returns an array of reminder bodies under the key ."reminders" E.g. { reminders : [{reminder1}, {reminder2}] }
    private static func createReminderIdsBody(forReminders reminders: [Reminder]) -> [String: [[String: Any]]] {
        var reminderIdsArray: [[String: Any]] = []
        for reminder in reminders {
            reminderIdsArray.append(reminder.createIdBody())
        }
        let body: [String: [[String: Any]]] = [ServerDefaultKeys.reminders.rawValue: reminderIdsArray]
        return body
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalDelete(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders/")
        let body = createReminderIdsBody(forReminders: reminders)
        
        return InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
}

extension RemindersRequest {
    
    // MARK: - Public Functions
    
    /**
     completionHandler returns a possible reminder and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func get(invokeErrorManager: Bool, forDogId dogId: Int, forReminderId reminderId: Int, completionHandler: @escaping (Reminder?, ResponseStatus) -> Void) {
        
        _ = RemindersRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminderId: reminderId) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [String: Any], result.isEmpty == false {
                    completionHandler(Reminder(fromBody: result), responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a possible array of reminders and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func get(invokeErrorManager: Bool, forDogId dogId: Int, completionHandler: @escaping ([Reminder]?, ResponseStatus) -> Void) {
        
        _ = RemindersRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminderId: nil) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [[String: Any]] {
                    var reminderArray: [Reminder] = []
                    for reminderBody in result {
                        let reminder = Reminder(fromBody: reminderBody)
                        reminderArray.append(reminder)
                    }
                    completionHandler(reminderArray, responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a possible reminder and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func create(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Reminder?, ResponseStatus) -> Void) {
        
        _ = RemindersRequest.internalCreate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminder: reminder) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let reminderBody = responseBody?[ServerDefaultKeys.result.rawValue] as? [String: Any], reminderBody.isEmpty == false  {
                    completionHandler(Reminder(fromBody: reminderBody), responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a possible array of reminders and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func create(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([Reminder]?, ResponseStatus) -> Void) {
        
        _ = RemindersRequest.internalCreate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: reminders) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let remindersBody = responseBody?[ServerDefaultKeys.result.rawValue] as? [[String: Any]] {
                    var reminderArray: [Reminder] = []
                    for reminderBody in remindersBody {
                        let reminder = Reminder(fromBody: reminderBody)
                        reminderArray.append(reminder)
                    }
                    completionHandler(reminderArray, responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func update(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        
        _ = RemindersRequest.internalUpdate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: [reminder]) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func update(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        
        _ = RemindersRequest.internalUpdate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: reminders) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        _ = RemindersRequest.internalDelete(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: [reminder]) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        _ = RemindersRequest.internalDelete(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: reminders) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
}
