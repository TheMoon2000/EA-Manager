//
//  StartDatePicker.swift
//  EA Manager
//
//  Created by Jia Rui Shan on 1/10/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class StartDatePicker: NSViewController {
    
    @IBOutlet weak var datePicker: NSDatePicker!

    let ap = NSApplication.shared().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = ap.vc.startDate.dateValue
        datePicker.dateValue = date
        datePicker.sendAction(on: NSEventMask(rawValue: UInt64(Int(NSEventMask.mouseExited.rawValue))))
    }
    
    @IBAction func pickDate(_ sender: NSDatePicker) {
        ap.vc.startDate.dateValue = sender.dateValue
        ap.vc.changeStartDate(ap.vc.startDate)
    }
    
}

class EndDatePicker: NSViewController {
    
    let ap = NSApplication.shared().delegate as! AppDelegate

    @IBOutlet weak var datePicker: NSDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = ap.vc.endDate.dateValue
        datePicker.dateValue = date
        datePicker.sendAction(on: NSEventMask(rawValue: UInt64(Int(NSEventMask.mouseExited.rawValue))))
    }
    
    @IBAction func pickDate(_ sender: NSDatePicker) {
        ap.vc.endDate.dateValue = sender.dateValue
        ap.vc.changeEndDate(ap.vc.endDate)
    }
}
