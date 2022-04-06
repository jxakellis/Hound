//
//  ReminderManagerError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Enum full of cases of possible errors from ReminderManager
enum ReminderManagerError: String, Error {
    case reminderIdNotPresent = "Something went wrong when trying to modify your reminder. Please reload and try again! (RME.rINP)"
}
