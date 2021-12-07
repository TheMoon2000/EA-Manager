//
//  ResetPassword.swift
//  Find my EA
//
//  Created by Jia Rui Shan on 1/24/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class ResetPassword: NSViewController {

    @IBOutlet weak var verticalBanner: NSView!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var oldPassword: NSSecureTextField!
    @IBOutlet weak var newPassword: NSSecureTextField!
    @IBOutlet weak var newPasswordConfirm: NSSecureTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var warning: NSTextField!
    @IBOutlet weak var changeButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verticalBanner.wantsLayer = true
        let themeColor = NSColor(red: 30/255, green: 140/255, blue: 220/255, alpha: 1)
        
        changeButton.image = #imageLiteral(resourceName: "continueLogin_blue")
        
        verticalBanner.layer?.backgroundColor = themeColor.cgColor
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        version.stringValue = currentVersion
        version.isHidden = true
    }
    
    @IBAction func changePassword(_ sender: NSButton) {
        warning.textColor = NSColor(red: 209/255, green: 37/255, blue: 34/255, alpha: 0.8)
        if newPassword.stringValue != newPasswordConfirm.stringValue {
            warning.stringValue = "Passwords don't match"
            return
        } else if newPassword.stringValue == "" {
            warning.stringValue = "Password should not be blank"
            return
        } else {
            warning.stringValue = ""
        }
        
        sender.isHidden = true
        spinner.startAnimation(nil)
        let url = URL(string: serverAddress + "tenicCore/ResetPassword.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "username=\(appstudentID)&old=\(oldPassword.stringValue.encodedString())&new=\(newPassword.stringValue.encodedString())"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, reponse, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.warning.stringValue = "Connection error."
                    sender.isHidden = false
                    self.spinner.stopAnimation(nil)
                }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary as! [String:String]
                DispatchQueue.main.async {
                    self.spinner.stopAnimation(nil)
                    sender.isHidden = false
                    if json["status"]! == "success" {
                        self.warning.stringValue = "Password changed."
                        self.warning.textColor = NSColor(red: 70/255, green: 0.9, blue: 70/255, alpha: 0.8)
                        let d = UserDefaults.standard
                        d.set(self.newPassword.stringValue.data(using: String.Encoding.utf8), forKey: "Password")
                        UserDefaults.standard.set(self.newPassword.stringValue.data(using: String.Encoding.utf8), forKey: "Password")
                    } else {
                        self.warning.stringValue = json["message"]!
                        self.warning.textColor = NSColor(red: 209/255, green: 37/255, blue: 34/255, alpha: 0.8)
                    }
                }
            } catch {
                
            }
        }
        task.resume()
    }
    
    @IBAction func finishEditingOldPassword(_ sender: NSTextField) {
        newPassword.becomeFirstResponder()
    }
    
    @IBAction func finishEditingNewPassword(_ sender: NSTextField) {
        newPasswordConfirm.becomeFirstResponder()
    }
    
    @IBAction func finishEditingNewPasswordConfirm(_ sender: NSTextField) {
        self.changePassword(changeButton)
    }
    
}
