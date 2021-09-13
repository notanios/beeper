//
//  Board.swift
//  beeper
//
//  Created by vlad on 13.09.2021.
//

import Foundation

let KEYS = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
               ["q", "w", "e", "r", "t", "y", "u", "u", "i", "o", "p"],
               ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
               ["z", "x", "c", "v", "b", "n", "m"]]

struct Sound: Codable {
    let title: String
    let key: String
    var duration: Float = 0.0
}

struct SoundBoard {
    var sounds: [Sound]
    
    func json() -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(self.sounds)
        let json = String(data: jsonData!, encoding: String.Encoding.utf8)
        
        return json!
    }
    
    func map() -> [[String]] {
        var soundMap:[[String]] = []
        
        for (i, array) in KEYS.enumerated() {
            soundMap.append([])
            for (_, letter) in array.enumerated() {
                if let soundName = soundName(forKey: letter) {
                    soundMap[i].append(soundName)
                } else {
                    soundMap[i].append("")
                }
            }
        }
        
        return soundMap
    }
    
    private func soundName(forKey key: String) -> String? {
        for sound in self.sounds {
            if key == sound.key {
                return sound.title
            }
        }
        
        return nil
    }
}
