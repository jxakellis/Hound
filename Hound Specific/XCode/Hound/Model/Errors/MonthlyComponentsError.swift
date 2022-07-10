//
//  MonthlyComponentsError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum MonthlyComponentsError: String, Error {
    case dayInvalid = "Please select a day of month for your reminder."
    case hourInvalid = "Please select a time of day for your reminder."
    case minuteInvalid = "Please select a time of day for your reminder. "
}
