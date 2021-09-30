//
//  StorageService.swift
//  beeper
//
//  Created by vlad on 13.09.2021.
//

import Foundation
import Cocoa

class StorageManager {
    static let shared = StorageManager()
    
    private func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
    
    private func url(withPath path: String) -> URL {
        return URL(fileURLWithPath: path)
    }
    
    private func append(toPath path: String,
                        withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            
            return pathURL.absoluteString
        }
        
        return nil
    }
    
    func createDirInDocuments(dirName: String) {
        let url = self.url(withPath: self.documentDirectory()).appendingPathComponent("Beeper")
        let manager = FileManager.default
        let _ = try? manager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
}
