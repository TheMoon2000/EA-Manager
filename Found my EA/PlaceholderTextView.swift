//
//  PlaceholderTextView.swift
//  Find my EA Messenger
//
//  Created by Jia Rui Shan on 12/21/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class PlaceholderTextView: NSTextView {

    
    override func becomeFirstResponder() -> Bool {
        self.needsDisplay = true
        return super.becomeFirstResponder()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        if (self.string! == "") {
            let placeHolderString: NSAttributedString = NSAttributedString(string: "Type your message here...", attributes: [NSForegroundColorAttributeName : NSColor(white: 0.8, alpha: 1), NSFontAttributeName: NSFont(name: "Source Sans Pro", size: 13.5)!])
            placeHolderString.draw(at: NSPoint(x: 5, y: -4))
        }
    }
    
}

class ProposalField: NSTextView {
    
    override var string: String? {
        didSet {
            let font = NSFont(name: "Source Sans Pro", size: 13)
            self.font = font
            let pstyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            pstyle.paragraphSpacing = 7
            pstyle.lineSpacing = 4
            self.textStorage?.addAttribute(NSParagraphStyleAttributeName, value: pstyle, range: NSMakeRange(0, self.textStorage!.length))
            
            if (self.string! == "") {
                let placeHolderString: NSAttributedString = NSAttributedString(string: "No proposal submitted", attributes: [NSForegroundColorAttributeName : NSColor(white: 0.7, alpha: 1), NSFontAttributeName: NSFont(name: "Source Sans Pro", size: 13)!])
                placeHolderString.draw(at: NSPoint(x: 5, y: -4))
                self.needsDisplay = true
            }
        }
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        if (self.string! == "") {
            let placeHolderString: NSAttributedString = NSAttributedString(string: "No proposal submitted", attributes: [NSForegroundColorAttributeName : NSColor(white: 0.7, alpha: 1), NSFontAttributeName: NSFont(name: "Source Sans Pro", size: 13)!])
            placeHolderString.draw(at: NSPoint(x: 5, y: -4))
            self.needsDisplay = true
        }
    }

}
