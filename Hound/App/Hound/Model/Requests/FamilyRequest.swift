//
//  FamilyRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum FamilyRequest: RequestProtocol {
    
    static var baseURLWithoutParams: URL { return UserRequest.baseURLWithUserId.appendingPathComponent("/family") }
    // UserRequest baseURL with the userId path param appended on
    static var baseURLWithFamilyId: URL { return FamilyRequest.baseURLWithoutParams.appendingPathComponent("/\(UserInformation.familyId ?? EnumConstant.HashConstant.defaultSHA256Hash)") }
    
    // MARK: - Private Functions
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalGet(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> URLSessionDataTask? {
       
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithFamilyId) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalCreate(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> URLSessionDataTask? {
        
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: [ : ]) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalUpdate(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> URLSessionDataTask? {
       
        // the user is trying to join a family with the family code, so omit familyId (as we don't have one)
        if body[ServerDefaultKeys.familyCode.rawValue] != nil {
            return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: body) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
        // user isn't trying to join a family, so add familyId
        else {
            return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithFamilyId, forBody: body) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalDelete(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> URLSessionDataTask? {
        
        return InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithFamilyId, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
}

extension FamilyRequest {
    
    // MARK: - Public Functions
    
    /**
     Retrieves the family configuration, automatically setting it up if the information is successfully retrieved.
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func get(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> URLSessionDataTask? {
        
        return FamilyRequest.internalGet(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [String: Any] {
                    // set up family configuration
                    FamilyConfiguration.setup(fromBody: result)
                    
                    completionHandler(true, responseStatus)
                }
                else {
                    completionHandler(false, responseStatus)
                }
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
            
        }
    }
    
    /**
     Sends a request for the user to create their own family.
     completionHandler returns a possible familyId and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func create(invokeErrorManager: Bool, completionHandler: @escaping (String?, ResponseStatus) -> Void) {
        _ = FamilyRequest.internalCreate(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // check for familyId
                if let familyId = responseBody?[ServerDefaultKeys.result.rawValue] as? String {
                    completionHandler(familyId, responseStatus)
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
     Update specific piece(s) of the family
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func update(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        _ = FamilyRequest.internalUpdate(invokeErrorManager: invokeErrorManager, body: body) { _, responseStatus in
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
     If the user is a familyMember, lets the user leave the family. If the user is a familyHead and are the only member, deletes the family. If they are a familyHead and there are other familyMembers, the request fails.
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func delete(invokeErrorManager: Bool, body: [String: Any] = [:], completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        _ = FamilyRequest.internalDelete(invokeErrorManager: invokeErrorManager, body: body) { _, responseStatus in
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
