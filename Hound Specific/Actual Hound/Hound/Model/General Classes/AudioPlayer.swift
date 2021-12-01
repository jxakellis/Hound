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
    
    ///Sets up the audio player to be of the right type. isLoud true means it will overtake others and be as loud as possible. isLoud false means it will be in the background and try to be incognito
    static private func loadAVAudioSession(isLoud: Bool) throws{
        if isLoud == true {
            
                //duck others isn't optimal. It makes it so our audio mixes with others but is louder than them. Want to stop their audio completely.
                //try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
            do {
                NSLog("Trying loud AVAudioSession")
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
                NSLog("Success loud AVAudioSession")
            }
            catch {
                NSLog("Trying backup loud AVAudioSession")
                try AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                NSLog("Success backup loud AVAudioSession")
            }
               // try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [ .defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
        }
        else {
            NSLog("Trying quiet AVAudioSession")
            try! AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            NSLog("Success quiet AVAudioSession")
        }
        
        try AVAudioSession.sharedInstance().setActive(true)
    }
    
    static func playLoudNotificationAudio(){
         DispatchQueue.global().async {
             NSLog("playLoudNotificationAudio")
             let path = Bundle.main.path(forResource: "\(NotificationConstant.notificationSound.rawValue.lowercased())", ofType: "mp3")!
             let url = URL(fileURLWithPath: path)
             
             do {
                 stopAudio()
                 
                 AudioPlayer.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                 AudioPlayer.sharedPlayer.numberOfLoops = -1
                 AudioPlayer.sharedPlayer.volume = 1.0
                 
                 MPVolumeView.setVolume(1.0)
                 
                 try loadAVAudioSession(isLoud: true)
                 
                 AudioPlayer.sharedPlayer.play()
                 
                
             } catch {
                 NSLog("Audio Session error: \(error)")
             }
         }
         
        
    }
    
    static func playSilenceAudio(){
        DispatchQueue.global().async {
            NSLog("playSilenceAudio")
            let path = Bundle.main.path(forResource: "silence", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                stopAudio()
                
                AudioPlayer.sharedPlayer = try! AVAudioPlayer(contentsOf: url)
                AudioPlayer.sharedPlayer.numberOfLoops = -1
                AudioPlayer.sharedPlayer.volume = 0
                
                try loadAVAudioSession(isLoud: false)
                
                AudioPlayer.sharedPlayer.play()
                
            } catch {
                NSLog("Audio Session error: \(error)")
            }

        }
    }
    
    static func playAudio(forAudioPath audioPath: String, isLoud: Bool){
        DispatchQueue.global().async {
            NSLog("playAudio: \(audioPath)")
            let path = Bundle.main.path(forResource: audioPath, ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                stopAudio()
                
                AudioPlayer.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioPlayer.sharedPlayer.numberOfLoops = -1
                AudioPlayer.sharedPlayer.volume = 1.0
                
                if isLoud == true {
                    MPVolumeView.setVolume(1.0)
                }
                
                try loadAVAudioSession(isLoud: isLoud)
                
                AudioPlayer.sharedPlayer.play()
            } catch {
                NSLog("Audio Session error: \(error)")
            }
        }
    }
    
    static func stopAudio(){
        DispatchQueue.global().async {
            //NSLog("stopAudio")
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
