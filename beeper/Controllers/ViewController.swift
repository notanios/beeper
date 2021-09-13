//
//  ViewController.swift
//  beeper
//
//  Created by vlad on 17.08.2021.
//

import Cocoa
import AVFoundation
import CocoaMQTT
import SwiftyJSON



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

private let defaultBoard = SoundBoard(title: "Default Board",
                                      sounds: [Sound(title: "badumtss", key: "1"),
                                               Sound(title: "coin", key: "2"),
                                               Sound(title: "applause", key: "3"),
                                               Sound(title: "cricket", key: "4"),
                                               Sound(title: "drumroll", key: "q"),
                                               Sound(title: "gong", key: "w"),
                                               Sound(title: "sadtrombone", key: "e"),
                                               Sound(title: "cowsay", key: "r"),
                                               Sound(title: "booing", key: "a"),
                                               Sound(title: "cheering", key: "s")])

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
    var players: [[AVAudioPlayer?]]?
    var soundMap: [[String]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPlayers()
        
        collectionView.register(SoundCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("SoundCollectionViewItem"))
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 80.0, height: 80.0)
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
                _ = self.connect(withConnection: connection)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if self.status == .connected {
            self.disconnect()
            return false
        } else if let connection = UDService.shared.getConnection() {
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
            } else {
                switch message {
                case "list":
                    let json = defaultBoard.json()
                    MQTTService.shared.publish(Message: "manifest:" + json, toChannel: soundboardTopic)
                default:
                    break
                }
            }
        }
    }
        
    func didConnect() {
        if let conn = self.tempConnection {
            UDService.shared.save(Connection: conn)
        } else {
            print("❌ Error, no temp connection to save")
        }
        self.tempConnection = nil
        self.status = .connected
    }
    
    func didDisconnect() {
        self.status = .disconnected
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
        
        self.status = .inProcess
        
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
            if self.playSwitch.isEnabled {
                self.playSwitch.state = self.playSwitch.state == .off ? .on : .off
            }
        case "l":
            if self.isServerSwitch.isEnabled {
                self.isServerSwitch.state = self.isServerSwitch.state == .off ? .on : .off
            }
        default:
            if let indexPath = indexPath(ofLetter: event.characters!) {
                handle(LocalIndexPath: indexPath)
            }
        }
    }
    
    func handle(LocalIndexPath indexPath: IndexPath) {
        if self.isServerSwitch.state == .off {
            MQTTService.shared.publish(Message: KEYS[indexPath.section][indexPath.item], toChannel: nil)
        }
        
        if self.playSwitch.state == .on, thereIsSoundAttached(indexPath) {
            self.players![indexPath.section][indexPath.item]!.stop()
            self.players![indexPath.section][indexPath.item]!.currentTime = 0.0
            self.players![indexPath.section][indexPath.item]!.play()
        }
    }
    
    func handle(RemoteIndexPath indexPath: IndexPath) {
        if self.isServerSwitch.state == .on, self.playSwitch.state == .on {
            self.players![indexPath.section][indexPath.item]!.stop()
            self.players![indexPath.section][indexPath.item]!.currentTime = 0.0
            self.players![indexPath.section][indexPath.item]!.play()
        }
    }
    
    func thereIsSoundAttached(_ indexPath: IndexPath) -> Bool {
        return !self.soundMap![indexPath.section][indexPath.item].isEmpty
    }
    
    func indexPath(ofLetter string: String) -> IndexPath? {
        for (i, array) in KEYS.enumerated() {
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
    
    func initPlayers() {
        initPlayers(WithSoundmap: defaultBoard.map())
    }


//    MARK: CollectionView delegates
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return KEYS[section].count
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return KEYS.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = self.collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SoundCollectionViewItem"), for: indexPath) as! SoundCollectionViewItem
        let keyString = KEYS[indexPath.section][indexPath.item]
        
        var desc: String? = nil
        var imageName: String? = nil
        
        if thereIsSoundAttached(indexPath) {
            desc = self.soundMap![indexPath.section][indexPath.item]
            imageName = "NSTouchBarPlayTemplate"
        }
        
        item.representedObject = SoundItem(imageName: imageName, keyStrokeName: keyString, desc: desc)
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)
        self.handle(LocalIndexPath: indexPaths.first!)
    }

}
