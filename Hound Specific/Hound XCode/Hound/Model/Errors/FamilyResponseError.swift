//
//  FamilyResponseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum FamilyResponseError: String, Error {
    
    /*

     // POST
     ER_ALREADY_PRESENT
     // PUT
     ER_VALUES_MISSING
     ER_NOT_FOUND
     ER_FAMILY_LOCKED
     */
    
    /// User is already in a family and therefore can't join a new one
    case inFamilyAlready = "You are already in a family. Please leave your existing family before attempting to join a new one."
    
    /// The family code was undefined
    case familyCodeMissing = "Your family code was blank. Please enter in a valid eight character code to join a family."
    
    /// Family code was valid but was not linked to any family
    case familyNotFound = "Your family code did not match to any existing family. Please enter in a valid eight character code to join a family."
    
    /// Family code was valid and linked to a family but the family was locked
    case familyLocked = "Your family is locked, preventing any new members from joining! Please have the head of the family unlock it and retry."
    
}
