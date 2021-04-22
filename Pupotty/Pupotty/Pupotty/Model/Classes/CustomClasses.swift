//
//  CustomClasses.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class Sender {
    
    let origin: AnyObject?
    var localized: AnyObject?
    
    init(origin: AnyObject, localized: AnyObject){
        if origin is Sender{
            let castedSender = origin as! Sender
            self.origin = castedSender.origin
        }
        else {
            self.origin = origin
        }
        if localized is Sender {
            fatalError("localized cannot be sender")
        }
        else{
            self.localized = localized
        }
    }
    
}


class GeneralAlertController: UIAlertController {
    override func viewDidDisappear(_ animated: Bool) {
        AlertPresenter.shared.viewDidComplete()
    }
}

class AlarmAlertController: GeneralAlertController {
    
    private var audioPlayer: AVAudioPlayer!
    
    private func loadAlarmSound(){
        let path = Bundle.main.path(forResource: "radar_ios_7.wav", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            //create your audioPlayer in your parent class as a property
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = .max
            
        } catch {
            print("couldn't load the file")
        }
    }
    
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
        DispatchQueue.global().async{
            self.loadAlarmSound()
            self.loopVibrate()
            self.audioPlayer.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global().async{
            self.audioPlayer.stop()
            self.shouldVibrate = false
        }
    }
}

class ScaledButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scaleSymbolPontSize()
    }
    
    private func scaleSymbolPontSize(){
        var smallestDimension: CGFloat {
            if self.frame.width <= self.frame.height {
                return self.frame.width
            }
            else {
                return self.frame.height
            }
        }
        
        if currentImage != nil && currentImage!.isSymbolImage == true {
            DispatchQueue.main.async {
                super.setImage(self.currentImage?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension)), for: .normal)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.scaleSymbolPontSize()
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        self.scaleSymbolPontSize()
    }
    
}

class CustomLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.adjustsFontSizeToFitWidth = true
    }
    
}
