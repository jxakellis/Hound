//
//  Constants.swift
//  Hound
//
//  Created by Jonathan Xakellis on 12/1/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum TimingConstant {

    // Immutable
    static var defaultTimeOfDay: DateComponents = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: 8, minute: 30, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    static var defaultSkipStatus: Bool = false

    // Mutable

    static var storedDefaultSnoozeLength: TimeInterval = TimeInterval(60*5)
    static var defaultSnoozeLength: TimeInterval {
        get {
            return storedDefaultSnoozeLength
        }
        set (newDefaultSnoozeLength) {
            guard newDefaultSnoozeLength != storedDefaultSnoozeLength else {
                return
            }
            storedDefaultSnoozeLength = newDefaultSnoozeLength
            AppDelegate.endpointLogger.notice("ENDPOINT Update defaultSnoozeLength")
        }
    }

    /// Saves state isPaused, self.isPaused can be modified by SettingsViewController but this is only when there are no active timers and pause is automatically set to unpaused
    static private var storedIsPaused: Bool = false
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

    /// Saves date of last pause (if there was one)
    static private var storedLastPause: Date?
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

    /// Saves date of last unpause (if there was one)
    static private var storedLastUnpause: Date?
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
}

enum NotificationConstant {
    static private var storedIsNotificationAuthorized: Bool = false
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

    static private var storedShouldLoudNotification: Bool = false
    static var shouldLoudNotification: Bool {
        get {
            return storedShouldLoudNotification
        }
        set (newShouldLoudNotification) {
            guard newShouldLoudNotification != storedShouldLoudNotification else {
                return
            }
            storedShouldLoudNotification = newShouldLoudNotification
            AppDelegate.endpointLogger.notice("ENDPOINT Update shouldLoudNotification")
        }
    }

    static private var storedShouldShowTerminationAlert: Bool = true
    static var shouldShowTerminationAlert: Bool {
        get {
            return storedShouldShowTerminationAlert
        }
        set (newShouldShowTerminationAlert) {
            guard newShouldShowTerminationAlert != storedShouldShowTerminationAlert else {
                return
            }
            storedShouldShowTerminationAlert = newShouldShowTerminationAlert
            AppDelegate.endpointLogger.notice("ENDPOINT Update shouldShowTerminationAlert")
        }
    }

    static private var storedShouldShowReleaseNotes: Bool = true
    static var shouldShowReleaseNotes: Bool {
        get {
            return storedShouldShowReleaseNotes
        }
        set (newShouldShowReleaseNotes) {
            guard newShouldShowReleaseNotes != storedShouldShowReleaseNotes else {
                return
            }
            storedShouldShowReleaseNotes = newShouldShowReleaseNotes
            AppDelegate.endpointLogger.notice("ENDPOINT Update shouldShowReleaseNotes")
        }
    }

    static private var storedShouldFollowUp: Bool = false
    static var shouldFollowUp: Bool {
        get {
            return storedShouldFollowUp
        }
        set (newShouldFollowUp) {
            guard newShouldFollowUp != storedShouldFollowUp else {
                return
            }
            storedShouldFollowUp = newShouldFollowUp
            AppDelegate.endpointLogger.notice("ENDPOINT Update storedShouldFollowUp")
        }
    }

    static private var storedFollowUpDelay: TimeInterval = 5.0 * 60.0
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

enum AppearanceConstant {
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

    static private var storeReviewRequestDates: [Date] = [Date()]
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
}
