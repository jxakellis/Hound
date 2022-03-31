//
//  InternalRequestUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/25/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// abstractions used by other endpoint classes to make their request to the server, not used anywhere else in hound so therefore internal to endpoints and api requests.
enum InternalRequestUtils {
    static let basePathWithoutParams: URL = URL(string: "http://192.168.4.253:5000/api/v1")!
    // home URL(string: "http://10.0.0.107:5000/api/v1")!
    //  school URL(string: "http://10.1.10.235:5000/api/v1")!
    // hotspot URL(string: "http://172.20.10.2:5000/api/v1")!
    // no wifi / local simulator URL(string: "http://localhost:5000/api/v1")!
    /*
     let sessionConfig = URLSessionConfiguration.default
     sessionConfig.timeoutIntervalForRequest = 30.0
     sessionConfig.timeoutIntervalForResource = 60.0
     let session = URLSession(configuration: sessionConfig)
     */
    private static var sessionConfig: URLSessionConfiguration {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 15.0
        sessionConfig.timeoutIntervalForResource = 30.0
        return sessionConfig
    }
    static let session = URLSession(configuration: sessionConfig)
    
    /// Takes an already constructed URLRequest and executes it, returning it in a compeltion handler. This is the basis to all URL requests
    static func genericRequest(request: URLRequest, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        // send request
        let task = session.dataTask(with: request) { data, response, error in
            // extract status code from URLResponse
            var responseCode: Int?
            if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
            }
            
            // parse response from json
            var responseBody: [String: Any]?
            // if no data or if no status code, then request failed
            if data != nil && responseCode != nil {
                do {
                    // try to serialize data as "result" form with array of info first, if that fails, revert to regular "message" and "error" format
                    responseBody = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String: [[String: Any]]] ?? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String: Any]
                }
                catch {
                    AppDelegate.APIRequestLogger.error("Error When Serializing Data Into JSON \(error.localizedDescription)")
                }
            }
            
            // pass out information
            if error != nil || (data == nil && response == nil) {
                // assume an error is no response as that implies request/response failure, meaning the end result of no response is the same
                completionHandler(responseBody, .noResponse)
            }
            else if responseCode != nil {
                // we got a response from the server
                if 200...299 ~= responseCode! && responseBody != nil {
                    // our request was valid and successful
                    completionHandler(responseBody, .successResponse)
                }
                else {
                    // our request was invalid or some other problem
                    completionHandler(responseBody, .failureResponse)
                }
            }
            else {
                // something happened and we got no response
                completionHandler(responseBody, .noResponse)
            }
            
        }
        
        // free up task when request is pushed
        task.resume()
    }
}

extension InternalRequestUtils {
    
    /// Perform a generic get request at the specified url, assuming path params are already provided.
    static func genericGetRequest(path: URL, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        // create request to send
        var req = URLRequest(url: path)
        
        // specify http method
        req.httpMethod = "GET"
        
        genericRequest(request: req) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
        AppDelegate.APIRequestLogger.notice("Get Request for \(path)")
    }
    
