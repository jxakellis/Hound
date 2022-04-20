//
//  UserRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum UserRequest: RequestProtocol {
    
    static let baseURLWithoutParams: URL = InternalRequestUtils.baseURLWithoutParams.appendingPathComponent("/user")
    // UserRequest baseURL with the userId URL param appended on
    static var baseURLWithUserId: URL { return UserRequest.baseURLWithoutParams.appendingPathComponent("/\(UserInformation.userId ?? -1)") }
    
    /**
     Uses userIdentifier and (if present) userId to retrieve information
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    static func get(completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        let URL: URL!
        if UserInformation.userId != nil {
            URL = baseURLWithUserId
        }
        else {
            URL =  baseURLWithoutParams
        }
        // at this point in time, an error can only occur if there is a invalid body provided. Since there is no body, there is no risk of an error.
        InternalRequestUtils.genericGetRequest(forURL: URL) { responseBody, responseStatus in
            DispatchQueue.main.async {
                completionHandler(responseBody, responseStatus)
            }
        }
        
    }
    
    /**
     completionHandler returns a Int. If the query returned a 200 status and is successful, then userId is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func create(completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        
        // make post request, assume body valid as constructed with method
        InternalRequestUtils.genericPostRequest(forURL: baseURLWithoutParams, forBody: InternalRequestUtils.createFullUserBody()) { responseBody, responseStatus in
            DispatchQueue.main.async {
                if responseBody != nil, let userId = responseBody![ServerDefaultKeys.result.rawValue] as? Int {
                completionHandler(userId, responseStatus)
            }
            else {
                completionHandler(nil, responseStatus)
            }
            }
        }
        
    }
    
    // MARK: - Private Functions
    
    /**
     Targeted update. Specifically updates user information or configuration. Body is constructed from known good values so can assume no failures as all pre determiend.
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func update(body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPutRequest(forURL: baseURLWithUserId, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     Lazy update, sends all configuration and information
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func updateAll(completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        let body = InternalRequestUtils.createFullUserBody()
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPutRequest(forURL: baseURLWithUserId, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func delete(completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        InternalRequestUtils.genericDeleteRequest(forURL: baseURLWithUserId) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
}

extension UserRequest {
    
    // MARK: - Public Functions
    
    /**
     Uses userId to retrieve data.
     completionHandler returns a dictionary of the response body. If the query returned a 200 status and is successful, then the dictionary of the response body is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    /*
    static func get(completionHandler: @escaping ([String: Any]?) -> Void) {
        UserRequest.get { responseBody, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    if responseBody != nil {
                        completionHandler(responseBody!)
                    }
                    else {
                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                    }
                case .failureResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                case .noResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                }
            }
        }
        
    }
     */
    /**
        Uses userEmail to retrieve data.
     completionHandler returns a dictionary of the response body. If the query returned a 200 status and is successful, then the dictionary of the response body is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    /*
    static func get(forUserEmail: String, completionHandler: @escaping ([String: Any]?) -> Void) {
        UserRequest.get(forUserEmail: forUserEmail) { responseBody, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    if responseBody != nil {
                        completionHandler(responseBody!)
                    }
                    else {
                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                    }
                case .failureResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                case .noResponse:
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                }
            }
        }
        
    }
     */
    
    /**
     completionHandler returns a Int. If the query returned a 200 status and is successful, then userId is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    /*
    static func create(completionHandler: @escaping (Int?) -> Void) {
        
        UserRequest.create { userId, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    if userId != nil {
                        completionHandler(userId!)
                    }
                    else {
                        completionHandler(nil)
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
     */
    
    /**
     Targeted update. Specifically updates user information or configuration.
     completionHandler returns a Bool. If the query returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked.
     */
    static func update(body: [String: Any], completionHandler: @escaping (Bool) -> Void) {
        UserRequest.update(body: body) { _, responseStatus in
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
     Lazy update, sends all configuration and information.
     completionHandler returns a Bool. If the query returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked.
     */
    static func updateAll(completionHandler: @escaping (Bool) -> Void) {
        UserRequest.updateAll { _, responseStatus in
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
     completionHandler returns a Bool. If the query returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked.
     */
    static func delete(completionHandler: @escaping (Bool) -> Void) {
        UserRequest.delete { _, responseStatus in
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
}