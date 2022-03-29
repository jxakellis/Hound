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
        
        /*
         get(forDogId: dogId, forLogId: logId) { responseBody, responseStatus in
         switch responseStatus {
         case .successResponse:
         // Array of log JSON [{log1:'foo'},{log2:'bar'}]
         if let result = responseBody!["result"] as? [[String: Any]] {
         let log = Log(fromBody: result[0])
         // able to add all
         DispatchQueue.main.async {
         completionHandler(log)
         }
         }
         */
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
                        ErrorManager.alert(forError: GeneralResponseError.failurePostResponse)
                    }
                case .failureResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failurePostResponse)
                case .noResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noPostResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns an array of reminders. If the queries all returned a 200 status and are successful, then the reminder array with reminderIds is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked (only once).
     */
    static func create(forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([Reminder]?) -> Void) {
        DispatchQueue.global().async {
            var queriedReminders: [Reminder] = []
            
            var didCompleteCompletionHandler = false
            var didRecieveFailureResponse = false
            var didRecieveNoResponse = false
            
            // get reminder id for each reminder
            for reminder in reminders {
                // we want all or nothing, so stop if any reminder failed at any point
                guard didRecieveFailureResponse == false && didRecieveNoResponse == false else {
                    break
                }
                RemindersRequest.create(forDogId: dogId, forReminder: reminder) { reminderId, responseStatus in
                    switch responseStatus {
                    case .successResponse:
                        if reminderId != nil {
                            reminder.reminderId = reminderId!
                            queriedReminders.append(reminder)
                            checkForCompletionHandler()
                        }
                        else {
                            didRecieveFailureResponse = true
                            checkForCompletionHandler()
                        }
                    case .failureResponse:
                        didRecieveFailureResponse = true
                        checkForCompletionHandler()
                    case .noResponse:
                        didRecieveNoResponse = true
                        checkForCompletionHandler()
                    }
                }
            }
            
            func checkForCompletionHandler() {
                guard didCompleteCompletionHandler == false else {
                    return
                }
                if didRecieveNoResponse == true {
                    didCompleteCompletionHandler = true
                    DispatchQueue.main.async {
                        completionHandler(nil)
                        ErrorManager.alert(forError: GeneralResponseError.noPostResponse)
                    }
                    // delete created reminders as we don't want them locally
                    for reminder in queriedReminders {
                        RemindersRequest.delete(forDogId: dogId, forReminderId: reminder.reminderId) { _, _ in
                            // do nothing, we want to try to delete as much as possible but its fine if doesn't all work
                        }
                    }
                    
                }
                else if didRecieveFailureResponse == true {
                    didCompleteCompletionHandler = true
                    DispatchQueue.main.async {
                        completionHandler(nil)
                        ErrorManager.alert(forError: GeneralResponseError.failurePostResponse)
                    }
                    // delete created reminders as we don't want them locally
                    for reminder in queriedReminders {
                        RemindersRequest.delete(forDogId: dogId, forReminderId: reminder.reminderId) { _, _ in
                            // do nothing, we want to try to delete as much as possible but its fine if doesn't all work
                        }
                    }
                    
                }
                else {
                    if queriedReminders.count == reminders.count {
                        didCompleteCompletionHandler = true
                        DispatchQueue.main.async {
                            // finished queries all the reminders
                            completionHandler(queriedReminders)
                        }
                    }
                    else {
                        // still querying reminders.
                        // Either all of the reminders will be successfully queried and the above piece of code will trigger OR at some point a failure/no response will be encountered and the code at the beginning of this function will return
                    }
                    
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
                    ErrorManager.alert(forError: GeneralResponseError.failurePutResponse)
                case .noResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.noPutResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns a boolean. If the queries all returned a 200 status and are successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked (only once).
     */
    static func update(forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            var successfullyQueriedReminders = 0
            
            var didCompleteCompletionHandler = false
            var didRecieveFailureResponse = false
            var didRecieveNoResponse = false
            
            // get reminder id for each reminder
            for reminder in reminders {
                // we want all or nothing, so stop if any reminder failed at any point
                guard didRecieveFailureResponse == false && didRecieveNoResponse == false else {
                    break
                }
                RemindersRequest.update(forDogId: dogId, forReminder: reminder) { _, responseStatus in
                    switch responseStatus {
                    case .successResponse:
                        successfullyQueriedReminders += 1
                        checkForCompletionHandler()
                    case .failureResponse:
                        didRecieveFailureResponse = true
                        checkForCompletionHandler()
                    case .noResponse:
                        didRecieveNoResponse = true
                        checkForCompletionHandler()
                    }
                }
            }
            
            func checkForCompletionHandler() {
                guard didCompleteCompletionHandler == false else {
                    return
                }
                if didRecieveNoResponse == true {
                    didCompleteCompletionHandler = true
                    DispatchQueue.main.async {
                        completionHandler(false)
                        ErrorManager.alert(forError: GeneralResponseError.noPutResponse)
                    }
                }
                else if didRecieveFailureResponse == true {
                    didCompleteCompletionHandler = true
                    DispatchQueue.main.async {
                        completionHandler(false)
                        ErrorManager.alert(forError: GeneralResponseError.failurePutResponse)
                    }
                }
                else {
                    if successfullyQueriedReminders == reminders.count {
                        didCompleteCompletionHandler = true
                        DispatchQueue.main.async {
                            // finished queries all the reminders
                            completionHandler(true)
                        }
                    }
                    else {
                        // still querying reminders.
                        // Either all of the reminders will be successfully queried and the above piece of code will trigger OR at some point a failure/no response will be encountered and the code at the beginning of this function will return
                    }
                    
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
                    ErrorManager.alert(forError: GeneralResponseError.failureDeleteResponse)
                case .noResponse:
                    completionHandler(false)
                    ErrorManager.alert(forError: GeneralResponseError.noDeleteResponse)
                }
            }
        }
    }
    
    /**
     completionHandler returns a boolean. If the queries all returned a 200 status and are successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked (only once).
     */
    static func delete(forDogId dogId: Int, reminderIds: [Int], completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            var successfullyQueriedReminders = 0
            
            var didCompleteCompletionHandler = false
            var didRecieveFailureResponse = false
            var didRecieveNoResponse = false
            
            // get reminder id for each reminder
            for reminderId in reminderIds {
                // we want all or nothing, so stop if any reminder failed at any point
                guard didRecieveFailureResponse == false && didRecieveNoResponse == false else {
                    break
                }
                RemindersRequest.delete(forDogId: dogId, forReminderId: reminderId) { _, responseStatus in
                    switch responseStatus {
                    case .successResponse:
                        successfullyQueriedReminders += 1
                        checkForCompletionHandler()
                    case .failureResponse:
                        didRecieveFailureResponse = true
                        checkForCompletionHandler()
                    case .noResponse:
                        didRecieveNoResponse = true
                        checkForCompletionHandler()
                    }
                }
            }
            
            func checkForCompletionHandler() {
                guard didCompleteCompletionHandler == false else {
                    return
                }
                if didRecieveNoResponse == true {
                    didCompleteCompletionHandler = true
                    DispatchQueue.main.async {
                        completionHandler(false)
                        
                        ErrorManager.alert(forError: GeneralResponseError.noPutResponse)
                    }
                }
                else if didRecieveFailureResponse == true {
                    didCompleteCompletionHandler = true
                    DispatchQueue.main.async {
                        completionHandler(false)
                        ErrorManager.alert(forError: GeneralResponseError.failurePutResponse)
                    }
                }
                else {
                    if successfullyQueriedReminders == reminderIds.count {
                        didCompleteCompletionHandler = true
                        DispatchQueue.main.async {
                            // finished queries all the reminders
                            completionHandler(true)
                        }
                    }
                    else {
                        // still querying reminders.
                        // Either all of the reminders will be successfully queried and the above piece of code will trigger OR at some point a failure/no response will be encountered and the code at the beginning of this function will return
                    }
                }
                
            }
            
        }
    }
}