    /// Perform a generic get request at the specified url with provided body. Throws as creating request can fail if body is invalid.
    static func genericPostRequest(path: URL, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForEmptyBody(forPath: path, forBody: body)
        
        // create request to send
        var req = URLRequest(url: path)
        
        // specify http method
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            req.httpBody = jsonData
            
            genericRequest(request: req) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
            
            AppDelegate.APIRequestLogger.notice("Post Request for \(path)")
            // AppDelegate.APIRequestLogger.notice("Post Request for \(path) \n For Body: \(body)")
        }
        catch {
            completionHandler(nil, .noResponse)
        }
        
    }
    
    /// Perform a generic get request at the specified url with provided body, assuming path params are already provided. Throws as creating request can fail if body is invalid
    static func genericPutRequest(path: URL, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForEmptyBody(forPath: path, forBody: body)
        
        // create request to send
        var req = URLRequest(url: path)
        
        // specify http method
        req.httpMethod = "PUT"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            req.httpBody = jsonData
            
            genericRequest(request: req) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
            
            AppDelegate.APIRequestLogger.notice("Put Request for \(path)")
            // AppDelegate.APIRequestLogger.notice("Put Request for \(path) \n For Body: \(body)")
        }
        catch {
            completionHandler(nil, .noResponse)
        }
        
    }
    
    /// Perform a generic get request at the specified url, assuming path params are already provided. No body needed for request. No throws as request creating cannot fail
    static func genericDeleteRequest(path: URL, body: [String: Any]? = nil, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        // create request to send
        var req = URLRequest(url: path)
        
        // specify http method
        req.httpMethod = "DELETE"
        
        if body == nil {
            genericRequest(request: req) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
        else {
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body!)
                req.httpBody = jsonData
                
                genericRequest(request: req) { responseBody, responseStatus in
                    completionHandler(responseBody, responseStatus)
                }
            }
            catch {
                completionHandler(nil, .noResponse)
            }
        }
        
        AppDelegate.APIRequestLogger.notice("Delete Request for \(path)")
        
    }
    
    /// returns an array that contains the user's personal information and userConfiguration and is suitable to be a http request body
    static func createFullUserBody() -> [String: Any] {
        var body: [String: Any] = createUserConfigurationBody()
        body[UserDefaultsKeys.userIdentifier.rawValue] = UserInformation.userIdentifier
        body[UserDefaultsKeys.userEmail.rawValue] = UserInformation.userEmail
        body[UserDefaultsKeys.userFirstName.rawValue] = UserInformation.userFirstName
        body[UserDefaultsKeys.userLastName.rawValue] = UserInformation.userLastName
        return body
    }
    
    static func createUserInformationBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[UserDefaultsKeys.userIdentifier.rawValue] = UserInformation.userIdentifier
        body[UserDefaultsKeys.userEmail.rawValue] = UserInformation.userEmail
        body[UserDefaultsKeys.userFirstName.rawValue] = UserInformation.userFirstName
        body[UserDefaultsKeys.userLastName.rawValue] = UserInformation.userLastName
        return body
    }
    
    /// returns an array that only contains the user's userConfiguration and is that is suitable to be a http request body
    static func createUserConfigurationBody() -> [String: Any] {
        var body: [String: Any] = [:]
        // isCompactView
        // interfaceStyle
        // snoozeLength
        // isPaused
        // isNotificationAuthorized
        // isNotificationEnabled
        // isLoudNotification
        // isFollowUpEnabled
        // followUpDelay
        // notificationSound
        
        body[UserDefaultsKeys.isCompactView.rawValue] = UserConfiguration.isCompactView
        body[UserDefaultsKeys.interfaceStyle.rawValue] = UserConfiguration.interfaceStyle.rawValue
        body[UserDefaultsKeys.snoozeLength.rawValue] = UserConfiguration.snoozeLength
        body[UserDefaultsKeys.isPaused.rawValue] = UserConfiguration.isPaused
        body[UserDefaultsKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
        body[UserDefaultsKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
        body[UserDefaultsKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
        body[UserDefaultsKeys.followUpDelay.rawValue] = UserConfiguration.followUpDelay
        body[UserDefaultsKeys.notificationSound.rawValue] = UserConfiguration.notificationSound.rawValue
        return body
    }
    
    /// returns an array that is suitable to be a http request body
    static func createDogBody(dog: Dog) -> [String: Any] {
        var body: [String: Any] = [:]
        body["dogName"] = dog.dogName
        return body
    }
    
    /// returns an array that is suitable to be a http request body
    static func createLogBody(log: Log) -> [String: Any] {
        var body: [String: Any] = [:]
        body["note"] = log.note
        body["date"] = log.date.ISO8601Format()
        body["logAction"] = log.logAction.rawValue
        if log.logAction == .custom && log.customActionName != nil {
            body["customActionName"] = log.customActionName
        }
        return body
        
    }
    
    /// returns an array that is suitable to be a http request body
    static func createReminderBody(reminder: Reminder) -> [String: Any] {
        var body: [String: Any] = [:]
        body["reminderId"] = reminder.reminderId
        body["reminderAction"] = reminder.reminderAction.rawValue
        if reminder.reminderAction == .custom && reminder.customActionName != nil {
            body["customActionName"] = reminder.customActionName
        }
        body["executionBasis"] = reminder.executionBasis.ISO8601Format()
        body["isEnabled"] = reminder.isEnabled
        
        body["reminderType"] = reminder.reminderType.rawValue
        // add the reminder components depending on the reminderType
        switch reminder.reminderType {
        case .countdown:
            body["countdownExecutionInterval"] = reminder.countdownComponents.executionInterval
            body["countdownIntervalElapsed"] = reminder.countdownComponents.intervalElapsed
        case .weekly:
            body["weeklyHour"] = reminder.weeklyComponents.dateComponents.hour
            body["weeklyMinute"] = reminder.weeklyComponents.dateComponents.minute
           body["weeklyIsSkipping"] = reminder.weeklyComponents.isSkipping
            if reminder.weeklyComponents.isSkipping == true && reminder.weeklyComponents.isSkippingDate != nil {
                body["weeklySkipDate"] = reminder.weeklyComponents.isSkippingDate!.ISO8601Format()
            }
            
            body["sunday"] = false
            body["monday"] = false
            body["tuesday"] = false
            body["wednesday"] = false
            body["thursday"] = false
            body["friday"] = false
            body["saturday"] = false
            
            for weekday in reminder.weeklyComponents.weekdays {
                switch weekday {
                case 1:
                    body["sunday"] = true
                case 2:
                    body["monday"] = true
                case 3:
                    body["tuesday"] = true
                case 4:
                    body["wednesday"] = true
                case 5:
                    body["thursday"] = true
                case 6:
                    body["friday"] = true
                case 7:
                    body["saturday"] = true
                default:
                    continue
                }
            }
            
        case .monthly:
            body["monthlyHour"] = reminder.monthlyComponents.dateComponents.hour
            body["monthlyMinute"] = reminder.monthlyComponents.dateComponents.minute
            body["monthlyIsSkipping"] = reminder.monthlyComponents.isSkipping
            if reminder.monthlyComponents.isSkipping == true && reminder.monthlyComponents.isSkippingDate != nil {
                body["monthlySkipDate"] = reminder.monthlyComponents.isSkippingDate!.ISO8601Format()
            }
            body["dayOfMonth"] = reminder.monthlyComponents.dayOfMonth
        case .oneTime:
            body["date"] = reminder.oneTimeComponents.executionDate.ISO8601Format()
        }
        
        return body
    }
    
    /// Returns an array of reminder bodies under the key "reminders". E.g. { reminders : [{reminder1}, {reminder2}] }
    static func createRemindersBody(reminders: [Reminder]) -> [String: [[String: Any]]] {
        var remindersArray: [[String: Any]] = []
        for reminder in reminders {
            remindersArray.append(createReminderBody(reminder: reminder))
        }
        let body: [String: [[String: Any]]] = ["reminders": remindersArray]
        return body
    }
    
    /// returns an array that is suitable to be a http request body
    static func createReminderIdBody(reminderId: Int) -> [String: Any] {
        var body: [String: Any] = [:]
        body["reminderId"] = reminderId
       return body
    }
    
    /// Returns an array of reminder bodies under the key "reminders". E.g. { reminders : [{reminder1}, {reminder2}] }
    static func createReminderIdsBody(reminderIds: [Int]) -> [String: [[String: Any]]] {
        var reminderIdsArray: [[String: Any]] = []
        for reminderId in reminderIds {
            reminderIdsArray.append(createReminderIdBody(reminderId: reminderId))
        }
        let body: [String: [[String: Any]]] = ["reminders": reminderIdsArray]
        return body
    }
    
}

enum RequestUtils {
    static var ISO8601DateFormatter: ISO8601DateFormatter = {
        let formatter = Foundation.ISO8601DateFormatter()
        formatter.formatOptions = [.withFractionalSeconds, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]
        return formatter
    }()
    
    /**
     completionHandler returns a dogManager. If the query returned a 200 status and is successful, then the dogManager is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func getDogManager(completionHandler: @escaping (DogManager?) -> Void) {
        // assume userId valid as it was retrieved when the app started. Later on with familyId, if a user was removed from the family, then this refresh could fail.
        
        // Retrieve any dogs the user may have
        DogsRequest.getAll(reminders: true, logs: true) { dogArray in
            if dogArray != nil {
                let dogManager = DogManager(forDogs: dogArray!)
                DispatchQueue.main.async {
                    completionHandler(dogManager)
                }
            }
            else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
        }
    }
    /// Provides warning if the id of anything is set to a placeholder value. 
    static func warnForPlaceholderId(dogId: Int? = nil, reminders: [Reminder]? = nil, reminderId: Int? = nil, reminderIds: [Int]? = nil, logId: Int? = nil) {
        if UserInformation.userId == nil {
            AppDelegate.APIRequestLogger.warning("Warning: userId is nil")
        }
        if UserInformation.userId! < 0 {
            AppDelegate.APIRequestLogger.warning("Warning: userId is placeholder \(UserInformation.userId!)")
        }
        if dogId != nil && dogId! < 0 {
            AppDelegate.APIRequestLogger.warning("Warning: dogId is placeholder \(dogId!)")
        }
        if reminders != nil {
            for singleReminder in reminders! where singleReminder.reminderId < 0 {
                AppDelegate.APIRequestLogger.warning("Warning: reminderId is placeholder \(singleReminder.reminderId)")
            }
        }
        if reminderIds != nil {
            for singleReminderId in reminderIds! where singleReminderId < 0 {
                AppDelegate.APIRequestLogger.warning("Warning: reminderId is placeholder \(singleReminderId)")
            }
        }
        if reminderId != nil && reminderId! < 0 {
            AppDelegate.APIRequestLogger.warning("Warning: reminderId is placeholder \(reminderId!)")
        }
        if logId != nil && logId! < 0 {
            AppDelegate.APIRequestLogger.warning("Warning: logId is placeholder \(logId!)")
        }
    }
    /// Provides warning if the id of anything is set to a placeholder value.
    static func warnForEmptyBody(forPath path: URL, forBody body: [String: Any]) {
        if body.keys.count == 0 {
            AppDelegate.APIRequestLogger.warning("Warning: Body is empty \nFor path: \(path)")
        }
    }
    
    /// Presents a custom made loadingAlertController on the global presentor that blocks everything until endAlertControllerQueryIndictator is called
    static func beginAlertControllerQueryIndictator() {
        AlertManager.enqueueAlertForPresentation(AlertManager.shared.loadingAlertController)
    }
    
    /// Dismisses the custom made loadingAlertController. Allow the app to resume normal execution once the completion handler is called (as that indicates the loadingAlertController was dismissed and new things can be presented/segued to).
    static func endAlertControllerQueryIndictator(completionHandler: @escaping () -> Void) {
        AlertManager.shared.loadingAlertController.dismiss(animated: false) {
            completionHandler()
        }
    }
}
