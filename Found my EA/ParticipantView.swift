//
//  ParticipantView.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/8/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

let greenColor = NSColor(red: 0.93, green: 1, blue: 0.92, alpha: 0.7).cgColor
let redColor = NSColor(red: 1, green: 0.86, blue: 0.86, alpha: 0.6).cgColor

enum Attendance {
    case absent
    case present
    case unapproved
    case none
}

class ParticipantView: NSTableCellView, NSPopoverDelegate, NSTextFieldDelegate {
    
    var EA_Name = ""
    var userID: String? {
        return self.toolTip?.components(separatedBy: "\r")[0].components(separatedBy: ": ")[1]
    }

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var advisory: NSTextField!
    @IBOutlet weak var approvalButton: NSButton!
    @IBOutlet weak var messageButton: NSButton!
    @IBOutlet weak var approvalSpinner: NSProgressIndicator!
    @IBOutlet weak var approveLabel: NSTextField!
    @IBOutlet weak var attendanceSpinner: NSProgressIndicator!
    
    // Inside the popover
    @IBOutlet weak var message: NSTextField!
    @IBOutlet weak var messageTo: NSTextField!
    @IBOutlet weak var contentView: NSView!
    
    var popover = NSPopover()
    
    var attendance = Attendance.none {
        didSet {
            self.wantsLayer = true
            switch attendance {
            case .none:
                self.layer?.backgroundColor = NSColor(white: 1, alpha: 0.6).cgColor
            case .present:
                self.layer?.backgroundColor = greenColor
            case .absent:
                self.layer?.backgroundColor = redColor
            case .unapproved:
                self.layer?.backgroundColor = NSColor(white: 0.85, alpha: 0.9).cgColor
            }
        }
    }

    @IBAction func sendMessage(_ sender: NSButton) {
        messageTo.stringValue = "\(name.stringValue) (\(advisory.stringValue)) has provided the following information:"
        let vc = NSViewController(nibName: "ParticipantView", bundle: Bundle.main)
        
        vc!.view = contentView
        popover.contentViewController = vc
        popover.behavior = .transient
        popover.show(relativeTo: messageButton.bounds, of: sender, preferredEdge: .maxX)
    }
    
    @IBAction func approve(_ sender: NSButton) {
        if sender.title == "Approve" {
            let id = self.toolTip!.components(separatedBy: "\r")[0].components(separatedBy: ": ")[1]
            updateEA(EA_Name, id: id, key: "Approval", value: "Approved")
            self.approvalSpinner.startAnimation(nil)
            sender.isHidden = true
        }
    }
    
    func updateEA(_ EA: String, id: String, key: String, value: String) {
        let url = URL(string: serverAddress + "tenicCore/EAParticipantUpdate.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        var hasRun = false
        
        let postString = "EA=\(EA_Name)&ID=\(id)&key=\(key)&value=\(value)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if hasRun {return}
            do {
                Swift.print(String(data: data!, encoding: String.Encoding.utf8)!)
                let _ = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary as! [String:String]
                    DispatchQueue.main.async {
                    self.approvalSpinner.stopAnimation(nil)
                    if value == "Approved" {
                        self.approveLabel.isHidden = false
                        self.approvalButton.isHidden = true
                    }
                }
                
                DispatchQueue.main.async {
                    let vc = (NSApplication.shared().delegate as! AppDelegate).vc
                    
                    for i in 0..<vc.participants.count {
                        if vc.participants[i].id == id {
                            vc.participants[i].approval = "Approved"
                        }
                    }
                }
                
                broadcastMessage("Find my EA", message: "You have successfully joined \(EA)!", filter: "I:\(id)")
            } catch {
                Swift.print("error=\(error)")
            }
            hasRun = true
            return
        }
            
        task.resume()

    }
    
    func changeStatusForKey(_ key: String, value: String, spinner: NSProgressIndicator?, id: String, present: Bool?) {
        spinner?.startAnimation(nil)
        let url = URL(string: serverAddress + "tenicCore/EAParticipantUpdate.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        var hasRun = false
        let postString = "EA=\(EA_Name)&key=\(key)&value=\(value)&ID=\(id)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if error != nil {
                return
            }
            if hasRun {return}
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                if json["status"] as! String != "success" {return}
                DispatchQueue.main.async {
                    spinner?.stopAnimation(nil)
                    self.popover.close()
                    if (present != nil) && present! {
                        self.attendance = .present
                    } else if (present != nil) && !present! {
                        self.attendance = .absent
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    spinner?.stopAnimation(nil)
                    let alert = NSAlert()
                    alert.messageText = "Connection to Server Failed"
                    alert.informativeText = "Your modifications to the EA settings have not been uploaded to the server."
                    alert.addButton(withTitle: "OK")
                    let ad = NSApplication.shared().delegate as! AppDelegate
                    alert.beginSheetModal(for: ad.vc.view.window!, completionHandler: nil)
                }
            }
            hasRun = true
            return
        }
        
        task.resume()
    }

    
    
    
}
