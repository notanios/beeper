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

protocol DragDropDelegate {
    func droped(file url: URL, onCell cell : NSCollectionViewItem, withItem item: SoundItem)
    func droped(files urls: [URL], onCell cell : NSCollectionViewItem, withItem item: SoundItem)
}

class SoundCollectionViewItem: NSCollectionViewItem, ADragDropViewDelegate {

    @IBOutlet var customView: ADragDropView!
    @IBOutlet weak var imageLabel: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var descLabel: NSTextField!
    var item: SoundItem?
    var delegate: DragDropDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        self.customView.delegate = self
        self.customView.acceptedFileExtensions = ["mp3"]
    }
    
    override func viewDidAppear() {
        
        if let object = self.item {
            self.descLabel.stringValue = object.desc ?? "<no sound>"
            self.titleLabel.stringValue = object.keyStrokeName
            view.layer?.backgroundColor = (object.desc != nil) ? NSColor.systemPink.cgColor : NSColor.systemGray.cgColor
            
            if let _ = self.item?.desc {
                self.customView.drawArrow = false
                self.customView.draw(self.customView.visibleRect)
                self.imageLabel.image = NSImage(named: "NSTouchBarPlayTemplate")
            } else {
                self.customView.drawArrow = true
                self.customView.draw(self.customView.visibleRect)
                self.imageLabel.image = nil
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
            if let obj = (representedObject as! SoundItem?) {
                self.item = obj
                
                if obj.keyStrokeName == "a" {
                    print("receiving the obj to A")
                }
                
                if obj.keyStrokeName == "1" {
                    print("receiving the obj to A")
                }
            }
        }
    }
    
    
//    MARK: Drag and Drop
    
    func dragDropView(_ dragDropView: ADragDropView, droppedFileWithURL URL: URL) {
        if let delegate = self.delegate {
            delegate.droped(file: URL, onCell: self, withItem: self.item!)
        }
    }
    
    func dragDropView(_ dragDropView: ADragDropView, droppedFilesWithURLs URLs: [URL]) {
        if let delegate = self.delegate {
            delegate.droped(files: URLs, onCell: self, withItem: self.item!)
        }
    }
}

