//
//  PlayersManager.swift
//  beeper
//
//  Created by vlad on 13.09.2021.
//

import Foundation
import AVFoundation

class PlayersManager {
    static let shared = PlayersManager()
    var soundMap: [[String]]?
    private var players: [[AVAudioPlayer?]]?
    
    func initPlayers(WithSoundmap soundMap: [[String]]) {
        self.soundMap = soundMap
        self.players = []
        
        for (i, array) in KEYS.enumerated() {
            self.players?.append([])
            for (j, _) in array.enumerated() {
                if !soundMap[i][j].isEmpty {
                    self.players![i].append(self.player(forFile: soundMap[i][j], ext: "mp3")!)
                } else {
                    self.players![i].append(nil)
                }
            }
        }
    }
    
    private func player(forFile file:String, ext:String) -> AVAudioPlayer? {
        let url = Bundle.main.url(forResource: file, withExtension: ext)!
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            if audioPlayer.prepareToPlay() {
                return audioPlayer
            } else {
                throw NSError()
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func playPlayer(atIndexPath indexPath: IndexPath) {
        self.players![indexPath.section][indexPath.item]!.stop()
        self.players![indexPath.section][indexPath.item]!.currentTime = 0.0
        self.players![indexPath.section][indexPath.item]!.play()
    }
    
    func isPlayer(atIndexPath indexPath: IndexPath) -> Bool {
        return !self.soundMap![indexPath.section][indexPath.item].isEmpty
    }
}
