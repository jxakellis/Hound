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
    /// Sets the UserInformation values equal to all the values found in the body. The key for the each body value must match the name of the UserConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: Any]) {
        if let userId = body[ServerDefaultKeys.userId.rawValue] as? String {
            self.userId = userId
        }
        if let userNotificationToken = body[ServerDefaultKeys.userNotificationToken.rawValue] as? String {
            self.userNotificationToken = userNotificationToken
        }
        if let familyId = body[ServerDefaultKeys.familyId.rawValue] as? String {
            self.familyId = familyId
        }
        if let userEmail = body[ServerDefaultKeys.userEmail.rawValue] as? String {
            self.userEmail = userEmail
        }
        if let userFirstName = body[ServerDefaultKeys.userFirstName.rawValue] as? String {
            self.userFirstName = userFirstName
        }
        if let userLastName = body[ServerDefaultKeys.userLastName.rawValue] as? String {
            self.userLastName = userLastName
        }
    }
    
    static var userId: String?
    
    static var userIdentifier: String?
    
    static var userNotificationToken: String?
    
    static var familyId: String?
    
    static var userEmail: String?
    
    static var userFirstName: String?
    
    static var userLastName: String?
}

extension UserInformation {
    // MARK: -
    
    /// The users member's full name. Handles cases where the first name and/or last name may be ""
    static var displayFullName: String {
        let trimmedFirstName = userFirstName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = userLastName?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // check to see if anything is blank
        if (trimmedFirstName == nil || trimmedFirstName == "") && (trimmedLastName == nil || trimmedLastName == "") {
            return "No Name"
        }
        // we know one of OR both of the trimmedFirstName and trimmedLast name are != nil && != ""
        else if trimmedFirstName == nil && trimmedFirstName == "" {
            // no first name but has last name
            return trimmedLastName!
        }
        else if trimmedLastName == nil && trimmedLastName == "" {
            // no last name but has first name
            return trimmedFirstName!
        }
        else {
            return "\(trimmedFirstName!) \(trimmedLastName!)"
        }
    }
    
    // MARK: - Request
    /// Returns an array literal of the user information's properties. This is suitable to be used as the JSON body for a HTTP request
    static func createBody(addingOntoBody body: [String: Any]?) -> [String: Any] {
        var body: [String: Any] = body ?? [:]
        body[ServerDefaultKeys.userIdentifier.rawValue] = UserInformation.userIdentifier
        body[ServerDefaultKeys.userEmail.rawValue] = UserInformation.userEmail
        body[ServerDefaultKeys.userFirstName.rawValue] = UserInformation.userFirstName
        body[ServerDefaultKeys.userLastName.rawValue] = UserInformation.userLastName
        return body
    }
}
