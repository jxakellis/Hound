//
//  ReminderError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ReminderError: String, Error {
    case reminderActionBlank = "Your reminder has no action, try selecting one!"
    case reminderCustomActionNameCharacterLimitExceeded = "Your reminders's custom name is too long, please try a shorter one."
}
