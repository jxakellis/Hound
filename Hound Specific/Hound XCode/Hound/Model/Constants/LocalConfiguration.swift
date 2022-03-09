//
//  LocalConfiguration.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Configuration that is local to the app only. If the app is reinstalled then this data should be fresh
enum LocalConfiguration {

    static private var storedLastPause: Date?
    /// Saves date of last pause (if there was one). This is not needed on the server as it can automatically perform calculations if the reminders are paused/unapused. App needs this to perform calculations as it can be exited and lose track of time.
    static var lastPause: Date? {
        get {
            return storedLastPause
            }
        set (newLastPause) {
            guard newLastPause != storedLastPause else {
                return
            }
            storedLastPause = newLastPause
            AppDelegate.endpointLogger.notice("ENDPOINT Update lastPause")
        }
    }

    static private var storedLastUnpause: Date?
    /// Saves date of last unpause (if there was one). This is not needed on the server as it can automatically perform calculations if the reminders are paused/unapused. App needs this to perform calculations as it can be exited and lose track of time.
    static var lastUnpause: Date? {
        get {
            return storedLastUnpause
            }
        set (newLastUnpause) {
            guard newLastUnpause != storedLastUnpause else {
                return
            }
            storedLastUnpause = newLastUnpause
            AppDelegate.endpointLogger.notice("ENDPOINT Update lastUnpause")
        }
    }

    /// Used to track when the user was last asked to review the app
    static private var storeReviewRequestDates: [Date] = [Date()]
    /// Used to track when the user was last asked to review the app
    static var reviewRequestDates: [Date] {
        get {
            return storeReviewRequestDates
        }
        set (newReviewRequestDates) {
            guard newReviewRequestDates != storeReviewRequestDates else {
                return
            }
            storeReviewRequestDates = newReviewRequestDates
            AppDelegate.endpointLogger.notice("LOCAL Update reviewRequestDates")
        }
    }

    static private var storedIsShowTerminationAlert: Bool = true
    /// Determines where or not the app should display an alert when it believes the app was terminated.
    static var isShowTerminationAlert: Bool {
        get {
            return storedIsShowTerminationAlert
        }
        set (newIsShowTerminationAlert) {
            guard newIsShowTerminationAlert != storedIsShowTerminationAlert else {
                return
            }
            storedIsShowTerminationAlert = newIsShowTerminationAlert
            AppDelegate.endpointLogger.notice("LOCAL Update isShowTerminationAlert")
        }
    }

    static private var storedIsShowReleaseNotes: Bool = true
    /// Determines where or not the app should display an message when the app is first opened after an update
    static var isShowReleaseNotes: Bool {
        get {
            return storedIsShowReleaseNotes
        }
        set (newIsShowReleaseNotes) {
            guard newIsShowReleaseNotes != storedIsShowReleaseNotes else {
                return
            }
            storedIsShowReleaseNotes = newIsShowReleaseNotes
            AppDelegate.endpointLogger.notice("LOCAL Update isShowReleaseNotes")
        }
    }

    static private var storedHasLoadedIntroductionViewControllerBefore: Bool = false
    /// Keeps track of if the user has viewed AND completed the dogs introduction view controller (which helps the user setup their first reminders)
    static var hasLoadedIntroductionViewControllerBefore: Bool {
        get {
            return storedHasLoadedIntroductionViewControllerBefore
        }
        set (newHasLoadedIntroductionViewControllerBefore) {
            guard newHasLoadedIntroductionViewControllerBefore != storedHasLoadedIntroductionViewControllerBefore else {
                return
            }
            storedHasLoadedIntroductionViewControllerBefore = newHasLoadedIntroductionViewControllerBefore
            AppDelegate.endpointLogger.notice("LOCAL Update hasLoadedIntroductionViewControllerBefore")
        }
    }

    static private var storedHasLoadedDogsIntroductionViewControllerBefore: Bool = true
    /// Keeps track of if the user has viewed AND completed the dogs introduction view controller (which helps the user setup their first reminders)
    static var hasLoadedDogsIntroductionViewControllerBefore: Bool {
        get {
            return storedHasLoadedDogsIntroductionViewControllerBefore
        }
        set (newHasLoadedDogsIntroductionViewControllerBefore) {
            guard newHasLoadedDogsIntroductionViewControllerBefore != storedHasLoadedDogsIntroductionViewControllerBefore else {
                return
            }
            storedHasLoadedDogsIntroductionViewControllerBefore = newHasLoadedDogsIntroductionViewControllerBefore
            AppDelegate.endpointLogger.notice("LOCAL Update hasLoadedDogsIntroductionViewControllerBefore")
        }
    }

}
