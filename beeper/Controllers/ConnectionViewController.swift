//
//  ConnectionViewController.swift
//  beeper
//
//  Created by vlad on 01.09.2021.
//

import Cocoa

class ConnectionViewController: NSViewController {
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var hostField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var rememberButton: NSButton!
    
    var connHandler: ((Connection) -> Void)?
    var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let message = self.message {
            self.statusLabel.stringValue = message
        }
    }
    
    @IBAction func connectPressed(_ sender: Any) {
        if let handler = self.connHandler {
            handler(Connection(username: usernameField.stringValue, password: passwordField.stringValue, host: hostField.stringValue, port: UInt16(portField.stringValue)!))
        }
        self.dismiss(nil)
    }
}
