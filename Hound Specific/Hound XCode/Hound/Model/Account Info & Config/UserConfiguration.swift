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
    
    // MARK: - Ordered List
    // isCompactView
    // interfaceStyle
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
        if let logsInterfaceScaleString = body[ServerDefaultKeys.logsInterfaceScale.rawValue] as? String, let logsInterfaceScale = LogsInterfaceScale(rawValue: logsInterfaceScaleString) {
            self.logsInterfaceScale = logsInterfaceScale
        }
        if let remindersInterfaceScaleString = body[ServerDefaultKeys.remindersInterfaceScale.rawValue] as? String, let remindersInterfaceScale = RemindersInterfaceScale(rawValue: remindersInterfaceScaleString) {
            self.remindersInterfaceScale = remindersInterfaceScale
        }
        if let interfaceStyleInt = body[ServerDefaultKeys.interfaceStyle.rawValue] as? Int, let interfaceStyle = UIUserInterfaceStyle(rawValue: interfaceStyleInt) {
            self.interfaceStyle = interfaceStyle
        }
        if let snoozeLength = body[ServerDefaultKeys.snoozeLength.rawValue] as? TimeInterval {
            self.snoozeLength = snoozeLength
        }
        if let isNotificationEnabled = body[ServerDefaultKeys.isNotificationEnabled.rawValue] as? Bool {
            self.isNotificationEnabled = isNotificationEnabled
        }
        if let isLoudNotification = body[ServerDefaultKeys.isLoudNotification.rawValue] as? Bool {
            self.isLoudNotification = isLoudNotification
        }
        if let isFollowUpEnabled = body[ServerDefaultKeys.isFollowUpEnabled.rawValue] as? Bool {
            self.isFollowUpEnabled = isFollowUpEnabled
        }
        if let followUpDelay = body[ServerDefaultKeys.followUpDelay.rawValue] as? TimeInterval {
            self.followUpDelay = followUpDelay
        }
        if let notificationSoundString = body[ServerDefaultKeys.notificationSound.rawValue] as? String, let notificationSound = NotificationSound(rawValue: notificationSoundString) {
            self.notificationSound = notificationSound
        }
    }
    
    // MARK: - In-App Appearance Related
    
    static var logsInterfaceScale: LogsInterfaceScale = .medium
    
    static var remindersInterfaceScale: RemindersInterfaceScale = .medium
    
    static var interfaceStyle: UIUserInterfaceStyle = .unspecified
    
    // MARK: - Alarm Timing Related
    
    static var snoozeLength: TimeInterval = TimeInterval(60*5)
    
    // MARK: - iOS Notification Related
    
    /// This should be stored on the server as it is important to only send notifications to devices that can use them. This will always be overriden by the user upon reinstall if its state is different in that new install.
    static var isNotificationEnabled: Bool = false
    
    /// Determines if the app should send the user loud notifications. Loud notification bypass most iPhone settings to play at max volume (Do Not Disturb, ringer off, volume off...)
    static var isLoudNotification: Bool = false
    
    /// Sends a secondary, follow up notifcation if the first, primary notification about a reminder's alarm is not addressed.
    static var isFollowUpEnabled: Bool = false
    
    /// The delay between the inital, primary notifcation of a reminder and a seconary, followup notification of a reminder.
    static var followUpDelay: TimeInterval = 5.0 * 60.0
    
    /// Sound a notification will play
    static var notificationSound: NotificationSound = NotificationSound.radar
    
}
