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
    static let basePathWithoutParams: URL = URL(string: "http://10.0.0.107:5000/api/v1")!
    static let session = URLSession.shared

    /// Takes an already constructed URLRequest and executes it, returning it in a compeltion handler. This is the basis to all URL requests
    static func genericRequest(request: URLRequest, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {
        // send request
        let task = session.dataTask(with: request) { data, response, err in
            // extract status code from URLResponse
            var httpResponseStatusCode: Int?
            if let httpResponse = response as? HTTPURLResponse {
                httpResponseStatusCode = httpResponse.statusCode
            }

            // parse response from json
            var dataJSON: [String: Any]?

            // if no data or if no status code, then request failed
            if data != nil && httpResponseStatusCode != nil {
                do {
                    // try to serialize data as "result" form with array of info first, if that fails, revert to regular "message" and "error" format
                    dataJSON = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String: [[String: Any]]] ?? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String: Any]
                }
                catch {
                    AppDelegate.APIRequestLogger.error("Error when serializing data into JSON \(error.localizedDescription)")
                }
            }

            // pass out information
            completionHandler(dataJSON, httpResponseStatusCode, err)

        }

        // free up task when request is pushed
        task.resume()
    }
}

extension InternalRequestUtils {

    /// Perform a generic get request at the specified url, assuming path params are already provided.
    static func genericGetRequest(path: URL, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {
        // create request to send
        var req = URLRequest(url: path)

        // specify http method
        req.httpMethod = "GET"

        /*
         no body in get request
        if body != nil {
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body!)
                req.httpBody = jsonData
            }
            catch {
                throw error
            }
        }
         */

        genericRequest(request: req) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }

    /// Perform a generic get request at the specified url with provided body. Throws as creating request can fail if body is invalid.
    static func genericPostRequest(path: URL, body: [String: Any], completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {
        // create request to send
        var req = URLRequest(url: path)

        // specify http method
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            req.httpBody = jsonData
        }
        catch {
            throw error
        }

        genericRequest(request: req) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
    }

    /// Perform a generic get request at the specified url with provided body, assuming path params are already provided. Throws as creating request can fail if body is invalid
    static func genericPutRequest(path: URL, body: [String: Any], completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) throws {
        // create request to send
        var req = URLRequest(url: path)

        // specify http method
        req.httpMethod = "PUT"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            req.httpBody = jsonData
        }
        catch {
            throw error
        }

        genericRequest(request: req) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
    }

    /// Perform a generic get request at the specified url, assuming path params are already provided. No body needed for request. No throws as request creating cannot fail
    static func genericDeleteRequest(path: URL, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {
        // create request to send
        var req = URLRequest(url: path)

        // specify http method
        req.httpMethod = "DELETE"

        genericRequest(request: req) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }

    }

    /// returns an array that contains the user's personal information and userConfiguration and is suitable to be a http request body
    static func createFullUserBody() -> [String: Any] {
        var body: [String: Any] = createUserConfigurationBody()
        body[UserDefaultsKeys.userEmail.rawValue] = UserInformation.userEmail
        body[UserDefaultsKeys.userFirstName.rawValue] = UserInformation.userFirstName
        body[UserDefaultsKeys.userLastName.rawValue] = UserInformation.userLastName
        return body
    }

    static func createUserInformationBody() -> [String: Any] {
        var body: [String: Any] = [:]
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
        body["logType"] = log.logType.rawValue
        if log.logType == .custom && log.customTypeName != nil {
            body["customTypeName"] = log.customTypeName
        }
        return body

    }

    /// returns an array that is suitable to be a http request body
    static func createReminderBody(reminder: Reminder) -> [String: Any] {
        var body: [String: Any] = [:]
        body["reminderAction"] = reminder.reminderAction.rawValue
        if reminder.reminderAction == .custom && reminder.customTypeName != nil {
            body["customTypeName"] = reminder.customTypeName
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
            body["hour"] = reminder.weeklyComponents.dateComponents.hour
            body["minute"] = reminder.weeklyComponents.dateComponents.minute
            body["skipping"] = reminder.weeklyComponents.isSkipping
            if reminder.weeklyComponents.isSkipping == true && reminder.weeklyComponents.isSkippingLogDate != nil {
                body["skipDate"] = reminder.weeklyComponents.isSkippingLogDate!.ISO8601Format()
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
            body["hour"] = reminder.monthlyComponents.dateComponents.hour
            body["minute"] = reminder.monthlyComponents.dateComponents.minute
            body["skipping"] = reminder.monthlyComponents.isSkipping
            if reminder.monthlyComponents.isSkipping == true && reminder.monthlyComponents.isSkippingLogDate != nil {
                body["skipDate"] = reminder.monthlyComponents.isSkippingLogDate!.ISO8601Format()
            }
            body["dayOfMonth"] = reminder.monthlyComponents.dayOfMonth
        case .oneTime:
            body["date"] = reminder.oneTimeComponents.executionDate.ISO8601Format()
        }

        return body
    }

}

enum RequestUtils {
    static var ISO8601DateFormatter: ISO8601DateFormatter = {
        let formatter = Foundation.ISO8601DateFormatter()
        formatter.formatOptions = [.withFractionalSeconds, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]
        return formatter
    }()

    /// Combines the different get requests functions to query for all the components for a  fully formed dogManager
    static func getDogManager(completionHandler: @escaping (DogManager?) -> Void) {
        // assume userId valid as it was retrieved when the app started. Later on with familyId, if a user was removed from the family, then this refresh could fail.
        let dogManager = DogManager()

            // Retrieve any dogs the user may have
            DogsRequest.get(forDogId: nil, completionHandler: { responseBody, _, _ in
                    if responseBody != nil {
                        // Array of dog JSON [{dog1:'foo'},{dog2:'bar'}]
                        if let result = responseBody!["result"] as? [[String: Any]] {
                            for dogBody in result {
                                do {
                                    // add dog to the DogManager
                                    let dog = try Dog(fromBody: dogBody)
                                    dogManager.addDog(newDog: dog)
                                    return queryFinished(successful: true)
                                }
                                catch {
                                    // handle if problem with adding dog
                                }

                            }

                        }
                    }

                    // this whole body is sync. If the execution didn't make it to return queryFinished(successful: true), then it means there was an error encountered. If it did make it to that statement then this code wouldn't be executed
                    return queryFinished(successful: false)
                })

        // depending on whether or not the query was successful, we return different completioHandlers
        func queryFinished(successful: Bool) {
            if successful == true {
                completionHandler(dogManager)
            }
            else {
                completionHandler(nil)
            }
        }
    }
    /// Provides warning if the id of anything is set to a placeholder value. 
    static func checkId(dogId: Int? = nil, reminderId: Int? = nil, logId: Int? = nil) {
        if UserInformation.userId == -1 {
            AppDelegate.APIRequestLogger.warning("Warning: userId is -1")
        }
        if dogId != nil && dogId! == -1 {
            AppDelegate.APIRequestLogger.warning("Warning: dogId is -1")
        }
        if reminderId != nil && reminderId! == -1 {
            AppDelegate.APIRequestLogger.warning("Warning: reminderId is -1")
        }
        if logId != nil && logId! == -1 {
            AppDelegate.APIRequestLogger.warning("Warning: logId is -1")
        }
    }
}
