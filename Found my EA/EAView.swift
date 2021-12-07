//
//  EAView.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/6/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class EAView: NSTableCellView {
    
    @IBOutlet weak var EAName: NSTextField!
    @IBOutlet weak var supervisor: NSTextField!
    @IBOutlet weak var supervisorLabel: NSTextField!
    @IBOutlet weak var numberOfParticipants: NSTextField!
    @IBOutlet weak var leaders: NSTextField!
    @IBOutlet weak var date: NSTextField!
    @IBOutlet weak var location: NSTextField!
    @IBOutlet weak var statusIcon: NSImageView!
    @IBOutlet weak var horizontalLine: NSBox!
    
    
    enum EAStatus {
        case active
        case inactive
        case unapproved
        case pending
        case finished
        case none
    }
    
    var status: EAStatus = .none {
        didSet {
            switch status {
            case .active:
                statusIcon.image = NSImage(named: "NSStatusAvailable")
            case .unapproved:
                statusIcon.image = NSImage(named: "NSStatusUnavailable")
            case .pending:
                statusIcon.image = NSImage(named: "NSStatusPartiallyAvailable")
            case .inactive:
                statusIcon.image = NSImage(named: "NSStatusNone")
            case .none:
                statusIcon.image = nil
            case .finished:
                statusIcon.image = #imageLiteral(resourceName: "Finished")
            }
        }
    }

    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
//    
    override var backgroundStyle: NSBackgroundStyle {
        didSet {
            if backgroundStyle == .dark {
                self.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
                horizontalLine.appearance = NSAppearance(named: NSAppearanceNameAqua)
            } else {
                self.appearance = NSAppearance(named: NSAppearanceNameAqua)
            }
        }
    }
    
}
