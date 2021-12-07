//
//  CheckForUpdates.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/30/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Foundation
import Cocoa
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


var ischecking = false

func checkForUpdates(_ active: Bool) {
    if !logged_in {return}
    if ischecking {return}
    ischecking = true
    
    let ap = NSApplication.shared().delegate as! AppDelegate
    
    if active {
        ap.vc.updateDownloadProgress.startAnimation(nil)
        ap.vc.eaInfoLabel.stringValue = "Checking for update..."
    }
    
    let alert = NSAlert()

    let url = URL(string: serverAddress + "tenicCore/CheckUpdate.php")!
    
    let task = URLSession.shared.dataTask(with: url) {
        data, response, error in
        if error != nil {
            print("error=\(error!)")
            if !active {return}
            DispatchQueue.main.async {
                alert.messageText = "Connection Error!"
                alert.informativeText = "We did not establish a connection to our server. Please try again later."
                alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                alert.runModal()
                ap.vc.updateDownloadProgress.stopAnimation(nil)
                ap.vc.updateDownloadProgress.isHidden = true
                ap.vc.updateStats()
            }
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
            var updateInfo = json[2] as! [String:String]
            let currentVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
            ischecking = false
            DispatchQueue.main.async {
                if active {
                    ap.vc.updateDownloadProgress.stopAnimation(nil)
                    ap.vc.updateStats()
                } else {
//                    ap.vc.eaInfoLabel.stringValue = "Update is available."
                }
            }
            if Int(updateInfo["Version"]!) > Int(currentVersion) {
                DispatchQueue.main.asyncAfter(deadline: .now()) {

                    alert.messageText = "An Update is Available!"
                    alert.informativeText = updateInfo["Description"]!
                    alert.addButton(withTitle: "Update").keyEquivalent = "\r"
                    if updateInfo["Importance"]! == "0"{
                        alert.addButton(withTitle: "Not Now")
                    }
                    if alert.runModal() == NSAlertFirstButtonReturn {
                        ap.vc.startUpdate()
                    } else {
                        ap.vc.updateStats()
                    }
                }
            } else if active {
                DispatchQueue.main.async {
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.messageText = "No Update Available"
                    alert.informativeText = "This is currently the newest version of EA Manager."
                    ap.vc.eaInfoLabel.stringValue = ""
                    alert.runModal()
                }
            }
            
        } catch let err as NSError {
            print(err)
        }
        return
    }
    task.resume()
    
}
