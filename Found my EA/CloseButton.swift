//
//  CloseButton.swift
//  Find my EA Messenger
//
//  Created by Jia Rui Shan on 12/25/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class CloseButton: NSButton {

    var entered = false
    var down = false
    var focused = true
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.cornerRadius = 10
    }
    
    override func awakeFromNib() {
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 129), owner: self, userInfo: nil))

    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        entered = true
        self.image = #imageLiteral(resourceName: "closebutton_highlighted")
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        entered = false
        if focused {
            self.image = #imageLiteral(resourceName: "closebutton_focused")
        } else {
            self.image = #imageLiteral(resourceName: "closebutton_unfocused")
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        down = true
        self.image = #imageLiteral(resourceName: "closebutton_pressed")
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        down = false
        if entered {
            // self.window?.performClose(self)
            self.window?.orderOut(nil)
        } else {
            self.image = #imageLiteral(resourceName: "closebutton_focused")
        }
    }
    
}
