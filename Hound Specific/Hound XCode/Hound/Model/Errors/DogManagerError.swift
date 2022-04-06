//
//  DogManagerError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Enum full of cases of possible errors from DogManager
enum DogManagerError: String, Error {
    case dogIdNotPresent = "Couldn't find a match for a dog with that id. Please reload and try again!"
}
