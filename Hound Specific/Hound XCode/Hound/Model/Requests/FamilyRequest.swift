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
    
    static let baseURLWithoutParams: URL = UserRequest.baseURLWithUserId.appendingPathComponent("/family")
    // UserRequest baseURL with the userId path param appended on
    static var baseURLWithFamilyId: URL { return FamilyRequest.baseURLWithoutParams.appendingPathComponent("/\(UserInformation.familyId ?? -1)") }
    
    // MARK: - Private Functions
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalGet(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithFamilyId) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalCreate(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: [ : ]) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalUpdate(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        // the user is trying to join a family with the family code, so omit familyId (as we don't have one)
        if body[ServerDefaultKeys.familyCode.rawValue] != nil {
            InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: body) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
        // user isn't trying to join a family, so add familyId
        else {
            InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithFamilyId, forBody: body) { responseBody, responseStatus in
                completionHandler(responseBody, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalDelete(invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithFamilyId) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
}

extension FamilyRequest {
    
    // MARK: - Public Functions
    
    /**
     Retrieves the family configuration, automatically setting it up if the information is successfully retrieved.
     completionHandler returns a possible array of familyMembers and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func get(invokeErrorManager: Bool, completionHandler: @escaping ([FamilyMember]?, ResponseStatus) -> Void) {
        
        FamilyRequest.internalGet(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [String: Any], let familyMembersBody = result[ServerDefaultKeys.familyMembers.rawValue] as? [[String: Any]] {
                    // set up family configuration
                    FamilyConfiguration.setup(fromBody: result)
                    
                    // decode family members
                    var familyMembers: [FamilyMember] = []
                    // get individual bodies
                    for familyMemberBody in familyMembersBody {
                        // convert individual bodies to family member
                        let familyMember = FamilyMember(fromBody: familyMemberBody)
                        familyMembers.append(familyMember)
                    }
                    
                    // assign familyHead
                    if let familyHeadUserId = result[ServerDefaultKeys.userId.rawValue] as? Int {
                        for familyMember in familyMembers where familyMember.userId == familyHeadUserId {
                            familyMember.isFamilyHead = true
                        }
                    }
                    
                    // sort so family head is first then users in ascending userid order
                    familyMembers.sort { familyMember1, familyMember2 in
                        // the family head should always be first
                        if familyMember1.isFamilyHead == true {
                            // 1st element is head so should come before therefore return true
                            return true
                        }
                        else if familyMember2.isFamilyHead == true {
                            // 2nd element is head so should come before therefore return false
                            return false
                        }
                        else {
                            // the user with the lower userId should come before the higher id
                            // if familyMember1 has a smaller userId then comparison returns true and then true is returned again, bringing familyMember1 to be first
                            // if familyMember2 has a smaller userId then comparison returns false and then false is returned, bringing familyMember2 to be first
                            return (familyMember1.userId < familyMember2.userId)
                        }
                    }
                    
                    completionHandler(familyMembers, responseStatus)
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
     Sends a request for the user to create their own family.
     completionHandler returns a possible familyId and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func create(invokeErrorManager: Bool, completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        FamilyRequest.internalCreate(invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // check for familyId
                if let familyId = responseBody?[ServerDefaultKeys.result.rawValue] as? Int {
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
        FamilyRequest.internalUpdate(invokeErrorManager: invokeErrorManager, body: body) { _, responseStatus in
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
    static func delete(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        FamilyRequest.internalDelete(invokeErrorManager: invokeErrorManager) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                // reset the local configurations so they are ready for the next family member
                LocalConfiguration.hasLoadedFamilyIntroductionViewControllerBefore = false
                LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = false
                LocalConfiguration.dogIcons = []
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
}
