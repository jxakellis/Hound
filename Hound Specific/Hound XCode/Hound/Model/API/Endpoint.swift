//
//  Endpoint.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/25/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum EndpointUtils {
    static let basePath: URL = URL(string: "http://localhost:5000/api/v1")!
    static let session = URLSession.shared
    
    ///Takes an already constructed URLRequest and executes it, returning it in a compeltion handler. This is the basis to all URL requests
    static func genericRequest(request: URLRequest, completionHandler: @escaping (Dictionary<String, Any>?, Int?, Error?) -> ()){
        
        //send request
        let task = session.dataTask(with: request) { data, response, err in
            
            //extract status code from URLResponse
            var httpResponseStatusCode: Int? = nil
            if let httpResponse = response as? HTTPURLResponse{
                httpResponseStatusCode = httpResponse.statusCode
            }
            
            //parse response from json
            var dataJSON: Dictionary<String, Any>? = nil
            
            //if no data or if no status code, then request failed
            if (data != nil && httpResponseStatusCode != nil){
                do {
                    //try to serialize data as "result" form with array of info first, if that fails, revert to regular "message" and "error" format
                    dataJSON = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? Dictionary<String,[Dictionary<String,Any>]> ?? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? Dictionary<String,Any>
                } catch {
                    print("Error when serializing data into JSON \(error)")
                }
            }
            
            //pass out information
            completionHandler(dataJSON, httpResponseStatusCode, err)
            
        }
        
        //free up task when request is pushed
        task.resume()
    }
}

extension EndpointUtils{
    
    ///Perform a generic get request at the specified url, assuming path params are already provided. No body needed for request. No throws as request creating cannot fail
    static func genericGetRequest(path: URL, completionHandler: @escaping (Dictionary<String, Any>?, Int?, Error?) -> ()) {
        //create request to send
        var req = URLRequest(url: path)
        
        //specify http method
        req.httpMethod = "GET"
        
        genericRequest(request: req) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
        
    }
    
    ///Perform a generic get request at the specified url with provided body. Throws as creating request can fail if body is invalid.
    static func genericPostRequest(path: URL, body: [String:Any], completionHandler: @escaping (Dictionary<String, Any>?, Int?, Error?) -> ()) throws {
        //create request to send
        var req = URLRequest(url: path)
        
        //specify http method
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            req.httpBody = jsonData
        } catch {
            throw error
        }
        
        genericRequest(request: req) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
    }
    
    ///Perform a generic get request at the specified url with provided body, assuming path params are already provided. Throws as creating request can fail if body is invalid
    static func genericPutRequest(path: URL, body: [String:Any], completionHandler: @escaping (Dictionary<String, Any>?, Int?, Error?) -> ()) throws {
        //create request to send
        var req = URLRequest(url: path)
        
        //specify http method
        req.httpMethod = "PUT"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            req.httpBody = jsonData
        } catch {
            throw error
        }
        
        genericRequest(request: req) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
    }
    
    ///Perform a generic get request at the specified url, assuming path params are already provided. No body needed for request. No throws as request creating cannot fail
    static func genericDeleteRequest(path: URL, completionHandler: @escaping (Dictionary<String, Any>?, Int?, Error?) -> ()) {
        //create request to send
        var req = URLRequest(url: path)
        
        //specify http method
        req.httpMethod = "DELETE"
        
        genericRequest(request: req) { dictionary, status, error in
            completionHandler(dictionary, status, error)
        }
        
    }
}

protocol EndpointProtocol {
    ///base path for given endpoint where all the requests will be sent
    static var basePath: URL { get }
    
    //MARK: - HTTP Methods
    
    /*
     Two Types of Response Format
     
     
     Type 1 - Success:
     {
     "result":
     [
        {"propertyOne":"data",
         "propertyTwo":"data
     ]
     }
     
     Type 2 - Failure:
     {
     "message":"failure message",
     "error":"error code"
     }
     */
    
    /**
        If a path param is required for request, then provide it otherwise an error will be thrown. userId sourced from already stored value. Note: path param of target endpoint can be omitted if you want to recieve all entries (e.g. omit forReminderId if you want to recieve all of a dog's reminders)
        completionHandler returns dictionary of response, the status code, and any error that occured when request sent.
        Throws if necessary path param is not provided
     */
    static func get(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId: Int?, completionHandler: @escaping (Dictionary<String, Any>?, Int?, Error?) -> ()) throws
    
    /**
     If creating a user or dog, forDogId is not needed. Only specify if creating a reminder or log.
     completionHandler returns dictionary of response, the status code, and any error that occured when request sent.
     Throws if body fails to be converted and attached to request or necessary path param is not provided
     */
    static func create(forDogId dogId: Int?, body: [String:Any], completionHandler: @escaping (Dictionary<String, Any>?, Int?, Error?) -> ()) throws
    
    /**
     If a path param is required for request, then provide it otherwise an error will be thrown. userId sourced from already stored value.
     completionHandler returns dictionary of response, the status code, and any error that occured when request sent.
     Throws if body fails to be converted and attached to request or necessary path param is not provided
     */
    static func update(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId: Int?, body: [String:Any], completionHandler: @escaping (Dictionary<String, Any>?, Int?, Error?) -> ()) throws
    
    /**
     If a path param is required for request, then provide it otherwise an error will be thrown. userId sourced from already stored value.
     completionHandler returns dictionary of response, the status code, and any error that occured when request sent.
     Throws if necessary path param is not provided
     */
    static func delete(forDogId dogId: Int?, forReminderId reminderId: Int?, forLogId: Int?, completionHandler: @escaping (Dictionary<String, Any>?, Int?, Error?) -> ()) throws
}


