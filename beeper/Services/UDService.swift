//
//  UDService.swift
//  beeper
//
//  Created by vlad on 13.09.2021.
//

import Foundation


enum StorageKeys: String {
    case username = "usernamekey"
    case password = "passwordkey"
    case host = "hostkey"
    case port = "portkey"
    case soundboards = "soundboardskey"
}

class UDService {
    static let shared = UDService()
    
//    MARK: Connections
    func save(Connection connection: Connection) -> Void {
        UserDefaults.standard.register(defaults: [StorageKeys.host.rawValue: connection.host])
        UserDefaults.standard.register(defaults: [StorageKeys.port.rawValue: connection.port])
        UserDefaults.standard.register(defaults: [StorageKeys.username.rawValue: connection.username])
        UserDefaults.standard.register(defaults: [StorageKeys.password.rawValue: connection.password])
    }
    
    func forgetConnection() -> Void {
        UserDefaults.resetStandardUserDefaults()
    }
    
    func getConnection() -> Connection? {
        let username = UserDefaults.standard.value(forKey: StorageKeys.username.rawValue) as! String?
        if username == nil {
            return nil
        }
        
        let password = UserDefaults.standard.value(forKey: StorageKeys.password.rawValue) as! String?
        if password == nil {
            return nil
        }
        
        let host = UserDefaults.standard.value(forKey: StorageKeys.host.rawValue) as! String?
        if host == nil {
            return nil
        }
        
        let port = UserDefaults.standard.value(forKey: StorageKeys.port.rawValue) as! UInt16?
        if port == nil {
            return nil
        }
        
        return Connection(username: username!, password: password!, host: host!, port: port!)
    }
    
//    MARK: Sound Baords
    func save(_ board: SoundBoard) {
        if let boards = self.getBoards() {
            var boardsPlus: [SoundBoard] = []
            boardsPlus.append(contentsOf: boards)
            boardsPlus.append(board)
            
            UserDefaults.standard.setValue(boardsPlus, forKey: StorageKeys.soundboards.rawValue)
        }
    }
    
    func remove(_ board: SoundBoard) {
        if let boards = self.getBoards() {
            for (index, storedBoard) in boards.enumerated() {
                if board.title == storedBoard.title {
                    let boardsBefore = boards[..<index]
                    let boardsAfter = boards[index...]
                    var boardsMinus: [SoundBoard] = []
                    boardsMinus.append(contentsOf: boardsBefore)
                    boardsMinus.append(contentsOf: boardsAfter)
                    UserDefaults.standard.setValue(boardsMinus, forKey: StorageKeys.soundboards.rawValue)
                }
            }
        }
    }
    
    private func indexOf(_ board: SoundBoard) -> Int {
        if let boards = self.getBoards() {
            for (index, storedBoard) in boards.enumerated() {
                if board.title == storedBoard.title {
                    return index
                }
            }
        }
        
        return -1
    }
    
    private func getBoards() -> [SoundBoard]? {
        return UserDefaults.standard.value(forKey: StorageKeys.soundboards.rawValue) as! [SoundBoard]?
    }
    
    func getBoards() -> [SoundBoard] {
        return self.getBoards()!
    }
}
