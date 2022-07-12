//
//  LogActionError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogActionError: String, Error {
    case blankLogAction = "Your log has no action, try selecting one!"
}
