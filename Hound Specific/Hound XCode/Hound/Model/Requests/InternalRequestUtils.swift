//
//  InternalRequestUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// abstractions used by other endpoint classes to make their request to the server, not used anywhere else in hound so therefore internal to endpoints and api requests.
enum InternalRequestUtils {
    static let baseURLWithoutParams: URL = URL(string: "http://172.20.10.2:5000/api/v1")!
    // home URL(string: "http://10.0.0.107:5000/api/v1")!
    //  school URL(string: "http://10.1.11.124:5000/api/v1")!
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
        sessionConfig.timeoutIntervalForRequest = 7.5
        sessionConfig.timeoutIntervalForResource = 15.0
        return sessionConfig
    }
    private static let session = URLSession(configuration: sessionConfig)
    
    /// Takes an already constructed URLRequest and executes it, returning it in a compeltion handler. This is the basis to all URL requests
    private static func genericRequest(forRequest request: URLRequest, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        var modifiedRequest = request
        
        // append userIdentifier if we have it, need it to perform requests
        if UserInformation.userIdentifier != nil {
            // deconstruct request slightly
            var deconstructedURLComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            // if we try to append to nil, then it fails. so if the array is nil, we just make it an empty array
            deconstructedURLComponents!.queryItems = deconstructedURLComponents!.queryItems ?? []
            deconstructedURLComponents!.queryItems!.append(URLQueryItem(name: ServerDefaultsKeys.userIdentifier.rawValue, value: UserInformation.userIdentifier!))
            modifiedRequest.url = deconstructedURLComponents?.url ?? request.url
        }
        
        AppDelegate.APIRequestLogger.notice("\(modifiedRequest.httpMethod ?? "unknown") Request for \(modifiedRequest.url?.description ?? "unknown")")
        
        // send request
        let task = session.dataTask(with: modifiedRequest) { data, response, error in
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
                AppDelegate.APIResponseLogger.warning(
                    "No \(request.httpMethod ?? "unknown") Response for \(request.url?.description ?? "unknown")\nData Task Error: \(error?.localizedDescription ?? "unknown")")
                completionHandler(responseBody, .noResponse)
            }
            else if responseCode != nil {
                // we got a response from the server
                if 200...299 ~= responseCode! && responseBody != nil {
                    // our request was valid and successful
                    AppDelegate.APIResponseLogger.notice("Success \(request.httpMethod ?? "unknown") Response for \(request.url?.description ?? "unknown")")
                    completionHandler(responseBody, .successResponse)
                }
                else {
                    // our request was invalid or some other problem
                    AppDelegate.APIResponseLogger.warning(
                        "Failure \(request.httpMethod ?? "unknown") Response for \(request.url?.description ?? "unknown")\nFailure Message: \(responseBody?["message"] as? String ?? "unknown")\nFailure Code: \(responseBody?["code"] as? String ?? "unknown")\nFailure Type:\(responseBody?["name"] as? String ?? "unknown")")
                    completionHandler(responseBody, .failureResponse)
                }
            }
            else {
                // something happened and we got no response
                AppDelegate.APIResponseLogger.warning(
                    "No \(request.httpMethod ?? "unknown") Response for \(request.url?.description ?? "unknown")")
                completionHandler(responseBody, .noResponse)
            }
            
        }
        
        // free up task when request is pushed
        task.resume()
    }
}

extension InternalRequestUtils {
    
    // MARK: - Generic GET, POST, PUT, and DELETE requests
    
