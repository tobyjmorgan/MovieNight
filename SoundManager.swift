//
//  SoundManager.swift
//  AmusementParkPart1
//
//  Created by redBred LLC on 11/16/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation
import AudioToolbox

class SoundManager {
    
    enum Notifications: String {
        case notificationPlayClickSound
        case notificationPlayAlertSound
        case notificationPlayTadaSound
    }
    
    // sounds
    var clickSound: SystemSoundID = 0
    var alertSound: SystemSoundID = 0
    var tadaSound: SystemSoundID = 0
    
    init() {
        loadSounds()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playClickSound), name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playAlertSound), name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayAlertSound.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playTadaSound), name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayTadaSound.rawValue), object: nil)
    }
    
    // load the specified sound
    func loadSound(filename: String, systemSound: inout SystemSoundID) {
        
        if let pathToSoundFile = Bundle.main.path(forResource: filename, ofType: "wav") {
            
            let soundURL = URL(fileURLWithPath: pathToSoundFile)
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &systemSound)
        }
    }
    
    // load all needed sounds
    func loadSounds() {
        
        loadSound(filename: "Click", systemSound: &clickSound)
        loadSound(filename: "Alert", systemSound: &alertSound)
        loadSound(filename: "Tada", systemSound: &tadaSound)
    }
    
    @objc func playClickSound() {
        AudioServicesPlaySystemSound(clickSound)
    }

    @objc func playAlertSound() {
        AudioServicesPlaySystemSound(alertSound)
    }

    @objc func playTadaSound() {
        AudioServicesPlaySystemSound(tadaSound)
    }
}
