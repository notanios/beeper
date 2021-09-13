//
//  SoundCollectionViewItem.swift
//  beeper
//
//  Created by vlad on 17.08.2021.
//

import Cocoa

struct SoundItem {
    let imageName: String?
    let keyStrokeName: String
    let desc: String?
}

class SoundCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var imageLabel: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var descLabel: NSTextField!
    var item: SoundItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let object = (self.representedObject as! SoundItem?) {
            self.imageLabel.image = NSImage(named: object.imageName ?? "")
            self.descLabel.stringValue = object.desc ?? "<no sound>"
            self.titleLabel.stringValue = object.keyStrokeName
            view.layer?.backgroundColor = (object.desc != nil) ? NSColor.systemPink.cgColor : NSColor.systemGray.cgColor
        }
    }
    
    override var representedObject: Any? {
        didSet {
            if let obj = (representedObject as! SoundItem?) {
                self.item = obj
                self.imageLabel.image = NSImage(named: self.item!.imageName ?? "")
                self.titleLabel.stringValue = self.item!.keyStrokeName
                self.descLabel.stringValue = self.item!.desc ?? "<no sound>"
            } else {
                print("Anyway...")
            }
        }
    }
}
