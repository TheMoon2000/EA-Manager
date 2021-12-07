//
//  ConfirmationWindow.swift
//  Find my EA
//
//  Created by Jia Rui Shan on 3/22/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class ConfirmationWindow: NSWindowController {
    override func windowDidLoad() {
        window!.standardWindowButton(.zoomButton)?.isHidden = true
        window!.titlebarAppearsTransparent = true
        window!.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        window!.isMovableByWindowBackground = true
    }
}

class ConfirmationView: NSViewController {

    @IBOutlet weak var confirmButton: NSButton!
    @IBOutlet weak var fullname: NSTextField!
    @IBOutlet weak var email: NSTextField!
    @IBOutlet weak var advisory: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in [fullname, email, advisory] {
            let attrStr = NSMutableAttributedString(string: (i?.placeholderString!)!)
            attrStr.addAttributes([
                NSFontAttributeName: NSFont(name: "Raleway", size: 14)!,
                NSForegroundColorAttributeName: NSColor(white: 0.9, alpha: 0.4)
                ], range: NSMakeRange(0, attrStr.length))
            i?.placeholderAttributedString = attrStr
        }
        
        fullname.stringValue = appfullname
        if appadvisory.contains("@") {
            email.stringValue = appadvisory
        } else {
            advisory.stringValue = appadvisory
        }
    }
        
    override func viewDidAppear() {
        super.viewDidLoad()
        
        confirmButton.wantsLayer = true
        confirmButton.layer!.backgroundColor = NSColor(red: 0.1, green: 0.7, blue: 0.9, alpha: 0.15).cgColor
        confirmButton.layer!.borderWidth = 1
        confirmButton.layer!.cornerRadius = 4
        confirmButton.layer!.borderColor = NSColor(white: 1, alpha: 0.25).cgColor
        
        advisory.isEditable = false
        advisory.textColor = NSColor(white: 0.98, alpha: 0.6)
        advisory.stringValue = "Unavailable to staff members"
    }
    
    func updateInfo(_ sender: NSButton) {
        
        sender.title = "Saving Profile..."
        sender.alphaValue = 0.6
        sender.isEnabled = false
        
        appadvisory = email.stringValue
        appfullname = fullname.stringValue
        
        let d = UserDefaults.standard
        d.set(appstudentID, forKey: "ID")
        d.set(loginPass.data(using: String.Encoding.utf8), forKey: "Password")
        
        logged_in = true
        
        let url = URL(string: serverAddress + "tenicCore/UserUpdate.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "id=\(appstudentID)&name=\(fullname.stringValue)&advisory=&email=\(email.stringValue)&host=\(Host.current().name!)&password=\(loginPass.encodedString())&admin=0"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error != nil {
                print(error!)
            }

            if String(data: data!, encoding: String.Encoding.utf8)! == "successful" {
                DispatchQueue.main.async {
                    
                    let path: NSString = "~/Library/Application Support/Find my EA/.identity.tenic"
                    var identity = NSKeyedUnarchiver.unarchiveObject(withFile: path.expandingTildeInPath) as? [String:String] ?? [String:String]()
                    identity["ID"] = appstudentID
                    identity["Advisory"] = appadvisory
                    identity["Name"] = appfullname
                    NSKeyedArchiver.archiveRootObject(identity, toFile: path.expandingTildeInPath)
                    
                    self.performSegue(withIdentifier: "Finish Confirmation", sender: self)
                    logged_in = true
                    self.view.window?.performClose(nil)
                }
            } else {
                print(String(data: data!, encoding: String.Encoding.utf8) ?? "Unable to display string")
                sender.title = "Update Profile"
                sender.isEnabled = true
                sender.alphaValue = 1
            }
        }
        task.resume()

    }
    
}

class ConfirmButton: NSButton {
    
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
            self.layer?.backgroundColor = NSColor(red: 0.05, green: 0.6, blue: 0.85, alpha: 0.1).cgColor
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        if mouseIsIn {
            let vc = self.window?.contentViewController as! ConfirmationView
            vc.updateInfo(self)
        }
        self.layer?.backgroundColor = NSColor(red: 0.1, green: 0.7, blue: 0.9, alpha: 0.15).cgColor
    }
}
