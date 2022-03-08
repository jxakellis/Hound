//
//  Utils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import CallKit
import Foundation
import UIKit
import StoreKit

class Utils {

    static func willCreateFollowUpUNUserNotification(dogName: String, reminder: Reminder) {

        guard reminder.executionDate != nil else {
            AppDelegate.generalLogger.fault("willCreateFollowUpUNUserNotification executionDate nil")
            return
        }
        // let reminder = try! MainTabBarViewController.staticDogManager.findDog(forDogId: dogName).dogReminders.findReminder(forReminderId: reminderUUID)

         let content = UNMutableNotificationContent()
        content.interruptionLevel = .timeSensitive

         content.title = "Follow up notification for \(dogName)!"

        content.body = "It's been \(String.convertToReadable(fromTimeInterval: UserConfiguration.followUpDelay, capitalizeLetters: false)), give your dog a helping hand with \(reminder.displayTypeName)!"

        if UserConfiguration.isLoudNotification == false {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(UserConfiguration.notificationSound.rawValue.lowercased())30.wav"))
        }

        let executionDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.executionDate! + UserConfiguration.followUpDelay)

        let trigger = UNCalendarNotificationTrigger(dateMatching: executionDateComponents, repeats: false)

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                AppDelegate.generalLogger.error("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }

    static func willCreateUNUserNotification(dogName: String, reminder: Reminder) {

        guard reminder.executionDate != nil else {
            AppDelegate.generalLogger.fault("willCreateUNUserNotification executionDate nil")
            return
        }
        // let reminder = try! MainTabBarViewController.staticDogManager.findDog(forDogId: dogName).dogReminders.findReminder(forReminderId: reminderUUID)
         let content = UNMutableNotificationContent()
        content.interruptionLevel = .timeSensitive

         content.title = "Reminder for \(dogName)!"

        content.body = reminder.displayTypeName

        if UserConfiguration.isLoudNotification == false {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(UserConfiguration.notificationSound.rawValue.lowercased())30.wav"))
        }

        let executionDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.executionDate!)

        let trigger = UNCalendarNotificationTrigger(dateMatching: executionDateComponents, repeats: false)

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                AppDelegate.generalLogger.error("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }

    /// Checks to see if the user is eligible for a notification to review Hound and if so presents the notification
    static func checkForReview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25, execute: {
                func requestReview() {
                    if let window = UIApplication.keyWindow?.windowScene {
                        AppDelegate.generalLogger.notice("Asking user to review Hound")
                        SKStoreReviewController.requestReview(in: window)
                        LocalConfiguration.reviewRequestDates.append(Date())
                    }
                    else {
                        AppDelegate.generalLogger.fault("checkForReview unable to fire, window not established")
                    }
                }

                switch LocalConfiguration.reviewRequestDates.count {
                // never reviewed before (first date is just put as a placeholder, not actual ask date)
                case 1:
                    // been a 5 days since installed app or got update to add review feature
                    if LocalConfiguration.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*5) {
                        requestReview()
                    }
                    else {
                        // AppDelegate.generalLogger.notice("Too soon to ask user for another review \nCount: \(LocalConfiguration.reviewRequestDates.count)\nCurrent date: \(Date())\nLast date \(LocalConfiguration.reviewRequestDates.last!.description)\nCurrent distance \(LocalConfiguration.reviewRequestDates.last!.distance(to: Date()))\nDistance left \((60*60*24*5)-LocalConfiguration.reviewRequestDates.last!.distance(to: Date()))")
                    }
                // been asked once before
                case 2:
                    // been 10 days since last ask (15 days since beginning)
                    if LocalConfiguration.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*10) {
                        requestReview()
                    }
                    else {
                        // AppDelegate.generalLogger.notice("Too soon to ask user for another review - count: \(LocalConfiguration.reviewRequestDates.count) - current date: \(Date()) - last date \(LocalConfiguration.reviewRequestDates.last!.description) - current distance \(LocalConfiguration.reviewRequestDates.last!.distance(to: Date())) - distance left \((60*60*24*10)-LocalConfiguration.reviewRequestDates.last!.distance(to: Date()))")
                    }
                // been asked twice before
                case 3:
                    // been 20 days since last ask (35 days total)
                    if LocalConfiguration.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*20) {
                        requestReview()
                    }
                    else {
                        // AppDelegate.generalLogger.notice("Too soon to ask user for another review - count: \(LocalConfiguration.reviewRequestDates.count) - current date: \(Date()) - last date \(LocalConfiguration.reviewRequestDates.last!.description) - current distance \(LocalConfiguration.reviewRequestDates.last!.distance(to: Date())) - distance left \((60*60*24*20)-LocalConfiguration.reviewRequestDates.last!.distance(to: Date()))")
                    }
                // been asked three times before
                case 4:
                    // been 40 days since last ask (75 days total)
                    if LocalConfiguration.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*40) {
                        requestReview()
                    }
                    else {
                        // AppDelegate.generalLogger.notice("Too soon to ask user for another review - count: \(LocalConfiguration.reviewRequestDates.count) - current date: \(Date()) - last date \(LocalConfiguration.reviewRequestDates.last!.description) - current distance \(LocalConfiguration.reviewRequestDates.last!.distance(to: Date())) - distance left \((60*60*24*40)-LocalConfiguration.reviewRequestDates.last!.distance(to: Date()))")
                    }
                    // out of asks
                case 5:
                    AppDelegate.generalLogger.notice("Out of review requests")
                default:
                    AppDelegate.generalLogger.notice("Fall through when asking user to review Hound")

                }

        })

    }
}
