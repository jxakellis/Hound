//
//  CustomClasses.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import MediaPlayer
import UIKit

class GeneralAlertController: UIAlertController {
    override func viewDidDisappear(_ animated: Bool) {
        AlertPresenter.shared.viewDidComplete()
    }
}

class AlarmAlertController: GeneralAlertController {
    
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
        DispatchQueue.global().async{
            print("willAppear")
                self.loopVibrate()
                AudioPlayer.loadDefaultAudioPlayer()
                AudioPlayer.sharedPlayer.play()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard NotificationConstant.isNotificationEnabled && NotificationConstant.shouldLoudNotification else {
            return
        }
        DispatchQueue.global().async{
            print("disappear")
            self.shouldVibrate = false
            AudioPlayer.sharedPlayer.stop()
        }
    }
}


