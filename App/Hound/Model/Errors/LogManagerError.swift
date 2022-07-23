//
//  LogManagerError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Enum full of cases of possible errors
enum LogManagerError: String, Error {
    case logIdNotPresent = "Something went wrong when trying modify your log, please try again! (LME.lINP)"
}
