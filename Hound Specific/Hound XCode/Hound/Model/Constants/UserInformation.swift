//
//  UserInformation.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Attempted to update a user informationn value and it failed. These errors make it easier to standardize for ErrorManager.
/*
enum UserInformationResponseError: Error {
    case updateUserEmailFailed
    case updateUserFirstNameFailed
    case updateUserLastNameFailed
}
 */

/// Information specific to the user.
enum UserInformation {
    
    // MARK: - Ordered List
    // userId
    // userEmail
    // userFirstName
    // userLastName
    
    // MARK: - Main
    
    /// Sets the UserInformation values equal to all the values found in the body. The key for the each body value must match the name of the UserConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: Any]) {
        if let userId = body["userId"] as? Int {
            self.userId = userId
        }
        if let userEmail = body["userEmail"] as? String {
            storedUserEmail = userEmail
        }
        if let userFirstName = body["userFirstName"] as? String {
            storedUserFirstName = userFirstName
        }
        if let userLastName = body["userLastName"] as? String {
            storedUserLastName = userLastName
        }
    }
    
    static var userId: Int = 1
    
    static private var storedUserEmail: String = "blanktest@gmail.com"
    static var userEmail: String {
        get {
            return storedUserEmail
        }
        set (newUserEmail) {
            guard newUserEmail != storedUserEmail else {
                return
            }
            storedUserEmail = newUserEmail
        }
    }
    
    static private var storedUserFirstName: String = "Blank"
    static var userFirstName: String {
        get {
            return storedUserFirstName
        }
        set (newUserFirstName) {
            guard newUserFirstName != storedUserFirstName else {
                return
            }
            storedUserFirstName = newUserFirstName
        }
    }
    
    static private var storedUserLastName: String = "Test"
    static var userLastName: String {
        get {
            return storedUserLastName
        }
        set (newUserLastName) {
            guard newUserLastName != storedUserLastName else {
                return
            }
            storedUserLastName = newUserLastName
        }
    }
}
