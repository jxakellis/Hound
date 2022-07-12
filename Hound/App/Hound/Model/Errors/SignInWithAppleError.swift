//
//  ASAuthorizationError.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/31/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum SignInWithAppleError: String, Error {
    case canceled = "The 'Sign In With Apple' page was prematurely canceled. Please retry and follow the prompts."
    case notSignedIn = "The 'Sign In With Apple' page failed as you have no Apple ID. Please create an Apple ID with two-factor authentication enabled and retry."
    case other = "The 'Sign In With Apple' page failed. Please make sure you have an Apple ID with two-factor authentication enabled and retry."
}
