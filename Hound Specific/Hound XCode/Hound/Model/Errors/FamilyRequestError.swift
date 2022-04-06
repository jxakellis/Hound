//
//  FamilyRequestError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum FamilyRequestError: String, Error {
    case noFamilyCode = "Your family code is blank! Please enter one and retry."
    case familyCodeFormatInvalid = "Your family code is incorrect! Please make sure you enter the eight character code correctly and retry."
}