    /// Perform a generic get request at the specified url, assuming URL params are already provided.
    static func genericGetRequest(forURL URL: URL, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "GET"
        
        genericRequest(forRequest: request) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /// Perform a generic get request at the specified url with provided body. Throws as creating request can fail if body is invalid.
    static func genericPostRequest(forURL URL: URL, forBody body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        InternalRequestUtils.warnForEmptyBody(forURL: URL, forBody: body)
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            genericRequest(forRequest: request) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
        catch {
            completionHandler(nil, .noResponse)
        }
        
    }
    
    /// Perform a generic get request at the specified url with provided body, assuming URL params are already provided. Throws as creating request can fail if body is invalid
    static func genericPutRequest(forURL URL: URL, forBody body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        InternalRequestUtils.warnForEmptyBody(forURL: URL, forBody: body)
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            genericRequest(forRequest: request) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
        catch {
            completionHandler(nil, .noResponse)
        }
        
    }
    
    /// Perform a generic get request at the specified url, assuming URL params are already provided. No body needed for request. No throws as request creating cannot fail
    static func genericDeleteRequest(forURL URL: URL, forBody body: [String: Any]? = nil, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        // if a body is present, we want to make sure it isn't empty
        if body != nil {
            InternalRequestUtils.warnForEmptyBody(forURL: URL, forBody: body!)
        }
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "DELETE"
        
        if body == nil {
            genericRequest(forRequest: request) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
        else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body!)
                request.httpBody = jsonData
                
                genericRequest(forRequest: request) { responseBody, responseStatus in
                    completionHandler(responseBody, responseStatus)
                }
            }
            catch {
                completionHandler(nil, .noResponse)
            }
        }
    }
    
    // MARK: - Create Body for Request from Object
    
    /// returns an array that contains the user's personal information and userConfiguration and is suitable to be a http request body
    static func createFullUserBody() -> [String: Any] {
        var body: [String: Any] = createUserConfigurationBody()
        body[ServerDefaultsKeys.userIdentifier.rawValue] = UserInformation.userIdentifier
        body[ServerDefaultsKeys.userEmail.rawValue] = UserInformation.userEmail
        body[ServerDefaultsKeys.userFirstName.rawValue] = UserInformation.userFirstName
        body[ServerDefaultsKeys.userLastName.rawValue] = UserInformation.userLastName
        return body
    }
    
    static func createUserInformationBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultsKeys.userIdentifier.rawValue] = UserInformation.userIdentifier
        body[ServerDefaultsKeys.userEmail.rawValue] = UserInformation.userEmail
        body[ServerDefaultsKeys.userFirstName.rawValue] = UserInformation.userFirstName
        body[ServerDefaultsKeys.userLastName.rawValue] = UserInformation.userLastName
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
        
        body[ServerDefaultsKeys.isCompactView.rawValue] = UserConfiguration.isCompactView
        body[ServerDefaultsKeys.interfaceStyle.rawValue] = UserConfiguration.interfaceStyle.rawValue
        body[ServerDefaultsKeys.snoozeLength.rawValue] = UserConfiguration.snoozeLength
        body[ServerDefaultsKeys.isPaused.rawValue] = UserConfiguration.isPaused
        body[ServerDefaultsKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
        body[ServerDefaultsKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
        body[ServerDefaultsKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
        body[ServerDefaultsKeys.followUpDelay.rawValue] = UserConfiguration.followUpDelay
        body[ServerDefaultsKeys.notificationSound.rawValue] = UserConfiguration.notificationSound.rawValue
        return body
    }
    
    /// returns an array that is suitable to be a http request body
    static func createDogBody(dog: Dog) -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultsKeys.dogName.rawValue] = dog.dogName
        return body
    }
    
    /// returns an array that is suitable to be a http request body
    static func createLogBody(log: Log) -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultsKeys.logNote.rawValue] = log.logNote
             body[ServerDefaultsKeys.logDate.rawValue] = log.logDate.ISO8601FormatWithFractionalSeconds()
             body[ServerDefaultsKeys.logAction.rawValue] = log.logAction.rawValue
        if log.logAction == .custom && log.customActionName != nil {
            body[ServerDefaultsKeys.customActionName.rawValue] = log.customActionName
        }
        return body
        
    }
    
    /// returns an array that is suitable to be a http request body
    static func createReminderBody(reminder: Reminder) -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultsKeys.reminderId.rawValue] = reminder.reminderId
             body[ServerDefaultsKeys.reminderAction.rawValue] = reminder.reminderAction.rawValue
        if reminder.reminderAction == .custom && reminder.customActionName != nil {
            body[ServerDefaultsKeys.customActionName.rawValue] = reminder.customActionName
        }
        body[ServerDefaultsKeys.executionBasis.rawValue] = reminder.executionBasis.ISO8601FormatWithFractionalSeconds()
        body[ServerDefaultsKeys.isEnabled.rawValue] = reminder.isEnabled
        
        body[ServerDefaultsKeys.reminderType.rawValue] = reminder.reminderType.rawValue
        // add the reminder components depending on the reminderType
        switch reminder.reminderType {
        case .countdown:
            body[ServerDefaultsKeys.countdownExecutionInterval.rawValue] = reminder.countdownComponents.executionInterval
            body[ServerDefaultsKeys.countdownIntervalElapsed.rawValue] = reminder.countdownComponents.intervalElapsed
        case .weekly:
            body[ServerDefaultsKeys.weeklyHour.rawValue] = reminder.weeklyComponents.dateComponents.hour
            body[ServerDefaultsKeys.weeklyMinute.rawValue] = reminder.weeklyComponents.dateComponents.minute
            body[ServerDefaultsKeys.weeklyIsSkipping.rawValue] = reminder.weeklyComponents.isSkipping
            if reminder.weeklyComponents.isSkipping == true && reminder.weeklyComponents.isSkippingDate != nil {
                body[ServerDefaultsKeys.weeklyIsSkippingDate.rawValue] = reminder.weeklyComponents.isSkippingDate!.ISO8601FormatWithFractionalSeconds()
            }
            
            body[ServerDefaultsKeys.sunday.rawValue] = false
            body[ServerDefaultsKeys.monday.rawValue] = false
            body[ServerDefaultsKeys.tuesday.rawValue] = false
            body[ServerDefaultsKeys.wednesday.rawValue] = false
            body[ServerDefaultsKeys.thursday.rawValue] = false
            body[ServerDefaultsKeys.friday.rawValue] = false
            body[ServerDefaultsKeys.saturday.rawValue] = false
            
            for weekday in reminder.weeklyComponents.weekdays {
                switch weekday {
                case 1:
                    body[ServerDefaultsKeys.sunday.rawValue] = true
                case 2:
                    body[ServerDefaultsKeys.monday.rawValue] = true
                case 3:
                    body[ServerDefaultsKeys.tuesday.rawValue] = true
                case 4:
                    body[ServerDefaultsKeys.wednesday.rawValue] = true
                case 5:
                    body[ServerDefaultsKeys.thursday.rawValue] = true
                case 6:
                    body[ServerDefaultsKeys.friday.rawValue] = true
                case 7:
                    body[ServerDefaultsKeys.saturday.rawValue] = true
                default:
                    continue
                }
            }
            
        case .monthly:
            body[ServerDefaultsKeys.monthlyHour.rawValue] = reminder.monthlyComponents.dateComponents.hour
            body[ServerDefaultsKeys.monthlyMinute.rawValue] = reminder.monthlyComponents.dateComponents.minute
            body[ServerDefaultsKeys.monthlyIsSkipping.rawValue] = reminder.monthlyComponents.isSkipping
            if reminder.monthlyComponents.isSkipping == true && reminder.monthlyComponents.isSkippingDate != nil {
                body[ServerDefaultsKeys.monthlyIsSkippingDate.rawValue] = reminder.monthlyComponents.isSkippingDate!.ISO8601FormatWithFractionalSeconds()
            }
            body[ServerDefaultsKeys.dayOfMonth.rawValue] = reminder.monthlyComponents.dayOfMonth
        case .oneTime:
            body[ServerDefaultsKeys.oneTimeDate.rawValue] = reminder.oneTimeComponents.oneTimeDate.ISO8601FormatWithFractionalSeconds()
        }
        
        return body
    }
    
    /// Returns an array of reminder bodies under the key "reminders". E.g. { reminders : [{reminder1}, {reminder2}] }
    static func createRemindersBody(reminders: [Reminder]) -> [String: [[String: Any]]] {
        var remindersArray: [[String: Any]] = []
        for reminder in reminders {
            remindersArray.append(createReminderBody(reminder: reminder))
        }
        let body: [String: [[String: Any]]] = [ServerDefaultsKeys.reminders.rawValue: remindersArray]
        return body
    }
    
    /// returns an array that is suitable to be a http request body
    static func createReminderIdBody(reminderId: Int) -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultsKeys.reminderId.rawValue] = reminderId
        return body
    }
    
    /// Returns an array of reminder bodies under the key ."reminders" E.g. { reminders : [{reminder1}, {reminder2}] }
    static func createReminderIdsBody(reminderIds: [Int]) -> [String: [[String: Any]]] {
        var reminderIdsArray: [[String: Any]] = []
        for reminderId in reminderIds {
            reminderIdsArray.append(createReminderIdBody(reminderId: reminderId))
        }
        let body: [String: [[String: Any]]] = [ServerDefaultsKeys.reminders.rawValue: reminderIdsArray]
        return body
    }
    
    // MARK: - Warn if a property has an undesired value
    
    /// Provides warning if the id of anything is set to a placeholder value.
    static func warnForPlaceholderId(dogId: Int? = nil, reminders: [Reminder]? = nil, reminderId: Int? = nil, reminderIds: [Int]? = nil, logId: Int? = nil) {
        if UserInformation.userId == nil {
            AppDelegate.APIRequestLogger.warning("Warning: userId is nil")
        }
        else if UserInformation.userId! < 0 {
            AppDelegate.APIRequestLogger.warning("Warning: userId is placeholder \(UserInformation.userId!)")
        }
        if UserInformation.userIdentifier == nil {
            AppDelegate.APIRequestLogger.warning("Warning: userIdentifier is nil")
        }
        if UserInformation.familyId == nil {
            AppDelegate.APIRequestLogger.warning("Warning: familyId is nil")
        }
        else if UserInformation.familyId! < 0 {
            AppDelegate.APIRequestLogger.warning("Warning: familyId is placeholder \(UserInformation.familyId!)")
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
    private static func warnForEmptyBody(forURL URL: URL, forBody body: [String: Any]) {
        if body.keys.count == 0 {
            AppDelegate.APIRequestLogger.warning("Warning: Body is empty \nFor URL: \(URL)")
        }
    }
    
}
