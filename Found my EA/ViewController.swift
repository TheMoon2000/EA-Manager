//
//  ViewController.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/5/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa
import CoreWLAN
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


let loading_delay = 1.0

let animationPack = NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.path(forResource: "Assets", ofType: "tenic")!) as! [String: Data]

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSTextViewDelegate, NSURLDownloadDelegate, WindowResizeDelegate, GRRequestsManagerDelegate, NSMenuDelegate, NSSplitViewDelegate {
    
    @IBOutlet weak var EATableView: NSTableView!
//    @IBOutlet weak var startupView: NSView!
    @IBOutlet weak var mainView: NSView!
//    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet var loadImage: LoadImage!
    @IBOutlet weak var splitviewLeft: NSView!
    @IBOutlet weak var splitviewRight: NSView!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var EA_Name: NSTextField!
    @IBOutlet weak var noEA_label: NSTextField!
    @IBOutlet weak var eaInfoLabel: NSTextField!
    
    @IBOutlet weak var version: NSTextField!
    
    @IBOutlet weak var activeSwitch: NSSegmentedControl!
    @IBOutlet weak var activeSpinner: NSProgressIndicator!
    
    @IBOutlet weak var monday: NSButton!
    @IBOutlet weak var tuesday: NSButton!
    @IBOutlet weak var wednesday: NSButton!
    @IBOutlet weak var thursday: NSButton!
    @IBOutlet weak var friday: NSButton!
    @IBOutlet weak var frequency: NSPopUpButton!
    @IBOutlet weak var time: NSPopUpButton!
    @IBOutlet weak var time_detail: NSTextField!
    @IBOutlet weak var dateSpinner: NSProgressIndicator!
    @IBOutlet weak var location: NSTextField!
    @IBOutlet weak var locationSpinner: NSProgressIndicator!
    
    @IBOutlet weak var startDate: NSDatePicker!
    @IBOutlet weak var endDate: NSDatePicker!
    @IBOutlet weak var changeEADateSpinner: NSProgressIndicator!
    
    @IBOutlet weak var EA_Description: NSTextField!
    @IBOutlet weak var descriptionCount: NSTextField!
    @IBOutlet weak var descriptionSpinner: NSProgressIndicator!
    @IBOutlet weak var uploadDescriptionButton: NSButton!
    
    @IBOutlet weak var maxStudents: NSComboBox!
    @IBOutlet weak var maxStudentsSpinner: NSProgressIndicator!
    @IBOutlet weak var enableMaxStudents: NSButton!
    @IBOutlet weak var leaderIDs: NSTokenField!
    @IBOutlet weak var leaderIDSpinner: NSProgressIndicator!
    @IBOutlet weak var supervisor: NSTokenField!
    @IBOutlet weak var supervisorLabel: NSTextField!
    @IBOutlet weak var supervisorSpinner: NSProgressIndicator!
    @IBOutlet weak var participantTable: NSTableView!
//    @IBOutlet weak var participantSpinner: NSProgressIndicator!
    @IBOutlet var proposal: ProposalField!
    @IBOutlet weak var participantLoader: LoadImage!
    @IBOutlet weak var prompt: NSTextField!
    @IBOutlet weak var promptSpinner: NSProgressIndicator!
    
    @IBOutlet weak var leaders: NSTokenField!
    @IBOutlet weak var leadersSpinner: NSProgressIndicator!
    
    @IBOutlet weak var categoryPopup: NSPopUpButton!
    @IBOutlet weak var categorySpinner: NSProgressIndicator!
    
    var boldMenuItem: NSMenuItem!
    @IBOutlet var message: NSTextView!
    @IBOutlet weak var fontStyle: NSSegmentedControl!
    @IBOutlet weak var alignmentSegment: NSSegmentedControl!
    @IBOutlet weak var colorWell: NSColorWell!
    @IBOutlet weak var attributeView: NSView!
    @IBOutlet weak var descriptionUpdateSpinner: NSProgressIndicator!
    @IBOutlet weak var revertSpinner: NSProgressIndicator!
    var atrview: NSView? = nil
    
    @IBOutlet weak var minGradeCheckbox: NSButton!
    @IBOutlet weak var maxGradeCheckbox: NSButton!
    @IBOutlet weak var minGrade: NSPopUpButton!
    @IBOutlet weak var maxGrade: NSPopUpButton!
    @IBOutlet weak var gradeSpinner: NSProgressIndicator!
    
    @IBOutlet weak var nextSessionDateTextfield: NSTextField!
    @IBOutlet weak var markAllAbsent: NSButton!
    @IBOutlet weak var markAllPresent: NSButton!
    
    var syncTextfields = [NSTextField]()
    
    var nextSessionDate: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM. d, y"
            formatter.locale = Locale(identifier:"en_US")
            
            if nextSessionDateTextfield.stringValue != "Today" && nextSessionDateTextfield.stringValue != "" {
                return nextSessionDateTextfield.stringValue
            } else {
                return formatter.string(from: Date()) // This runs when the displayed date is "Today"
            }
        }
        set (newValue) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM. d, y"
            formatter.locale = Locale(identifier:"en_US")
            if newValue == "Unavailable" {
                nextSessionDateTextfield.stringValue = "Unavailable" // Don't set a date then
                confirmDateButton.isEnabled = false
            } else {
                let today = formatter.string(from: Date())
                // Decide whether the app should display "today" based on whether the date is today
                if newValue == today {
                    nextSessionDateTextfield.stringValue = "Today"
                } else {
                    nextSessionDateTextfield.stringValue = newValue
                }
                confirmDateButton.isEnabled = true
            }
            if newValue == "Unavailable" {
                markAllPresent.isEnabled = false
                markAllAbsent.isEnabled = false
                nextSessionDateTextfield.alphaValue = 1
            } else {
                markAllPresent.isEnabled = formatter.date(from: formatter.string(from: Date()))!.timeIntervalSince(formatter.date(from: newValue)!) >= 0
                markAllAbsent.isEnabled = markAllPresent.isEnabled
                nextSessionDateTextfield.alphaValue = markAllAbsent.isEnabled ? 0.5 : 1
            }
        }
    }

    @IBOutlet weak var sessionDateSpinner: NSProgressIndicator!
    @IBOutlet weak var previousDate: NSButton!
    @IBOutlet weak var nextDate: NSButton!
    @IBOutlet weak var confirmDateButton: NSButton!
    
    @IBOutlet weak var EASearchField: NSSearchField!
    
    var downloadQueue = [String: NSURLDownload]()
    
    var sheetWindow = NSWindow()
    
    var constraint = [NSLayoutConstraint]()
    
    var length = 0
    
    var shouldUpdate = true // Whether the table updates with the values
    
    var myEAs = [EA]() {
        didSet (oldValue) {
            if myEAs.count != 0 || !loadImage.isAnimating {
                loadImage.stopAnimation()
            }
            if needsMoveAnimation {return}
            let row = EATableView.selectedRow
            if myEAs.count > oldValue.count {
                // If more rows have been added
                if oldValue.count == 0 {
                    EATableView.insertRows(at: IndexSet(integersIn: NSMakeRange(0, myEAs.count).toRange()!), withAnimation: .effectFade)
                    
                } else {
                    EATableView.insertRows(at: IndexSet(integersIn: NSMakeRange(oldValue.count, 1).toRange() ?? 0..<0), withAnimation: .effectFade)
                }
            } else if myEAs.count < oldValue.count {
                if myEAs.count == 0 {
                    EATableView.removeRows(at: IndexSet(integersIn: NSMakeRange(0, EATableView.numberOfRows).toRange()!), withAnimation: .effectFade)
                } else {
                    EATableView.removeRows(at: IndexSet(integersIn: NSMakeRange(row, 1).toRange() ?? 0..<0), withAnimation: .slideUp)
                }
            } else if shouldUpdate {
                EATableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: 0))
                EATableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection:false)
            }
        }
    }
    
    var myEAs_backup = [EA]()
    
    var participants = [Participant]() {
        didSet {
            if !refreshParticipants {return}
            participantTable.reloadData()
            if participants.count != 0 || !participantLoader.isAnimating {
                participantLoader.stopAnimation()
            }
        }
    }
    
    var EA_Namelist = [String]()
        
    let d = UserDefaults.standard
    
    let requestManager = GRRequestsManager(hostname: "47.52.6.204:23333", user: "eamanager", password: "Tenic@EA")
    
    var currentItem: NSObject?

    override func viewDidLoad() {
        
        checkForUpdates(false)
        
        let ad = NSApplication.shared().delegate as! AppDelegate
        ad.vc = self
        
        sheetWindow = NSWindow(contentRect: NSMakeRect(0, 0, 270, 133), styleMask: NSWindowStyleMask(rawValue: 32775), backing: .buffered, defer: false)
        
        boldMenuItem = ad.boldMenuItem
        
        nextSessionDateTextfield.stringValue = ""
        
        syncTextfields = [leaders, leaderIDs, location, EA_Description, supervisor, maxStudents, time_detail, prompt]
        
        
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        menu.addItem(withTitle: "EA Hasn't Run, Cannot Mark Attendance", action: nil, keyEquivalent: "").isEnabled = false
        participantTable.menu = menu
                
        let eaNib = NSNib(nibNamed: "EAView", bundle: Bundle.main)
        EATableView.register(eaNib!, forIdentifier: "EA View")
        
        let participantNib = NSNib(nibNamed: "ParticipantView", bundle: Bundle.main)
        participantTable.register(participantNib!, forIdentifier: "Participant Table")
        
        splitviewLeft.wantsLayer = true
        splitviewLeft.layer?.backgroundColor = NSColor(red: 230/255, green: 243/255, blue: 255/255, alpha: 1).cgColor
        splitviewRight.wantsLayer = true
        splitviewRight.layer?.backgroundColor = NSColor(red: 247/255, green: 251/255, blue: 255/255, alpha: 1).cgColor
        
        super.viewDidLoad()
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        version.stringValue = "EA Manager v" + currentVersion
        
//        d.removeObjectForKey("Has Launched Before")

        EATableView.becomeFirstResponder()
//        if !d.boolForKey("Has Launched Before") {
//            // First launch
//            view = sv
//        } else {
            loadFromServer()
//        }

    }
    
    override func viewDidAppear() {
        let ad = NSApplication.shared().delegate as! AppDelegate
        ad.vc = self
    }
    
    override func viewDidDisappear() {
        for i in myEAs {
            Terminal().deleteFileWithPath(NSTemporaryDirectory() + i.name + ".rtfd")
        }
    }
    

    func letsBegin(_ sender: NSButton) {
        view.window?.standardWindowButton(.zoomButton)?.isHidden = false
        view.window?.standardWindowButton(.miniaturizeButton)?.isHidden = false
        
        d.set(true, forKey: "Has Launched Before")
        
        myEAs.removeAll()
        tableViewSelectionIsChanging(Notification(name: Notification.Name(rawValue: ""), object: nil))
        
        loadFromServer()

        view = mainView
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == EATableView {
            return myEAs.count
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            if nextSessionDate == "Unavailable" {
                return 0
            } else {
                //let theEA = myEAs.filter({$0.name == EA_Name.stringValue})[0]
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM. d, y"
                return nextSessionDate == "Unavailable" ? 0 : participantsAtGivenDate(participants, date: formatter.date(from: nextSessionDate)!).count
            }
        }
    }
    
    func participantsAtGivenDate(_ participants: [Participant], date: Date) -> [Participant] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        let tmp = participants.filter {participant -> Bool in
            if participant.startDate == "" {return false}
            let startDates = participant.startDate.components(separatedBy: "|").map {
                return formatter.date(from: $0) ?? formatter.date(from: formatter.string(from: Date()))!
            }
            var endDates = participant.endDate.components(separatedBy: "|").map {
                return formatter.date(from: $0) ?? Date(timeIntervalSinceReferenceDate: 0)
            }
            if (endDates.count < startDates.count || endDates.first!.timeIntervalSinceReferenceDate == 0) && date.timeIntervalSince(startDates.last!) >= 0 {return true}
            if participant.approval == "Pending" {return date.timeIntervalSince(startDates.last!) >= 0}
            
            for i in 0..<startDates.count {
                if startDates[i].timeIntervalSince(date) <= 0 && endDates[i].timeIntervalSince(date) > 0 {
                    return true
                }
            }
            return false
        }
        return tmp
    }
    
    var shouldUpdateParticipantsTable = false
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        
        let EAcell = EATableView.make(withIdentifier: "EA View", owner: self) as! EAView
        if tableView == EATableView {
            EAcell.EAName.stringValue = myEAs[row].name
            if myEAs[row].type == "Teacher" {
                EAcell.supervisorLabel.stringValue = "Contact Email(s):"
            } else {
                EAcell.supervisorLabel.stringValue = "Supervisor:"
            }
            EAcell.supervisor.stringValue = myEAs[row].supervisor
            EAcell.date.stringValue = myEAs[row].time
            EAcell.location.stringValue = myEAs[row].location
            
            EAcell.leaders.stringValue = myEAs[row].leader
            
            switch myEAs[row].approval {
            case "Approved":
                EAcell.status = .active
            case "Pending":
                EAcell.status = .pending
            case "Inactive":
                EAcell.status = .inactive
            case "Unapproved":
                EAcell.status = .unapproved
            default:
                EAcell.status = .none
            }
            
            if myEAs[row].dates != "" {
                let lastDate = myEAs[row].dates.components(separatedBy: " | ").last!
                if formatter.date(from: lastDate)!.timeIntervalSince(formatter.date(from: formatter.string(from: Date()))!) < 0 {
                    EAcell.status = .finished
                }
            }
            
            if myEAs[row].dates != "Unavailable" {
                EAcell.numberOfParticipants.stringValue = "..."
                shouldUpdate = false
                let next = updateDatesForEA(myEAs[row])
                shouldUpdate = true
                updateParticipantsForEA(myEAs[row].name, date: next, updateTable: shouldUpdateParticipantsTable)
            } else {
                EAcell.numberOfParticipants.stringValue = "0"
            }

            return EAcell
        } else if tableView == participantTable {
            
            let currentDate = formatter.date(from: nextSessionDate)!
            
            let tmp = participantsAtGivenDate(participants, date: currentDate)
            
            let cell = participantTable.make(withIdentifier: "Participant Table", owner: self) as! ParticipantView
            if EATableView.selectedRow == -1 {return nil}
            cell.EA_Name = (EATableView.view(atColumn: 0, row: EATableView.selectedRow, makeIfNecessary: false) as! EAView).EAName.stringValue
            cell.name.stringValue = tmp[row].name
            cell.advisory.stringValue = tmp[row].advisory
            cell.toolTip = "Student ID: \(tmp[row].id)"
//            if tmp[row].wechat != "" {
//                cell.toolTip! += "\rWechat: " + tmp[row].wechat
//            }
            let msg = tmp[row].message == "N/A" ? "" : tmp[row].message.decodedString()
            cell.message.stringValue = msg == "" ? "The student was lazy and did not provide any supplementary information regarding himself/herself." : msg
            if tmp[row].approval == "Approved" {
                cell.approvalButton.isHidden = true
                cell.approveLabel.isHidden = false
            } else if tmp[row].approval == "Pending" {
                cell.approvalButton.title = "Approve"
                cell.approvalButton.isHidden = false
                cell.approveLabel.isHidden = true
            }
            let isFuture = currentDate.timeIntervalSince(Date()) > 0
            
            formatter.dateFormat = "y/M/d"
            let date = formatter.string(from: currentDate)
            
            if tmp[row].attendance.contains(date) {
                cell.attendance = .present
            } else if !isFuture {
                cell.attendance = .absent
            } else {
                cell.attendance = .none
            }
            
            
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return tableView == EATableView ? 147 : 45
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if tableView != EATableView {return false}
        
        /*
        for i in syncTextfields {
            if i.layer != nil && i.layer?.borderWidth != 0 && row != lastSelectedRow {
                let alert = NSAlert()
                alert.messageText = "Unsaved change!"
                alert.informativeText = "One or more changes you've made to your EA have not been synced to the server, and they have been outlined in orange color. These changes will be discarded as soon as you switch your selection."
                alert.alertStyle = .CriticalAlertStyle
                alert.window.title = "Warning"
                alert.addButtonWithTitle("Go Back and Check").keyEquivalent = "\r"
                alert.addButtonWithTitle("Discard Changes")
                if alert.runModal() == NSAlertFirstButtonReturn {
                    EATableView.selectRowIndexes(NSIndexSet(index: lastSelectedRow), byExtendingSelection: false)
                    tabView.hidden = false
                    noEA_label.hidden = true
                    EA_Name.stringValue = myEAs[lastSelectedRow].name
                    return false
                } else {
                    break
                }
            }
        } */
        
        if row == lastSelectedRow && myEAs[row].id == leaderIDs.stringValue {
//            EATableView.selectRowIndexes(NSIndexSet(index: lastSelectedRow), byExtendingSelection: false)
//            tabView.hidden = false
//            noEA_label.hidden = false
//            EA_Name.stringValue = myEAs[lastSelectedRow].name
//            return false
            lastSelectedRow = -1
            self.tableView(EATableView, shouldSelectRow: row)
        }
        noEA_label.isHidden = true
        
        tabView.isHidden = false
        let cell = EATableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! EAView
        let theEA = myEAs.filter({(ea) -> Bool in
            return ea.name == cell.EAName.stringValue
        })[0]
        
        EA_Name.stringValue = theEA.name
        
        activeSwitch.isEnabled = true
        
        activeSwitch.selectedSegment = -1
        
        confirmDateButton.isEnabled = theEA.dates != ""

        if theEA.approval == "Approved" {
            activeSwitch.selectedSegment = 0
        } else if theEA.approval == "Inactive" {
            activeSwitch.isEnabled = false
        } else if theEA.approval == "Pending" {
            // Do nothing cuz it's the default settings
        } else if theEA.approval == "Unapproved" {
            activeSwitch.selectedSegment = 1
        }
        
        // Fetching the description of the EA
        EA_Description.stringValue = theEA.description.decodedString()
        controlTextDidChange(Notification(name: Notification.Name(rawValue: ""), object: EA_Description))
        
        // Fetching the location
        location.stringValue = theEA.location
        
        //Fetch supplementary info:
        prompt.stringValue = theEA.prompt
        
        // Fetching the date
        let dateDescription = theEA.time.components(separatedBy: " | ")
        let defaultTimes = time.menu!.items.map({(item) -> String in
            return item.title
        })
        if dateDescription.count > 1 && defaultTimes.contains(dateDescription[1]) {
            time.title = dateDescription[1]
            time_detail.isHidden = true
        } else {
            time.title = "Other Time(s)"
            time_detail.isHidden = false
            time_detail.stringValue = dateDescription[1]
        }
        monday.integerValue = dateDescription[0].contains("Mon") ? 1 : 0
        tuesday.integerValue = dateDescription[0].contains("Tue") ? 1 : 0
        wednesday.integerValue = dateDescription[0].contains("Wed") ? 1 : 0
        thursday.integerValue = dateDescription[0].contains("Thu") ? 1 : 0
        friday.integerValue = dateDescription[0].contains("Fri") ? 1 : 0
        frequency.isEnabled = dateDescription[0].components(separatedBy: ",").count == 1
        frequency.selectItem(withTag: theEA.frequency)
        
        // Fetch leaders and supervisor
        if theEA.type == "Teacher" {
            supervisorLabel.stringValue = "Contact Email(s):"
            supervisor.placeholderString = "Enter as many as you need."
            supervisor.tokenStyle = .default
        } else {
            supervisorLabel.stringValue = "Supervisor:"
            supervisor.placeholderString = "Full name of supervisor..."
            supervisor.tokenStyle = .default
        }
        
        supervisor.stringValue = theEA.supervisor
        leaders.stringValue = theEA.leader
        leaders.placeholderString = d.value(forKey: "Name") as? String
        leaderIDs.stringValue = theEA.id
        if FileManager().fileExists(atPath: NSTemporaryDirectory() + theEA.name + ".rtfd") {
            message.readRTFD(fromFile: NSTemporaryDirectory() + theEA.name + ".rtfd")
            self.adjustImages()
        } else {
            updateDescription()
        }
        
        proposal.string = theEA.proposal
        
        let colors = ["Blue", "Orange", "Green", "Red", "Pink", "Yellow", "Purple", ""]
        
        if theEA.color.contains("|") {
            categoryPopup.selectItem(at: colors.index(of: theEA.color.components(separatedBy: "|")[0]) ?? 7)
        } else {
            categoryPopup.selectItem(at: colors.index(of: theEA.color) ?? 7)
        }
        
        
        // Maximum Students
        if theEA.max != "" && Int(theEA.max) > 0 {
            maxStudents.stringValue = theEA.max
            enableMaxStudents.integerValue = 1
            maxStudents.isEnabled = true
        } else {
            maxStudents.isEnabled = false
            maxStudents.stringValue = "10"
            enableMaxStudents.integerValue = 0
        }
        
        // Age restrictions
        
        if theEA.age.contains(" | ") {
            let bounds = theEA.age.components(separatedBy: " | ")
            if bounds[0] != "" {
                minGradeCheckbox.integerValue = 1
                minGrade.isEnabled = true
                minGrade.title = bounds[0]
            } else {
                minGradeCheckbox.integerValue = 0
                minGrade.isEnabled = false
                minGrade.title = "6"
            }
            if bounds[1] != "" {
                maxGradeCheckbox.integerValue = 1
                maxGrade.isEnabled = true
                maxGrade.title = bounds[1]
            } else {
                maxGradeCheckbox.integerValue = 0
                maxGrade.isEnabled = false
                maxGrade.title = "12"
            }
        } else {
            print(theEA.age)
        }
        
        // Start and End Date of EA
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, y"
        formatter.locale = Locale(identifier: "en_US")
        startDate.dateValue = formatter.date(from: theEA.startDate)!
        endDate.dateValue = formatter.date(from: theEA.endDate)!
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.nextSessionDate = self.updateDatesForEA(theEA)
            self.updateParticipantsForEA(theEA.name, date: nil, updateTable: true)
            //self.changeStatusForKey("Next", value: self.nextSessionDate, spinner: self.sessionDateSpinner, updateRow: false)
        }
        
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, shouldTypeSelectFor event: NSEvent, withCurrentSearch searchString: String?) -> Bool {
        return false
    }
    
    func updateDatesForEA(_ theEA: EA) -> String {
        if theEA.dates == "" || ["Unapproved", "Pending", "Incomplete"].contains(theEA.approval) {return "Unavailable"}
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, y"
        formatter.locale = Locale(identifier: "en_US")
        let today = formatter.string(from: Date())
        
        for i in theEA.dates.components(separatedBy: " | ") {
            if formatter.date(from: i)!.timeIntervalSince(formatter.date(from: today)!) >= 0 {
                return i
            }
        }
        
        
        return theEA.dates.components(separatedBy: " | ").last!
        /*
        formatter.dateFormat = "E"
        confirmDateButton.enabled = false
        if theEA.next == "" {
            let availableDays = theEA.time.componentsSeparatedByString(" | ")[0].componentsSeparatedByString(", ")
            
            let tmp = formatter.stringFromDate(NSDate())
            let currentDate = formatter.dateFromString(tmp)!
            var distance = 0.0
            if availableDays.count == 1 {
                let nextDate = formatter.dateFromString(availableDays[0])!
                let interval = nextDate.timeIntervalSinceDate(currentDate) / 86400
                if interval >= 0 {
                    distance = interval
                } else {
                    distance = 7 + interval
                }
            } else {
                var availableDate = ""
                for i in availableDays {
                    let nextDate = formatter.dateFromString(i)!
                    let interval = nextDate.timeIntervalSinceDate(currentDate) / 86400
                    if interval >= 0 {
                        distance = interval
                        availableDate = i
                        break
                    }
                }
                
                // If current date is later than any of the specified dates for the EA
                if availableDate == "" {
                    let interval = formatter.dateFromString(availableDays[0])!.timeIntervalSinceDate(currentDate) / 86400
                    distance = 7 - interval
                }
            }
            
            let nextSession = NSDate().dateByAddingTimeInterval(distance * 86400)
            formatter.dateFormat = "MMM. d, y"
            
            nextSessionDate = formatter.stringFromDate(nextSession)
            
            changeStatusForKey("Next", value: nextSessionDate, spinner: sessionDateSpinner, updateRow: false)
            for i in 0..<myEAs.count {
                if myEAs[i].name == theEA.name {
                    needsMoveAnimation = true
                    myEAs[i].next = nextSessionDate
                    needsMoveAnimation = false
                    break
                }
            }
            return formatter.stringFromDate(nextSession)
        } else {
            if theEA.next == "Unavailable" {
                previousDate.enabled = false
                nextDate.enabled = false
                //                confirmDateButton.enabled = false
                nextSessionDate = "Unavailable"
            } else {
                previousDate.enabled = true
                nextDate.enabled = true
                //                confirmDateButton.enabled = true
                formatter.dateFormat = "MMM. d, y"
                let oldDate = formatter.dateFromString(theEA.next)!
                let EAEndDate = formatter.dateFromString(theEA.endDate)!
                let todayDate = formatter.dateFromString(today)!
                if todayDate.timeIntervalSinceDate(oldDate) > 0 && EAEndDate.timeIntervalSinceDate(todayDate) > 0 {
                    theEA.next = ""
                    return updateDatesForEA(theEA)
                } else if EAEndDate.timeIntervalSinceDate(todayDate) < 0 {
                    let weekFormatter = NSDateFormatter()
                    weekFormatter.locale = NSLocale(localeIdentifier: "en_US")
                    weekFormatter.dateFormat = "E"
                    let availableDates = theEA.time.componentsSeparatedByString(" | ")[0].componentsSeparatedByString(", ")
                    let endweekday = weekFormatter.dateFromString(weekFormatter.stringFromDate(EAEndDate))! // Get the end date in the format of weekday
                    var timeDifference = 7.0 * 86400 - weekFormatter.dateFromString(availableDates.last!)!.timeIntervalSinceDate(endweekday)
                    for i in availableDates {
                        let availableDateInWeek = weekFormatter.dateFromString(i)! // e.g. Monday
                        let difference = endweekday.timeIntervalSinceDate(availableDateInWeek)
                        if difference < timeDifference && difference >= 0 {
                            timeDifference = difference
                        }
                    }
                    let lastSessionDate = EAEndDate.dateByAddingTimeInterval(-timeDifference)
                    nextSessionDate = formatter.stringFromDate(lastSessionDate)
                } else {
                    nextSessionDate = theEA.next
                }
            }
            if theEA.approval == "Unapproved" {confirmDateButton.enabled = false}
        }
        return nextSessionDate
*/
    }
    
    func windowWillResize(_ sender: AnyObject?) {
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "[firstview(\(splitviewLeft.frame.width))]", options: NSLayoutFormatOptions.alignmentMask, metrics: nil, views: ["firstview": splitviewLeft])
        splitviewLeft.addConstraints(constraint)
        
    }
    
    func windowHasResized(_ sender: AnyObject?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.splitviewLeft.removeConstraints(self.constraint)
        }
    }
    
    @IBAction func mailAll(_ sender: NSButton) {
        let emails = (leaderIDs.objectValue as! [String]).map {(regularizeID($0) ?? $0) + "@mybcis.cn"} + participants.map{participant -> String in
            return participant.id + "@mybcis.cn"
        }
        
        let url = URL(string: "mailto:" + emails.joined(separator: ","))!
        if NSEvent.modifierFlags() == .option {
            do {
                try NSWorkspace.shared().open([url], withApplicationAt: URL(string: "file:///Applications/Microsoft%20Outlook.app") ?? URL(string: "file:///Applications/Mail.app")!, options: .withoutAddingToRecents, configuration: [String:AnyObject]())
            } catch {
            
            }
        } else {
            NSWorkspace.shared().open(url)
        }
    }
    
    //////////
    
    
    //Fetching EAs from the server
    func loadFromServer() {
        loadImage.startAnimation("Cloud Sync")
        eaInfoLabel.stringValue = "Synchronizing data..."
        Thread.sleep(forTimeInterval: 0)
        let url = URL(string: serverAddress + "tenicCore/service.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let alert = NSAlert()
        
        let postString = "id=0"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil || data == nil {
                DispatchQueue.main.async {
                    self.loadImage.stopAnimation()
                    if self.myEAs.count != 0 {return}
                    alert.messageText = "Connection to Server Failed"
                    alert.informativeText = "Please check you internet connection."
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
                print("error=\(error!)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                var EAs = [[String: String]]()
                
                for i in json {
                    EAs.append(i as! [String:String])
//                    print(i)
                }
                self.myEAs_backup.removeAll()
                var tmp = [EA]()
                for i in EAs {
                    var ea = EA(EA_Name: i["Name"]!, description: i["Description"]!, date: i["Date"]!, leader: i["Leader"]!, id: i["ID"]!, supervisor: i["Supervisor"]!, location: i["Location"]!, approval: i["Status"]!, participants: i["Participants"]!, approved: i["Approved"]!, max: i["Max"]!, dates: i["Dates"]!, startDate: i["Start Date"]!, endDate: i["End Date"]!, proposal: i["Proposal"]!.decodedString(), prompt: i["Prompt"]!.decodedString(), type: i["Type"]!, frequency: Int(i["Frequency"]!) ?? 4)
                    ea.color = i["Color"]!
                    if ea.participants == "-1" {
                        ea.participants = "0"
                    }
                    if ea.approved == "-1" {
                        ea.approved = "0"
                    }
                    
                    if ea.approval != "Incomplete" && ea.approval != "Hidden" {
                        
                        if !self.myEAs_backup.contains(where: {$0.name == ea.name}) {
                            self.myEAs_backup.append(ea)
                        }
                        
                        if self.EASearchField.stringValue == "" {
                            tmp.append(ea)
                        } else {
                            if [ea].filter({(ea) -> Bool in
                                for i in [ea.name, ea.supervisor, ea.time, ea.leader, ea.dates, ea.description.decodedString()] {
                                    let range = NSString(string: i).range(of: self.EASearchField.stringValue, options: .caseInsensitive)
                                    if range.location != NSNotFound {return true}
                                }
                                return false
                            }).count > 0 {
                                tmp.append(ea)
                            }
                        }
                    }
                }
                
                tmp = tmp.sorted {ea1, ea2 -> Bool in
                    if ea1.approval != ea2.approval {
                        return ea1.approval > ea2.approval
                    } else {
                        return ea1.name < ea2.name
                    }
                }
                
                Thread.sleep(forTimeInterval: loading_delay)
                
                DispatchQueue.main.async {
                    self.loadImage.stopAnimation()
                    self.myEAs = tmp
                    if self.updateDownloadProgress.isIndeterminate {
                        self.updateStats()
                    }
                    self.EATableView.reloadData()
                }

            } catch let err as NSError {
                DispatchQueue.main.async {
                    self.loadImage.stopAnimation()
                    if self.myEAs.count != 0 {return}
                    let alert = NSAlert()
                    alert.messageText = "Connection to Server Failed"
                    if error == nil {
                        alert.informativeText = "Our server is down for maintenance. We will be back very soon~~"
                    } else {
                        alert.informativeText = "Please check you internet connection."
                    }
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
                print(err)
            }
            return
            
        }) 
        task.resume()
        
    }
    
    func updateStats() {
        var approved = 0
        var inactive = 0
        for i in myEAs {
            if i.approval == "Approved" {
                approved += 1
            } else if i.approval == "Inactive" {
                inactive += 1
            } else {
                
            }
        }
        eaInfoLabel.stringValue = "\(myEAs.count) EAs in total, \(approved + inactive) approved, \(approved) active."
    }
    
    func updateParticipantsForEA(_ EA_Name: String, date: String?, updateTable: Bool) {
        
        if EA_Name == self.EA_Name.stringValue && updateTable {
            participants = []
            participantLoader.startAnimation("Globe")
        }
        
        let theEA = myEAs.filter({$0.name == EA_Name})[0]

        let url = URL(string: serverAddress + "tenicCore/EAInfo.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        var hasRun = false
        let postString = "EA=\(EA_Name)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if hasRun {return}
            
            if data == nil || error != nil {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                var tmpParticipants = [Participant]()
                
                for i in json {
                    let dict = i as! [String:String]
//                    print(dict)
                    let p = Participant(name: dict["Name"]!, id: dict["ID"]!, advisory: dict["Advisory"]!, message: dict["Message"]!, approval: dict["Approval"]!, attendance: dict["Attendance"]!, startDate: dict["Start Date"]!, endDate: dict["End Date"]!)
                    if p.approval != "Inactive" {
                        tmpParticipants.append(p)
                    }
                }
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM. d, y"
                
                let sessionDate = formatter.date(from: date ?? "_") ?? formatter.date(from: self.updateDatesForEA(theEA))
                
                DispatchQueue.main.async(execute: {
                    if EA_Name == self.EA_Name.stringValue && updateTable {
                        self.participants = tmpParticipants
                        self.participantLoader.stopAnimation()
                    }
                    if tmpParticipants.count > 0 && sessionDate != nil {
                        tmpParticipants = self.participantsAtGivenDate(tmpParticipants, date: sessionDate!)
                    }
                    
                    for i in 0..<self.EATableView.numberOfRows {
                        if let cell = self.EATableView.view(atColumn: 0, row: i, makeIfNecessary: false) as? EAView {
                            if cell.EAName.stringValue == EA_Name {
                                cell.numberOfParticipants.integerValue = tmpParticipants.count
                            }
                        }
                    }
                })
            } catch {
                print("connection error")
                self.participantLoader.stopAnimation()
            }
            hasRun = true
        }
        
        task.resume()
    }
    
    @IBAction func reloadTables(_ sender: NSButton) {
        if let textfield = currentItem as? NSTextField {
            controlTextDidEndEditing(Notification(name: Notification.Name(rawValue: ""), object: textfield, userInfo: nil))
        }
        currentItem = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.empty()
            self.myEAs.removeAll()
            self.loadFromServer()
        }
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        if EATableView.selectedRow == -1 {
            tabView.isHidden = true
            EA_Name.stringValue = ""
            noEA_label.isHidden = false
        } else if EATableView.selectedRow != lastSelectedRow {
            noEA_label.isHidden = true
            for i in syncTextfields {
                i.layer?.borderWidth = 0
            }
        }
    }
    
    var lastSelectedRow = -1
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if EATableView.selectedRow != -1 {
            lastSelectedRow = EATableView.selectedRow
            noEA_label.isHidden = true
        }
    }
    
    func empty() {
        tabView.isHidden = true
        EA_Name.stringValue = ""
        noEA_label.isHidden = false
        for i in syncTextfields {
            i.layer?.borderWidth = 0
        }
    }

    @IBAction func changeApprovalStatus(_ sender: NSSegmentedControl) {
        shouldUpdateParticipantsTable = false
        let mod = NSEvent.modifierFlags()
        
        if !sender.isSelected(forSegment: 0) && !sender.isSelected(forSegment: 1) {
            changeStatusForKey("Status", value: "Pending", spinner: activeSpinner, updateRow: true)
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].approval = "Pending"
//                    myEAs[i].next = "Unavailable"
                    //updateDatesForEA(myEAs[i])
//                    changeStatusForKey("Next", value: "Unavailable", spinner: sessionDateSpinner)
                    break
                }
            }
        }
        
        else if sender.selectedSegment == 0 {
            sender.setSelected(false, forSegment: 1)
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].approval = "Approved"
                    
                    myEAs[i].dates = generateAvailableDates(myEAs[i])
                    confirmDateButton.isEnabled = true
                    nextSessionDate = updateDatesForEA(myEAs[i])
                    changeStatusForKey("Status", value: "Approved", spinner: activeSpinner, updateRow: true)
                    changeStatusForKey("Dates", value: myEAs[i].dates, spinner: activeSpinner, updateRow: false)
                    
                    if !NSEvent.modifierFlags().contains(.option) {
                        broadcastMessage("Found my EA", message: "Your \(myEAs[i].name) has been approved. You can start recruiting new members!", filter: "I:" + myEAs[i].id)
                    }
                    break
                }
            }
        } else if sender.selectedSegment == 1 {
            sender.setSelected(false, forSegment: 0)
            changeStatusForKey("Status", value: "Unapproved", spinner: activeSpinner, updateRow: true)
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].approval = "Unapproved"
                    if !mod.contains(.option) {
                        broadcastMessage("Found my EA", message: "Your \(myEAs[i].name) has not been approved. Talk to the EA coordinator to find out why!", filter: "I:" + myEAs[i].id)
                    }
                    break
                }
            }
        }
        
        let tmp = myEAs.sorted(by: {ea1, ea2 -> Bool in
            if ea1.approval != ea2.approval {
                return ea1.approval > ea2.approval
            } else {
                return ea1.name < ea2.name
            }
        })
        var index = -1
        for i in 0..<tmp.count {
            if tmp[i].name == EA_Name.stringValue {
                index = i
            }
        }
        let selectedRow = EATableView.selectedRow
        if index != -1 && selectedRow != -1 {
            needsMoveAnimation = true
            self.myEAs = tmp
            EATableView.moveRow(at: selectedRow, to: index)
            EATableView.scrollRowToVisible(index)
            self.needsMoveAnimation = false
        }
        shouldUpdateParticipantsTable = true
    }
    
    func generateAvailableDates(_ theEA: EA) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, y"
        formatter.locale = Locale(identifier: "en_US")
