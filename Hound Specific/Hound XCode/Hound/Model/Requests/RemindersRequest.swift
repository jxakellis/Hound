//
//  RemindersRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum RemindersRequest: RequestProtocol {
    
    static let basePathWithoutParams: URL = UserRequest.basePathWithUserId.appendingPathComponent("/dogs")
    
    // MARK: - Private Functions
    
    /**
     reminderId optional, providing it only returns the single reminder (if found) otherwise returns all reminders
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func get(forDogId dogId: Int, forReminderId reminderId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId, reminderId: reminderId)
        let pathWithParams: URL
        
        if reminderId != nil {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders/\(reminderId!)")
        }
        // don't necessarily need a reminderId, no reminderId specifys that you want all reminders for a dog
        else {
            pathWithParams = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders")
        }
        
        // make get request
        InternalRequestUtils.genericGetRequest(path: pathWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: reminderId for the created reminder and the ResponseStatus
     */
    private static func create(forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders/")
        
        let body = InternalRequestUtils.createReminderBody(reminder: reminder)
        
        // make post request, assume body valid as constructed with method
        try! InternalRequestUtils.genericPostRequest(path: pathWithParams, body: body) { responseBody, responseStatus in
            if responseBody != nil, let reminderId = responseBody!["result"] as? Int {
                completionHandler(reminderId, responseStatus)
            }
            else {
                completionHandler(nil, responseStatus)
            }
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func update(forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId, reminderId: reminder.reminderId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders/\(reminder.reminderId)")
        
        let body = InternalRequestUtils.createReminderBody(reminder: reminder)
        
        // make put request, assume body valid as constructed with method
        try! InternalRequestUtils.genericPutRequest(path: pathWithParams, body: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func delete(forDogId dogId: Int, forReminderId reminderId: Int, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId, reminderId: reminderId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)/reminders/\(reminderId)")
        
        // make delete request
        InternalRequestUtils.genericDeleteRequest(path: pathWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
}

extension RemindersRequest {
    
    // MARK: - Public Functions
    
    /**
     completionHandler returns a reminder. If the query returned a 200 status and is successful, then the reminder is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func get(forDogId dogId: Int, forReminderId reminderId: Int, completionHandler: @escaping (Reminder?) -> Void) {
        
        // make get request
        RemindersRequest.get(forDogId: dogId, forReminderId: reminderId) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Array of reminder JSON [{reminder1:'foo'},{reminder2:'bar'}]
                if let result = responseBody!["result"] as? [[String: Any]] {
                    let reminder = Reminder(fromBody: result[0])
                    // able to add all
                    DispatchQueue.main.async {
                        completionHandler(reminder)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                    }
                }
            case .failureResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                }
                
            case .noResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                }
            }
        }
    }
    
    /**
     ccompletionHandler returns an array of reminders. If the query returned a 200 status and is successful, then the array of reminders is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func getAll(forDogId dogId: Int, completionHandler: @escaping ([Reminder]?) -> Void) {
        
        // make get request
        RemindersRequest.get(forDogId: dogId, forReminderId: nil) { responseBody, responseStatus in
            
            switch responseStatus {
            case .successResponse:
                // Array of reminder JSON [{reminder1:'foo'},{reminder2:'bar'}]
                if let result = responseBody!["result"] as? [[String: Any]] {
                    var reminderArray: [Reminder] = []
                    for reminderBody in result {
                        let reminder = Reminder(fromBody: reminderBody)
                        reminderArray.append(reminder)
                    }
                    // able to add all
                    DispatchQueue.main.async {
                        completionHandler(reminderArray)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                    }
                }
            case .failureResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                }
                
            case .noResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns a Int. If the query returned a 200 status and is successful, then reminderId is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func create(forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Int?) -> Void) {
        
        RemindersRequest.create(forDogId: dogId, forReminder: reminder) { reminderId, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    if reminderId != nil {
                        completionHandler(reminderId!)
                    }
                    else {
                        ErrorManager.alert(forError: GeneralResponseError.failureResponse)
                    }
                case .failureResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failureResponse)
                case .noResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns a Bool. If the query returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked.
     */
    static func update(forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Bool) -> Void) {
        
        RemindersRequest.update(forDogId: dogId, forReminder: reminder) { _, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    completionHandler(true)
                case .failureResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.failureResponse)
                case .noResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.noResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns a Bool. If the query returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked.
     */
    static func delete(forDogId dogId: Int, forReminderId reminderId: Int, completionHandler: @escaping (Bool) -> Void) {
        RemindersRequest.delete(forDogId: dogId, forReminderId: reminderId) { _, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    completionHandler(true)
                case .failureResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.failureResponse)
                case .noResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.noResponse)
                }
            }
        }
    }
}
