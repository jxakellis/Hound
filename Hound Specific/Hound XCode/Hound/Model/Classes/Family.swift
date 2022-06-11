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
    
    init(userId: Int, firstName: String?, lastName: String?) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        super.init()
    }
    
    /// Assume array of family properties
    convenience init(fromBody body: [String: Any]) {
        let userId = body[ServerDefaultKeys.userId.rawValue] as? Int ?? -1
        let firstName = body[ServerDefaultKeys.userFirstName.rawValue] as? String
        let lastName = body[ServerDefaultKeys.userLastName.rawValue] as? String
        self.init(userId: userId, firstName: firstName, lastName: lastName)
    }
    
    // MARK: - Properties
    
    /// The family member's first name
    var firstName: String?
    
    /// The family member's last name
    var lastName: String?
    
    /// The family member's userId
    var userId: Int
    
    /// Indicates where or not this user is the head of the family
    var isFamilyHead: Bool = false
    
}

extension FamilyMember {
    /// The family member's full name. Handles cases where the first name and/or last name may be ""
    var displayFullName: String {
        let trimmedFirstName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedLastName = lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // check to see if anything is blank
        if trimmedFirstName == "" && trimmedLastName == "" {
            return "No Name"
        }
        // we know one of OR both of the trimmedFirstName and trimmedLast name are != nil && != ""
        else if trimmedFirstName == "" {
            // no first name but has last name
            return trimmedLastName
        }
        else if trimmedLastName == "" {
            // no last name but has first name
            return trimmedFirstName
        }
        else {
            return "\(trimmedFirstName) \(trimmedLastName)"
        }
    }
    
    /// The family member's initals name. Handles cases where the first name and/or last name may be ""
    var displayInitals: String {
        // get the first character of each string (using " " if nothing) then convert to single character string
        let firstNameFirstLetter: String = String(firstName?.trimmingCharacters(in: .whitespacesAndNewlines).first ?? Character(""))
        let lastNameFirstLetter: String = String(lastName?.trimmingCharacters(in: .whitespacesAndNewlines).first ?? Character(""))
        
        // check to see if anything is blank
        if firstNameFirstLetter == "" && lastNameFirstLetter == "" {
            return "UKN⚠️"
        }
        // we know one of OR both of the trimmedFirstName and trimmedLast name are != nil && != ""
        else if firstNameFirstLetter == "" {
            // no first name but has last name
            return lastNameFirstLetter
        }
        else if firstNameFirstLetter == "" {
            // no last name but has first name
            return lastNameFirstLetter
        }
        else {
            return "\(firstNameFirstLetter).\(lastNameFirstLetter)."
        }
    }
    
    /// The family member's first name. Handles cases where the first name may be "", therefore trying to use the last name to substitute
    var displayFirstName: String {
        let trimmedFirstName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedLastName = lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // check to see if anything is blank
        if trimmedFirstName == "" && trimmedLastName == "" {
            return "No Name"
        }
        // we know one of OR both of the trimmedFirstName and trimmedLast name are != ""
        else if trimmedFirstName == "" {
            // no first name but has last name
            return trimmedLastName
        }
        // we know the user has a firstName that isn't == "", so we can use that
        else {
            return trimmedFirstName
        }
    }
    
    static func findFamilyMember(forUserId userId: Int?) -> FamilyMember? {
        guard userId != nil else {
            return nil
        }
        
        let matchingFamilyMember: FamilyMember? = FamilyConfiguration.familyMembers.first { familyMember in
            if familyMember.userId == userId! {
                return true
            }
            else {
                return false
            }
        }
        
        return matchingFamilyMember
    }
}
