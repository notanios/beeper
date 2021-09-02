//
//  MQTTService.swift
//  beeper
//
//  Created by vlad on 01.09.2021.
//

import Cocoa
import CocoaMQTT

let soundboardTopic = "soundboard/play"

protocol MQTTCOnnectionDelegate {
    func didConnect() -> Void
    func didDisconnect() -> Void
}

protocol MQTTCommunicationDelegate {
    func received(Message message: String) -> Void
}

class MQTTService: NSObject, CocoaMQTTDelegate {
    
    static let shared = MQTTService()
    var connectionDelegate: MQTTCOnnectionDelegate?
    var communicationDelegate: MQTTCommunicationDelegate?
    var mqtt:CocoaMQTT?
    
//    MARK: Custom Methods
    
    func connect(toServer host: String, withPort port: UInt16, username: String, andPassword password: String) {
        let clientID = "CocoaMQTT" + String(ProcessInfo().processIdentifier)
        self.mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        self.mqtt!.username = username
        self.mqtt!.password = password
        self.mqtt!.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        self.mqtt!.keepAlive = 60
        self.mqtt!.allowUntrustCACertificate = true
        self.mqtt!.delegate = self
        _ = self.mqtt!.connect()
    }
    
    func disconnect() {
        self.mqtt!.disconnect()
    }
    
    func isConnected() -> Bool {
        self.mqtt?.connState == .connected ? true : false
    }
    
    func publish(Message message: String, toChannel channel: String?) {
        self.mqtt?.publish(soundboardTopic, withString: message)
    }

    //MARK: CocoaMQTT Delegate
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("👌 connect")
        self.mqtt?.subscribe(soundboardTopic)
        if let delegate = self.connectionDelegate {
            delegate.didConnect()
        }
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("🚫 disconnect")
        if let delegate = self.connectionDelegate {
            delegate.didDisconnect()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("📯 subscribed to topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("❌ Did unsubscribed from topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("📤 published message: \(message.topic), \(message.string!)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("💬 Did receive message: \(message.string!)")
        if message.topic != soundboardTopic {
            return
        }
        if let delegate = self.communicationDelegate {
            delegate.received(Message: message.string!)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        print("📯 Did subscribe topic: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("📡 Ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("🏓 Pong")
    }
}

