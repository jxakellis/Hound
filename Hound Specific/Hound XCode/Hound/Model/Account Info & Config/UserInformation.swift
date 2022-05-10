//
//  UserInformation.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Information specific to the user.
enum UserInformation {
    
    // TO DO remove unnecessary 'static private var storedVarible'. Make it all just static var with no getter/setters (unless its something speicial like dogIcon, logCustomActioNames, etc..)
    
    // MARK: - Ordered List
    // userId
    // userIdentifier
    // userNotificationToken
    // familyId
    // userEmail
    // userFirstName
    // userLastName
    
    // MARK: - Main
    
    /// Sets the UserInformation values equal to all the values found in the body. The key for the each body value must match the name of the UserConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: Any]) {
        if let userId = body[ServerDefaultKeys.userId.rawValue] as? Int {
            self.userId = userId
        }
        if let userNotificationToken = body[ServerDefaultKeys.userNotificationToken.rawValue] as? String {
            self.userNotificationToken = userNotificationToken
        }
        if let familyId = body[ServerDefaultKeys.familyId.rawValue] as? Int {
            self.familyId = familyId
        }
        if let userEmail = body[ServerDefaultKeys.userEmail.rawValue] as? String {
            storedUserEmail = userEmail
        }
        if let userFirstName = body[ServerDefaultKeys.userFirstName.rawValue] as? String {
            storedUserFirstName = userFirstName
        }
        if let userLastName = body[ServerDefaultKeys.userLastName.rawValue] as? String {
            storedUserLastName = userLastName
        }
    }
    
    static var userId: Int?
    
    static var userIdentifier: String?
    
    static var userNotificationToken: String?
    
    static var familyId: Int?
    
    static private var storedUserEmail: String?
    static var userEmail: String? {
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
    
    static private var storedUserFirstName: String = ""
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
    
    static private var storedUserLastName: String = ""
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
