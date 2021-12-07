//
//  BugReporter.swift
//  Find my EA
//
//  Created by Jia Rui Shan on 3/29/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class BugReporterWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        window!.styleMask = NSBorderlessWindowMask
        window!.isMovableByWindowBackground = true
        window!.backgroundColor = NSColor.clear
        window!.isOpaque = false
    }
}

class BugReportWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}

class SubmitBugButton: NSButton {
    
    var mouseIsIn = false
    
    override func awakeFromNib() {
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 129), owner: self, userInfo: nil))
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        mouseIsIn = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        mouseIsIn = false
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if self.isEnabled {
            self.layer?.backgroundColor = NSColor(white: 0.95, alpha: 0.05).cgColor
        }
    }
    
    override var isEnabled: Bool {
        get {
            return self.alphaValue == 1.0
        }
        
        set (newValue) {
            self.alphaValue = newValue ? 1.0 : 0.5
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        if mouseIsIn && self.isEnabled {
            self.isEnabled = false
            self.title = "Uploading..."
            reporter.bugContent.isEditable = false
            let url = URL(string: serverAddress + "tenicCore/ReportBug.php")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            let postString = "username=\(appstudentID)&advisory=\(appadvisory)&bug=\(reporter.bugContent.string!.encodedString())"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                if error != nil {
                    Swift.print(error!)
                    return
                }
                if String(data: data!, encoding: String.Encoding.utf8) == "1" {
                    DispatchQueue.main.async {
                        reporter.bugContent.string = ""
                        self.title = "Successfully Sent"
                        reporter.bugContent.isEditable = true
                    }
                } else {
                    self.title = "Network Error"
                    self.isEnabled = true
                    DispatchQueue.main.async {
                        reporter.bugContent.isEditable = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.title = "Submit Bug"
                }
            }
            task.resume()
        }
        self.layer?.backgroundColor = NSColor(white: 1, alpha: 0.1).cgColor
    }
}
    
var reporter = BugReporter()

class BugReporter: NSViewController, NSTextDelegate, NSTextViewDelegate {
    
    @IBOutlet var bugContent: BugTextView!
    @IBOutlet weak var submitButton: SubmitBugButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reporter = self
        
        bugContent.delegate = self
        
        bugContent.insertionPointColor = NSColor(white: 1, alpha: 0.5)
        
        view.wantsLayer = true
        view.layer!.cornerRadius = view.frame.width / 2
        view.layer!.masksToBounds = true
        
        submitButton.isEnabled = false
        submitButton.wantsLayer = true
        submitButton.layer!.backgroundColor = NSColor(white: 1, alpha: 0.1).cgColor
        submitButton.layer!.borderWidth = 1
        submitButton.layer!.cornerRadius = 4
        submitButton.layer!.borderColor = NSColor(red: 0.6, green: 0.8, blue: 1, alpha: 0.3).cgColor
        
    }
    
    func textDidChange(_ notification: Notification) {
        
        if bugContent.string! == "" {
            submitButton.isEnabled = false
        } else {
            submitButton.title = "Submit Bug"
            submitButton.isEnabled = true
        }
        bugContent.reloadAppearance()
    }
    
}

class BugTextView: NSTextView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        /*
         if (self.string! == "") {
         let placeHolderString: NSAttributedString = NSAttributedString(string: "Send us the bug, or ask us any questions...", attributes: [NSForegroundColorAttributeName : NSColor(white: 1, alpha: 0.5), NSFontAttributeName: NSFont(name: "Source Sans Pro", size: 13.5)!])
         placeHolderString.draw(at: NSPoint(x: 5, y: -4))
         } else {
         self.textStorage!.addAttribute(NSForegroundColorAttributeName, value: NSColor.white, range: NSMakeRange(0, self.textStorage!.length - 1))
         }*/
        
    }
    
    override func awakeFromNib() {
        self.insertionPointColor = NSColor(white: 1, alpha: 0.7)
    }
    
    func reloadAppearance() {
        self.textColor = NSColor.white
        
        let pstyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        pstyle.paragraphSpacing = 7
        self.textStorage?.addAttribute(NSParagraphStyleAttributeName, value: pstyle, range: NSMakeRange(0, self.textStorage!.length))
        
        let font = NSFont(name: "Source Sans Pro", size: 13.5)
        if self.font != font {
            self.font = font
        }
    }
}
