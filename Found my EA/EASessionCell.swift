//
//  EASessionCell.swift
//  EA Manager
//
//  Created by Jia Rui Shan on 4/25/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class EASessionCell: NSTableCellView {

    @IBOutlet weak var dateLabel: NSTextField!
    @IBOutlet weak var overlay: NSView!
    
    override var backgroundStyle: NSBackgroundStyle {
        didSet {
            if backgroundStyle == .dark {
                dateLabel.textColor = NSColor.white
            } else {
                dateLabel.textColor = NSColor.black
            }
        }
    }
    
    override func awakeFromNib() {
        overlay.wantsLayer = true
        overlay.layer!.backgroundColor = NSColor(white: 1, alpha: 0.6).cgColor
    }

    var enabled = true {
        didSet {
            overlay.isHidden = enabled
        }
    }
    
}
