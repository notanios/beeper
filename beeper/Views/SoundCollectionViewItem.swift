//
//  SoundCollectionViewItem.swift
//  beeper
//
//  Created by vlad on 17.08.2021.
//

import Cocoa
import ADragDropView

struct SoundItem {
    let indexPath: IndexPath
    let keyStrokeName: String
    let desc: String?
}

class SoundCollectionViewItem: NSCollectionViewItem, ADragDropViewDelegate {

    @IBOutlet var customView: ADragDropView!
    @IBOutlet weak var imageLabel: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var descLabel: NSTextField!
    var item: SoundItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        self.customView.delegate = self
        self.customView.acceptedFileExtensions = ["gif", "mp3", "ogg", "wav"]
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let object = (self.representedObject as! SoundItem?) {
            self.descLabel.stringValue = object.desc ?? "<no sound>"
            self.titleLabel.stringValue = object.keyStrokeName
            view.layer?.backgroundColor = (object.desc != nil) ? NSColor.systemPink.cgColor : NSColor.systemGray.cgColor
            
            if let _ = self.item?.desc {
                self.customView.drawArrow = false
                self.imageLabel.image = NSImage(named: "NSTouchBarPlayTemplate")
            } else {
                self.customView.drawArrow = true
                self.imageLabel.image = nil
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
            if let obj = (representedObject as! SoundItem?) {
                self.item = obj
                self.titleLabel.stringValue = self.item!.keyStrokeName
                self.descLabel.stringValue = self.item!.desc ?? "<no sound>"
            }
        }
    }
    
    
//    MARK: Drag and Drop
    
    func dragDropView(_ dragDropView: ADragDropView, droppedFileWithURL URL: URL) {
        print("File dragged: \(URL) on cell: \(self.item!.indexPath)")
    }
    
    func dragDropView(_ dragDropView: ADragDropView, droppedFilesWithURLs URLs: [URL]) {
        print("Files dragged: \(URLs) on cell: \(self.item!.indexPath)")
    }
}
