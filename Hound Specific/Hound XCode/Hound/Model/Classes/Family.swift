//
//  Family.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

class FamilyMember: NSObject {
    
    // MARK: - Main
    
    init(userId: Int, firstName: String, lastName: String, isFamilyHead: Bool) {
        self.storedUserId = userId
        self.storedFirstName = firstName
        self.storedLastName = lastName
        self.storedIsFamilyHead = isFamilyHead
        super.init()
    }
    
    /// Assume array of family properties
    convenience init(fromBody body: [String: Any]) {
        let userId = body[ServerDefaultKeys.userId.rawValue] as? Int ?? -1
        let firstName = body[ServerDefaultKeys.userFirstName.rawValue] as? String ?? ""
        let lastName = body[ServerDefaultKeys.userLastName.rawValue] as? String ?? ""
        let isFamilyHead = body[ServerDefaultKeys.isFamilyHead.rawValue] as? Bool ?? false
        self.init(userId: userId, firstName: firstName, lastName: lastName, isFamilyHead: isFamilyHead)
    }
    
    // MARK: - Properties
    
    private var storedFirstName: String
    /// The family member's first name
    var firstName: String {
        return storedFirstName
    }
    
    private var storedLastName: String
    /// The family member's last name
    var lastName: String {
        return storedLastName
    }
    
    private var storedUserId: Int
    /// The family member's userId
    var userId: Int {
        return storedUserId
    }
    
    private var storedIsFamilyHead: Bool
    /// Indicates where or not this user is the head of the family
    var isFamilyHead: Bool {
        return storedIsFamilyHead
    }
    
}