//        let today = formatter.date(from: formatter.string(from: Date()))!
        let dates = theEA.time.components(separatedBy: " | ")[0].components(separatedBy: ", ")
        
        
        let start = formatter.date(from: theEA.startDate)!
        var current = formatter.date(from: formatter.string(from: Date()))!.addingTimeInterval(86400)
        if current.timeIntervalSince(start) < 0 {current = start}
        let endDate = formatter.date(from: theEA.endDate)!
        
        var availableDates = [String]()
        if theEA.dates != "" {
            availableDates = theEA.dates.components(separatedBy: " | ").map {formatter.date(from: $0)!} . filter {$0.timeIntervalSince(current) < 0} . map {formatter.string(from: $0)}
        }

        for i in 0...Int(endDate.timeIntervalSince(current) / 86400) {
            formatter.dateFormat = "E"
            let tmpdate = current.addingTimeInterval(Double(i * 86400))
            let weekday = formatter.string(from: tmpdate)
            if dates.contains(weekday) || dates[0].hasPrefix(weekday) {
                formatter.dateFormat = "MMM. d, y"
                availableDates.append(formatter.string(from: tmpdate))
            }
        }
        
        switch theEA.frequency {
        case 4:
            return availableDates.joined(separator: " | ")
        case 2:
            return availableDates.filter({availableDates.index(of: $0)! % 2 == 0}).joined(separator: " | ")
        case 1:
            return availableDates.filter({availableDates.index(of: $0)! % 4 == 0}).joined(separator: " | ")
        default:
            return availableDates.joined(separator: " | ")
        }
    }
    
    var needsMoveAnimation = false
    
    @IBAction func sendDescription(_ sender: NSButton) {
        
        if EA_Description.stringValue.encodedString().characters.count > 250 {
            return
        }
        
        changeStatusForKey("Description", value: EA_Description.stringValue.encodedString(), spinner: descriptionSpinner, updateRow: false)
        shouldUpdate = false
        
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].description = EA_Description.stringValue.encodedString()
                break
            }
        }
        shouldUpdate = true
        sender.layer?.borderWidth = 0
    }
    
    @IBAction func changeEADate(_ sender: NSObject) {
        
        var dates = [String]()
        if monday.integerValue == 1 {dates.append("Mon")}
        if tuesday.integerValue == 1 {dates.append("Tue")}
        if wednesday.integerValue == 1 {dates.append("Wed")}
        if thursday.integerValue == 1 {dates.append("Thu")}
        if friday.integerValue == 1 {dates.append("Fri")}
        let backupDates = dates
        if dates.count == 0 {
            time.isEnabled = false
            return
        } else {
            time.isEnabled = true
            if dates.count == 1 {
                if monday.integerValue == 1 {dates = ["Monday"]}
                if tuesday.integerValue == 1 {dates = ["Tuesday"]}
                if wednesday.integerValue == 1 {dates = ["Wednesday"]}
                if thursday.integerValue == 1 {dates = ["Thursday"]}
                if friday.integerValue == 1 {dates = ["Friday"]}
            } else {
                frequency.selectItem(withTag: 4)
            }
        }
        
        frequency.isEnabled = dates.count == 1
        
        time_detail.layer?.borderWidth = 0
        
        let date = time_detail.isHidden ? time.title : time_detail.stringValue
        
        let theDate = dates.joined(separator: ", ") + " | " + date
        changeStatusForKey("Date", value: theDate, spinner: dateSpinner, updateRow: true)
        
        let generalFormatter = DateFormatter()
        generalFormatter.dateFormat = "MMM. d, y"
        generalFormatter.locale = Locale(identifier: "en_US")
        
        let weekFormatter = DateFormatter()
        weekFormatter.dateFormat = "E"
        
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].time = theDate
                
                if myEAs[i].dates != "" && frequency.selectedTag() == 4, let button = sender as? NSButton, (sender as! NSButton).integerValue == 1 {
                    shouldUpdate = false
                    if let dayOfTheWeekIndex = [monday, tuesday, wednesday, thursday, friday].index(where: {$0 == button}) {
                        let dayOfTheWeek = ["Mon", "Tue", "Wed", "Thu", "Fri"][dayOfTheWeekIndex]
                        let start = generalFormatter.date(from: myEAs[i].startDate)!
                        var current = generalFormatter.date(from: generalFormatter.string(from: Date()))!.addingTimeInterval(86400)
                        if current.timeIntervalSince(start) < 0 {current = start}
                        let end = generalFormatter.date(from: myEAs[i].endDate)!
                        var dateList = myEAs[i].dates.components(separatedBy: " | ").map {generalFormatter.date(from: $0)!}
                        
                        
                        while end.timeIntervalSince(current) > 0 {
                            if weekFormatter.string(from: current) == dayOfTheWeek {
                                dateList.append(current)
                                current.addTimeInterval(7 * 86400)
                            } else {
                                current.addTimeInterval(86400)
                            }
                        }
                        shouldUpdate = true
                        dateList.sort()
                        myEAs[i].dates = dateList.map {generalFormatter.string(from: $0)} .joined(separator: " | ")
                    }
                } else if myEAs[i].dates != "" && frequency.selectedTag() == 4, (sender as? NSButton)?.integerValue == 0 {
                    //problem with unavailable detection
                    
                    var dateList = myEAs[i].dates.components(separatedBy: " | ").map {generalFormatter.date(from: $0)!}
                    
                    dateList = dateList.filter {backupDates.contains(weekFormatter.string(from: $0))}
                    myEAs[i].dates = dateList.map({generalFormatter.string(from: $0)}).joined(separator: " | ")
                }
            }
        }

    }
    
    @IBAction func changeFrequency(_ sender: NSPopUpButton) {
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].frequency = sender.selectedTag()
                changeStatusForKey("Frequency", value: String(sender.selectedTag()), spinner: nil, updateRow: false)
                
                if myEAs[i].dates == "" {return}
                myEAs[i].dates = generateAvailableDates(myEAs[i])
                changeStatusForKey("Dates", value: myEAs[i].dates, spinner: nil, updateRow: false)
            }
        }
    }
    
    @IBAction func toggleOtherTime(_ sender: NSPopUpButton) {
        if time.title == "Other Time(s)" {
            time_detail.isHidden = false
            return
        } else {
            time_detail.isHidden = true
        }        
        changeEADate(sender)
    }
    
    @IBAction func changeLocation(_ sender: NSTextField) {
        shouldUpdateParticipantsTable = false
        changeStatusForKey("Location", value: location.stringValue, spinner: locationSpinner, updateRow: true)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].location = location.stringValue
                break
            }
        }
        shouldUpdateParticipantsTable = true
        sender.layer?.borderWidth = 0
    }
    
    @IBAction func updatePrompt(_ sender: NSTextField) {
        shouldUpdate = false
        changeStatusForKey("Prompt", value: sender.stringValue.encodedString(), spinner: promptSpinner, updateRow: false)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].prompt = sender.stringValue.encodedString()
            }
        }
        shouldUpdate = true
        sender.layer?.borderWidth = 0
    }
    
    @IBAction func changeSupervisor(_ sender: NSTextField) {
        shouldUpdateParticipantsTable = false
        changeStatusForKey("Supervisor", value: supervisor.stringValue, spinner: supervisorSpinner, updateRow: true)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].supervisor = supervisor.stringValue
                break
            }
        }
        shouldUpdateParticipantsTable = true
        sender.layer?.borderWidth = 0
    }
    
    @IBAction func changeLeader(_ sender: NSTokenField) {
        let string = (sender.objectValue as! [String]).joined(separator: ", ")
        if string == "" {return}
        shouldUpdateParticipantsTable = false
        changeStatusForKey("Leader", value: string, spinner: leadersSpinner, updateRow: true)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].leader = string
                break
            }
        }
        shouldUpdateParticipantsTable = true
        sender.layer?.borderWidth = 0
    }
    
    func changeStatusForKey(_ key: String, value: String, spinner: NSProgressIndicator?, updateRow: Bool) {
        let row = EATableView.selectedRow
        spinner?.startAnimation(nil)
        let url = URL(string: serverAddress + "tenicCore/EAUpdate.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "EA=\(EA_Name.stringValue)&key=\(key)&value=\(value)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let alert = NSAlert()
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if row == -1 {return}
            
            if (data == nil || error != nil) {
                if key != "Next" {
                    DispatchQueue.main.async {
                        spinner?.stopAnimation(nil)
                        alert.messageText = "Connection to Server Failed"
                        alert.informativeText = "Your modifications to the EA settings have not been uploaded to the server."
                        alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                    }
                }
                return
            }
            
            do {
                let _ = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                DispatchQueue.main.async(execute: {
                    spinner?.stopAnimation(nil)
                    if updateRow {
                        self.updateValuesForRow(row)
                    }
                    self.updateStats()
                })
            } catch {
                DispatchQueue.main.async(execute: {
                    spinner?.stopAnimation(nil)
                    alert.messageText = "Connection to Server Failed"
                    alert.informativeText = "Your modifications to the EA settings have not been uploaded to the server."
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                })
            }
            return
        }
        
        task.resume()
    }
    
    
    func updateValuesForRow(_ row: Int) {
        if EATableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? EAView == nil {return}
        let cell = EATableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! EAView
        let theEA = myEAs.filter({(ea) -> Bool in
            return ea.name == cell.EAName.stringValue
        })[0]
        
        switch theEA.approval {
        case "Approved":
            cell.status = .active
        case "Pending":
            cell.status = .pending
        case "Inactive":
            cell.status = .inactive
        case "Unapproved":
            cell.status = .unapproved
        default:
            cell.status = .none
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        if myEAs[row].dates != "" {
            let lastDate = myEAs[row].dates.components(separatedBy: " | ").last!
            if formatter.date(from: lastDate)!.timeIntervalSince(formatter.date(from: formatter.string(from: Date()))!) < 0 {
                cell.status = .finished
            }
        }
        
        cell.date.stringValue = theEA.time
        cell.location.stringValue = theEA.location
        cell.supervisor.stringValue = theEA.supervisor
    }
    
    
    func adjustImages() {
        if #available(OSX 10.11, *) {
            if message.attributedString().containsAttachments {
                var content = message.getParts()
                let images = message.getAlignImages()
                let attributedImages = message.getAttributedAlignImages()
                
                var indexOfAlignImages = [Int]()
                
                for i in 0..<content.count {
                    if content[i].containsAttachments {
                        indexOfAlignImages.append(i)
                    }
                }
                
                
                let newImages = images.map {image -> NSImage in
                    let scaleFactor = (message.frame.width - 10) / image.size.width
                    image.size.width *= scaleFactor
                    image.size.height *= scaleFactor
                    if image.size.width >= image.resolution.width ||
                        image.size.height >= image.resolution.height {
                        image.size = image.resolution
                    }
                    return image
                }
                
                
                let newAttrStr = NSMutableAttributedString()
                
                var newImageCount = 0
                
                for i in 0..<content.count {
                    if !indexOfAlignImages.contains(i) {
                        newAttrStr.append(content[i])
                    } else {
                        let tmp = NSMutableAttributedString(attributedString: attributedImages[newImageCount])
                        var oldattr = attributedImages[newImageCount].attributes(at: 0, effectiveRange: nil)
                        let attachment = oldattr["NSAttachment"] as! NSTextAttachment
                        attachment.attachmentCell = NSTextAttachmentCell(imageCell: newImages[newImageCount])
                        oldattr["NSAttachment"] = attachment
                        tmp.addAttributes(oldattr, range: NSMakeRange(0, tmp.length))
                        newAttrStr.append(tmp)
                        newImageCount += 1
                    }
                }
                message.textStorage?.setAttributedString(newAttrStr)
            }
        }
    }
    
    func splitViewDidResizeSubviews(_ notification: Notification) {
        adjustImages()
    }
    
    //////////////
    
    func participantsUpdate(_ EA_Name: String) {
        for i in 0..<myEAs.count {
            let cell = EATableView.view(atColumn: 0, row: i, makeIfNecessary: false) as! EAView
//                myEAs[i].approved = String(Int(myEAs[i].approved)! + 1)
                cell.numberOfParticipants.integerValue += 1
        }
    }

    //////////////
    
    override func controlTextDidChange(_ obj: Notification) {
        switch obj.object as! NSTextField {
        case EA_Description:
            descriptionCount.stringValue = wordCountFormatter(EA_Description.stringValue.encodedString().characters.count, max: 250)
            uploadDescriptionButton.isEnabled = EA_Description.stringValue.characters.count <= 250
        case EASearchField:
            print("changed")
            if EASearchField.stringValue != "" {
                needsMoveAnimation = true
                myEAs = myEAs_backup.filter({(ea) -> Bool in
                    for i in [ea.name, ea.supervisor, ea.time, ea.leader, ea.dates, ea.description.decodedString()] {
                        let range = NSString(string: i).range(of: EASearchField.stringValue, options: .caseInsensitive)
                        if range.location != NSNotFound {return true}
                    }
                    return false
                })
                myEAs = myEAs.sorted(by: {ea1, ea2 -> Bool in
                    if ea1.approval != ea2.approval {
                        return ea1.approval > ea2.approval
                    } else {
                        return ea1.name < ea2.name
                    }
                })
                needsMoveAnimation = false
                EATableView.reloadData()
                EATableView.deselectAll(nil)
                tableViewSelectionIsChanging(Notification(name: Notification.Name(rawValue: ""), object: nil))
            } else {
                needsMoveAnimation = false
                myEAs = myEAs_backup.sorted {ea1, ea2 -> Bool in
                    if ea1.approval != ea2.approval {
                        return ea1.approval > ea2.approval
                    } else {
                        return ea1.name < ea2.name
                    }
                }
                EATableView.reloadData()
                needsMoveAnimation = true
            }
        default:
            break
        }
       (obj.object as! NSTextField).layer?.borderWidth = 0
        currentItem = obj.object as! NSTextField
    }
    
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSTextField
        if EA_Name.stringValue == "" || textfield == EASearchField {return}
        let theEA = myEAs.filter({ea -> Bool in
            return ea.name == EA_Name.stringValue})[0]
        switch textfield {
        case EA_Description:
            if theEA.description.decodedString() != textfield.stringValue {sendDescription(uploadDescriptionButton)}
        case location:
            if theEA.location != textfield.stringValue {changeLocation(location)}
        case supervisor:
            if theEA.supervisor != textfield.stringValue {changeSupervisor(supervisor)}
        case leaderIDs:
            if theEA.id != textfield.stringValue {updateLeaderIDs(leaderIDs)}
        case leaders:
            if theEA.leader != textfield.stringValue {changeLeader(leaders)}
        case maxStudents:
            if theEA.max != textfield.stringValue && textfield.isEnabled || Int(textfield.stringValue) == nil {changeMaxStudents(maxStudents)}
        case time_detail:
            if theEA.time.components(separatedBy: " | ")[1] != textfield.stringValue && !textfield.isHidden {changeEADate(time_detail)}
        case prompt:
            if theEA.prompt != textfield.stringValue {updatePrompt(prompt)}
        default:
            print(textfield.stringValue)
        }
        currentItem = textfield
