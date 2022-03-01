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

class Utils
{
    
    
    static func willCreateFollowUpUNUserNotification(dogName: String, reminder: Reminder){
        
        guard reminder.executionDate != nil else {
            AppDelegate.generalLogger.fault("willCreateFollowUpUNUserNotification executionDate nil")
            return
        }
        //let reminder = try! MainTabBarViewController.staticDogManager.findDog(forName: dogName).dogReminders.findReminder(forUUID: reminderUUID)
        
         let content = UNMutableNotificationContent()
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        } else {
            // Fallback on earlier versions
        }
        
         content.title = "Follow up notification for \(dogName)!"
        
        content.body = "It's been \(String.convertToReadable(interperateTimeInterval: NotificationConstant.followUpDelay, capitalizeLetters: false)), give your dog a helping hand with \(reminder.displayTypeName)!"
        
        if NotificationConstant.shouldLoudNotification == false {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(NotificationConstant.notificationSound.rawValue.lowercased())30.wav"))
        }
       
        let executionDateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: reminder.executionDate! + NotificationConstant.followUpDelay)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: executionDateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if (error != nil){
                AppDelegate.generalLogger.error("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }
    
    static func willCreateUNUserNotification(dogName: String, reminder: Reminder){
    
        guard reminder.executionDate != nil else {
            AppDelegate.generalLogger.fault("willCreateUNUserNotification executionDate nil")
            return
        }
        //let reminder = try! MainTabBarViewController.staticDogManager.findDog(forName: dogName).dogReminders.findReminder(forUUID: reminderUUID)
         let content = UNMutableNotificationContent()
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        } else {
            // Fallback on earlier versions
        }
        
         content.title = "Reminder for \(dogName)!"
        
        content.body = reminder.displayTypeName
        
        if NotificationConstant.shouldLoudNotification == false {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(NotificationConstant.notificationSound.rawValue.lowercased())30.wav"))
        }
        
        let executionDateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: reminder.executionDate!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: executionDateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if (error != nil){
                AppDelegate.generalLogger.error("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }
    
    ///Checks to see if the user is eligible for a notification to review Hound and if so presents the notification
    static func checkForReview(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25, execute: {
                func requestReview(){
                    if let window = UIApplication.shared.keyWindow?.windowScene {
                        AppDelegate.generalLogger.notice("Asking user to review Hound")
                        SKStoreReviewController.requestReview(in: window)
                        AppearanceConstant.reviewRequestDates.append(Date())
                    }
                    else {
                        AppDelegate.generalLogger.fault("checkForReview unable to fire, window not established")
                    }
                }
                
                switch AppearanceConstant.reviewRequestDates.count {
                //never reviewed before (first date is just put as a placeholder, not actual ask date)
                case 1:
                    //been a 5 days since installed app or got update to add review feature
                    if AppearanceConstant.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*5){
                        requestReview()
                    }
                    else {
                        AppDelegate.generalLogger.notice("Too soon to ask user for another review \nCount: \(AppearanceConstant.reviewRequestDates.count)\nCurrent date: \(Date())\nLast date \(AppearanceConstant.reviewRequestDates.last!.description)\nCurrent distance \(AppearanceConstant.reviewRequestDates.last!.distance(to: Date()))\nDistance left \((60*60*24*5)-AppearanceConstant.reviewRequestDates.last!.distance(to: Date()))")
                    }
                //been asked once before
                case 2:
                    //been 10 days since last ask (15 days since beginning)
                    if AppearanceConstant.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*10){
                        requestReview()
                    }
                    else {
                        AppDelegate.generalLogger.notice("Too soon to ask user for another review - count: \(AppearanceConstant.reviewRequestDates.count) - current date: \(Date()) - last date \(AppearanceConstant.reviewRequestDates.last!.description) - current distance \(AppearanceConstant.reviewRequestDates.last!.distance(to: Date())) - distance left \((60*60*24*10)-AppearanceConstant.reviewRequestDates.last!.distance(to: Date()))")
                    }
                //been asked twice before
                case 3:
                    //been 20 days since last ask (35 days total)
                    if AppearanceConstant.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*20){
                        requestReview()
                    }
                    else {
                        AppDelegate.generalLogger.notice("Too soon to ask user for another review - count: \(AppearanceConstant.reviewRequestDates.count) - current date: \(Date()) - last date \(AppearanceConstant.reviewRequestDates.last!.description) - current distance \(AppearanceConstant.reviewRequestDates.last!.distance(to: Date())) - distance left \((60*60*24*20)-AppearanceConstant.reviewRequestDates.last!.distance(to: Date()))")
                    }
                //been asked three times before
                case 4:
                    //been 40 days since last ask (75 days total)
                    if AppearanceConstant.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*40){
                        requestReview()
                    }
                    else {
                        AppDelegate.generalLogger.notice("Too soon to ask user for another review - count: \(AppearanceConstant.reviewRequestDates.count) - current date: \(Date()) - last date \(AppearanceConstant.reviewRequestDates.last!.description) - current distance \(AppearanceConstant.reviewRequestDates.last!.distance(to: Date())) - distance left \((60*60*24*40)-AppearanceConstant.reviewRequestDates.last!.distance(to: Date()))")
                    }
                    //out of asks
                case 5:
                    AppDelegate.generalLogger.notice("Out of review requests")
                default:
                    AppDelegate.generalLogger.notice("Fall through when asking user to review Hound")
                    
                }
            
        })
        
    }
}





