//
//  LogError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogError: String, Error {
    case logActionBlank = "Your log has no action, try selecting one!"
    case logCustomActionNameCharacterLimitExceeded = "Your log's custom name is too long, please try a shorter one."
}
