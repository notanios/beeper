//
//  ViewController.swift
//  beeper
//
//  Created by vlad on 17.08.2021.
//

import Cocoa

let letters = [["1", "2", "3", "4", "5"],
               ["q", "w", "e", "r", "t"],
               ["a", "s", "d", "f", "g"],
               ["z", "x", "c", "v", "b"]]

class ViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    @IBOutlet weak var collectionView: NSCollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SoundCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("SoundCollectionViewItem"))
        
        let flowLayout = NSCollectionViewFlowLayout()
            flowLayout.itemSize = NSSize(width: 120.0, height: 120.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            flowLayout.minimumInteritemSpacing = 10.0
            flowLayout.minimumLineSpacing = 10.0
            collectionView.collectionViewLayout = flowLayout
            view.wantsLayer = true
            collectionView.layer?.backgroundColor = NSColor.systemPink.cgColor
        
        collectionView.reloadData()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.makeFirstResponder(self.view)
        
        if let soundView = (self.view as! SoundView?) {
            soundView.eventHandler = { event in
                print("Now print from Controller \(event)")
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

}

