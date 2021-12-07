//
//  StartupView.swift
//  EA Registration
//
//  Created by Jia Rui Shan on 12/4/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

let blueColor = NSColor(red: 38/255, green: 130/255, blue: 250/255, alpha: 0.1)
//let highlightColor = NSColor(red: 30/255, green: 120/255, blue: 248/255, alpha: 1)
//let mouseDownColor = NSColor(red: 25/255, green: 115/255, blue: 245/255, alpha: 1)
let highlightColor = NSColor(red: 38/255, green: 130/255, blue: 250/255, alpha: 0.2)
let mouseDownColor = NSColor(red: 38/255, green: 130/255, blue: 250/255, alpha: 0.15)


var isOutside = true

class StartupView: NSView, NSTextFieldDelegate {

    @IBOutlet weak var beginButton: NSButton!

    
    let d = NSUserDefaults.standardUserDefaults()
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    
    override func awakeFromNib() {

        
        beginButton.wantsLayer = true
        beginButton.layer?.backgroundColor = blueColor.CGColor
        
        beginButton.layer?.cornerRadius = 22
        beginButton.layer?.borderColor = NSColor.whiteColor().CGColor
        beginButton.layer?.borderWidth = 1
        
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .Center
        
        let buttonFont = NSFont(name: "Helvetica Neue", size: 18)
        
//        beginButton.attributedTitle = NSAttributedString(string: "Let's Begin", attributes: [NSForegroundColorAttributeName: NSColor.whiteColor(), NSParagraphStyleAttributeName: pstyle, NSFontAttributeName: buttonFont!])
        
        beginButton.addTrackingArea(NSTrackingArea(rect: beginButton.bounds, options: NSTrackingAreaOptions(rawValue: 129), owner: self, userInfo: nil))
        
        window?.standardWindowButton(.ZoomButton)?.hidden = true
        window?.standardWindowButton(.MiniaturizeButton)?.hidden = true

    }
    
    override func mouseEntered(theEvent: NSEvent) {
        isOutside = false
        beginButton.layer?.backgroundColor = highlightColor.CGColor
    }
    
    override func mouseExited(theEvent: NSEvent) {
        isOutside = true
        beginButton.layer?.backgroundColor = blueColor.CGColor
    }
    
    @IBAction func begin(sender: NSButton) {

        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let vc = appDelegate.vc
        vc.letsBegin(beginButton)
//
    }
    
}

class beginButton: NSButton {
    override func mouseDown(theEvent: NSEvent) {
        self.layer?.backgroundColor = mouseDownColor.CGColor
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if !isOutside {
            self.layer?.backgroundColor = highlightColor.CGColor
            super.mouseDown(theEvent)
        }
    }
}