//        if change {
//            textfield.layer?.borderColor = NSColor.orangeColor().CGColor
//            textfield.layer?.borderWidth = 1
//        } else {
//            textfield.layer?.borderWidth = 0
//        }
    }
    
    func wordCountFormatter(_ length: Int, max: Int) -> String {
        if length == 1 {
            return "1/\(max) character"
        } else if length == 0 {
            return "\(max) characters max"
        } else {
            return "\(length)/\(max) characters"
        }
    }

    @IBAction func maxStudents(_ sender: NSButton) {
        maxStudents.isEnabled = sender.objectValue as! Bool
        if enableMaxStudents.integerValue == 1 {
            changeMaxStudents(maxStudents)
            controlTextDidEndEditing(Notification(name: Notification.Name(rawValue: ""), object: maxStudents))
        } else {
            changeStatusForKey("Max", value: "", spinner: maxStudentsSpinner, updateRow: false)
            shouldUpdate = false
            maxStudents.layer?.borderWidth = 0
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].max = ""
                }
            }
            shouldUpdate = true
        }
    }
    
    @IBAction func changeMaxStudents(_ sender: NSComboBox) {
        if Int(sender.stringValue) == nil || sender.integerValue <= 0 || sender.integerValue > 999 {return}
        sender.layer?.borderWidth = 0
        changeStatusForKey("Max", value: sender.stringValue, spinner: maxStudentsSpinner, updateRow: false)
        shouldUpdate = false
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].max = sender.stringValue
            }
        }
        shouldUpdate = true
    }
    
    
    @IBAction func changeAlignment(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            message.alignLeft(sender)
        case 1:
            message.alignCenter(sender)
        case 2:
            message.alignRight(sender)
        case 3:
            message.alignJustified(sender)
        default:
            break
        }
    }
    
    
    @IBAction func fontStyle(_ sender: NSSegmentedControl) {
        boldMenuItem.menu?.update()
        if sender.selectedSegment == 3 {
            NSFontManager.shared().orderFrontFontPanel(sender)
            sender.setSelected(false, forSegment: 3)
        } else if sender.selectedSegment == 0 {
            boldMenuItem.menu?.update()
            boldMenuItem.menu?.performActionForItem(at: 1)
        } else if sender.selectedSegment == 1 {
            boldMenuItem.menu?.performActionForItem(at: 2)
        } else {
            //            boldMenuItem.menu?.performActionForItemAtIndex(3)
            message.underline(sender)
        }
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
        let fm = NSFontManager.shared()
        if let s = fm.selectedFont {
            fontStyle.setSelected(fm.weight(of: s) >= 8, forSegment: 0)
        }
        if let i = fm.selectedFont?.italicAngle {
            fontStyle.setSelected(i != 0, forSegment: 1)
        }
        boldMenuItem.menu?.update()
        fontStyle.setSelected(boldMenuItem.menu?.item(at: 3)?.state == 1, forSegment: 2)
        
        var range = message.selectedRange()
        if range.length == 0 && message.textStorage!.length != 0 {
            if range.location != 0 {
                range.location -= 1
            }
            range.length += 1
        }
        //        else if message.textStorage?.length == 0 {
        //            colorWell.color = NSColor.black
        //        }
        if message.textStorage?.length == 0 {return}
        
        let attrStr = message.attributedString().attributedSubstring(from: range)
        if let color = attrStr.attributes(at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, attrStr.length))[NSForegroundColorAttributeName] as? NSColor {
            colorWell.color = color
        } else {
            colorWell.color = NSColor.black
        }
        
        if let alignment = message.attributedString().attributedSubstring(from: range).attributes(at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, message.attributedString().length))[NSParagraphStyleAttributeName] as? NSParagraphStyle {
            switch (alignment.alignment) {
            case .left:
                alignmentSegment.selectedSegment = 0
            case .right:
                alignmentSegment.selectedSegment = 2
            case .center:
                alignmentSegment.selectedSegment = 1
            case .justified:
                alignmentSegment.selectedSegment = 3
            default:
                alignmentSegment.selectedSegment = 0
            }
        
        }
    }
    
    
    func textViewDidChangeTypingAttributes(_ notification: Notification) {
        textViewDidChangeSelection(notification)
    }
    
    @IBAction func moreAttributes(_ sender: NSButton) {
        let viewController = NSViewController()
        if atrview != nil {
            viewController.view = atrview!
        } else {
            viewController.view = attributeView
            atrview = attributeView
        }
        viewController.view.frame.size = CGSize(width: 187, height: 204)
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = viewController
        popover.show(relativeTo: viewController.view.bounds, of: sender, preferredEdge: .maxX)
    }
    
    @IBAction func uploadDescription(_ sender: NSButton) {
        
        /* 
        if CWWiFiClient()?.interface()?.ssid() == "BCIS WIFI" || CWWiFiClient()?.interface()?.ssid() == "BCIS_AP_Visitor" {
            let alert = NSAlert()
            alert.messageText = "Oops! You're on school wifi."
            alert.informativeText = "Unfortunately, BCIS Wi-Fi blocked all outgoing network traffic on FTP servers. Therefore, you must switch to a different network in order to upload."
            alert.addButtonWithTitle("Fine").keyEquivalent = "\r"
            alert.window.title = "Unavailable Network"
            if alert.runModal() == NSAlertFirstButtonReturn {return}
        } */
        
        descriptionUpdateSpinner.startAnimation(nil)
        sender.isEnabled = false
        
        // Prepare description RTFD file to upload (as zip)
        message.writeRTFD(toFile: NSTemporaryDirectory() + "Description.rtfd", atomically: true)
        message.writeRTFD(toFile: NSTemporaryDirectory() + EA_Name.stringValue + ".rtfd", atomically: true)
        let command = Terminal(launchPath: "/usr/bin/zip", arguments: ["-r", EA_Name.stringValue + ".zip", "Description.rtfd"])
        command.currentPath = NSTemporaryDirectory()
        command.deleteFileWithPath("./\(EA_Name.stringValue).zip")
        command.execUntilExit()
        command.deleteFileWithPath("./Description.rtfd")
        
        var config = SessionConfiguration()
//        config.host = "e45.ehosts.com"
//        config.username = "ea@thefluxfilm.com"
//        config.password = "tenic"
        
        config.host = "47.52.6.204:23333"
        config.username = "root"
        config.password = "Tenic@2017"
        config.passive = true
        
        let session = Session(configuration: config)
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory() + EA_Name.stringValue + ".zip")
        session.upload(fileURL, path: "/var/www/html/EA/" + EA_Name.stringValue + ".zip") {(result, error) -> Void in
            DispatchQueue.main.async(execute: {
                self.descriptionUpdateSpinner.stopAnimation(nil)
                sender.isEnabled = true
            })
            if result {
                print("uploaded")
            } else {
                let alert = NSAlert()
                alert.messageText = "Upload Failed"
                if error?.code == 2 {
                    alert.informativeText = "Please check your internet connection."
                } else {
                    print(error)
                }
                DispatchQueue.main.async(execute: {
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                })
            }
        }
    }
    
    @IBAction func revertDescription(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.informativeText = "If you continue, your EA's description will be reverted to the last version you've uploaded to the server."
        alert.addButton(withTitle: "Proceed").keyEquivalent = "\r"
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == NSAlertSecondButtonReturn {return}
        updateDescription()
    }
    
    func updateDescription() {
        revertSpinner.startAnimation(nil)
        let acceptableChars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789_-")
        
        let name = EA_Name.stringValue.addingPercentEncoding(withAllowedCharacters: acceptableChars)
        message.string = ""
        let request = URLRequest(url: URL(string: serverAddress + "EA/\(name!).zip")!)
        let download = NSURLDownload.init(request: request, delegate: self)
        download.setDestination(NSTemporaryDirectory() + EA_Name.stringValue + ".zip", allowOverwrite: true)
        download.deletesFileUponFailure = true
        downloadQueue[EA_Name.stringValue] = download
        message.isEditable = false
        Terminal().deleteFileWithPath(NSTemporaryDirectory() + EA_Name.stringValue + ".rtfd")
        Terminal().deleteFileWithPath(NSTemporaryDirectory() + "Description.rtfd")
    }
    
    func downloadDidFinish(_ download: NSURLDownload) {
        message.isEditable = true
        revertSpinner.stopAnimation(nil)

        if downloadQueue[EA_Name.stringValue] == download {
            let command = Terminal(launchPath: "/usr/bin/unzip", arguments: ["-o", EA_Name.stringValue + ".zip"])
            command.currentPath = NSTemporaryDirectory()
            command.execUntilExit()
            command.launchPath = "/bin/mv"
            command.deleteFileWithPath(NSTemporaryDirectory() + EA_Name.stringValue + ".rtfd")
            command.arguments = ["Description.rtfd", EA_Name.stringValue + ".rtfd"]
            command.execUntilExit()
            message.readRTFD(fromFile: NSTemporaryDirectory() + EA_Name.stringValue + ".rtfd")
            adjustImages()
            length = 0
        }
    }
    
    func download(_ download: NSURLDownload, didReceiveDataOfLength length: Int) {
        self.length += length
    }
    
    func download(_ download: NSURLDownload, didFailWithError error: Error) {
        revertSpinner.stopAnimation(nil)
        if error._code == -1100 && downloadQueue[EA_Name.stringValue] == download {
            message.string = "Give a brief introduction to your EA. Similar to how you would advertise your EA on the Student Bulletin, use graphics and texts to attract students and convince them to join! Some things you may want to include:\n\n • A QR code of your Wechat group\n • What students will be doing in this EA\n • The final outcome of this EA\n • Images of the EA\n • Requirements / Prerequisites\n • Start Date & End Date\n • Updates on current progress\n\nNote: If you want to import a photo from an apple device, plug it in, right click and select \"Import Image\"!"
            message.font = NSFont(name: "Helvetica", size: 13)
            message.alignment = .left
            message.isEditable = true
            message.textColor = NSColor.black
            let pstyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            pstyle.paragraphSpacing = 7
            pstyle.lineSpacing = 1.1
            message.textStorage?.addAttribute(NSParagraphStyleAttributeName, value: pstyle, range: NSMakeRange(0, message.textStorage!.length))
        }
    }
    
    @IBAction func removeEA(_ sender: NSButton) {
        
        let row = EATableView.selectedRow
        if row == -1 {return}
        
        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.informativeText = "If you continue, you will permanently remove \(EA_Name.stringValue) from the server."
        alert.alertStyle = .critical
        alert.window.title = "Remove EA"
        alert.addButton(withTitle: "Remove").keyEquivalent = "\r"
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() != NSAlertFirstButtonReturn {
            return
        }

        let cell = EATableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! EAView
        let url = URL(string: serverAddress + "tenicCore/RemoveEA.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        var hasRun = false
        let postString = "EA=\(cell.EAName.stringValue)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if hasRun {return}
            hasRun = true
            
            if error != nil {
                DispatchQueue.main.async {
                    alert.messageText = "EA Deletion Error"
                    alert.informativeText = "You seem to be offline."
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.runModal()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.myEAs.remove(at: row)
                self.tableViewSelectionIsChanging(Notification(name: Notification.Name(rawValue: ""), object: nil))
                self.updateStats()
            }
            
        }
        task.resume()
    }
    
    @IBAction func updateLeaderIDs(_ sender: NSTokenField) {
        let string = (sender.objectValue as! [String]).joined(separator: ", ")
        shouldUpdate = false
        changeStatusForKey("ID", value: string, spinner: leaderIDSpinner, updateRow: false)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].id = string
            }
        }
        shouldUpdate = true
        sender.layer?.borderWidth = 0
    }
    
    @IBAction func enableMinGrade(_ sender: NSButton) {
        minGrade.isEnabled = sender.integerValue == 1
        changeGradeBoundary(sender)
    }
    
    @IBAction func enableMaxGrade(_ sender: NSButton) {
        maxGrade.isEnabled = sender.integerValue == 1
        changeGradeBoundary(sender)
    }
    
    @IBAction func changeGradeBoundary(_ sender: NSObject) {
        
        if Int(minGrade.title) > Int(maxGrade.title) && minGrade.isEnabled && maxGrade.isEnabled {
            let alert = NSAlert()
            alert.messageText = "Your minimum grade is GREATER than maximum grade"
            alert.informativeText = "Technically, it means no one can join the EA. Are you sure about that?"
            alert.addButton(withTitle: "Yes").keyEquivalent = "\r"
            alert.addButton(withTitle: "No")
            if alert.runModal() != NSAlertFirstButtonReturn {
                switch sender {
                case maxGrade:
                    maxGrade.title = minGrade.title
                case maxGradeCheckbox:
                    maxGradeCheckbox.integerValue = 0
                    maxGrade.isEnabled = false
                case minGrade:
                    minGrade.title = maxGrade.title
                case minGradeCheckbox:
                    minGradeCheckbox.integerValue = 0
                    minGrade.isEnabled = false
                default:
                    break
                }
                return
            }
            
        }
        
        var minAge = ""
        if minGrade.isEnabled {minAge = minGrade.title}
        var maxAge = ""
        if maxGrade.isEnabled {maxAge = maxGrade.title}
        shouldUpdate = false
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].age = minAge + " | " + maxAge
            }
        }
        shouldUpdate = true
        changeStatusForKey("Age", value: minAge + " | " + maxAge, spinner: gradeSpinner, updateRow: false)
        (sender as? NSComboBox)?.layer?.borderWidth = 0
    }
    
    @IBAction func changeCategory(_ sender: NSPopUpButton) {
        let color = ["Blue", "Orange", "Green", "Red", "Pink", "Yellow", "Purple", ""][sender.selectedTag()]
        let theEA = myEAs.filter({$0.name == EA_Name.stringValue})[0]
        
        if theEA.color.contains("|") {
            changeStatusForKey("Color", value: [color, theEA.color.components(separatedBy: "|")[1]].joined(separator: "|"), spinner: categorySpinner, updateRow: false)
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].color = color + "|" + theEA.color.components(separatedBy: "|")[1]
                }
            }
        } else {
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].color = color
                }
            }
        }
        changeStatusForKey("Color", value: color, spinner: categorySpinner, updateRow: false)
    }
    
    @IBAction func nextDate(_ sender: NSButton) {
        
        if EATableView.selectedRow == -1 || nextSessionDate == "Unavailable" {return}
        
        let theEA = myEAs[EATableView.selectedRow]
        
        if theEA.dates == "" {return}
        
        let allDates = theEA.dates.components(separatedBy: " | ")
        if let currentIndex = allDates.index(of: nextSessionDate) {
            if currentIndex < allDates.count - 1 {nextSessionDate = allDates[currentIndex+1]} else {
                nextSessionDate = allDates.last!
            }
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            
            let oldDate = formatter.date(from: nextSessionDate)!
            
            var targetDate = Date()
            
            for i in allDates.map({formatter.date(from: $0)!}) {
                let distance = i.timeIntervalSince(oldDate) / 86400
                if distance > 0 {
                    targetDate = i
                }
            }
            nextSessionDate = formatter.string(from: targetDate)
        }
        

        participantTable.reloadData()

    }
    
    @IBAction func previousDate(_ sender: NSButton) {
        if EATableView.selectedRow == -1 || nextSessionDate == "Unavailable" {return}
        
        let theEA = myEAs[EATableView.selectedRow]
        
        let allDates = theEA.dates.components(separatedBy: " | ")
        if let currentIndex = allDates.index(of: nextSessionDate) {
            if currentIndex > 0 {nextSessionDate = allDates[currentIndex-1]}
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            
            let oldDate = formatter.date(from: nextSessionDate)!
            
            var targetDate = Date()
            
            for i in allDates.map({formatter.date(from: $0)!}).reversed() {
                let distance = i.timeIntervalSince(oldDate) / 86400
                if distance < 0 {
                    targetDate = i
                }
            }
            nextSessionDate = formatter.string(from: targetDate)
        }
        participantTable.reloadData()
    }
    /*
    @IBAction func confirmDate(sender: NSButton) {

        changeStatusForKey("Next", value: nextSessionDate, spinner: sessionDateSpinner, updateRow: false)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].next = nextSessionDate
                sender.enabled = false
                break
            }
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM. d, y"
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let rawDate = formatter.dateFromString(nextSessionDate)
        formatter.dateFormat = "MMMM d"
        broadcastMessage("Find my EA", message: "Next session of \(EA_Name.stringValue) has been set to \(formatter.stringFromDate(rawDate!)).", filter: "E:\(EA_Name.stringValue)")
    }*/
    
    @IBAction func activateScheduler(_ sender: NSButton) {
        self.performSegue(withIdentifier: "Session Scheduler", sender: self)
    }
    
    @IBAction func changeStartDate(_ sender: NSDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, y"
        formatter.locale = Locale(identifier: "en_US")
        changeStatusForKey("Start Date", value: formatter.string(from: startDate.dateValue), spinner: changeEADateSpinner, updateRow: false)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                shouldUpdateParticipantsTable = true
                myEAs[i].startDate = formatter.string(from: startDate.dateValue)
                shouldUpdateParticipantsTable = false
                break
            }
        }
    }
    
    @IBAction func changeEndDate(_ sender: NSDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, y"
        formatter.locale = Locale(identifier: "en_US")
        changeStatusForKey("End Date", value: formatter.string(from: endDate.dateValue), spinner: changeEADateSpinner, updateRow: false)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                shouldUpdateParticipantsTable = true
                myEAs[i].endDate = formatter.string(from: endDate.dateValue)
                shouldUpdateParticipantsTable = false
                break
            }
        }
    }
    
    @IBAction func logout(_ sender: NSButton) {
        self.performSegue(withIdentifier: "Log out", sender: self)
        for i in NSApplication.shared().windows {
            if i.title != "Login" {
                i.orderOut(self)
            }
        }
        logged_in = false
    }
    
    // Managing the attendence system
    
    // Right Click
    var rightclickRowIndex = -1
    
    func menuWillOpen(_ menu: NSMenu) {
        
        let cursor = NSEvent.mouseLocation()
        let cursorInWindow = NSPoint(x: cursor.x - (view.window?.frame.origin.x)!, y: cursor.y - (view.window?.frame.origin.y)!)
        rightclickRowIndex = participantTable.row(at: participantTable.convert(cursorInWindow, from: view))
        if rightclickRowIndex == -1 {menu.removeAllItems(); return}
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        if nextSessionDateTextfield.stringValue != "Today" {
            let tmp = formatter.date(from: nextSessionDate)!
            if tmp.timeIntervalSince(Date()) > 0 {
                menu.removeAllItems()
                menu.addItem(withTitle: "EA Hasn't Run, Cannot Mark Attendance", action: "", keyEquivalent: "").isEnabled = false
                menu.addItem(NSMenuItem.separator())
                menu.addItem(withTitle: "Force Remove Student From EA", action: #selector(ViewController.removeParticipant), keyEquivalent: "")
                return
            }
        }
        
        let cell = participantTable.view(atColumn: 0, row: rightclickRowIndex, makeIfNecessary: false) as! ParticipantView
        
        menu.removeAllItems()
        if cell.attendance == .unapproved {return}
        menu.addItem(withTitle: "Mark as Present for this Session", action: #selector(ViewController.markAsPresent), keyEquivalent: "")
        menu.addItem(withTitle: "Mark as Absent for this Session", action: #selector(ViewController.markAsAbsent), keyEquivalent: "")
        
        if cell.attendance == .present {
            menu.item(at: 0)?.isEnabled = false
        } else if cell.attendance == .absent {
            menu.item(at: 1)?.isEnabled = false
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Force Remove Student From EA", action: #selector(ViewController.removeParticipant), keyEquivalent: "")
    }
    
    func removeParticipant() {
        let cell = participantTable.view(atColumn: 0, row: rightclickRowIndex, makeIfNecessary: false) as! ParticipantView
        for i in 0..<participants.count {
            if participants[i].id == cell.toolTip!.components(separatedBy: "\r")[0].components(separatedBy: ": ")[1] {
                print(participants[i].id)
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM. d, y"
                
                let url = URL(string: serverAddress + "tenicCore/signup.php")
                var request = URLRequest(url: url!)
                request.httpMethod = "POST"
                
                let postString = "id=\(participants[i].id)&ea=\(EA_Name.stringValue)&action=Leave&date=\(formatter.string(from: Date()))"
                
                request.httpBody = postString.data(using: String.Encoding.utf8)
                
                // Specify the session task
                let uploadtask = URLSession.shared.dataTask(with: request, completionHandler: {
                    data, response, error in
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary as! [String:String]
                        if json["status"] == "success" {
                            DispatchQueue.main.async {
                                self.updateParticipantsForEA(self.EA_Name.stringValue, date: self.nextSessionDate, updateTable: true)
                            }
                            broadcastMessage("Find my EA", message: "You have been removed from \(self.EA_Name.stringValue) by the admin.", filter: "I: \(self.participants[i].id)")
                            return
                        }
                        
                    } catch {
                        print(String(data: data!, encoding: String.Encoding.utf8)!)
                    }
                })
                // Begin
                uploadtask.resume()
            }
        }
    }
    
    var refreshParticipants = true
    
    @IBAction func markAllAsPresent(_ sender: NSButton) {
        for i in 0..<participantTable.numberOfRows {
            let cell = participantTable.view(atColumn: 0, row: i, makeIfNecessary: false) as! ParticipantView
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            
            let tmp = formatter.date(from: nextSessionDate)!
            formatter.dateFormat = "y/M/d"
            let date = formatter.string(from: tmp)
            
            let currentID = cell.userID ?? "_"
            
            let pid = participants.map {$0.id}
            
            if let index = pid.index(of: currentID), !participants[index].attendance.contains(date) {
                refreshParticipants = false
                let add = participants[index].attendance == "" ? date : date + ", "
                participants[index].attendance = add + participants[index].attendance // Don't do the refresh yet
                refreshParticipants = true
                cell.changeStatusForKey("Attendance", value: participants[index].attendance, spinner: cell.attendanceSpinner, id: participants[index].id, present: true)
            }
        }
    }
    
    @IBAction func markAllAsAbsent(_ sender: NSButton) {
        let formatter = DateFormatter()
        for i in 0..<participantTable.numberOfRows {
            let cell = participantTable.view(atColumn: 0, row: i, makeIfNecessary: false) as! ParticipantView
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            
            let tmp = formatter.date(from: nextSessionDate)!
            formatter.dateFormat = "y/M/d"
            let date = formatter.string(from: tmp)
            
            let currentID = cell.userID ?? "_"
            
            let pid = participants.map {$0.id}
            
            if let index = pid.index(of: currentID), participants[index].attendance.contains(date) {
                var attendenceDates = participants[index].attendance.components(separatedBy: ", ")
                if attendenceDates.contains(date) {
                    attendenceDates.remove(at: attendenceDates.index(of: date)!)
                }
                refreshParticipants = false
                participants[index].attendance = attendenceDates.joined(separator: ", ")
                refreshParticipants = true
                cell.changeStatusForKey("Attendance", value: participants[index].attendance, spinner: cell.attendanceSpinner, id: participants[index].id, present: false)
            }
        }
    }
    
    func markAsPresent() {
        print("Marking present for row: \(rightclickRowIndex)")
        let cell = participantTable.view(atColumn: 0, row: rightclickRowIndex, makeIfNecessary: false) as! ParticipantView
        if cell.attendance == .present {return}
        for i in 0..<participants.count {
            if participants[i].id == cell.toolTip!.components(separatedBy: "\r")[0].components(separatedBy: ": ")[1] {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM. d, y"
                
                let tmp = formatter.date(from: nextSessionDate)!
                formatter.dateFormat = "y/M/d"
                let date = formatter.string(from: tmp)
                
                let add = participants[i].attendance == "" ? date : date + ", "
//                refreshParticipants = false
                participants[i].attendance = add + participants[i].attendance // Don't do the refresh yet
//                refreshParticipants = true
                cell.changeStatusForKey("Attendance", value: participants[i].attendance, spinner: cell.attendanceSpinner, id: participants[i].id, present: true)
            }
        }
    }
    
    func markAsAbsent() {
        let cell = participantTable.view(atColumn: 0, row: rightclickRowIndex, makeIfNecessary: false) as! ParticipantView
        if cell.attendance == .absent {return}
        for i in 0..<participants.count {
            if participants[i].id == cell.toolTip!.components(separatedBy: "\r")[0].components(separatedBy: ": ")[1] {
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM. d, y"
                
                let tmp = formatter.date(from: nextSessionDate)!
                formatter.dateFormat = "y/M/d"
                let date = formatter.string(from: tmp)
                
                var attendenceDates = participants[i].attendance.components(separatedBy: ", ")
                if attendenceDates.contains(date) {
                    attendenceDates.remove(at: attendenceDates.index(of: date)!)
                }
                refreshParticipants = false
                participants[i].attendance = attendenceDates.joined(separator: ", ")
                refreshParticipants = true
                cell.changeStatusForKey("Attendance", value: participants[i].attendance, spinner: cell.attendanceSpinner, id: participants[i].id, present: false)
            }
        }
    }
    
    // FTP server communication
    
    @IBOutlet weak var updateDownloadProgress: NSProgressIndicator!
    
    func startUpdate() {
        eaInfoLabel.stringValue = "Preparing update..."
        requestManager?.delegate = self
        updateDownloadProgress.startAnimation(nil)
        let menu = NSMenu(title: "Update")
        menu.addItem(withTitle: "Cancel Download", action: #selector(ViewController.cancelUpdate), keyEquivalent: "")
        updateDownloadProgress.menu = menu
        requestManager?.addRequestForDownloadFile(atRemotePath: "../downloads/EA Manager.pkg", toLocalPath: NSTemporaryDirectory() + "EA Manager.pkg")
        requestManager?.startProcessingRequests()
    }
    
    func cancelUpdate() {
        requestManager?.stopAndCancelAllRequests()
        updateDownloadProgress.stopAnimation(nil)
        updateDownloadProgress.isIndeterminate = true
        eaInfoLabel.stringValue = "Update Cancelled."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateStats()
        }
    }
    
    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompletePercent percent: Float, forRequest request: GRRequestProtocol!) {
        if updateDownloadProgress.isIndeterminate {
            updateDownloadProgress.isIndeterminate = false
        }
        eaInfoLabel.stringValue = "Downloading...\(Int(percent * 100))%"
        updateDownloadProgress.doubleValue = Double(percent * 100)
    }

    
    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompleteDownloadRequest request: GRDataExchangeRequestProtocol!) {
        updateFinished()
    }
    
    func updateFinished() {
        updateDownloadProgress.isIndeterminate = true
        updateDownloadProgress.stopAnimation(nil)
        eaInfoLabel.stringValue = "Update complete."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateStats()
        }
        let alert = NSAlert()
        alert.window.title = "EA Manager Update"
        alert.messageText = "Update Completed"
        alert.informativeText = "Would you like to install the update now?"
        alert.addButton(withTitle: "Install Now").keyEquivalent = "\r"
        alert.addButton(withTitle: "Later")
        if alert.runModal() == NSAlertFirstButtonReturn {
            let command = Terminal(launchPath: "/usr/bin/open", arguments: [NSTemporaryDirectory() + "EA Manager.pkg"])
            command.execUntilExit()
            NSApplication.shared().terminate(0)
        } else {
            (NSApplication.shared().delegate as! AppDelegate).installUpdate.isHidden = false
            (NSApplication.shared().delegate as! AppDelegate).updateItem.isEnabled = false
        }
        
    }
    
    func writeEAsToFile(_ sender: NSMenuItem) {
        
        if myEAs.count == 0 {
            let alert = NSAlert()
            alert.messageText = "Nothing to Write!"
            alert.informativeText = "The full list of EAs does not seem to be loaded."
            alert.addButton(withTitle: "OK").keyEquivalent = "\r"
            alert.window.title = "Export Error"
            alert.runModal()
            return
        }
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["csv"]
        panel.title = "Export EAs as Table"
        panel.message = "Please choose a destination for your file:"
        panel.prompt = "Export"
        panel.canSelectHiddenExtension = true
        panel.nameFieldStringValue = "EAs.csv"
        panel.canCreateDirectories = true
        let result = panel.runModal()
        if result == 1 {
            let path = panel.url!.path
            print(panel.url!)
            self.exportEAs(path)
        }
    }
    
    func exportEAs(_ path: String) {
        var filedata = "\"Name of Organization\",\"Leader(s)\",\"Leader Identity\",\"Start Date\",\"End Date\",\"Category\",\"ID(s)\",\"Supervisor / Contact\",\"Date\",\"Location\",\"Maximum Students\",\"Min Grade\",\"Max Grade\",\"Session Schedule\"\n"
        for i in myEAs {
            let colors = ["Blue", "Green", "Cyan", "Pink", "Yellow", "Purple", ""]
            let category = ["Science & Technology", "Humanities", "Arts & Literature", "Community-based", "Sports & Health", "Recreational", "Others"][colors.index(of: i.color) ?? 6]
            let ages = i.age.components(separatedBy: " | ")
            filedata += "\"\(i.name)\",\"\(i.leader)\",\"\(i.type)\",\"\(i.startDate)\",\"\(i.endDate)\",\"\(category)\",\"\(i.id)\",\"\(i.supervisor)\",\"\(i.time)\",\"\(i.location)\",\"\(i.max == "" ? "No Maximum" : i.max)\",\"\(ages[0] == "" ? "No Requirement" : ages[0])\",\"\(ages[1] == "" ? "No Requirement" : ages[1])\",\"\(i.dates)\"\n"
        }
        let alert = NSAlert()
        do {
            try filedata.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            alert.messageText = "Export Succeeded"
            alert.informativeText = "File has been exported to: \(path)."
            alert.addButton(withTitle: "OK").keyEquivalent = "\r"
            alert.runModal()
        } catch {
            alert.messageText = "File Output Error"
            alert.informativeText = "Please make sure you have write permission for the output directory you've specified."
            alert.addButton(withTitle: "OK").keyEquivalent = "\r"
            alert.runModal()
        }
    }
}

