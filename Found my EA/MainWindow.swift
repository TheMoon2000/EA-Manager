//
//  MainWindow.swift
//  Find my EA
//
//  Created by Jia Rui Shan on 12/5/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class MainWindow: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var mainwindow: NSWindow!
    
    var resizeDelegate: WindowResizeDelegate?
    
    override func windowWillLoad() {
        mainwindow.delegate = self
        mainwindow.titlebarAppearsTransparent = true
        mainwindow.titleVisibility = .hidden
        mainwindow.backgroundColor = NSColor.white

    }
    
    override func windowDidLoad() {
        let vc = self.contentViewController! as! ViewController
        self.resizeDelegate = vc
    }
    
    func windowWillStartLiveResize(_ notification: Notification) {
        resizeDelegate?.windowWillResize(nil)
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        resizeDelegate?.windowHasResized(nil)
    }
    
    func windowDidResize(_ notification: Notification) {
        let vc = self.contentViewController! as! ViewController
        vc.adjustImages()
    }
}

class DraggableImage: NSImageView {
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
