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
    static var baseURLWithUserId: URL { return UserRequest.baseURLWithoutParams.appendingPathComponent("/\(UserInformation.userId ?? Hash.defaultSHA256Hash)") }
    
    // MARK: - Private Functions
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalGet(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        let URL: URL!
        if UserInformation.userId != nil {
            URL = baseURLWithUserId
        }
        else {
            URL = baseURLWithoutParams
        }
        InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: URL) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns a response data: dictionary of the body and the ResponseStatus
     */
    private static func internalCreate(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: InternalRequestUtils.createFullUserBody()) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalUpdate(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithUserId, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalDelete(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithUserId) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
}

extension UserRequest {
    
    // MARK: - Public Functions
    
    /**
     Uses userIdentifier to retrieve the userConfiguration and userInformation, automatically setting them up if the information is successfully retrieved.
     completionHandler returns a possible familyId and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func get(invokeErrorManager: Bool, completionHandler: @escaping (String?, String?, ResponseStatus) -> Void) {
        UserRequest.internalGet(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // attempt to extract body and userId
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [String: Any], let userId = result[ServerDefaultKeys.userId.rawValue] as? String, result.isEmpty == false {
                    
                    // set all local configuration equal to whats in the server
                    UserInformation.setup(fromBody: result)
                    UserConfiguration.setup(fromBody: result)
                    
                    let familyId: String? = result[ServerDefaultKeys.familyId.rawValue] as? String
                    
                    completionHandler(userId, familyId, .successResponse)
                }
                else {
                    completionHandler(nil, nil, .failureResponse)
                }
            case .failureResponse:
                completionHandler(nil, nil, .failureResponse)
            case .noResponse:
                completionHandler(nil, nil, .noResponse)
            }
        }
    }
    
    /**
     Creates a user's account on the server
     completionHandler returns a possible userId and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func create(invokeErrorManager: Bool, completionHandler: @escaping (String?, ResponseStatus) -> Void) {
        UserRequest.internalCreate(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let userId = responseBody?[ServerDefaultKeys.result.rawValue] as? String {
                    completionHandler(userId, responseStatus)
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
     Updates specific piece(s) of userInformation or userConfiguration
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func update(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        UserRequest.internalUpdate(invokeErrorManager: invokeErrorManager, body: body) { _, responseStatus in
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
     Deletes the user and their userConfiguration. If they are a familyMember leaves the family, If they are a familyHead and are the only member, deletes the family. If they are a familyHead and there are other familyMembers, the request fails.
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func delete(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        UserRequest.internalDelete(invokeErrorManager: invokeErrorManager) { _, responseStatus in
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