// Animations

let database = ["Cloud Sync": (108, 19), "Globe": (506, 57)]

class LoadImage: NSImageView {
    
    var isAnimating = false
    var imageName = ""
    var max = 0
    var breakpoint = 0
    
    var currentThread: Thread?
    
    let resourcePath = Bundle.main.resourcePath!
    
    func startAnimation(_ image: String) {
        if currentThread != nil && !currentThread!.isCancelled || isAnimating {return}
        self.isHidden = false
        self.image = nil
        isAnimating = true
        self.imageName = image
        max = database[imageName]!.0
        breakpoint = database[imageName]!.1
        self.currentThread = Thread(target: self, selector: #selector(LoadImage.loop), object: nil)
        self.currentThread!.start()
    }
    
    func stopAnimation() {
        isAnimating = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.currentThread?.cancel()
        }
    }
    
    func loop() {
        isAnimating = true
        var currentFrame = 0
        let imageData = NSData.data(withCompressedData: (animationPack[NSString(string: imageName).aes256Encrypt(withKey: AESKey)]! as NSData).aes256Decrypt(withKey: AESKey)) as! Data
        let sequence = NSKeyedUnarchiver.unarchiveObject(with: imageData) as! [Data]
        while isAnimating {
//            let name = imageName + "_" + String(format: "%03d", currentFrame) + ".png"
//            let tmp = NSImage(contentsOfFile: resourcePath + "/" + imageName + "/" + name)
            DispatchQueue.main.async(execute: {self.image = NSImage(data: sequence[currentFrame])})
            currentFrame = currentFrame < max ? currentFrame + 1 : breakpoint
            Thread.sleep(forTimeInterval: 0.035)
        }
        isAnimating = false
        self.isHidden = true
        return
    }
}

extension NSTokenField {
    override open var stringValue: String {
        get {
            let raw = self.objectValue as! [String]
            return raw.joined(separator: ", ")
        } set (newValue) {
            let content = newValue.components(separatedBy: ", ")
            self.objectValue = newValue == "" ? [String]() : content
        }
    }
}

