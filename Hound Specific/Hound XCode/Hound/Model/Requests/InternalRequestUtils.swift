//
//  InternalRequestUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// abstractions used by other endpoint classes to make their request to the server, not used anywhere else in hound so therefore internal to endpoints and api requests.
enum InternalRequestUtils {
    static let baseURLWithoutParams: URL = URL(string: "http://172.20.10.2:3000/api/\(UIApplication.appBuild)")!
    // home URL(string: "http://10.0.0.110:5000/api/v1")!
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
    private static func genericRequest(forRequest request: URLRequest, completionHandler: @escaping ([String: Any]?, ResponseStatus, Error?) -> Void) {
        
        var modifiedRequest = request
        
        // append userIdentifier if we have it, need it to perform requests
        if UserInformation.userIdentifier != nil {
            // deconstruct request slightly
            var deconstructedURLComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            // if we try to append to nil, then it fails. so if the array is nil, we just make it an empty array
            deconstructedURLComponents!.queryItems = deconstructedURLComponents!.queryItems ?? []
            deconstructedURLComponents!.queryItems!.append(URLQueryItem(name: ServerDefaultKeys.userIdentifier.rawValue, value: UserInformation.userIdentifier!))
            modifiedRequest.url = deconstructedURLComponents?.url ?? request.url
        }
        
        AppDelegate.APIRequestLogger.notice("\(modifiedRequest.httpMethod ?? "unknown") Request for \(modifiedRequest.url?.description ?? "unknown")")
        
        // send request
        let task = session.dataTask(with: modifiedRequest) { data, response, error in
            // extract status code from URLResponse
            var responseStatusCode: Int?
            if let httpResponse = response as? HTTPURLResponse {
                responseStatusCode = httpResponse.statusCode
            }
            
            // parse response from json
            var responseBody: [String: Any]?
            // if no data or if no status code, then request failed
            if data != nil && responseStatusCode != nil {
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
                completionHandler(responseBody, .noResponse, nil)
            }
            else if responseStatusCode != nil {
                // we got a response from the server
                if 200...299 ~= responseStatusCode! && responseBody != nil {
                    // our request was valid and successful
                    AppDelegate.APIResponseLogger.notice("Success \(request.httpMethod ?? "unknown") Response for \(request.url?.description ?? "unknown")")
                    completionHandler(responseBody, .successResponse, nil)
                }
                else {
                    // our request was invalid or some other problem
                    AppDelegate.APIResponseLogger.warning(
                        "Failure \(request.httpMethod ?? "unknown") Response for \(request.url?.description ?? "unknown")\n Message: \(responseBody?[ServerDefaultKeys.message.rawValue] as? String ?? "unknown")\n Code: \(responseBody?[ServerDefaultKeys.code.rawValue] as? String ?? "unknown")\n Type:\(responseBody?[ServerDefaultKeys.name.rawValue] as? String ?? "unknown")")
                    var responseCode: Error?
                    
                    if let responseCodeString = responseBody?[ServerDefaultKeys.code.rawValue] as? String {
                        responseCode = AppBuildResponseError(rawValue: responseCodeString) ?? FamilyResponseError(rawValue: responseCodeString) ?? LimitResponseError(rawValue: responseCodeString)
                    }
                    
                    guard (responseCode is AppBuildResponseError) == false else {
                        // If we experience an app build response error, that means the user's local app is outdated. If this is the case, then nothing will work until the user updates their app. Therefore we stop everything and do not return a completion handler. This might break something but we don't care.
                        DispatchQueue.main.async {
                            ErrorManager.alert(forError: responseCode!)
                        }
                        return
                    }
                    
                    completionHandler(responseBody, .failureResponse, responseCode)
                }
            }
            else {
                // something happened and we got no response
                AppDelegate.APIResponseLogger.warning(
                    "No \(request.httpMethod ?? "unknown") Response for \(request.url?.description ?? "unknown")")
                completionHandler(responseBody, .noResponse, nil)
            }
            
        }
        
        // free up task when request is pushed
        task.resume()
    }
}

extension InternalRequestUtils {
    
    // MARK: - Generic GET, POST, PUT, and DELETE requests
    
    /// Perform a generic get request at the specified url, assuming URL params are already provided. completionHandler is on the .main thread.
    static func genericGetRequest(invokeErrorManager: Bool, forURL URL: URL, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "GET"
        
        genericRequest(forRequest: request) { responseBody, responseStatus, responseCode in
            DispatchQueue.main.async {
                completionHandler(responseBody, responseStatus)
                // the user wants to invoke the error manager, so we check to see if it needs invoked
                if invokeErrorManager == true {
                    if responseCode != nil {
                        ErrorManager.alert(forError: responseCode!)
                    }
                    else if responseStatus == .failureResponse {
                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                    }
                    else if responseStatus == .noResponse {
                        ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                    }
                }
            }
        }
    }
    
