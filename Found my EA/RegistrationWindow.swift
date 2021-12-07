//
//  RegistrationWindow.swift
//  Find my EA
//
//  Created by Jia Rui Shan on 1/23/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class RegistrationWindow: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        //17369E
        window?.backgroundColor = NSColor(red: 1, green: 0.99, blue: 0.99, alpha: 1)
        window?.titlebarAppearsTransparent = true
        window?.standardWindowButton(.zoomButton)?.isHidden = true
        window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        let menu = NSApplication.shared().mainMenu!.item(withTitle: "EA Manager")!
//        if NSUserDefaults.standardUserDefaults().boolForKey("Blue Theme") {
            menu.submenu?.item(withTitle: "Blue Theme")?.state = 1
            window?.standardWindowButton(.closeButton)?.isHidden = true
//        }
        window?.titleVisibility = .hidden
        window?.isMovableByWindowBackground = true
        
        if !FileManager().fileExists(atPath: Bundle.main.bundlePath + "/Contents/Resources/Assets.tenic") {
            let alert = NSAlert()
            alert.messageText = "Source File Missing"
            alert.informativeText = "'Assets.tenic' cannot be located. Did you delete it?"
            alert.addButton(withTitle: "Quit").keyEquivalent = "\r"
            alert.runModal()
            NSApplication.shared().terminate(nil)
        }
    }

}

class Non_Draggable_Image: NSView {
    override var mouseDownCanMoveWindow: Bool {
        return false
    }
}
