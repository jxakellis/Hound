//
//  CheckManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import CallKit
import StoreKit

enum CheckManager {

    /// Checks to see if the user is eligible for a notification to review Hound and if so presents the notification
    static func checkForReview() {
        // TO DO FUTURE add alert controller that asks if the user wants to review the app before attempting to show the alert controller
        // slight delay so it pops once some things are done
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            func requestReview() {
                guard let window = UIApplication.keyWindow?.windowScene else {
                    AppDelegate.generalLogger.error("checkForReview unable to fire, window not established")
                    return
                }
                
                AppDelegate.generalLogger.notice("Asking user to review Hound")
                SKStoreReviewController.requestReview(in: window)
                LocalConfiguration.reviewRequestDates.append(Date())
            }
            
            switch LocalConfiguration.reviewRequestDates.count {
                
            case 1:
                // never reviewed before (first date is just put as a placeholder, not actual ask date)
                // been a 5 days since installed app or got update to add review feature
                if LocalConfiguration.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*5) {
                    requestReview()
                }
                
            case 2:
                // been asked once before
                // been 10 days since last ask (15 days since beginning)
                if LocalConfiguration.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*10) {
                    requestReview()
                }
            case 3:
                // been asked twice before
                // been 20 days since last ask (35 days total)
                if LocalConfiguration.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*20) {
                    requestReview()
                }
            case 4:
                // been asked three times before
                // been 40 days since last ask (75 days total)
                if LocalConfiguration.reviewRequestDates.last!.distance(to: Date()) > (60*60*24*40) {
                    requestReview()
                }
            case 5:
                // out of asks
                AppDelegate.generalLogger.notice("Out of review requests")
            default:
                AppDelegate.generalLogger.notice("Fall through when asking user to review Hound")
                
            }
            
        })
        
    }
    
    /// Displays release notes about a new version to the user if they have that setting enabled and the app was updated to that new version
    static func checkForReleaseNotes() {
        // make sure this feature is enabled
        guard LocalConfiguration.shouldShowReleaseNotes == true else {
            return
        }
        // make sure the app had been opened before, we don't want to show the user release notes on their first launch
        guard UIApplication.previousAppBuild != nil else {
            return
        }
        
        // make sure the previousAppBuild and current appBuild are equal, indicating that the app was updated
        guard UIApplication.previousAppBuild! != UIApplication.appBuild else {
            return
        }
        
        // make sure we haven't shown the release notes for this version before. To do this, we check to see if our array of app builds that we showed release notes for contains the app build of the current version. If the array does not contain the current app build, then we haven't shown release notes for this new version and we are ok to proceed.
        guard LocalConfiguration.appBuildsWithReleaseNotesShown.contains(UIApplication.appBuild) == false else {
            return
        }
        
       AppDelegate.generalLogger.notice("Showing Release Notes")
            var message: String?
            
            switch UIApplication.appBuild {
            case 4000:
                message = "-- Cloud storage! Create your Hound account with the 'Sign In with Apple' feature and have all of your information saved to the Hound server.\n-- Family sharing! Create your own Hound family and have other users join it, allowing your logs, reminders, and notifications to all sync.\n-- Refined UI. Enjoy a smoother, more fleshed out UI experience with quality of life tweaks.\n-- Settings Revamp. Utilize the redesigned settings page to view more options in a cleaner way."
            default:
                message = nil
            }
            
            guard message != nil else {
                return
            }
            
            let updateAlertController = GeneralUIAlertController(title: "Release Notes For Hound \(UIApplication.appVersion ?? String(UIApplication.appBuild))", message: message, preferredStyle: .alert)
            let understandAlertAction = UIAlertAction(title: "Ok, sounds great!", style: .default, handler: nil)
            let stopAlertAction = UIAlertAction(title: "Don't show release notes again", style: .default) { _ in
                LocalConfiguration.shouldShowReleaseNotes = false
            }
            
            updateAlertController.addAction(understandAlertAction)
            updateAlertController.addAction(stopAlertAction)
            AlertManager.enqueueAlertForPresentation(updateAlertController)
            // we successfully showed the message, so store the build we showed it for
            LocalConfiguration.appBuildsWithReleaseNotesShown.append(UIApplication.appBuild)
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
            NotificationManager.requestNotificationAuthorization {
                // everything already handled
            }
        }
    }
    
}
