//
//  AudioManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import MediaPlayer

class AudioManager {
    
    static var sharedPlayer: AVAudioPlayer!
    
    /// Sets up the audio player to be of the right type. isLoud true means it will overtake others and be as loud as possible. isLoud false means it will be in the background and try to be incognito
    static private func loadAVAudioSession(isLoud: Bool) throws {
        if isLoud == true {
            
            // duck others isn't optimal. It makes it so our audio mixes with others but is louder than them. Want to stop their audio completely.
            // try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
            do {
                AppDelegate.generalLogger.notice("Attempting to load loud AVAudioSession")
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
                AppDelegate.generalLogger.notice("Success in loading loud AVAudioSession")
            }
            catch {
                AppDelegate.generalLogger.notice("Attempting to load backup loud AVAudioSession")
                try AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                AppDelegate.generalLogger.notice("Success in loading backup loud AVAudioSession")
            }
            // try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [ .defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
        }
        else {
            AppDelegate.generalLogger.notice("Attempting to load quiet AVAudioSession")
            try! AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            AppDelegate.generalLogger.notice("Success in loading quiet AVAudioSession")
        }
        
        try AVAudioSession.sharedInstance().setActive(true)
    }
    
    static func playLoudNotificationAudio() {
        DispatchQueue.global().async {
            AppDelegate.generalLogger.notice("playLoudNotificationAudio")
            let path = Bundle.main.path(forResource: "\(UserConfiguration.notificationSound.rawValue.lowercased())", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                stopAudio()
                
                AudioManager.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioManager.sharedPlayer.numberOfLoops = -1
                AudioManager.sharedPlayer.volume = 1.0
                
                MPVolumeView.setVolume(1.0)
                
                try loadAVAudioSession(isLoud: true)
                
                AudioManager.sharedPlayer.play()
                
            }
            catch {
                AppDelegate.generalLogger.error("playLoudNotificationAudio error: \(error.localizedDescription)")
            }
        }
        
    }
    
    static func playSilenceAudio() {
        DispatchQueue.global().async {
            AppDelegate.generalLogger.notice("playSilenceAudio")
            let path = Bundle.main.path(forResource: "silence", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                stopAudio()
                
                AudioManager.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioManager.sharedPlayer.numberOfLoops = -1
                AudioManager.sharedPlayer.volume = 0
                
                try loadAVAudioSession(isLoud: false)
                
                AudioManager.sharedPlayer.play()
                
            }
            catch {
                AppDelegate.generalLogger.notice("playSilenceAudio error: \(error.localizedDescription)")
            }
            
        }
    }
    
    static func playAudio(forAudioPath audioPath: String, isLoud: Bool) {
        DispatchQueue.global().async {
            AppDelegate.generalLogger.notice("playAudio: \(audioPath)")
            let path = Bundle.main.path(forResource: audioPath, ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                stopAudio()
                
                AudioManager.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioManager.sharedPlayer.numberOfLoops = -1
                AudioManager.sharedPlayer.volume = 1.0
                
                if isLoud == true {
                    MPVolumeView.setVolume(1.0)
                }
                
                try loadAVAudioSession(isLoud: isLoud)
                
                AudioManager.sharedPlayer.play()
            }
            catch {
                AppDelegate.generalLogger.error("playAudio error: \(error.localizedDescription)")
            }
        }
    }
    
    static func stopAudio() {
        DispatchQueue.global().async {
            // AppDelegate.generalLogger.notice("stopAudio")
            if AudioManager.sharedPlayer != nil {
                AudioManager.sharedPlayer.stop()
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
