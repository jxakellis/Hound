//
//  InternalEndpointUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/25/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// abstractions used by other endpoint classes to make their request to the server, not used anywhere else in hound so therefore internal to endpoints and api requests.
enum InternalEndpointUtils {
    static let basePathWithoutParams: URL = URL(string: "http://localhost:5000/api/v1")!
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
                    print("Error when serializing data into JSON \(error)")
                }
            }

            // pass out information
            completionHandler(dataJSON, httpResponseStatusCode, err)

        }

        // free up task when request is pushed
        task.resume()
    }
}

extension InternalEndpointUtils {

    /// Perform a generic get request at the specified url, assuming path params are already provided. No body needed for request. No throws as request creating cannot fail
    static func genericGetRequest(path: URL, completionHandler: @escaping ([String: Any]?, Int?, Error?) -> Void) {
        // create request to send
        var req = URLRequest(url: path)

        // specify http method
        req.httpMethod = "GET"

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

    /// returns an array that only contains the user's userConfiguration and is that is suitable to be a http request body
    static func createUserConfigurationBody() -> [String: Any] {
        var body: [String: Any] = [:]
        // isCompactView
        // darkModeStyle
        // snoozeLength
        // isPaused
        // isNotificationAuthorized
        // isNotificationEnabled
        // isLoudNotification
        // isFollowUpEnabled
        // followUpDelay
        // notificationSound

        body[UserDefaultsKeys.isCompactView.rawValue] = UserConfiguration.isCompactView
        body[UserDefaultsKeys.darkModeStyle.rawValue] = UserConfiguration.darkModeStyle
        body[UserDefaultsKeys.snoozeLength.rawValue] = UserConfiguration.snoozeLength
        body[UserDefaultsKeys.isPaused.rawValue] = UserConfiguration.isPaused
        body[UserDefaultsKeys.isNotificationAuthorized.rawValue] = UserConfiguration.isNotificationAuthorized
        body[UserDefaultsKeys.isNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
        body[UserDefaultsKeys.isLoudNotification.rawValue] = UserConfiguration.isLoudNotification
        body[UserDefaultsKeys.isFollowUpEnabled.rawValue] = UserConfiguration.isFollowUpEnabled
        body[UserDefaultsKeys.followUpDelay.rawValue] = UserConfiguration.followUpDelay
        body[UserDefaultsKeys.notificationSound.rawValue] = UserConfiguration.notificationSound
        return body
    }

    /// returns an array that is suitable to be a http request body
    static func createDogBody(dog: Dog) -> [String: Any] {
        return [:]
    }

    /// returns an array that is suitable to be a http request body
    static func createLogBody(log: KnownLogType) -> [String: Any] {
        return [:]
    }

    /// returns an array that is suitable to be a http request body
    static func createReminderBody(reminder: Reminder) -> [String: Any] {
        return [:]
    }

}

enum EndpointUtils {

}
