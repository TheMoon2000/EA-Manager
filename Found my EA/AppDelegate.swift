//
//  AppDelegate.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/5/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

let serverAddress = "http://47.52.6.204/"


var appadvisory = ""
var appfullname = ""
var appstudentID = ""

let schoolWifi = ["BCIS WIFI", "BCIS INF"]

var AESKey = "Tenic"

var logged_in = false {
    didSet {
        let menu = NSApplication.shared().mainMenu!.item(withTitle: "EA Manager")!
        menu.submenu?.item(withTitle: "Change Password")?.isEnabled = logged_in
        let filemenu = NSApplication.shared().mainMenu!.item(withTitle: "File")
        filemenu!.submenu?.item(withTitle: "Export...")?.isEnabled = logged_in
        menu.submenu?.item(withTitle: "Log in...")?.isHidden = logged_in
        menu.submenu?.item(withTitle: "Log out...")?.isHidden = !logged_in
        menu.submenu?.item(withTitle: "Update Profile...")?.isEnabled = logged_in
        menu.submenu?.item(withTitle: "Make Announcement...")?.isEnabled = logged_in
    }
}

func teacher(_ id: String) -> Bool { // A function that determines whether a given ID is of a teacher or student
    
    if ["SSEA", "99999999"].contains(id) {return true}
    
    if id.characters.count < 8 {return false}
    
    if id.characters.count == 10 {return false}
    
    let year = String(Array(id.characters)[0...1])
    
    return year == "20"
}

func regularizeID(_ id: String) -> String? {
    if ["99999999", "SSEA"].contains(id) {
        return id
    } else if ![10,8].contains(id.characters.count) || Int(id) == nil || !["0", "1"].contains(String(id.characters.last!)) && id.characters.count != 8 {
        return nil
    } else if id.characters.count == 8 && !id.hasPrefix("20") {
        return "20" + id
    } else {
        return id
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    var vc = ViewController()
    
    @IBOutlet weak var boldMenuItem: NSMenuItem!
    @IBOutlet weak var updateItem: NSMenuItem!
    @IBOutlet weak var installUpdate: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func logout(_ sender: NSMenuItem) {
        vc.logout(NSButton())
    }
    
    @IBAction func checkforUpdates(_ sender: NSMenuItem) {
        checkForUpdates(true)
    }
    
    @IBAction func export(_ sender: NSMenuItem) {
        vc.writeEAsToFile(sender)
    }
    
    @IBAction func installUpdate(_ sender: NSMenuItem) {
        let command = Terminal(launchPath: "/usr/bin/open", arguments: [NSTemporaryDirectory() + "EA Manager.pkg"])
        command.execUntilExit()
        NSApplication.shared().terminate(0)
        sender.isEnabled = false
    }
    
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if item?.title == "Install Update" {
            let attributes = [NSFontAttributeName: NSFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: NSColor(red: 1, green: 0.99, blue: 0.7, alpha: 1)]
            installUpdate.attributedTitle = NSAttributedString(string: installUpdate.title, attributes: attributes)
        } else {
            let attributes = [NSFontAttributeName: NSFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: NSColor(red: 1/255, green: 141/255, blue: 140/255, alpha:1)]
            installUpdate.attributedTitle = NSAttributedString(string: installUpdate.title, attributes: attributes)
        }
    }
    
    @IBAction func visitFacebook(_ sender: NSMenuItem) {
        NSWorkspace.shared().open(URL(string: "https://www.facebook.com/teamtenic/")!)
    }
    
    @IBAction func visitWebsite(_ sender: NSMenuItem) {
        NSWorkspace.shared().open(URL(string: "http://tenic.xyz/")!)
    }
}

func broadcastMessage(_ title: String, message: String, filter: String) {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "y/MM/dd HH:mm:ss:SSS"
    let date = formatter.string(from: Date())
    let url = URL(string: serverAddress + "tenicCore/SendMessage.php")
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    let postString = "date=\(date)&message=\([filter.encodedString(), title.encodedString(), message.encodedString()].joined(separator: "\u{2028}"))"
    request.httpBody = postString.data(using: String.Encoding.utf8)
    let task = URLSession.shared.dataTask(with: request) {
        data, response, error in
        if error != nil {
            print("error=\(error!)")
        }
        return
    }
    task.resume()
}
