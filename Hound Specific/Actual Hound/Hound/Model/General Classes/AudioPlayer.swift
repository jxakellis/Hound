//
//  AudioPlayer.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import MediaPlayer

class AudioPlayer {
    
    static var sharedPlayer: AVAudioPlayer!
    
    ///Sets up the audio player to be of the right type. shouldDuck true means it will overtake others and be as loud as possible. shouldDuck false means it will be in the background and try to be incognito
    static private func loadAVAudioSession(shouldDuck: Bool) throws{
        if shouldDuck == true {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
        }
        else {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        }
        
        try AVAudioSession.sharedInstance().setActive(true)
    }
    
    static func playLoudNotificationAudio(){
        DispatchQueue.global().async {
            print("playLoudNotificationAudio")
            let path = Bundle.main.path(forResource: "\(NotificationConstant.notificationSound.rawValue.lowercased()).wav", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                stopAudio()
                
                AudioPlayer.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioPlayer.sharedPlayer.numberOfLoops = -1
                AudioPlayer.sharedPlayer.volume = 1.0
                
                MPVolumeView.setVolume(1.0)
                
                try loadAVAudioSession(shouldDuck: true)
                
                AudioPlayer.sharedPlayer.play()
            } catch {
                NSLog("Audio Session error: \(error)")
            }
        }
    }
    
    static func playSilenceAudio(){
        DispatchQueue.global().async {
            print("playSilenceAudio")
            let path = Bundle.main.path(forResource: "silence.wav", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                stopAudio()
                
                AudioPlayer.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioPlayer.sharedPlayer.numberOfLoops = -1
                AudioPlayer.sharedPlayer.volume = 0
                
                try loadAVAudioSession(shouldDuck: false)
                
                AudioPlayer.sharedPlayer.play()
            } catch {
                NSLog("Audio Session error: \(error)")
            }

        }
    }
    
    static func playAudio(forAudioPath audioPath: String, atVolume volume: Float?){
        DispatchQueue.global().async {
            print("playAudio: \(audioPath)")
            let path = Bundle.main.path(forResource: audioPath, ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                stopAudio()
                
                AudioPlayer.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioPlayer.sharedPlayer.numberOfLoops = -1
                if volume != nil {
                    AudioPlayer.sharedPlayer.volume = volume!
                    MPVolumeView.setVolume(volume!)
                }
                try loadAVAudioSession(shouldDuck: true)
                
                AudioPlayer.sharedPlayer.play()
            } catch {
                NSLog("Audio Session error: \(error)")
            }
        }
    }
    
    static func stopAudio(){
        DispatchQueue.global().async {
            print("stopAudio")
            if AudioPlayer.sharedPlayer != nil {
                AudioPlayer.sharedPlayer.stop()
            }
        }
        
    }
    
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        DispatchQueue.main.async {
            let volumeView = MPVolumeView()
            let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                slider?.value = volume
            }
        }
    }
}
