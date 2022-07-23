//
//  EnumConstant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/17/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum EnumConstant {
    enum HashConstant {
        static let defaultSHA256Hash: String = Hash.sha256Hash(forString: "-1")
    }
}
