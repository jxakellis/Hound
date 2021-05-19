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
    
    static private func loadAVAudioSession(shouldDuck: Bool) throws{
        if shouldDuck == true {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
        }
        else {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        }
        
        try AVAudioSession.sharedInstance().setActive(true)
    }
    
    static func loadDefaultAudioPlayer(){
        let path = Bundle.main.path(forResource: "radar.wav", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            if AudioPlayer.sharedPlayer != nil {
                AudioPlayer.sharedPlayer.stop()
            }
            
            AudioPlayer.sharedPlayer = try AVAudioPlayer(contentsOf: url)
            AudioPlayer.sharedPlayer.numberOfLoops = -1
            AudioPlayer.sharedPlayer.volume = 1.0
            
            MPVolumeView.setVolume(1.0)
            
            try loadAVAudioSession(shouldDuck: true)
        } catch {
            NSLog("Audio Session error: \(error)")
        }
    }
    
    static func loadSilenceAudioPlayer(){
        let path = Bundle.main.path(forResource: "silence.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            if AudioPlayer.sharedPlayer != nil {
                AudioPlayer.sharedPlayer.stop()
            }
            
            AudioPlayer.sharedPlayer = try AVAudioPlayer(contentsOf: url)
            AudioPlayer.sharedPlayer.numberOfLoops = -1
            try loadAVAudioSession(shouldDuck: false)
        } catch {
            NSLog("Audio Session error: \(error)")
        }
    }
    
    static func loadAudio(forAudioPath audioPath: String, atVolume volume: Float?){
        let path = Bundle.main.path(forResource: audioPath, ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            if AudioPlayer.sharedPlayer != nil {
                AudioPlayer.sharedPlayer.stop()
            }
            
            AudioPlayer.sharedPlayer = try AVAudioPlayer(contentsOf: url)
            AudioPlayer.sharedPlayer.numberOfLoops = -1
            if volume != nil {
                AudioPlayer.sharedPlayer.volume = volume!
                MPVolumeView.setVolume(volume!)
            }
            try loadAVAudioSession(shouldDuck: true)
        } catch {
            NSLog("Audio Session error: \(error)")
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
