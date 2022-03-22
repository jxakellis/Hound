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
    
    // MARK: iOS Notification Related
    
    static private var storedIsNotificationAuthorized: Bool = false
    /// This should be stored on the server as it is important to only send notifications to devices that can use them. This will always be overriden by the user upon reinstall if its state is different in that new install.
    static var isNotificationAuthorized: Bool {
        get {
            return storedIsNotificationAuthorized
        }
        set (newIsNotificationAuthorized) {
            guard newIsNotificationAuthorized != storedIsNotificationAuthorized else {
                return
            }
            storedIsNotificationAuthorized = newIsNotificationAuthorized
        }
    }
    
    // MARK: Alarm Timing Related
    
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
        }
    }
    
    // MARK: Alert Related
    
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
        }
    }
    
}
