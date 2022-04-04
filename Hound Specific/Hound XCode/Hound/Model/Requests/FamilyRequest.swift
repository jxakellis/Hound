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
    
    static let basePathWithoutParams: URL = UserRequest.basePathWithUserId.appendingPathComponent("/family")
    // UserRequest basePath with the userId path param appended on
    static var basePathWithFamilyId: URL { return FamilyRequest.basePathWithoutParams.appendingPathComponent("/\(UserInformation.familyId ?? -1)") }
    
    /**
     Uses familyId to retrieve information
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    static func get(completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        RequestUtils.warnForPlaceholderId()
        // at this point in time, an error can only occur if there is a invalid body provided. Since there is no body, there is no risk of an error.
        InternalRequestUtils.genericGetRequest(path: basePathWithoutParams) { responseBody, responseStatus in
            DispatchQueue.main.async {
                completionHandler(responseBody, responseStatus)
            }
        }
        
    }
    
    /**
     completionHandler returns a Int. If the query returned a 200 status and is successful, then familyId is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func create(completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        
        // make post request, assume body valid as constructed with method
        InternalRequestUtils.genericPostRequest(path: basePathWithoutParams, body: [ : ]) { responseBody, responseStatus in
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
     Targeted update. Specifically updates user information or configuration. Body is constructed from known good values so can assume no failures as all pre determiend.
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    static func update(body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        RequestUtils.warnForPlaceholderId()
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPutRequest(path: basePathWithFamilyId, body: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    static func delete(completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        RequestUtils.warnForPlaceholderId()
        InternalRequestUtils.genericDeleteRequest(path: basePathWithFamilyId) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
}
