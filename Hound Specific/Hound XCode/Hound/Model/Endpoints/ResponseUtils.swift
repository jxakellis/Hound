//
//  ResponseUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ResponseUtils {
    static func dateFormatter(fromISO8601String ISO8601String: String) -> Date? {
        // from client
        // 2022-04-06T21:03:15Z
        // from server
        // 2022-04-12T20:40:00.000Z
        let formatterWithMilliseconds = Foundation.ISO8601DateFormatter()
        formatterWithMilliseconds.formatOptions = [.withFractionalSeconds, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]
        let formatterWithoutMilliseconds = Foundation.ISO8601DateFormatter()
        formatterWithoutMilliseconds.formatOptions = [.withDashSeparatorInDate, .withColonSeparatorInTime, .withFullDate, .withTime]
        return formatterWithMilliseconds.date(from: ISO8601String) ?? formatterWithoutMilliseconds.date(from: ISO8601String) ?? nil
        
    }
}
