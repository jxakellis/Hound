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
    
    override func viewDidDisappear(_ animated: Bool) {
        AlertPresenter.shared.viewDidComplete()
    }
    
    
}

class AlarmUIAlertController: GeneralUIAlertController {
    
    private var shouldVibrate = true
    private func loopVibrate(){
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
        guard NotificationConstant.isNotificationEnabled && NotificationConstant.shouldLoudNotification else {
            return
        }
            AppDelegate.lifeCycleLogger.notice("AlarmUIAlertController will appear")
                self.loopVibrate()
                AudioPlayer.playLoudNotificationAudio()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //DispatchQueue.global().async{
            AppDelegate.lifeCycleLogger.notice("AlarmUIAlertController will disappear")
            self.shouldVibrate = false
            
            AudioPlayer.stopAudio()
            
       // }
    }
}

