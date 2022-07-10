//
//  RequestError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/9/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum RequestError: String, Error {
    case noInternetConnection = "Your device doesn't appear to be connected to the internet. Please verify that you are connected to the internet and retry."
}
