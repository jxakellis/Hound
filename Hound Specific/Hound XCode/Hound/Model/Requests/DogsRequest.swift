//
//  DogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogsRequestError: Error {
    case dogIdMissing
    case bodyInvalid
}

enum DogsRequest: RequestProtocol {
    static let basePathWithoutParams: URL = UserRequest.basePathWithUserId.appendingPathComponent("/dogs")
    
    // MARK: - Private Functions
    
    /**
     dogId optional, providing it only returns the single dog (if found) otherwise returns all dogs
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func get(forDogId dogId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId)
        
        let pathWithParams: URL
        
        // special case where we append the query parameter of all. Its value doesn't matter but it just tells the server that we want the logs and reminders of the dog too.
        if dogId != nil {
            
            var path = URLComponents(url: basePathWithoutParams.appendingPathComponent("/\(dogId!)"), resolvingAgainstBaseURL: false)!
            path.queryItems = [URLQueryItem(name: "reminders", value: "true"), URLQueryItem(name: "logs", value: "true")]
            pathWithParams = path.url!
        }
        else {
            var path = URLComponents(url: basePathWithoutParams.appendingPathComponent(""), resolvingAgainstBaseURL: false)!
            path.queryItems = [URLQueryItem(name: "reminders", value: "true"), URLQueryItem(name: "logs", value: "true")]
            pathWithParams = path.url!
        }
        
        // make get request
        InternalRequestUtils.genericGetRequest(path: pathWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dogId for the created dog and the ResponseStatus
     */
    private static func create(forDog dog: Dog, completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        RequestUtils.warnForPlaceholderId()
        let body = InternalRequestUtils.createDogBody(dog: dog)
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPostRequest(path: basePathWithoutParams, body: body) { responseBody, responseStatus in
            
            if responseBody != nil, let dogId = responseBody!["result"] as? Int {
                completionHandler(dogId, responseStatus)
            }
            else {
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func update(forDog dog: Dog, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dog.dogId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dog.dogId)")
        
        let body = InternalRequestUtils.createDogBody(dog: dog)
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPutRequest(path: pathWithParams, body: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func delete(forDogId dogId: Int, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        RequestUtils.warnForPlaceholderId(dogId: dogId)
        let pathWithParams: URL = basePathWithoutParams.appendingPathComponent("/\(dogId)")
        
        // make delete request
        InternalRequestUtils.genericDeleteRequest(path: pathWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
}

extension DogsRequest {
    
    // MARK: - Public Functions
    
    /**
     completionHandler returns a dog. If the query returned a 200 status and is successful, then the dog is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func get(forDogId dogId: Int, completionHandler: @escaping (Dog?) -> Void) {
        
        DogsRequest.get(forDogId: dogId) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Array of log JSON [{dog1:'foo'},{dog2:'bar'}]
                if let result = responseBody!["result"] as? [[String: Any]] {
                    let dog = Dog(fromBody: result[0])
                    // able to add all
                    DispatchQueue.main.async {
                        completionHandler(dog)
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
     completionHandler returns an array of dogs. If the query returned a 200 status and is successful, then the array of dogs is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func getAll(completionHandler: @escaping ([Dog]?) -> Void) {
        DogsRequest.get(forDogId: nil) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                var dogArray: [Dog] = []
                // Array of dog JSON [{dog1:'foo'},{dog2:'bar'}]
                if let result = responseBody!["result"] as? [[String: Any]] {
                    for dogBody in result {
                        let dog = Dog(fromBody: dogBody)
                        dogArray.append(dog)
                    }
                    // able to add all
                    DispatchQueue.main.async {
                        completionHandler(dogArray)
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
     completionHandler returns a Int. If the query returned a 200 status and is successful, then dogId is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func create(forDog dog: Dog, completionHandler: @escaping (Int?) -> Void) {
        
        DogsRequest.create(forDog: dog) { dogId, responseStatus in
            DispatchQueue.main.async {
                switch responseStatus {
                case .successResponse:
                    if dogId != nil {
                        completionHandler(dogId!)
                    }
                    else {
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
     completionHandler returns a Bool. If the query returned a 200 status and is successful, then true is returned. Otherwise, if there was a problem, false is returned and ErrorManager is automatically invoked.
     */
    static func update(forDog dog: Dog, completionHandler: @escaping (Bool) -> Void) {
        DogsRequest.update(forDog: dog) { _, responseStatus in
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
    static func delete(forDogId dogId: Int, completionHandler: @escaping (Bool) -> Void) {
        DogsRequest.delete(forDogId: dogId) { _, responseStatus in
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
