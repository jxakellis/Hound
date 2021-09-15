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
        print("alert will appear")
        guard NotificationConstant.isNotificationEnabled && NotificationConstant.shouldLoudNotification else {
            return
        }
        DispatchQueue.global().async{
            print("willAppear loadDefaultAudioPlayer")
                self.loopVibrate()
                AudioPlayer.loadDefaultAudioPlayer()
                AudioPlayer.sharedPlayer.play()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.global().async{
            print("disappear, halting")
            self.shouldVibrate = false
            if AudioPlayer.sharedPlayer != nil {
                AudioPlayer.sharedPlayer.stop()
            }
            
        }
    }
}


