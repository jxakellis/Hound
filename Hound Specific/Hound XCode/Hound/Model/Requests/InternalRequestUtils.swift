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
    static let baseURLWithoutParams: URL = URL(string: "http://10.0.0.108:3000/api/\(UIApplication.appBuild)")!
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
        
        // TO DO add guard statement that checks if the user has an internet connection, instantly rejecting with completionHandler if no connection
        
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
                        // TO DO add family/dog/reminderlimit exceeded as a proper error message
                        // TO DO add subscription expired as proper error message
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
    
    // MARK: - Warn if a property has an undesired value
    
    /// Provides warning if the id of anything is set to a placeholder value.
    static func warnForPlaceholderId(dogId: Int? = nil, reminderId: Int? = nil, reminders: [Reminder]? = nil, logId: Int? = nil) {
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
