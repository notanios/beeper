//
//  SoundView.swift
//  beeper
//
//  Created by vlad on 17.08.2021.
//

import Cocoa

class SoundView: NSView {
    var eventHandler: ((NSEvent) -> Void)?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func keyDown(with event: NSEvent) {
        if let handler = eventHandler {
            handler(event)
        }
    }
    
    override var acceptsFirstResponder: Bool { return true }
    
}
