//
//  EnumConstant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/17/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum EnumConstant {
    enum DevelopmentConstant {
        static let isProduction: Bool = true
        /// The domain that api requests go to
        static let apiDomain: String = isProduction ? "api.houndorganizer.com/prod" : "10.0.0.108/dev"
        /// The interval at which the date picker should display minutes. Use this property to set the interval displayed by the minutes wheel (for example, 15 minutes). The interval value must be evenly divided into 60; if it is not, the default value is used. The default and minimum values are 1; the maximum value is 30.
        static let reminderMinuteInterval = isProduction ? 5 : 1
    }
    enum HashConstant {
        static let defaultSHA256Hash: String = Hash.sha256Hash(forString: "-1")
    }
}
