//
//  WeeklyComponentsError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum WeeklyComponentsError: String, Error {
    case weekdayArrayInvalid = "Please select at least one day of the week for your reminder. You can do this by clicking on the S, M, T, W, T, F, or S. A blue letter means that your reminder's alarm will sound that day and grey means it won't."
    case hourInvalid = "Please select a time of day for your reminder."
    case minuteInvalid = "Please select a time of day for your reminder. "
}
