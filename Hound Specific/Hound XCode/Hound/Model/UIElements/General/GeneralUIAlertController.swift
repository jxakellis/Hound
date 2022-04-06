//
//  CustomClasses.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import MediaPlayer
import UIKit

class GeneralUIAlertController: UIAlertController {
    
    /// This is simply a tag attached to the alertController. This helps keep track of different types alert controller and remove duplicates
    var tag: Int = 0
    
    override func viewDidDisappear(_ animated: Bool) {
        AlertManager.shared.alertDidComplete()
    }
    
}

class AlarmUIAlertController: GeneralUIAlertController {
    
    private var shouldVibrate = true
    private func loopVibrate() {
        if shouldVibrate == true {
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                    self.loopVibrate()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotification else {
            return
        }
        AppDelegate.lifeCycleLogger.notice("AlarmUIAlertController will appear")
        self.loopVibrate()
        AudioManager.playLoudNotificationAudio()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.lifeCycleLogger.notice("AlarmUIAlertController will disappear")
        self.shouldVibrate = false
        
        AudioManager.stopAudio()
    }
}
