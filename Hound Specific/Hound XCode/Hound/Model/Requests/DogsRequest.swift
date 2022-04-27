//
//  DogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogsRequest: RequestProtocol {
    static let baseURLWithoutParams: URL = FamilyRequest.baseURLWithFamilyId.appendingPathComponent("/dogs")
    
    // MARK: - Private Functions
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalGet(invokeErrorManager: Bool, forDogId dogId: Int?, reminders: Bool, logs: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        InternalRequestUtils.warnForPlaceholderId(dogId: dogId)
        
        let URLWithParams: URL
        var urlComponents: URLComponents!
        // special case where we append the query parameter of all. Its value doesn't matter but it just tells the server that we want the logs and reminders of the dog too.
        if dogId != nil {
            urlComponents = URLComponents(url: baseURLWithoutParams.appendingPathComponent("/\(dogId!)"), resolvingAgainstBaseURL: false)!
            
        }
        else {
            urlComponents = URLComponents(url: baseURLWithoutParams.appendingPathComponent(""), resolvingAgainstBaseURL: false)!
        }
        
        urlComponents.queryItems = []
        if reminders == true {
            urlComponents.queryItems!.append(URLQueryItem(name: "reminders", value: "true"))
        }
        if logs == true {
            urlComponents.queryItems!.append(URLQueryItem(name: "logs", value: "true"))
        }
        URLWithParams = urlComponents.url!
        
        // make get request
        InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dogId for the created dog and the ResponseStatus
     */
    private static func internalCreate(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        let body = InternalRequestUtils.createDogBody(dog: dog)
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: baseURLWithoutParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalUpdate(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        InternalRequestUtils.warnForPlaceholderId(dogId: dog.dogId)
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dog.dogId)")
        
        let body = InternalRequestUtils.createDogBody(dog: dog)
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalDelete(invokeErrorManager: Bool, forDogId dogId: Int, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        InternalRequestUtils.warnForPlaceholderId(dogId: dogId)
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)")
        
        // make delete request
        InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
}

extension DogsRequest {
    
    // MARK: - Public Functions
    
    /**
     completionHandler returns a possible dog and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func get(invokeErrorManager: Bool, forDogId dogId: Int, reminders: Bool, logs: Bool, completionHandler: @escaping (Dog?, ResponseStatus) -> Void) {
        
        DogsRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: dogId, reminders: reminders, logs: logs) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Array of log JSON [{dog1:'foo'},{dog2:'bar'}]
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [[String: Any]] {
                    let dog = Dog(fromBody: result[0])
                    // If we have an image stored locally for a dog, then we apply the icon.
                    // If the dog has no icon (because someone else in the family made it and the user hasn't selected their own icon OR because the user made it and never added an icon) then the dog just gets the defaultDogIcon
                    dog.dogIcon = LocalDogIcon.getIcon(forDogId: dog.dogId) ?? DogConstant.defaultDogIcon
                    
                    completionHandler(dog, responseStatus)
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
     completionHandler returns a possible array of dogs and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func getAll(invokeErrorManager: Bool, reminders: Bool, logs: Bool, completionHandler: @escaping ([Dog]?, ResponseStatus) -> Void) {
        DogsRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: nil, reminders: reminders, logs: logs) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                var dogArray: [Dog] = []
                // Array of dog JSON [{dog1:'foo'},{dog2:'bar'}]
                if let result = responseBody?[ServerDefaultKeys.result.rawValue] as? [[String: Any]] {
                    for dogBody in result {
                        let dog = Dog(fromBody: dogBody)
                        // If we have an image stored locally for a dog, then we apply the icon.
                        // If the dog has no icon (because someone else in the family made it and the user hasn't selected their own icon OR because the user made it and never added an icon) then the dog just gets the defaultDogIcon
                        dog.dogIcon = LocalDogIcon.getIcon(forDogId: dog.dogId) ?? DogConstant.defaultDogIcon
                        dogArray.append(dog)
                    }
                    
                    LocalDogIcon.checkForExtraIcons(forDogs: dogArray)
                    completionHandler(dogArray, responseStatus)
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
     completionHandler returns a possible dogId and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func create(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        DogsRequest.internalCreate(invokeErrorManager: invokeErrorManager, forDog: dog) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let dogId = responseBody?[ServerDefaultKeys.result.rawValue] as? Int {
                    // Successfully saved to server, so save dogIcon locally
                    // add a localDogIcon that has the same dogId and dogIcon as the newly created dog
                    LocalDogIcon.addIcon(forDogId: dogId, forDogIcon: dog.dogIcon)
                    completionHandler(dogId, responseStatus)
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
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func update(invokeErrorManager: Bool, forDog dog: Dog, completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        DogsRequest.internalUpdate(invokeErrorManager: invokeErrorManager, forDog: dog) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Successfully saved to server, so update dogIcon locally
                // check to see if a localDogIcon exists for the dog
                LocalDogIcon.addIcon(forDogId: dog.dogId, forDogIcon: dog.dogIcon)
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    static func delete(invokeErrorManager: Bool, forDogId dogId: Int, completionHandler: @escaping (Bool, ResponseStatus) -> Void) {
        DogsRequest.internalDelete(invokeErrorManager: invokeErrorManager, forDogId: dogId) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Successfully saved to server, so remove the stored dogIcons that have the same dogId as the removed dog
                LocalDogIcon.removeIcon(forDogId: dogId)
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
}
