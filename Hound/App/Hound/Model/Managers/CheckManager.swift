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

    /// Checks to see if the user is eligible for a notification to asking them to review Hound and if so presents the notification
    static func checkForReview() {
        // slight delay so it pops once some things are done
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            // Open Apple's built in review page. Simple a pop-up that allows user to select number of starts and submit
            func requestUserToRate() {
                guard let window = UIApplication.keyWindow?.windowScene else {
                    AppDelegate.generalLogger.error("checkForReview unable to fire, window not established")
                    return
                }
                
                AppDelegate.generalLogger.notice("Asking user to rate Hound")
                SKStoreReviewController.requestReview(in: window)
                LocalConfiguration.rateReviewRequestedDates.append(Date())
                PersistenceManager.persistRateReviewRequestedDates()
            }
            // Open web page where the user can write a review on Hound
            func requestUserToWriteReview() {
                guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1564604025?action=write-review")
                else { return }
                AppDelegate.generalLogger.notice("Asking user to write a review Hound")
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                LocalConfiguration.writeReviewRequestedDates.append(Date())
            }
            
            func askUserToReview() {
                let requestReviewController = GeneralUIAlertController(title: "Are you enjoying Hound?", message: "Your feedback helps support future development and improvements!", preferredStyle: .alert)
                
                var isEligibleForRateReviewRequest = false
                // You can request a maximum of three reviews through StoreKit a year. If < 3, then the user is eligible to be asked.
                if LocalConfiguration.rateReviewRequestedDates.count < 3 {
                    isEligibleForRateReviewRequest = true
                }
                else {
                    // User has been asked >= 3 times through StoreKit for review
                    // The last three times that the user was requested to review Hound.
                    // Must cast array slice to array. Doesn't give compile error if you don't but [0] will crash below if slicing an array that isn't equal to suffix value
                    let lastThreeDates = Array(LocalConfiguration.rateReviewRequestedDates.suffix(3))
                    
                    // If the first element in this array is > 1 year ago, then we can give the option to use the built in app review method. This is because we aren't exceeding our 3 a year limit anymore
                    
                    let timeWaitedSinceLastRate = lastThreeDates[0].distance(to: Date())
                    let timeNeededToWaitForNextRate = 367.0 * 24 * 60 * 60
                    if  timeWaitedSinceLastRate > timeNeededToWaitForNextRate {
                        isEligibleForRateReviewRequest = true
                    }
                }
                
                // If we have two buttons: "Absolutely, I'll write a review!" & "Yes, I'll rate it!"
                // If we have one button: "Yes, I'll write a review!"
                requestReviewController.addAction(UIAlertAction(title: "\(isEligibleForRateReviewRequest ? "Absolutely" : "Yes"), I'll write a review!", style: .default, handler: { _ in
                    requestUserToWriteReview()
                }))
                
                if isEligibleForRateReviewRequest {
                    requestReviewController.addAction(UIAlertAction(title: "Yes, I'll rate it!", style: .default, handler: { _ in
                        requestUserToRate()
                    }))
                }
                
                requestReviewController.addAction(UIAlertAction(title: "Not Now", style: .cancel))
                
                AlertManager.enqueueAlertForPresentation(requestReviewController)
                LocalConfiguration.userAskedToReviewHoundDates.append(Date())
            }
            
            guard let lastUserAskedToReviewHoundDate = LocalConfiguration.userAskedToReviewHoundDates.last else {
                return
            }
            
            // We want to ask the user in increasing intervals of time for a review on Hound. The function below increases the number of days between reviews and help ensure that reviews get asked at different times of day.
            var numberOfDaysToWaitForNextReview: Double {
                let count = LocalConfiguration.userAskedToReviewHoundDates.count
                guard count >= 5 else {
                    // Count == 1: Been asked zero times before (first Date() is a placeholder). We ask 9.2 days after the inital install.
                    // Count == 2: asked one time; 18.4 days since last ask; 27.6 days since beginning
                    // Count == 3: asked two times; 27.6 days since last ask; 55.2 since beginning
                    // Count == 4: asked three times; 36.8 days since last ask; 92.0 since beginning
                    return Double(count) * 9.2
                }
                
                // Count == 5: asked four times; 45.0 days since last ask; 182.2 since beginning
                // Count == 6: asked five times; 45.0 days; 182.2
                // Count == 7: asked six times; 45.0 days; 227.6
                // Count == 8: asked seven times; 45.0 days; 273.2
                // Count == 9: asked eight times; 45.0 days; 319.0
                // Count == 10: asked nine times; 45.0 days; 364.0
                return Double(45.0 + Double(count % 5) * 0.2)
            }
            
            let timeWaitedSinceLastAsk = lastUserAskedToReviewHoundDate.distance(to: Date())
            let timeNeededToWaitForNextAsk = numberOfDaysToWaitForNextReview * 24 * 60 * 60
            
            if timeWaitedSinceLastAsk > timeNeededToWaitForNextAsk {
                askUserToReview()
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
