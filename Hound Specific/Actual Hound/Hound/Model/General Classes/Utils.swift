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

class Utils
{
    ///Default sender used to present, this is necessary if an alert to be shown is called from a non UIViewController class as that is not in the view heirarchy and physically cannot present a view, so this is used instead.
    static var presenter: UIViewController? = nil
    
    
    ///Function used to present alertController, Utils.presenter is a default sender if non is specified, title and message are specifiable but other information is set to defaults.
    static func willShowAlert(title: String, message: String?)
    {
        var trimmedMessage: String? = message
        
        if message?.trimmingCharacters(in: .whitespaces) == ""{
            trimmedMessage = nil
        }
        
        let alertController = GeneralUIAlertController(
            title: title,
            message: trimmedMessage,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
    }
    
    static func willCreateFollowUpUNUserNotification(dogName: String, reminderUUID: String, executionDate: Date){
        let reminder = try! MainTabBarViewController.staticDogManager.findDog(dogName: dogName).dogReminders.findReminder(forUUID: reminderUUID)
        
         let content = UNMutableNotificationContent()
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        } else {
            // Fallback on earlier versions
        }
        
         content.title = "Follow up notification for \(dogName)!"
        
        content.body = "It's been \(String.convertToReadable(interperateTimeInterval: NotificationConstant.followUpDelay, capitalizeLetters: false)), give your dog a helping hand with \(reminder.displayTypeName)!"
        
        if NotificationConstant.shouldLoudNotification == false {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "radar30Loop.wav"))
        }
       
        let executionDateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: executionDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: executionDateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if (error != nil){
                print("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }
    
    static func willCreateUNUserNotification(dogName: String, reminderUUID: String, executionDate: Date){
        let reminder = try! MainTabBarViewController.staticDogManager.findDog(dogName: dogName).dogReminders.findReminder(forUUID: reminderUUID)
         let content = UNMutableNotificationContent()
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        } else {
            // Fallback on earlier versions
        }
        
         content.title = "Reminder for \(dogName)!"
        
        content.body = reminder.displayTypeName
        
        if NotificationConstant.shouldLoudNotification == false {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "radar30Loop.wav"))
        }
        
        let executionDateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: executionDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: executionDateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if (error != nil){
                print("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }
    
    static func willCreateUNUserNotification(title: String, body: String?, date: Date){
        
         let content = UNMutableNotificationContent()
         content.title = title
        
        if body != nil {
            content.body = body!
        }
        
         //content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "radar30Loop.wav"))
        
        let executionDateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: executionDateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if (error != nil){
                print("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }
}





