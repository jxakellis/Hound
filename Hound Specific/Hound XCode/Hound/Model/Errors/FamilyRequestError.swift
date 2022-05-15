//
//  FamilyRequestError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum FamilyRequestError: String, Error {
    case familyCodeBlank = "Your family code is blank! Please enter in a valid code and retry."
    case familyCodeInvalid = "Your family code's format is invalid! Please enter in a valid code and retry."
}
