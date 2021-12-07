//
//  LoginView.swift
//  Find my EA
//
//  Created by Jia Rui Shan on 1/23/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa
import CoreWLAN

var loginPass = ""

let appversion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String

class LoginView: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var verticalBanner: NSView!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var loginView: NSView!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var loginErrorPrompt: NSTextField!
    @IBOutlet weak var loginSpinner: NSProgressIndicator!
    @IBOutlet weak var signupView: NSView!
//    @IBOutlet weak var signupErrorPrompt: NSTextField!
    @IBOutlet weak var backButton: SignupButton!
    @IBOutlet weak var rememberPassword: ITSwitch!
    @IBOutlet weak var bottomView: NSView!
    
    @IBOutlet weak var signupID: NSTextField!
    @IBOutlet weak var signupIDPrompt: NSTextField!
    @IBOutlet weak var stepOneContinueButton: NSButton!
    @IBOutlet weak var signupIDSpinner: NSProgressIndicator!
    @IBOutlet weak var signupPassword: NSSecureTextField!
    @IBOutlet weak var signupPasswordConfirm: NSSecureTextField!
    @IBOutlet weak var createUserSpinner: NSProgressIndicator!
    
    @IBOutlet weak var identityView: NSView!
    @IBOutlet weak var identityName: NSTextField!
    @IBOutlet weak var identityAdvisory: NSTextField!
    @IBOutlet weak var identityPrompt: NSTextField!
    @IBOutlet weak var finishSignupButton: NSButton!
    
    @IBOutlet weak var loginID: NSTextField!
    @IBOutlet weak var loginPassword: NSSecureTextField!
    
    @IBOutlet weak var closeButton: CloseButton!
    
    let d = UserDefaults.standard
    
    override func viewDidLoad() {
        loginview = self
        loginButton.isEnabled = true
        stepOneContinueButton.isEnabled = false
        signupView.wantsLayer = true
        loginView.wantsLayer = true
        bottomView.wantsLayer = true
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        version.stringValue = currentVersion
        version.isHidden = true
        
        loginID.becomeFirstResponder()
        super.viewDidLoad()
        verticalBanner.wantsLayer = true
        
        let themeColor = NSColor(red: 30/255, green: 140/255, blue: 220/255, alpha: 1)
        closeButton.isHidden = false
        finishSignupButton.image = #imageLiteral(resourceName: "continueLogin_blue")
        loginButton.image = #imageLiteral(resourceName: "continueLogin_blue")
        stepOneContinueButton.image = #imageLiteral(resourceName: "continueLogin_blue")
        //}
            
        verticalBanner.layer?.backgroundColor = themeColor.cgColor

        rememberPassword.tintColor = themeColor
        
        if d.bool(forKey: "Remember Password") {
            loginID.stringValue = d.string(forKey: "ID") ?? ""
            let passdata = d.value(forKey: "Password") as? Data ?? "".data(using: String.Encoding.utf8)
            loginPassword.stringValue = String(data: passdata!, encoding: String.Encoding.utf8) ?? ""
            loginButton.keyEquivalent = "\r"
            rememberPassword.checked = true
        }
    }
    
    var BCISWIFI = false
    
    @IBAction func login(_ sender: NSButton) {
        
        if let _ = Int(loginID.stringValue) {
            loginErrorPrompt.stringValue = ""
        } else if loginID.stringValue != "SSEA" {
            loginErrorPrompt.textColor = NSColor(red: 209/255, green: 37/255, blue: 34/255, alpha: 0.8)
            loginErrorPrompt.stringValue = "You must enter an 8-digit ID"
            return
        }
        
        if !teacher(loginID.stringValue) {
            loginErrorPrompt.textColor = NSColor(red: 209/255, green: 37/255, blue: 34/255, alpha: 0.8)
            loginErrorPrompt.stringValue = "Insufficient Privilege"
            return
        } else {
            loginErrorPrompt.stringValue = ""
        }
        
        if !sender.isHidden {BCISWIFI = true}
        
        sender.isHidden = true
        loginSpinner.startAnimation(nil)
        loginID.layer?.borderWidth = 0
        
        d.set(self.rememberPassword.checked, forKey: "Remember Password")
        
        let currentMAC = shell("/usr/sbin/networksetup", arguments: ["-getmacaddress", "wi-fi"]).components(separatedBy: " ")[2]
        
        // School wifi connection
        if schoolWifi.contains(CWWiFiClient()?.interface()?.ssid() ?? "") && BCISWIFI {
            DispatchQueue.global().async {
                let result = shell("/usr/bin/php", arguments: [Bundle.main.bundlePath + "/Contents/Resources/ADAuthentication.php", self.loginID.stringValue, self.loginPassword.stringValue])
                if result.hasSuffix("1") {
                    appstudentID = self.loginID.stringValue // This is the login ID
                    print("BCIS auth passed")
                    let url = URL(string: serverAddress + "tenicCore/AdminAuthentication.php")
                    var request = URLRequest(url: url!)
                    request.httpMethod = "POST"
                    let postString = "username=\(self.loginID.stringValue)&password=\(self.loginPassword.stringValue.encodedString())&hostname=\(Host.current().name!)&mac=\(currentMAC)&version=x"
                    request.httpBody = postString.data(using: String.Encoding.utf8)
                    let task = URLSession.shared.dataTask(with: request) {
                        data, response, error in
                        if error != nil {
                            print(error!)
                        }
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary as! [String:String]
                            if json["message"]! == "User does not exist :(" {
                                DispatchQueue.main.async {
                                    loginPass = self.loginPassword.stringValue
                                    self.performSegue(withIdentifier: "Confirmation", sender: self)
                                    self.view.window?.performClose(nil)
                                } // Confirm window
                            } else {
                                DispatchQueue.main.async {
                                    self.BCISWIFI = false
                                    self.login(sender)
                                }
                                return
                            }
                        } catch {
                            print(String(data: data!, encoding: String.Encoding.utf8)!)
                        }
                        DispatchQueue.main.async {
                            self.loginSpinner.stopAnimation(nil)
                            sender.isHidden = false
                        }
                    }
                    task.resume()
                } else {
                    DispatchQueue.main.async {
                        print("Wrong BCIS account")
                        self.BCISWIFI = false
                        self.login(sender)
                    }
                }
                
            }
            return
        }
        
        // Remote authentication
        
        let url = URL(string: serverAddress + "tenicCore/AdminAuthentication.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "username=\(loginID.stringValue)&password=\(loginPassword.stringValue.encodedString())&hostname=\(Host.current().name!)&mac=\(currentMAC)&version=\(appversion)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, reponse, error in
            if error != nil || data == nil {
                DispatchQueue.main.async {
                    self.loginErrorPrompt.textColor = NSColor(red: 209/255, green: 37/255, blue: 34/255, alpha: 0.8)
                    self.loginErrorPrompt.stringValue = "Connection Error."
                }
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary as! [String:String]
                    if json["status"]! == "success" {
                        DispatchQueue.main.async {
                            let userInfo = json["message"]!.components(separatedBy: "|")
                            appstudentID = userInfo[0]
                            appfullname = userInfo[1]
                            appadvisory = userInfo[2]
                            self.d.set(appstudentID, forKey: "ID")
                            self.d.set(self.loginPassword.stringValue.data(using: String.Encoding.utf8), forKey: "Password")
                            
                            self.d.set(self.rememberPassword.checked, forKey: "Remember Password")
                            logged_in = true
                            
                            let block = {
                                self.performSegue(withIdentifier: "Show Main Window", sender: self)
                                self.view.window!.orderOut(self)
                            }
                            if currentMAC != userInfo[3] && userInfo[3] != "bogon" && userInfo[3] != "" {
                                let alert = NSAlert()
                                alert.messageText = "Suspicious Activity Detected"
                                alert.alertStyle = .critical
                                let hostname = userInfo[4].components(separatedBy: ".")[0]
                                alert.informativeText = "Your account has been used to log in to EA Manager from a different computer(\(hostname == "" ? "unknown" : hostname)). If that's not you, we strongly recommend you to change your password."
                                alert.addButton(withTitle: "I Understand").keyEquivalent = "\r"
                                alert.beginSheetModal(for: self.view.window!) {response in
                                    block()
                                }
                            } else {
                                block()
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.loginErrorPrompt.stringValue = json["message"]!
                            self.loginErrorPrompt.textColor = NSColor(red: 209/255, green: 37/255, blue: 34/255, alpha: 0.8)
                            if json["message"]!.contains("ssword") {
                                self.loginPassword.wantsLayer = true
                                self.loginPassword.layer?.borderColor = NSColor.red.cgColor
                                self.loginPassword.layer?.borderWidth = 1
                                self.loginPassword.layer?.cornerRadius = 4
                            } else if json["message"]!.contains("sername") || json["message"]!.contains("User") {
                                self.loginID.wantsLayer = true
                                self.loginID.layer?.borderColor = NSColor.red.cgColor
                                self.loginID.layer?.borderWidth = 1
                                self.loginID.layer?.cornerRadius = 4
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.loginErrorPrompt.textColor = NSColor(red: 209/255, green: 37/255, blue: 34/255, alpha: 0.8)
                        self.loginErrorPrompt.stringValue = "Connection Error."
                    }
                }
            }
            DispatchQueue.main.async {
                self.loginSpinner.stopAnimation(nil)
                sender.isHidden = false
            }
        }
        task.resume()
    }
    
    @IBAction func createUser(_ sender: NSButton) {
        sender.isHidden = true
        let currentMAC = shell("/usr/sbin/networksetup", arguments: ["-getmacaddress", "wi-fi"]).components(separatedBy: " ")[2]
        createUserSpinner.startAnimation(nil)
        let url = URL(string: serverAddress + "tenicCore/NewUserRegistration.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "username=\(signupID.stringValue)&password=\(signupPassword.stringValue.encodedString())&advisory=\(identityAdvisory.stringValue)&realname=\(identityName.stringValue)&mac=\(currentMAC)&computer=\(Host.current().name!)&version=\(appversion)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, reponse, error in
            if error != nil {
                print(error!)
                DispatchQueue.main.async { self.createUserSpinner.stopAnimation(nil) }
                return
            }
            DispatchQueue.main.async {
                self.createUserSpinner.stopAnimation(nil)
                sender.isHidden = false
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary as! [String:String]
                if json["status"]! == "success" {
                    DispatchQueue.main.async {
                        self.identityView.isHidden = true
                        self.loginView.isHidden = false
                        self.loginView.alphaValue = 1
                        self.bottomView.isHidden = false
                        self.backButton.isHidden = true
                        self.loginID.layer?.borderWidth = 0
                        self.loginErrorPrompt.textColor = NSColor(red: 70/255, green: 0.9, blue: 70/255, alpha: 0.8)
                        self.loginErrorPrompt.stringValue = "Please activate your account through email."
                    }
                } else {
                    DispatchQueue.main.async {
                        print(json)
                    }
                }
            } catch {
                print(String(data: data!, encoding: String.Encoding.utf8)!)
            }
        }
        task.resume()
    }
    
    @IBAction func signup(_ sender: NSButton) {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = 0
        animation.toValue = -30
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        loginView.layer?.add(animation, forKey: "Move")
        
        let dissolve = CABasicAnimation(keyPath: "opacity")
        loginView.alphaValue = 0
        dissolve.fromValue = 1
        dissolve.toValue = 0
        dissolve.duration = 0.2
        dissolve.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        loginView.layer?.add(dissolve, forKey: "Dissolve")

        animation.fromValue = 30
        animation.toValue = 0
        signupView.layer?.add(animation, forKey: "Signup")
        
        signupView.isHidden = false
        signupView.alphaValue = 1
        dissolve.fromValue = 0
        dissolve.toValue = 1
        signupView.layer?.add(dissolve, forKey: "Appear")
        
        backButton.isHidden = false
        backButton.clickable = false
        dissolve.toValue = 0.7
        backButton.layer?.add(dissolve, forKey: "Appear")
        
        bottomView.isHidden = true
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.loginView.isHidden = true
            self.bottomView.isHidden = true
            self.backButton.clickable = true
            self.signupID.becomeFirstResponder()
        }
    }
    
    @IBAction func continueSignup(_ sender: NSButton) {
        
        if signupPassword.stringValue != signupPasswordConfirm.stringValue || signupPassword.stringValue == "" {
            signupPassword.wantsLayer = true
            signupPassword.layer?.borderColor = NSColor.red.cgColor
            signupPassword.layer?.borderWidth = 1
            signupPasswordConfirm.wantsLayer = true
            signupPasswordConfirm.layer?.borderColor = NSColor.red.cgColor
            signupPasswordConfirm.layer?.borderWidth = 1
            return
        }

        identityView.layer?.removeAllAnimations()
        signupView.layer?.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = 0
        animation.toValue = -30
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        signupView.layer?.add(animation, forKey: "Move")
        
        let dissolve = CABasicAnimation(keyPath: "opacity")
        signupView.alphaValue = 0
        dissolve.fromValue = 1
        dissolve.toValue = 0
        dissolve.duration = 0.2
        dissolve.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        signupView.layer?.add(dissolve, forKey: "Dissolve")
        
        animation.fromValue = 30
        animation.toValue = 0
        animation.isRemovedOnCompletion = false
        identityView.layer?.add(animation, forKey: "Signup")
        
        identityView.alphaValue = 1
        identityView.isHidden = false
        dissolve.fromValue = 0
        dissolve.toValue = 1
        identityView.layer?.add(dissolve, forKey: "Appear")
        
        backButton.title = "Previous"
        backButton.clickable = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.signupView.isHidden = true
            self.backButton.clickable = true
            self.identityName.becomeFirstResponder()
        }
    }
    
    func returnLogin(_ sender: NSButton) {
        loginView.layer?.removeAllAnimations()
        signupView.layer?.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = 0
        animation.toValue = 30
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        signupView.layer?.add(animation, forKey: "Move")
        
        let dissolve = CABasicAnimation(keyPath: "opacity")
        signupView.alphaValue = 0
        dissolve.fromValue = 1
        dissolve.toValue = 0
        dissolve.duration = 0.2
        dissolve.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        signupView.layer?.add(dissolve, forKey: "Dissolve")
        
        loginView.isHidden = false
        animation.fromValue = -30
        animation.toValue = 0
        loginView.layer?.add(animation, forKey: "Signup")
        
        loginView.alphaValue = 1
        dissolve.fromValue = 0
        dissolve.toValue = 1
        loginView.layer?.add(dissolve, forKey: "Appear")
        
        bottomView.isHidden = false
        bottomView.alphaValue = 1
        bottomView.layer?.add(dissolve, forKey: "Dissolve")
        
        backButton.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.signupView.isHidden = true
            self.loginID.becomeFirstResponder()
        }
    }
    
    func returnSignup(_ sender: NSButton) {
        identityView.layer?.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = 0
        animation.toValue = 30
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        identityView.layer?.add(animation, forKey: "Move")
        
        let dissolve = CABasicAnimation(keyPath: "opacity")
        identityView.alphaValue = 0
        dissolve.fromValue = 1
        dissolve.toValue = 0
        dissolve.duration = 0.2
        dissolve.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        identityView.layer?.add(dissolve, forKey: "Dissolve")
        
        signupView.isHidden = false
        animation.fromValue = -30
        animation.toValue = 0
        signupView.layer?.add(animation, forKey: "Signup")
        
        signupView.alphaValue = 1
        dissolve.fromValue = 0
        dissolve.toValue = 1
        signupView.layer?.add(dissolve, forKey: "Appear")
        
        backButton.title = "Back to Login"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.identityView.isHidden = true
            self.signupID.becomeFirstResponder()
        }
    }
    
    var currentChecktime = Date()
    
    override func controlTextDidChange(_ obj: Notification) {
        let textfield = obj.object as! NSTextField
        if textfield != signupPassword && textfield != signupPasswordConfirm {
            textfield.layer?.borderWidth = 0
        } else if (textfield == signupPassword || textfield == signupPasswordConfirm) && signupPassword.stringValue == signupPasswordConfirm.stringValue {
            signupPassword.layer?.borderWidth = 0
            signupPasswordConfirm.layer?.borderWidth = 0
        }
        if textfield == signupID {
            stepOneContinueButton.isEnabled = false
            signupIDPrompt.stringValue = ""
            if signupID.stringValue.characters.count != 8 {return}
            if !"01".contains(String(signupID.stringValue.characters.last!)) {return}
            
            signupIDSpinner.startAnimation(nil)
            
        } else {
            if identityAdvisory.stringValue == "" || identityName.stringValue == "" {
                finishSignupButton.isEnabled = false
            } else {
                finishSignupButton.isEnabled = true
            }
            
            return
        }
        currentChecktime = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if Date().timeIntervalSince(self.currentChecktime) > 0.5 {
                let url = URL(string: serverAddress + "tenicCore/FetchAccounts.php")!
                let task = URLSession.shared.dataTask(with: url) {
                    data, response, error in
                    if error != nil {
                        print(error!)
                        return
                    }
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray as! [String]
                        DispatchQueue.main.async {
                            self.stepOneContinueButton.isEnabled = !json.contains(self.signupID.stringValue)
                            if !self.stepOneContinueButton.isEnabled {
                                textfield.wantsLayer = true
                                textfield.layer?.borderWidth = 1
                                textfield.layer?.borderColor = NSColor.red.cgColor
                                textfield.layer?.cornerRadius = 4
                                self.signupIDPrompt.stringValue = "User exists."
                            }
                        }
                    } catch {
                        
                    }
                    DispatchQueue.main.async {
                        self.signupIDSpinner.stopAnimation(nil)
                    }
                }
                task.resume()
            }
        }
    }
    
    @IBAction func finishEditingLoginID(_ sender: NSTextField) {
        if loginPassword.stringValue == "" {
            loginPassword.becomeFirstResponder()
        } else {
            self.login(loginButton)
        }
    }
    
    @IBAction func finishEditingLoginPassword(_ sender: NSSecureTextField) {
        self.login(loginButton)
    }
    
    @IBAction func finishEditingSignupID(_ sender: NSTextField) {
        signupPassword.becomeFirstResponder()
    }
    
    @IBAction func finishEditingSignupPassword(_ sender: NSTextField) {
        signupPasswordConfirm.becomeFirstResponder()
    }
    
    @IBAction func finishEditingSignupPasswordConfirm(_ sender: NSTextField) {
        if stepOneContinueButton.isEnabled {
            self.continueSignup(stepOneContinueButton)
        }
    }
    
    @IBAction func finishEditingFullName(_ sender: NSTextField) {
        identityAdvisory.becomeFirstResponder()
    }
    
    @IBAction func finishEditingAdvisory(_ sender: NSTextField) {
        if finishSignupButton.isEnabled {
            self.createUser(finishSignupButton)
        }
    }
}

var loginview = LoginView()
