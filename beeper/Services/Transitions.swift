//
//  Transitions.swift
//  beeper
//
//  Created by vlad on 02.09.2021.
//

import Foundation
import Cocoa

enum Controller: String {
    case main = "main"
    case table = "table"
    case connect = "connect"
}

class Transitions: NSObject {
    static let shared = Transitions()
    
    func performTransition(fromController: Controller, toController: Controller, assisting: NSViewController) {
        assisting.performSegue(withIdentifier: fromController.rawValue + "to" + toController.rawValue, sender: self)
    }
}
