//
//  LimitResponseError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/15/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LimitResponseError: String, Error {
    
    init?(rawValue: String) {
        if rawValue == "ER_REMINDER_LIMIT_EXCEEDED" {
            self = .reminderLimitExceeded
            return
        }
        else if rawValue == "ER_LOGS_LIMIT_EXCEEDED" {
            self = .logsLimitExceeded
            return
        }
        else {
            return nil
        }
    }
    
    /*
     ER_REMINDER_LIMIT_EXCEEDED
     */
    
    case reminderLimitExceeded = "Your dog can only have a limited amount of reminders! Please remove an existing reminder before trying to add a new one."
    case logsLimitExceeded = "Your dog can only have a maximum amount of 100,000 logs! Please remove an existing log before trying to add a new one. If you are having difficulty with this limit, contact Hound support."
}
