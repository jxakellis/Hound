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
    
    static func performSegueOnceInWindowHierarchy(segueIdentifier: String, viewController: UIViewController) {
        
        waitLoop()
        
        func waitLoop () {
            if viewController.isViewLoaded && viewController.view.window != nil {
                    viewController.performSegue(withIdentifier: segueIdentifier, sender: viewController)
            }
            else {
                AppDelegate.generalLogger.warning("waitloop for performSegueOnceInWindowHierarchy")
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    waitLoop()
                }
            }
        }
    }

    /// Checks to see if the user is eligible for a notification to review Hound and if so presents the notification
    static func checkForReview() {
        // slight delay so it pops once some things are done
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
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
    
    /// Displays a message about not terminating the app if that setting is enabled and the user terminated the app
    static func checkForTermination(forDogManager dogManager: DogManager) {
        
        // TO DO bug with this. If a user with notifications enabled, a dog, and an enabled reminder reinstalls the app, then this prompt will trigger. Figure out way that a user which is reinstalling is not prompted (for their first load)
        
        if  UIApplication.previousAppBuild != nil && UIApplication.previousAppBuild! == UIApplication.appBuild && LocalConfiguration.isShowTerminationAlert == true {
            
            AppDelegate.generalLogger.notice("App has not updated")
            
            // sharedPlayer nil indicates the background silence is absent
            // From there we perform checks to make sure the background silence should have been there
            // If those check pass, it means the background silence's absense is due to the app terminating
            if AudioManager.sharedPlayer == nil && UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotification && dogManager.hasEnabledReminder && !UserConfiguration.isPaused {
                
                AppDelegate.generalLogger.notice("Showing Termionation Alert")
                let terminationAlertController = GeneralUIAlertController(title: "Oops, you may have terminated Hound", message: "Your notifications won't ring properly if the app isn't running.", preferredStyle: .alert)
                let understandAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                let stopAlertAction = UIAlertAction(title: "Don't Show Again", style: .default) { _ in
                    LocalConfiguration.isShowTerminationAlert = false
                }
                
                terminationAlertController.addAction(understandAlertAction)
                terminationAlertController.addAction(stopAlertAction)
                AlertManager.enqueueAlertForPresentation(terminationAlertController)
            }
            
            /*
            do {
                if let decoded: Data = UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as? Data {
                    
                    let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: decoded)
                    unarchiver.requiresSecureCoding = false
                    let decodedDogManager: DogManager = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! DogManager
                    
                    // sharedPlayer nil indicates the background silence is absent
                    // From there we perform checks to make sure the background silence should have been there
                    // If those check pass, it means the background silence's absense is due to the app terminating
                    if AudioManager.sharedPlayer == nil && UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotification && decodedDogManager.hasEnabledReminder && !UserConfiguration.isPaused {
                        
                        AppDelegate.generalLogger.notice("Showing Termionation Alert")
                        let terminationAlertController = GeneralUIAlertController(title: "Oops, you may have terminated Hound", message: "Your notifications won't ring properly if the app isn't running.", preferredStyle: .alert)
                        let understandAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        let stopAlertAction = UIAlertAction(title: "Don't Show Again", style: .default) { _ in
                            LocalConfiguration.isShowTerminationAlert = false
                        }
                        
                        terminationAlertController.addAction(understandAlertAction)
                        terminationAlertController.addAction(stopAlertAction)
                        AlertManager.enqueueAlertForPresentation(terminationAlertController)
                    }
                    // }
                    
                }
                else {
                    AppDelegate.generalLogger.error("Failed to decode dogManager for termination checker")
                }
            }
            catch {
                AppDelegate.generalLogger.error("Failed to unarchive dogManager for termination checker \(error.localizedDescription)")
            }
             */
            
        }
    }
    
    /// Displays release notes about a new version to the user if they have that setting enabled and the app was updated to that new version
    static func checkForReleaseNotes() {
        if UIApplication.previousAppBuild != nil && UIApplication.previousAppBuild! != UIApplication.appBuild && LocalConfiguration.isShowReleaseNotes == true {
            AppDelegate.generalLogger.notice("Showing Release Notes")
            var message: String?
            
            switch UIApplication.appBuild {
            case 3810:
                message = "--Improved redundancy when unarchiving data"
            default:
                message = nil
            }
            
            guard message != nil else {
                return
            }
            
            let updateAlertController = GeneralUIAlertController(title: "Release Notes For Hound \(UIApplication.appVersion ?? String(UIApplication.appBuild))", message: message, preferredStyle: .alert)
            let understandAlertAction = UIAlertAction(title: "Ok, sounds great!", style: .default, handler: nil)
            let stopAlertAction = UIAlertAction(title: "Don't show release notes again", style: .default) { _ in
                LocalConfiguration.isShowReleaseNotes = false
            }
            
            updateAlertController.addAction(understandAlertAction)
            updateAlertController.addAction(stopAlertAction)
            AlertManager.enqueueAlertForPresentation(updateAlertController)
        }
    }
    
    /// If a user has an account with notifications enabled, then notifcaiton authorized, enabled, etc. will all be true. If they reinstall, then notification authorizaed will be false but the rest will be the previous values. Therefore, we must check and either get notifcations authorized again or set them all to false.
    static func checkForNotificationSettingImbalance() {
        guard LocalConfiguration.isNotificationAuthorized == false else {
            return
        }
        
        // If isNotificationAuthorized is false, check if any of the settings that should false are true
        if UserConfiguration.isNotificationEnabled == true || UserConfiguration.isFollowUpEnabled == true || UserConfiguration.isLoudNotification == true {
            // we request authorization again.
            // if permission is granted, then everything is updated to true and its ok
            // if permission is denied, then everything is updated to false
            NotificationManager.requestNotificationAuthorization { _ in
                // everything already handled
            }
        }
    }
    
}
