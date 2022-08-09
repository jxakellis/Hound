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
        /// True if the server we are contacting is our Ubuntu AWS instance, false if we are local hosting off personal computer
        static let isProductionServer: Bool = true
        /// True if we are contacting the production environment side of our server, false if we are contacting the development side
        static let isProductionDatabase: Bool = true
        /// Only the production server supports HTTPS
        private static let urlScheme: String = isProductionServer ? "https" : "http"
        /// The production server is attached to a real domain name, whereas our development server is off the local network
        private static let urlDomainName: String = isProductionServer ? "://api.houndorganizer.com" : "://10.0.0.108"
        /// The production server uses https on port 443 for the production database and 8443 for the development database. The development server always uses http on port 80.
        private static let urlPort: String = isProductionServer ? isProductionDatabase ? ":443" : ":8443" : ":80"
        /// The production environment goes off the prod path, whereas development goes off the dev path
        private static let urlBasePath: String = isProductionDatabase ? "/prod" : "/dev"
        /// All Hound app requests go under the app path
        private static let urlAppPath: String = "/app"
        /// The base url that api requests go to
        static let url: String = urlScheme + urlDomainName + urlPort + urlBasePath + urlAppPath
        /// The interval at which the date picker should display minutes. Use this property to set the interval displayed by the minutes wheel (for example, 15 minutes). The interval value must be evenly divided into 60; if it is not, the default value is used. The default and minimum values are 1; the maximum value is 30.
        static let reminderMinuteInterval = isProductionDatabase ? 5 : 1
    }
    enum HashConstant {
        static let defaultSHA256Hash: String = Hash.sha256Hash(forString: "-1")
    }
}
