//
//  ReminderActionError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ReminderActionError: String, Error {
    case blankReminderAction = "Your reminder has no action, try selecting one!"
}
