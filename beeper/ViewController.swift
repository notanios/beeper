//
//  ViewController.swift
//  beeper
//
//  Created by vlad on 17.08.2021.
//

import Cocoa
import AVFoundation
import CocoaMQTT

let letters = [["1", "2", "3", "4", "5"],
               ["q", "w", "e", "r", "t"],
               ["a", "s", "d", "f", "g"],
               ["z", "x", "c", "v", "b"]]

let sounds = ["beep", "bell", "badumtss", "coin", "chirp"]

class ViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource, CocoaMQTTDelegate {
    
    @IBOutlet weak var isServerSwitch: NSSwitch!
    @IBOutlet weak var playSwitch: NSSwitch!
    @IBOutlet weak var collectionView: NSCollectionView!
    var players: [[AVAudioPlayer]]?
    var mqtt:CocoaMQTT?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiatePlayers()
        
        collectionView.register(SoundCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("SoundCollectionViewItem"))
        
        let flowLayout = NSCollectionViewFlowLayout()
            flowLayout.itemSize = NSSize(width: 100.0, height: 100.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            flowLayout.minimumInteritemSpacing = 10.0
            flowLayout.minimumLineSpacing = 10.0
            collectionView.collectionViewLayout = flowLayout
            view.wantsLayer = true
            collectionView.layer?.backgroundColor = NSColor.systemPink.cgColor
        
        collectionView.isSelectable = true
        
        collectionView.reloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if self.view.acceptsFirstResponder {
            self.view.window!.makeFirstResponder(self)
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handle(Event: event)
            return nil
        }
        
        self.setupMQTT()
    }
    
//    MARK: IB Actions
    
//    MARK: MQTT
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("📯 subscride topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("❌ Did unsubscribe topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("📤 published message: \(message.topic), \(message.string!)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("💬 Did receive message: \(message.string!)")
        if let indexPath = indexPath(ofLetter: message.string!) {
            self.handle(RemoteIndexPath: indexPath)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        print("📯 Did subscribe topic: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("🚫 disconnect")
        self.mqtt?.unsubscribe("soundboard/play")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("👌 connect")
        self.mqtt?.subscribe("soundboard/play")
    }
    
//    MARK: Custom
    
    func setupMQTT() {
        let clientID = "CocoaMQTT" + String(ProcessInfo().processIdentifier)
        self.mqtt = CocoaMQTT(clientID: clientID, host: "40.68.246.153", port: 1883)
        self.mqtt!.username = "vlad"
        self.mqtt!.password = "password123"
        self.mqtt!.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        self.mqtt!.keepAlive = 60
        self.mqtt!.allowUntrustCACertificate = true
        self.mqtt!.delegate = self
        _ = self.mqtt!.connect()
    }
    
    func handle(Event event: NSEvent) {
        if let indexPath = indexPath(ofLetter: event.characters!) {
            handle(LocalIndexPath: indexPath)
        }
    }
    
    func handle(LocalIndexPath indexPath: IndexPath) {
        if self.isServerSwitch.state == .off {
            self.mqtt!.publish("soundboard/play", withString: letters[indexPath.section][indexPath.item])
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
        for i in 0...3 {
            self.players?.append([])
            for j in 0...4 {
                let soundName = sounds[j]
                self.players![i].append(player(forFile: soundName, ext: "mp3")!)
            }
        }
    }

//    MARK: CollectionView delegates
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = self.collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SoundCollectionViewItem"), for: indexPath) as! SoundCollectionViewItem
        
        let keyString = letters[indexPath.section][indexPath.item]
        
        item.representedObject = SoundItem(imageName: "nil", keyStrokeName: keyString)
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)
        self.handle(LocalIndexPath: indexPaths.first!)
    }

}
