//
//  RequestProtocol.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

protocol RequestProtocol {
    /// base URL for given endpoint where all the requests will be sent
    static var baseURLWithoutParams: URL { get }
}
