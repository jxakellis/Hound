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
    
    // MARK: Private Functions
    
    /**
     Uses familyId to retrieve information
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func get(completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        // at this point in time, an error can only occur if there is a invalid body provided. Since there is no body, there is no risk of an error.
        InternalRequestUtils.genericGetRequest(forURL: baseURLWithFamilyId) { responseBody, responseStatus in
            DispatchQueue.main.async {
                completionHandler(responseBody, responseStatus)
            }
        }
        
    }
    
    /**
     completionHandler returns response data: familyId for the created family and the ResponseStatus
     */
    private static func create(completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        
        // make post request, assume body valid as constructed with method
        InternalRequestUtils.genericPostRequest(forURL: baseURLWithoutParams, forBody: [ : ]) { responseBody, responseStatus in
            DispatchQueue.main.async {
                if responseBody != nil, let familyId = responseBody!["result"] as? Int {
                    completionHandler(familyId, responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            }
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func update(body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPutRequest(forURL: baseURLWithoutParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func delete(completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        InternalRequestUtils.genericDeleteRequest(forURL: baseURLWithFamilyId) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
}

extension FamilyRequest {
    
    // MARK: Public Functions
    
    /**
     completionHandler returns an array of family members. If the query returned a 200 status and is successful, then the dog is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func get(completionHandler: @escaping ([FamilyMember]?) -> Void) {
        
        FamilyRequest.get { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Array of family JSON [{familyMember1:'foo'},{familyMember2:'bar'}]
                if let result = responseBody!["result"] as? [String: Any], let familyMembersBody = result["familyMembers"] as? [[String: Any]] {
                    // decode familyCode and familyIsLocked
                    FamilyConfiguration.setup(fromBody: result)
                    
                    // decode family members
                    var familyMembers: [FamilyMember] = []
                    // get individual bodies
                    for familyMemberBody in familyMembersBody {
                        // convert individual bodies to family member
                        let familyMember = FamilyMember(fromBody: familyMemberBody)
                        familyMembers.append(familyMember)
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
                    
                    // able to add all
                    DispatchQueue.main.async {
                        completionHandler(familyMembers)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                    }
                }
            case .failureResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                }
                
            case .noResponse:
                DispatchQueue.main.async {
                    completionHandler(nil)
                    ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                }
            }
        
        }
    }
    
    /**
     Sends a request for the user to create their own family.
     completionHandler returns a Int. If the query returned a 200 status and is successful, then dogId is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func create(completionHandler: @escaping (Int?) -> Void) {
        
        FamilyRequest.create { familyId, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    if familyId != nil {
                        completionHandler(familyId!)
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
    
    /**
    Send a request for the user to attempt to join a family with the familyCode.
     completionHandler returns a Bool. If the query returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked.
     */
    static func update(familyCode: String, completionHandler: @escaping (Bool) -> Void) {
        let body = ["familyCode": familyCode]
        FamilyRequest.update(body: body) { _, responseStatus in
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
        FamilyRequest.delete { _, responseStatus in
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
