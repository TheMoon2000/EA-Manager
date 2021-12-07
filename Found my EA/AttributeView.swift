//
//  AttributeView.swift
//  EA Manager
//
//  Created by Jia Rui Shan on 3/28/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class AttributeView: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func listPanel(_ sender: NSButton) {
        let ap = NSApplication.shared().delegate as! AppDelegate
        ap.vc.message.orderFrontListPanel(sender)
    }
    
    @IBAction func linkPanel(_ sender: NSButton) {
        let ap = NSApplication.shared().delegate as! AppDelegate
        ap.vc.message.orderFrontLinkPanel(sender)
    }
    
    @IBAction func tablePanel(_ sender: NSButton) {
        let ap = NSApplication.shared().delegate as! AppDelegate
        ap.vc.message.orderFrontTablePanel(sender)
    }
    
    @IBAction func spacingPanel(_ sender: NSButton) {
        let ap = NSApplication.shared().delegate as! AppDelegate
        ap.vc.message.orderFrontSpacingPanel(sender)
    }
    
}
