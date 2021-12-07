//
//  AnnouncementViewController.swift
//  EA Manager
//
//  Created by Jia Rui Shan on 12/21/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class AnnouncementViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var messageTitle: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    override func viewWillAppear() {
        view.window!.styleMask.insert(.texturedBackground)
        view.window!.backgroundColor = NSColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textDidChange(Notification(name: Notification.Name(rawValue: ""), object: nil))
    }
    
    func textDidChange(_ notification: Notification) {
        let font = NSFont(name: "Source Sans Pro", size: 13.5)
        if textView.font != font {
            textView.font = font
        }
        let pstyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        pstyle.paragraphSpacing = 7
        pstyle.lineSpacing = 5
        textView.textStorage?.addAttribute(NSParagraphStyleAttributeName, value: pstyle, range: NSMakeRange(0, textView.textStorage!.length))
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        sendButton.isEnabled = messageTitle.stringValue != ""
    }
    
    @IBAction func sendMessage(_ sender: NSButton) {
        
        sender.isHidden = true
        spinner.startAnimation(nil)
        
        let filter = UserDefaults.standard.string(forKey: "Message Filter") ?? ""
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "y/MM/dd HH:mm:ss:SSS"
        let date = formatter.string(from: Date())
        
        let url = URL(string: serverAddress + "tenicCore/SendMessage.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "date=\(date)&message=\([filter.encodedString(), messageTitle.stringValue.encodedString(), textView.string!.encodedString()].joined(separator: "\u{2028}"))"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if error != nil {
                print("error=\(error!)")
            } else {
                print(String(data: data!, encoding: String.Encoding.utf8)!)
                DispatchQueue.main.async {
                    self.spinner.stopAnimation(nil)
                    self.messageTitle.stringValue = ""
                    self.textView.string = ""
                    sender.isHidden = false
                }
            }
        }
        task.resume()
    }
    
}