    /// Perform a generic get request at the specified url with provided body. completionHandler is on the .main thread.
    static func genericPostRequest(invokeErrorManager: Bool, forURL URL: URL, forBody body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        InternalRequestUtils.warnForEmptyBody(forURL: URL, forBody: body)
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            genericRequest(forRequest: request) { responseBody, responseStatus, responseCode in
                DispatchQueue.main.async {
                    completionHandler(responseBody, responseStatus)
                    // the user wants to invoke the error manager, so we check to see if it needs invoked
                    if invokeErrorManager == true {
                        if responseCode != nil {
                            ErrorManager.alert(forError: responseCode!)
                        }
                        else if responseStatus == .failureResponse {
                            ErrorManager.alert(forError: GeneralResponseError.failurePostResponse)
                        }
                        else if responseStatus == .noResponse {
                            ErrorManager.alert(forError: GeneralResponseError.noPostResponse)
                        }
                    }
                }
            }
        }
        catch {
            DispatchQueue.main.async {
                completionHandler(nil, .noResponse)
                // the user wants to invoke the error manager, so we check to see if it needs invoked
                if invokeErrorManager == true {
                    ErrorManager.alert(forError: GeneralResponseError.noPostResponse)
                }
                
            }
        }
        
    }
    
    /// Perform a generic get request at the specified url with provided body, assuming URL params are already provided. completionHandler is on the .main thread.
    static func genericPutRequest(invokeErrorManager: Bool, forURL URL: URL, forBody body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        InternalRequestUtils.warnForEmptyBody(forURL: URL, forBody: body)
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            genericRequest(forRequest: request) { responseBody, responseStatus, responseCode in
                DispatchQueue.main.async {
                    completionHandler(responseBody, responseStatus)
                    // the user wants to invoke the error manager, so we check to see if it needs invoked
                    if invokeErrorManager == true {
                        if responseCode != nil {
                            ErrorManager.alert(forError: responseCode!)
                        }
                        else if responseStatus == .failureResponse {
                            ErrorManager.alert(forError: GeneralResponseError.failurePutResponse)
                        }
                        else if responseStatus == .noResponse {
                            ErrorManager.alert(forError: GeneralResponseError.noPutResponse)
                        }
                    }
                }
            }
        }
        catch {
            DispatchQueue.main.async {
                completionHandler(nil, .noResponse)
                // the user wants to invoke the error manager, so we check to see if it needs invoked
                if invokeErrorManager == true {
                    ErrorManager.alert(forError: GeneralResponseError.noPutResponse)
                }
                
            }
        }
        
    }
    
    /// Perform a generic get request at the specified url, assuming URL params are already provided. completionHandler is on the .main thread.
    static func genericDeleteRequest(invokeErrorManager: Bool, forURL URL: URL, forBody body: [String: Any]? = nil, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        // if a body is present, we want to make sure it isn't empty
        if body != nil {
            InternalRequestUtils.warnForEmptyBody(forURL: URL, forBody: body!)
        }
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "DELETE"
        
        if body == nil {
            genericRequest(forRequest: request) { responseBody, responseStatus, responseCode in
                DispatchQueue.main.async {
                    completionHandler(responseBody, responseStatus)
                    // the user wants to invoke the error manager, so we check to see if it needs invoked
                    if invokeErrorManager == true {
                        if responseCode != nil {
                            ErrorManager.alert(forError: responseCode!)
                        }
                        else if responseStatus == .failureResponse {
                            ErrorManager.alert(forError: GeneralResponseError.failureDeleteResponse)
                        }
                        else if responseStatus == .noResponse {
                            ErrorManager.alert(forError: GeneralResponseError.noDeleteResponse)
                        }
                    }
                }
            }
        }
        else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body!)
                request.httpBody = jsonData
                
                genericRequest(forRequest: request) { responseBody, responseStatus, responseCode in
                    DispatchQueue.main.async {
                        completionHandler(responseBody, responseStatus)
                        // the user wants to invoke the error manager, so we check to see if it needs invoked
                        if invokeErrorManager == true {
                            if responseCode != nil {
                                ErrorManager.alert(forError: responseCode!)
                            }
                            else if responseStatus == .failureResponse {
                                ErrorManager.alert(forError: GeneralResponseError.failureDeleteResponse)
                            }
                            else if responseStatus == .failureResponse {
                                ErrorManager.alert(forError: GeneralResponseError.noDeleteResponse)
                            }
                        }
                    }
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(nil, .noResponse)
                    // the user wants to invoke the error manager, so we check to see if it needs invoked
                    if invokeErrorManager == true {
                        ErrorManager.alert(forError: GeneralResponseError.noDeleteResponse)
                    }
                }
            }
        }
    }
    
    // MARK: - Create Body for Request from Object
    
    /// returns an array that contains the user's personal information and userConfiguration and is suitable to be a http request body
    static func createFullUserBody() -> [String: Any] {
        var body: [String: Any] = createUserConfigurationBody()
        body[ServerDefaultKeys.userIdentifier.rawValue] = UserInformation.userIdentifier
        body[ServerDefaultKeys.userEmail.rawValue] = UserInformation.userEmail
        body[ServerDefaultKeys.userFirstName.rawValue] = UserInformation.userFirstName
        body[ServerDefaultKeys.userLastName.rawValue] = UserInformation.userLastName
        return body
    }
    
    static func createUserInformationBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultKeys.userIdentifier.rawValue] = UserInformation.userIdentifier
        body[ServerDefaultKeys.userEmail.rawValue] = UserInformation.userEmail
        body[ServerDefaultKeys.userFirstName.rawValue] = UserInformation.userFirstName
        body[ServerDefaultKeys.userLastName.rawValue] = UserInformation.userLastName
        return body
    }
    
    /// returns an array that only contains the user's userConfiguration and is that is suitable to be a http request body
    static func createUserConfigurationBody() -> [String: Any] {
        var body: [String: Any] = [:]
        // isCompactView
        // interfaceStyle
        // snoozeLength
        // isNotificationAuthorized
        // isNotificationEnabled
        // isLoudNotification
        // isFollowUpEnabled
        // followUpDelay
        // notificationSound
        
        body[ServerDefaultKeys.logsInterfaceScale.rawValue] = UserConfiguration.logsInterfaceScale.rawValue
        body[ServerDefaultKeys.remindersInterfaceScale.rawValue] = UserConfiguration.remindersInterfaceScale.rawValue
        body[ServerDefaultKeys.interfaceStyle.rawValue] = UserConfiguration.interfaceStyle.rawValue
        body[ServerDefaultKeys.snoozeLength.rawValue] = UserConfiguration.snoozeLength
        body[ServerDefaultKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
        body[ServerDefaultKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
        body[ServerDefaultKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
        body[ServerDefaultKeys.followUpDelay.rawValue] = UserConfiguration.followUpDelay
        body[ServerDefaultKeys.notificationSound.rawValue] = UserConfiguration.notificationSound.rawValue
        return body
    }
    
    /// returns an array that is suitable to be a http request body
    static func createDogBody(dog: Dog) -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultKeys.dogName.rawValue] = dog.dogName
        return body
    }
    
    /// returns an array that is suitable to be a http request body
    static func createLogBody(log: Log) -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultKeys.logNote.rawValue] = log.logNote
        body[ServerDefaultKeys.logDate.rawValue] = log.logDate.ISO8601FormatWithFractionalSeconds()
        body[ServerDefaultKeys.logAction.rawValue] = log.logAction.rawValue
        body[ServerDefaultKeys.logCustomActionName.rawValue] = log.logCustomActionName
        return body
        
    }
    
    /// returns an array that is suitable to be a http request body
    static func createReminderBody(reminder: Reminder) -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultKeys.reminderId.rawValue] = reminder.reminderId
        body[ServerDefaultKeys.reminderType.rawValue] = reminder.reminderType.rawValue
        body[ServerDefaultKeys.reminderAction.rawValue] = reminder.reminderAction.rawValue
        body[ServerDefaultKeys.reminderCustomActionName.rawValue] = reminder.reminderCustomActionName
        body[ServerDefaultKeys.reminderExecutionBasis.rawValue] = reminder.reminderExecutionBasis.ISO8601FormatWithFractionalSeconds()
        body[ServerDefaultKeys.reminderExecutionDate.rawValue] = reminder.reminderExecutionDate?.ISO8601FormatWithFractionalSeconds()
        body[ServerDefaultKeys.reminderIsEnabled.rawValue] = reminder.reminderIsEnabled
        
        // snooze
        body[ServerDefaultKeys.snoozeIsEnabled.rawValue] = reminder.snoozeComponents.snoozeIsEnabled
        body[ServerDefaultKeys.snoozeExecutionInterval.rawValue] = reminder.snoozeComponents.executionInterval
        body[ServerDefaultKeys.snoozeIntervalElapsed.rawValue] = reminder.snoozeComponents.intervalElapsed
        
        // countdown
        body[ServerDefaultKeys.countdownExecutionInterval.rawValue] = reminder.countdownComponents.executionInterval
        body[ServerDefaultKeys.countdownIntervalElapsed.rawValue] = reminder.countdownComponents.intervalElapsed
        
        // weekly
        body[ServerDefaultKeys.weeklyHour.rawValue] = reminder.weeklyComponents.hour
        body[ServerDefaultKeys.weeklyMinute.rawValue] = reminder.weeklyComponents.minute
        body[ServerDefaultKeys.weeklyIsSkipping.rawValue] = reminder.weeklyComponents.isSkipping
        body[ServerDefaultKeys.weeklyIsSkippingDate.rawValue] = reminder.weeklyComponents.isSkippingDate?.ISO8601FormatWithFractionalSeconds()
        
        body[ServerDefaultKeys.weeklySunday.rawValue] = false
        body[ServerDefaultKeys.weeklyMonday.rawValue] = false
        body[ServerDefaultKeys.weeklyTuesday.rawValue] = false
        body[ServerDefaultKeys.weeklyWednesday.rawValue] = false
        body[ServerDefaultKeys.weeklyThursday.rawValue] = false
        body[ServerDefaultKeys.weeklyFriday.rawValue] = false
        body[ServerDefaultKeys.weeklySaturday.rawValue] = false
        
        for weekday in reminder.weeklyComponents.weekdays {
            switch weekday {
            case 1:
                body[ServerDefaultKeys.weeklySunday.rawValue] = true
            case 2:
                body[ServerDefaultKeys.weeklyMonday.rawValue] = true
            case 3:
                body[ServerDefaultKeys.weeklyTuesday.rawValue] = true
            case 4:
                body[ServerDefaultKeys.weeklyWednesday.rawValue] = true
            case 5:
                body[ServerDefaultKeys.weeklyThursday.rawValue] = true
            case 6:
                body[ServerDefaultKeys.weeklyFriday.rawValue] = true
            case 7:
                body[ServerDefaultKeys.weeklySaturday.rawValue] = true
            default:
                continue
            }
        }
        
        // monthly
        body[ServerDefaultKeys.monthlyDay.rawValue] = reminder.monthlyComponents.day
        body[ServerDefaultKeys.monthlyHour.rawValue] = reminder.monthlyComponents.hour
        body[ServerDefaultKeys.monthlyMinute.rawValue] = reminder.monthlyComponents.minute
        body[ServerDefaultKeys.monthlyIsSkipping.rawValue] = reminder.monthlyComponents.isSkipping
        body[ServerDefaultKeys.monthlyIsSkippingDate.rawValue] = reminder.monthlyComponents.isSkippingDate?.ISO8601FormatWithFractionalSeconds()
        
        // one time
        body[ServerDefaultKeys.oneTimeDate.rawValue] = reminder.oneTimeComponents.oneTimeDate.ISO8601FormatWithFractionalSeconds()
        
        return body
    }
    
    /// Returns an array of reminder bodies under the key "reminders". E.g. { reminders : [{reminder1}, {reminder2}] }
    static func createRemindersBody(reminders: [Reminder]) -> [String: [[String: Any]]] {
        var remindersArray: [[String: Any]] = []
        for reminder in reminders {
            remindersArray.append(createReminderBody(reminder: reminder))
        }
        let body: [String: [[String: Any]]] = [ServerDefaultKeys.reminders.rawValue: remindersArray]
        return body
    }
    
    /// returns an array that is suitable to be a http request body
    static func createReminderIdBody(reminderId: Int) -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultKeys.reminderId.rawValue] = reminderId
        return body
    }
    
    /// Returns an array of reminder bodies under the key ."reminders" E.g. { reminders : [{reminder1}, {reminder2}] }
    static func createReminderIdsBody(reminderIds: [Int]) -> [String: [[String: Any]]] {
        var reminderIdsArray: [[String: Any]] = []
        for reminderId in reminderIds {
            reminderIdsArray.append(createReminderIdBody(reminderId: reminderId))
        }
        let body: [String: [[String: Any]]] = [ServerDefaultKeys.reminders.rawValue: reminderIdsArray]
        return body
    }
    
    // MARK: - Warn if a property has an undesired value
    
    /// Provides warning if the id of anything is set to a placeholder value.
    static func warnForPlaceholderId(dogId: Int? = nil, reminders: [Reminder]? = nil, reminderId: Int? = nil, reminderIds: [Int]? = nil, logId: Int? = nil) {
        if UserInformation.userId == nil {
            AppDelegate.APIRequestLogger.warning("Warning: userId is nil")
        }
        else if UserInformation.userId! == Hash.defaultSHA256Hash {
            AppDelegate.APIRequestLogger.warning("Warning: userId is placeholder \(UserInformation.userId!)")
        }
        if UserInformation.userIdentifier == nil {
            AppDelegate.APIRequestLogger.warning("Warning: userIdentifier is nil")
        }
        if UserInformation.familyId == nil {
            AppDelegate.APIRequestLogger.warning("Warning: familyId is nil")
        }
        else if UserInformation.familyId! == Hash.defaultSHA256Hash {
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
