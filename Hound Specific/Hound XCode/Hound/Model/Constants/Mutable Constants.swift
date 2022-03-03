//
//  Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 12/1/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Information specific to the user.
enum UserInformation {
    static private var storedUserEmail: String = "bobsmith@gmail.com"
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

    static private var storedUserFirstName: String = "Bob"
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

/// Configuration that is local to the app only. If the app is reinstalled then this data should be pulled down from the cloud
enum UserConfiguration {

    // MARK: Ordered List
    // isCompactView
    // darkModeStyle
    // snoozeLength
    // isPaused
    // isNotificationAuthorized
    // isNotificationEnabled
    // isLoudNotification
    // isFollowUpEnabled
    // followUpDelay
    // notificationSound

    // MARK: - In-App Appearance Related

    static private var storedIsCompactView: Bool = true
    static var isCompactView: Bool {
        get {
            return storedIsCompactView
        }
        set (newIsCompactView) {
            guard newIsCompactView != storedIsCompactView else {
                return
            }
            storedIsCompactView = newIsCompactView
            AppDelegate.endpointLogger.notice("ENDPOINT Update isCompactView")
        }
    }

    static private var storedDarkModeStyle: UIUserInterfaceStyle = .unspecified
    static var darkModeStyle: UIUserInterfaceStyle {
        get {
            return storedDarkModeStyle
        }
        set (newDarkModeStyle) {
            guard newDarkModeStyle != storedDarkModeStyle else {
                return
            }
            storedDarkModeStyle = newDarkModeStyle
            AppDelegate.endpointLogger.notice("ENDPOINT Update darkModeStyle")
        }
    }

    // MARK: - Alarm Timing Related

    static private var storedSnoozeLength: TimeInterval = TimeInterval(60*5)
    static var snoozeLength: TimeInterval {
        get {
            return storedSnoozeLength
        }
        set (newSnoozeLength) {
            guard newSnoozeLength != storedSnoozeLength else {
                return
            }
            storedSnoozeLength = newSnoozeLength
            AppDelegate.endpointLogger.notice("ENDPOINT Update snoozeLength")
        }
    }

    static private var storedIsPaused: Bool = false
    /// Saves state isPaused, self.isPaused can be modified by SettingsViewController but this is only when there are no active timers and pause is automatically set to unpaused
    static var isPaused: Bool {
        get {
            return storedIsPaused
            }
        set (newIsPaused) {
            guard newIsPaused != storedIsPaused else {
                return
            }
            storedIsPaused = newIsPaused
            AppDelegate.endpointLogger.notice("ENDPOINT Update isPaused")
        }
    }

    // MARK: - iOS Notification Related

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
            AppDelegate.endpointLogger.notice("ENDPOINT Update isNotificationAuthorized")
        }
    }

    static private var storedIsNotificationEnabled: Bool = false
    /// This should be stored on the server as it is important to only send notifications to devices that can use them. This will always be overriden by the user upon reinstall if its state is different in that new install.
    static var isNotificationEnabled: Bool {
        get {
            return storedIsNotificationEnabled
        }
        set (newIsNotificationEnabled) {
            guard newIsNotificationEnabled != storedIsNotificationEnabled else {
                return
            }
            storedIsNotificationEnabled = newIsNotificationEnabled
            AppDelegate.endpointLogger.notice("ENDPOINT Update isNotificationEnabled")
        }
    }

    static private var storedIsLoudNotification: Bool = false
    /// Determines if the app should send the user loud notifications. Loud notification bypass most iPhone settings to play at max volume (Do Not Disturb, ringer off, volume off...)
    static var isLoudNotification: Bool {
        get {
            return storedIsLoudNotification
        }
        set (newIsLoudNotification) {
            guard newIsLoudNotification != storedIsLoudNotification else {
                return
            }
            storedIsLoudNotification = newIsLoudNotification
            AppDelegate.endpointLogger.notice("ENDPOINT Update isLoudNotification")
        }
    }

    static private var storedIsFollowUpEnabled: Bool = false
    /// Sends a secondary, follow up notifcation if the first, primary notification about a reminder's alarm is not addressed.
    static var isFollowUpEnabled: Bool {
        get {
            return storedIsFollowUpEnabled
        }
        set (newIsFollowUpEnabled) {
            guard newIsFollowUpEnabled != storedIsFollowUpEnabled else {
                return
            }
            storedIsFollowUpEnabled = newIsFollowUpEnabled
            AppDelegate.endpointLogger.notice("ENDPOINT Update isFollowUpEnabled")
        }
    }

    static private var storedFollowUpDelay: TimeInterval = 5.0 * 60.0
   /// The delay between the inital, primary notifcation of a reminder and a seconary, followup notification of a reminder.
    static var followUpDelay: TimeInterval {
        get {
            return storedFollowUpDelay
        }
        set (newFollowUpDelay) {
            guard newFollowUpDelay != storedFollowUpDelay else {
                return
            }
            storedFollowUpDelay = newFollowUpDelay
            AppDelegate.endpointLogger.notice("ENDPOINT Update followUpDelay")
        }
    }

    static private var storedNotificationSound: NotificationSound = NotificationSound.radar
    /// Sound a notification will play
    static var notificationSound: NotificationSound {
        get {
            return storedNotificationSound
        }
        set (newNotificationSound) {
            guard newNotificationSound != storedNotificationSound else {
                return
            }
            storedNotificationSound = newNotificationSound
            AppDelegate.endpointLogger.notice("ENDPOINT Update notificationSound")
        }
    }

}

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

    static private var storedHasLoadedIntroductionViewControllerBefore: Bool = true
    /// Keeps track of if the user has viewed AND completed the introduction view controller (which helps the user setup their first dog)
    static var hasLoadedIntroductionViewControllerBefore: Bool {
        get {
            return storedHasLoadedIntroductionViewControllerBefore
        }
        set (newHasLoadedIntroductionViewControllerBefore) {
            guard newHasLoadedIntroductionViewControllerBefore != hasLoadedIntroductionViewControllerBefore else {
                return
            }
            storedHasLoadedIntroductionViewControllerBefore = newHasLoadedIntroductionViewControllerBefore
            AppDelegate.endpointLogger.notice("LOCAL Update hasLoadedIntroductionViewControllerBefore")
        }
    }

}
