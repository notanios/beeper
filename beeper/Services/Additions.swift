//
//  Additions.swift
//  beeper
//
//  Created by vlad on 24.09.2021.
//

import Foundation
import Cocoa

class MyWindowCOntroller: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.minSize = NSSize(width: 1000, height: 500)
        window?.maxSize = NSSize(width: 1000, height: 500)
    }
}
