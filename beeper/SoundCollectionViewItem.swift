//
//  SoundCollectionViewItem.swift
//  beeper
//
//  Created by vlad on 17.08.2021.
//

import Cocoa

struct SoundItem {
    let imageName: String
    let keyStrokeName: String
}

class SoundCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var imageLabel: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    var item: SoundItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.systemPink.cgColor
    }
    
    override var representedObject: Any? {
        didSet {
            if let obj = (representedObject as! SoundItem?) {
                self.item = obj
//                self.imageLabel.image = NSImage(contentsOf: URL())
                self.titleLabel.stringValue = self.item!.keyStrokeName
            } else {
                print("Anyway...")
            }
        }
    }
}
