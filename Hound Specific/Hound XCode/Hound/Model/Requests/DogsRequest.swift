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
     dogId optional, providing it only returns the single dog (if found) otherwise returns all dogs
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func get(forDogId dogId: Int?, reminders: Bool, logs: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
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
        InternalRequestUtils.genericGetRequest(forURL: URLWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dogId for the created dog and the ResponseStatus
     */
    private static func create(forDog dog: Dog, completionHandler: @escaping (Int?, ResponseStatus) -> Void) {
        InternalRequestUtils.warnForPlaceholderId()
        let body = InternalRequestUtils.createDogBody(dog: dog)
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPostRequest(forURL: baseURLWithoutParams, forBody: body) { responseBody, responseStatus in
            
            if responseBody != nil, let dogId = responseBody![ServerDefaultKeys.result.rawValue] as? Int {
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
        
        InternalRequestUtils.warnForPlaceholderId(dogId: dog.dogId)
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dog.dogId)")
        
        let body = InternalRequestUtils.createDogBody(dog: dog)
        
        // make put request, assume body valid as constructed with method
        InternalRequestUtils.genericPutRequest(forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func delete(forDogId dogId: Int, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) {
        
        InternalRequestUtils.warnForPlaceholderId(dogId: dogId)
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)")
        
        // make delete request
        InternalRequestUtils.genericDeleteRequest(forURL: URLWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
}

extension DogsRequest {
    
    // MARK: - Public Functions
    
    /**
     completionHandler returns a dog. If the query returned a 200 status and is successful, then the dog is returned. Otherwise, if there was a problem, nil is returned and ErrorManager is automatically invoked.
     */
    static func get(forDogId dogId: Int, reminders: Bool, logs: Bool, completionHandler: @escaping (Dog?) -> Void) {
        
        DogsRequest.get(forDogId: dogId, reminders: reminders, logs: logs) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                // Array of log JSON [{dog1:'foo'},{dog2:'bar'}]
                if let result = responseBody![ServerDefaultKeys.result.rawValue] as? [[String: Any]] {
                    let dog = Dog(fromBody: result[0])
                    // If we have an image stored locally for a dog, then we apply the icon.
                    // If the dog has no icon (because someone else in the family made it and the user hasn't selected their own icon OR because the user made it and never added an icon) then the dog just gets the defaultDogIcon
                    dog.dogIcon = LocalDogIcon.getIcon(forDogId: dog.dogId) ?? DogConstant.defaultDogIcon
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
    static func getAll(reminders: Bool, logs: Bool, completionHandler: @escaping ([Dog]?) -> Void) {
        DogsRequest.get(forDogId: nil, reminders: reminders, logs: logs) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                var dogArray: [Dog] = []
                // Array of dog JSON [{dog1:'foo'},{dog2:'bar'}]
                if let result = responseBody![ServerDefaultKeys.result.rawValue] as? [[String: Any]] {
                    for dogBody in result {
                        let dog = Dog(fromBody: dogBody)
                        // If we have an image stored locally for a dog, then we apply the icon.
                        // If the dog has no icon (because someone else in the family made it and the user hasn't selected their own icon OR because the user made it and never added an icon) then the dog just gets the defaultDogIcon
                        dog.dogIcon = LocalDogIcon.getIcon(forDogId: dog.dogId) ?? DogConstant.defaultDogIcon
                        dogArray.append(dog)
                    }
                    
                    LocalDogIcon.checkForExtraIcons(forDogs: dogArray)
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
                        // Successfully saved to server, so save dogIcon locally
                        // add a localDogIcon that has the same dogId and dogIcon as the newly created dog
                        LocalDogIcon.addIcon(forDogId: dogId!, forDogIcon: dog.dogIcon)
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
                    // Successfully saved to server, so update dogIcon locally
                    // check to see if a localDogIcon exists for the dog
                    LocalDogIcon.addIcon(forDogId: dog.dogId, forDogIcon: dog.dogIcon)
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
                    // Successfully saved to server, so remove the stored dogIcons that have the same dogId as the removed dog
                    LocalDogIcon.removeIcon(forDogId: dogId)
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
