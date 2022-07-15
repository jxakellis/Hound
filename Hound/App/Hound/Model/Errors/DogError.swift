//
//  DogError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogError: String, Error {
    case dogNameNil = "Your dog's name is invalid, please try a different one."
    case dogNameBlank = "Your dog's name is blank, try typing something in."
    case dogNameCharacterLimitExceeded = "Your dog's name is too long, please try a shorter one."
}
