//
//  UDService.swift
//  beeper
//
//  Created by vlad on 13.09.2021.
//

import Foundation

let usernameKey = "usernamekey"
let passwordKey = "passwordkey"
let hostKey = "hostkey"
let portKey = "portkey"

class UDService {
    static let shared = UDService()
    
//    MARK: Connections
    func save(Connection connection: Connection) -> Void {
        UserDefaults.standard.register(defaults: [hostKey: connection.host])
        UserDefaults.standard.register(defaults: [portKey: connection.port])
        UserDefaults.standard.register(defaults: [usernameKey: connection.username])
        UserDefaults.standard.register(defaults: [passwordKey: connection.password])
    }
    
    func eraseConnectionData() -> Void {
        UserDefaults.resetStandardUserDefaults()
    }
    
    func getConnection() -> Connection? {
        let username = UserDefaults.standard.value(forKey: usernameKey) as! String?
        if username == nil {
            return nil
        }
        
        let password = UserDefaults.standard.value(forKey: passwordKey) as! String?
        if password == nil {
            return nil
        }
        
        let host = UserDefaults.standard.value(forKey: hostKey) as! String?
        if host == nil {
            return nil
        }
        
        let port = UserDefaults.standard.value(forKey: portKey) as! UInt16?
        if port == nil {
            return nil
        }
        
        return Connection(username: username!, password: password!, host: host!, port: port!)
    }
}
