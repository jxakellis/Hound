//
//  UserInformation.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Information specific to the user.
enum UserInformation {

    static var userId: Int = 1

    static private var storedUserEmail: String = "joesmith@gmail.com"
    static var userEmail: String {
        get {
            return storedUserEmail
        }
        set (newUserEmail) {
            guard newUserEmail != storedUserEmail else {
                return
            }
            storedUserEmail = newUserEmail
            AppDelegate.endpointLogger.notice("ENDPOINT Update userEmail")
        }
    }

    static private var storedUserFirstName: String = "Joe"
    static var userFirstName: String {
        get {
            return storedUserFirstName
        }
        set (newUserFirstName) {
            guard newUserFirstName != storedUserFirstName else {
                return
            }
            storedUserFirstName = newUserFirstName
            AppDelegate.endpointLogger.notice("ENDPOINT Update userFirstName")
        }
    }

    static private var storedUserLastName: String = "Smith"
    static var userLastName: String {
        get {
            return storedUserLastName
        }
        set (newUserLastName) {
            guard newUserLastName != storedUserLastName else {
                return
            }
            storedUserLastName = newUserLastName
            AppDelegate.endpointLogger.notice("ENDPOINT Update userLastName")
        }
    }
}
