//
//  FamilyResponseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum FamilyResponseError: String, Error {
    
    init?(rawValue: String) {
        if rawValue == "ER_FAMILY_CODE_INVALID" {
            self = .familyCodeMissing
        }
        else if rawValue == "ER_FAMILY_NOT_FOUND" {
            self = .familyNotFound
        }
        else if rawValue == "ER_FAMILY_LOCKED" {
            self = .familyLocked
        }
        else if rawValue == "ER_FAMILY_ALREADY" {
            self = .familyAlready
        }
        else {
            return nil
        }
    }
    
    /*
     ER_FAMILY_CODE_INVALID
     ER_FAMILY_NOT_FOUND
     ER_FAMILY_LOCKED
     ER_FAMILY_ALREADY
     */
    
    /// The family code was undefined
    case familyCodeMissing = "Your family code was invalid. Please enter in a valid code and retry."
    
    /// Family code was valid but was not linked to any family
    case familyNotFound = "Your family code did not match to any existing family. Please enter in a valid code and retry."
    
    /// User is already in a family and therefore can't join a new one
    case familyAlready = "You are already in a family. Please leave your existing family before attempting to join a new one."
    
    /// Family code was valid and linked to a family but the family was locked
    case familyLocked = "The family your are trying to join is locked, preventing any new members from joining. Please have an existing family member unlock it and retry."
    
}
