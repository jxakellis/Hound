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
        // MARK: Limit
        if rawValue == "ER_FAMILY_LIMIT_FAMILY_MEMBER_TOO_LOW" {
            self = .limitFamilyMemberTooLow
        }
        else if rawValue == "ER_FAMILY_LIMIT_DOG_TOO_LOW" {
            self = .limitDogTooLow
        }
        else if rawValue == "ER_FAMILY_LIMIT_LOG_TOO_LOW" {
            self = .limitLogTooLow
        }
        else if rawValue == "ER_FAMILY_LIMIT_REMINDER_TOO_LOW" {
            self = .limitReminderTooLow
        }
        else if rawValue == "ER_FAMILY_LIMIT_FAMILY_MEMBER_EXCEEDED" {
            self = .limitFamilyMemberExceeded
        }
        else if rawValue == "ER_FAMILY_LIMIT_DOG_EXCEEDED" {
            self = .limitDogExceeded
        }
        // MARK: Join
        else if rawValue == "ER_FAMILY_JOIN_FAMILY_CODE_INVALID" {
            self = .joinFamilyCodeInvalid
        }
        else if rawValue == "ER_FAMILY_JOIN_FAMILY_LOCKED" {
            self = .joinFamilyLocked
        }
        else if rawValue == "ER_FAMILY_JOIN_IN_FAMILY_ALREADY" {
            self = .joinInFamilyAlready
        }
        // MARK: Leave
        else if rawValue == "ER_FAMILY_LEAVE_INVALID" {
            self = .leaveInvalid
        }
        // MARK: Permission
        else if rawValue == "ER_FAMILY_PERMISSION_INVALID" {
            self = .permissionInvalid
        }
        else {
            return nil
        }
    }
    
    // MARK: Limit
    // Too Low
    case limitFamilyMemberTooLow = "This family can only have a limited number of family members! Please have existing family member leave or the family head upgrade their subscription before attempting to join this family."
    case limitDogTooLow = "Your family can only have a limited number of dogs! Please remove an existing dog or have the family head upgrade your family's subscription before attempting to add a new dog."
    case limitLogTooLow = "Your dog can only have a limited number of logs! Please remove an existing log before trying to add a new one. If you are having difficulty with this limit, please contact Hound support."
    case limitReminderTooLow = "Your dog can only have a limited number of reminders! Please remove an existing reminder before trying to add a new one."
    
    // Exceeded
    case limitFamilyMemberExceeded = "Your family has exceeded it's family member limit and is unable to have data added or updated. This is likely due to your family's subscription being downgraded or expiring. Please remove existing family members or have the family head upgrade your family's subscription to restore functionality."
    case limitDogExceeded = "Your family has exceeded it's dog limit and is unable to have data added or updated. This is likely due to your family's subscription being downgraded or expiring. Please remove existing dogs or have the family head upgrade your family's subscription to restore functionality."
    
    // MARK: Join
   /// Family code was valid but was not linked to any family
    case joinFamilyCodeInvalid = "Your family code isn't linked to any family. Please enter a valid code and retry."
    /// Family code was valid and linked to a family but the family was locked
    case joinFamilyLocked = "The family you are trying to join is locked, preventing any new family members from joining. Please have an existing family member unlock it and retry."
    /// User is already in a family and therefore can't join a new one
    case joinInFamilyAlready = "You are already in a family. Please leave your existing family before attempting to join a new one. If this issue persists, please contact Hound support."
    
    // MARK: Leave
    case leaveInvalid = "You are unable to leave your current family. This is likely due to you being the family head and your family containing multiple family members. Please remove all existing family members before attempting to leave. If this issue persists, please contact Hound support."
    
    // MARK: Permission
    case permissionInvalid = "You are attempting to perform an action that only the family head can perform. Please contact the family head and have them complete this action. If this issue persists, please contact Hound support."
    
}
