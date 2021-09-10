//
//  ViewController.swift
//  beeper
//
//  Created by vlad on 17.08.2021.
//

import Cocoa
import AVFoundation
import CocoaMQTT

let usernameKey = "usernamekey"
let passwordKey = "passwordkey"
let hostKey = "hostkey"
let portKey = "portkey"

struct Connection {
    let username: String
    let password: String
    let host: String
    let port: UInt16
}

enum ConnStatus: String {
    case connected = "⚡Connected"
    case disconnected = "🚧Disconnected"
    case inProcess = "⏳In process"
}

let letters = [["1", "2", "3", "4"],
               ["q", "w", "e", "r"]]
let titles = [["badumtss", "coin", "applause", "cricket"],
               ["drumroll", "gong", "sadtrombone", "cowsay"]]

let sounds = ["badumtss", "coin", "applause", "cricket", "drumroll", "gong", "sadtrombone", "cowsay"]

class ViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource, MQTTCommunicationDelegate, MQTTCOnnectionDelegate {
    
    var tempConnection: Connection?
    var timer: Timer?
    var monitor: Any?
    var status: ConnStatus = .disconnected {
        didSet {
            self.statusLabel.stringValue = status.rawValue
            
            switch status {
            case .connected:
                self.connectButton.title = "Disconnect"
                self.connectButton.isEnabled = true
                self.isServerSwitch.state = .off
                self.isServerSwitch.isEnabled = true
            case .disconnected:
                self.connectButton.title = "Connect"
                self.connectButton.isEnabled = true
                self.isServerSwitch.state = .off
                self.isServerSwitch.isEnabled = false
            case .inProcess:
                self.connectButton.title = "Don't Touch"
                self.connectButton.isEnabled = false
            }
        }
    }
    
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var isServerSwitch: NSSwitch!
    @IBOutlet weak var playSwitch: NSSwitch!
    @IBOutlet weak var collectionView: NSCollectionView!
    var players: [[AVAudioPlayer]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiatePlayers()
        
        collectionView.register(SoundCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("SoundCollectionViewItem"))
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 140.0, height: 120.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 15.0, left: 0.0, bottom: 0.0, right: 0.0)
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 5.0
        
        collectionView.collectionViewLayout = flowLayout
        view.wantsLayer = true
        collectionView.layer?.backgroundColor = NSColor.systemPink.cgColor
        
        collectionView.isSelectable = true
        
        collectionView.reloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.enableKeyMonitor()
    }
    
    func enableKeyMonitor() {
        self.monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handle(Event: event)
            return nil
        }
    }
    
    func disableKeyMonitor() {
        NSEvent.removeMonitor(self.monitor!)
        self.monitor = nil
    }
    
//    MARK: Segues
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if self.status == .connected {
            MQTTService.shared.disconnect()
        } else {
            self.disableKeyMonitor()
            
            let connect = segue.destinationController as! ConnectionViewController
            
            connect.connHandler = { connection in
                self.enableKeyMonitor()
                self.status = .inProcess
                _ = self.connect(withConnection: connection)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if self.status == .connected {
            self.disconnect()
            return false
        } else if let connection = self.extractConnection() {
            _ = self.connect(withConnection: connection)
            return false
        } else {
            return true
        }
    }
    
//    MARK: MQTT
    
    func received(Message message: String) {
        if self.isServerSwitch.state == .on {
            if let indexPath = indexPath(ofLetter: message) {
                self.handle(RemoteIndexPath: indexPath)
            }
        }
    }
        
    func didConnect() {
        self.save(Connection: self.tempConnection!)
        self.tempConnection = nil
        self.status = .connected
    }
    
    func didDisconnect() {
        self.status = .disconnected
    }
    
//    MARK: Saving Connection
    
    func save(Connection connection: Connection) -> Void {
        UserDefaults.standard.register(defaults: [hostKey: connection.host])
        UserDefaults.standard.register(defaults: [portKey: connection.port])
        UserDefaults.standard.register(defaults: [usernameKey: connection.username])
        UserDefaults.standard.register(defaults: [passwordKey: connection.password])
    }
    
    func eraseConnectionData() -> Void {
        UserDefaults.resetStandardUserDefaults()
    }
    
    func extractConnection() -> Connection? {
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
    
//    MARK: Custom
    
    func disconnect() {
        MQTTService.shared.disconnect()
    }
    
    func connect(withConnection connection: Connection) -> Bool {
        if connection.port < 1 {
            return false
        }
        
        if connection.host.isEmpty {
            return false
        }
        
        if connection.password.isEmpty {
            return false
        }
        
        if connection.username.isEmpty {
            return false
        }
        
        MQTTService.shared.connectionDelegate = self
        MQTTService.shared.communicationDelegate = self
        MQTTService.shared.connect(toServer: connection.host, withPort: connection.port, username: connection.username, andPassword: connection.password)
        self.tempConnection = connection
        
        return true
    }
    
    func handle(Event event: NSEvent) {
        let command = event.characters!
        
        switch command {
        case "m":
            self.playSwitch.state = self.playSwitch.state == .off ? .on : .off
        case "l":
            self.isServerSwitch.state = self.isServerSwitch.state == .off ? .on : .off
        default:
            if let indexPath = indexPath(ofLetter: event.characters!) {
                handle(LocalIndexPath: indexPath)
            }
        }
    }
    
    func handle(LocalIndexPath indexPath: IndexPath) {
        if self.isServerSwitch.state == .off {
            MQTTService.shared.publish(Message: letters[indexPath.section][indexPath.item], toChannel: nil)
        }
        
        if self.playSwitch.state == .on {
            self.players![indexPath.section][indexPath.item].play()
        }
    }
    
    func handle(RemoteIndexPath indexPath: IndexPath) {
        if self.isServerSwitch.state == .on, self.playSwitch.state == .on {
            self.players![indexPath.section][indexPath.item].play()
        }
    }
    
    func indexPath(ofLetter string: String) -> IndexPath? {
        for (i, array) in letters.enumerated() {
            for (j, letter) in array.enumerated() {
                if letter == string {
                    return IndexPath(item: j, section: i)
                }
            }
        }
        return nil
    }
    
    func player(forFile file:String, ext:String) -> AVAudioPlayer? {
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
    
    func initiatePlayers() {
        self.players = []
        for i in 0...1 {
            self.players?.append([])
            for j in 0...3 {
                let soundName = titles[i][j]
                self.players![i].append(player(forFile: soundName, ext: "mp3")!)
            }
        }
    }

//    MARK: CollectionView delegates
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = self.collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SoundCollectionViewItem"), for: indexPath) as! SoundCollectionViewItem
        
        let keyString = letters[indexPath.section][indexPath.item]
        let desc = titles[indexPath.section][indexPath.item]
        
        item.representedObject = SoundItem(imageName: "nil", keyStrokeName: keyString, desc: desc)
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)
        self.handle(LocalIndexPath: indexPaths.first!)
    }

}
