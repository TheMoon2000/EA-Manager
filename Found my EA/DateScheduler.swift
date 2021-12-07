//
//  DateScheduler.swift
//  EA Manager
//
//  Created by Jia Rui Shan on 4/25/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class DateScheduler: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    let vc = (NSApplication.shared().delegate as! AppDelegate).vc
    let EA_Name = (NSApplication.shared().delegate as! AppDelegate).vc.EA_Name.stringValue
    
    @IBOutlet weak var topLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var datePicker: NSDatePicker!
    
    var needsUpdate = true
    var dates = [String]() {
        didSet {
            if !needsUpdate {return}
            for i in 0..<vc.myEAs.count {
                if vc.myEAs[i].name == EA_Name {
                    needsUpdate = false
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US")
                    formatter.dateFormat = "MMM. d, y"
                    dates.sort {date1, date2 -> Bool in
                        return formatter.date(from: date1)!.timeIntervalSince(formatter.date(from: date2)!) < 0
                    }
                    needsUpdate = true
                    vc.myEAs[i].dates = dates.joined(separator: " | ")
                    vc.changeStatusForKey("Dates", value: dates.joined(separator: " | "), spinner: NSProgressIndicator(), updateRow: false)
                    tableView.reloadData()
                    break
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.window?.backgroundColor = NSColor(red: 0.9, green: 0.95, blue: 1, alpha: 1)
        
        let nib = NSNib(nibNamed: "EASessionCell", bundle: Bundle.main)
        tableView.register(nib, forIdentifier: "Session Cell")
        
        let theEA = vc.myEAs.filter({$0.name == EA_Name})[0]
        
        dates = theEA.dates.components(separatedBy: " | ")
        
        topLabel.stringValue = "Upcoming dates for \(EA_Name):"
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        
        deleteButton.isEnabled = false
        
        datePicker.minDate = formatter.date(from: theEA.startDate)
        datePicker.maxDate = formatter.date(from: theEA.endDate)
        
        datePicker.dateValue = Date()
        
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        deleteButton.isEnabled = tableView.selectedRow != -1
        deleteButton.title = tableView.selectedRowIndexes.count == 1 ? "Delete Date" : "Delete Dates"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "Session Cell", owner: self) as! EASessionCell
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        let date = formatter.date(from: dates[row])!
        cell.enabled = date.timeIntervalSince(Date()) > 0
        formatter.dateFormat = "MMMM dd, y (EEEE)"
        cell.dateLabel.stringValue = formatter.string(from: date)
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let cell = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! EASessionCell
        return cell.enabled
    }
    
    @IBAction func addDate(_ sender: NSButton) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        let today = formatter.string(from: Date())
        let alert = NSAlert()
        if dates.contains(formatter.string(from: datePicker.dateValue)) {
            alert.messageText = "Date Already Exists!"
            alert.informativeText = "By school regulation, no EA is suppose to run twice on the same day."
            alert.addButton(withTitle: "OK").keyEquivalent = "\r"
            alert.window.title = "EA Manager Session Scheduler"
            alert.runModal()
        } else if formatter.string(from: datePicker.dateValue) == today {
            alert.messageText = "You are Too Late!"
            alert.informativeText = "You are attempting to modify a session for your EA within 24 of its runtime. By school regulation, this is not allowed."
            alert.addButton(withTitle: "OK").keyEquivalent = "\r"
            alert.window.title = "EA Manager Session Scheduler"
            alert.runModal()
        } else if Date().timeIntervalSince(datePicker.dateValue) > 0 {
            alert.messageText = "What Are You Doing?"
            alert.informativeText = "You are attempting to add a session to the past. You can't do that."
            alert.addButton(withTitle: "OK").keyEquivalent = "\r"
            alert.window.title = "EA Manager Session Scheduler"
            alert.runModal()
        } else {
            dates.append(formatter.string(from: datePicker.dateValue))
            let position = dates.index(of: formatter.string(from: datePicker.dateValue))!
            tableView.scrollRowToVisible(position)
            deleteButton.isEnabled = true
            tableView.selectRowIndexes(IndexSet(integer: position), byExtendingSelection: false)
        }
    }
    
    @IBAction func deleteDate(_ sender: NSButton) {
        needsUpdate = false
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        
        var tmpDates = dates
        
        for i in tableView.selectedRowIndexes {
            if let cell = self.tableView.view(atColumn: 0, row: i, makeIfNecessary: false) as? EASessionCell {
                formatter.dateFormat = "MMMM dd, y (EEEE)"
                let date = formatter.date(from: cell.dateLabel.stringValue)!
                formatter.dateFormat = "MMM. d, y"
                tmpDates.remove(at: tmpDates.index(of: formatter.string(from: date))!)
                let today = formatter.date(from: formatter.string(from: Date()))!
                if tableView.selectedRowIndexes.contains(i) && date.timeIntervalSince(today) == 0 && tableView.selectedRowIndexes.count == 1 {
                    let alert = NSAlert()
                    alert.messageText = "You are Too Late!"
                    alert.informativeText = "You are attempting to modify at least one session for your EA within 24 of its runtime. By school regulation, this is not allowed."
                    alert.runModal()
                    return
                }
            }
        }
        needsUpdate = true
        
        tableView.removeRows(at: tableView.selectedRowIndexes, withAnimation: .effectFade)
        
        deleteButton.isEnabled = false
        
        if !tmpDates.contains(vc.nextSessionDate) {
            vc.nextDate(sender)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dates = tmpDates
        }
        
    }
}

class SchedulerWindow: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titlebarAppearsTransparent = true
        window?.standardWindowButton(.zoomButton)?.isHidden = true
        window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window?.standardWindowButton(.closeButton)?.isHidden = true
        self.window?.backgroundColor = NSColor(red: 0.9, green: 0.95, blue: 1, alpha: 1)
    }
}
