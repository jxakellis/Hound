//
//  UserConfiguration.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

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

    // MARK: - Main

    /// Sets the UserConfiguration values equal to all the values found in the body. The key for the each body value must match the name of the UserConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: Any]) {
        if let isCompactView = body["isCompactView"] as? Bool {
            storedIsCompactView = isCompactView
        }
        if let darkModeStyleInt = body["darkModeStyle"] as? Int {
            if let darkModeStyle = UIUserInterfaceStyle(rawValue: darkModeStyleInt) {
                storedDarkModeStyle = darkModeStyle
            }
        }
        if let snoozeLength = body["snoozeLength"] as? TimeInterval {
            storedSnoozeLength = snoozeLength
        }
        if let isPaused = body["isPaused"] as? Bool {
            storedIsPaused = isPaused
        }
        if let isNotificationAuthorized = body["isNotificationAuthorized"] as? Bool {
            storedIsNotificationAuthorized = isNotificationAuthorized
        }
        if let isNotificationEnabled = body["isNotificationEnabled"] as? Bool {
            storedIsNotificationEnabled = isNotificationEnabled
        }
        if let isLoudNotification = body["isLoudNotification"] as? Bool {
            storedIsLoudNotification = isLoudNotification
        }
        if let isFollowUpEnabled = body["isFollowUpEnabled"] as? Bool {
            storedIsFollowUpEnabled = isFollowUpEnabled
        }
        if let followUpDelay = body["followUpDelay"] as? TimeInterval {
            storedFollowUpDelay = followUpDelay
        }
        if let notificationSoundString = body["notificationSound"] as? String {
            if let notificationSound = NotificationSound(rawValue: notificationSoundString) {
                storedNotificationSound = notificationSound
            }
        }
    }

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
