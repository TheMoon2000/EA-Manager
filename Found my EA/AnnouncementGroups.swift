//
//  AnnouncementGroups.swift
//  EA Manager
//
//  Created by Jia Rui Shan on 12/26/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class AnnouncementGroups: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var gradeLevel: NSButton!
    @IBOutlet weak var studentID: NSButton!
    @IBOutlet weak var EAs: NSButton!
    @IBOutlet weak var advisories: NSButton!
    @IBOutlet weak var IDs: NSTextField!
    @IBOutlet weak var EAList: NSTextField!
    @IBOutlet weak var advisoryList: NSTextField!
    @IBOutlet weak var fromGrade: NSPopUpButton!
    @IBOutlet weak var toGrade: NSPopUpButton!
    @IBOutlet weak var anyButton: NSButton!
    @IBOutlet weak var allButton: NSButton!
    
    var any = true
    var separator = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let filter = UserDefaults.standard.string(forKey: "Message Filter") ?? ""
        if filter == "" {return}
        separator = ""
        if filter.contains("&&") {
            separator = "&&"
            anyButton.state = 0
            allButton.state = 1
        } else {
            separator = "||"
            anyButton.state = 1
            allButton.state = 0
        }
        if separator == "" {return}
        for i in filter.components(separatedBy: separator) {
            let entry = i.components(separatedBy: ":")
            switch entry[0] {
            case "G":
                fromGrade.title = entry[1].components(separatedBy: "-")[0]
                toGrade.title = entry[1].components(separatedBy: "-")[1]
                gradeLevel.state = 1
                enableGradeFilter(gradeLevel)
            case "I":
                IDs.stringValue = entry[1]
                studentID.state = 1
                IDs.isEnabled = true
            case "E":
                EAList.stringValue = entry[1]
                EAs.state = 1
                EAList.isEnabled = true
            case "A":
                advisoryList.stringValue = entry[1]
                advisories.state = 1
                advisoryList.isEnabled = true
            default:
                break
            }
        }
    }
    
    @IBAction func updateGradeFilters(_ sender: NSPopUpButton) {
        saveFilterToFile()
    }
    
    @IBAction func anyOrAll(_ sender: NSButton) {
        any = sender == anyButton
        saveFilterToFile()
    }
    
    @IBAction func enableGradeFilter(_ sender: NSButton) {
        fromGrade.isEnabled = sender.objectValue as! Bool
        toGrade.isEnabled = fromGrade.isEnabled
        saveFilterToFile()
    }
    
    @IBAction func enableIDs(_ sender: NSButton) {
        IDs.isEnabled = sender.objectValue as! Bool
        IDs.selectText(nil)
        saveFilterToFile()
    }
    
    @IBAction func enableEAs(_ sender: NSButton) {
        EAList.isEnabled = sender.objectValue as! Bool
        EAList.selectText(nil)
        saveFilterToFile()
    }
    
    @IBAction func enableAdvisories(_ sender: NSButton) {
        advisoryList.isEnabled = sender.objectValue as! Bool
        advisoryList.selectText(nil)
        saveFilterToFile()
    }
    
    func saveFilterToFile() {
        let d = UserDefaults.standard
        d.setValue(filterString, forKey: "Message Filter")
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        saveFilterToFile()
    }
    
    var filterString: String {
        var criteria = [String]()
        if gradeLevel.objectValue as! Bool {criteria.append("G:\(fromGrade.title)-\(toGrade.title)")}
        if studentID.objectValue as! Bool {criteria.append("I:\(IDs.stringValue)")}
        if EAs.objectValue as! Bool {criteria.append("E:\(EAList.stringValue)")}
        if advisories.objectValue as! Bool {criteria.append("A:\(advisoryList.stringValue)")}
        let delimiter = any ? "||" : "&&"
        return criteria.joined(separator: delimiter)
    }
    
}
