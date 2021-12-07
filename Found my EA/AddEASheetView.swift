//
//  AddEASheetView.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/11/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class AddEASheetView: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func cancel(_ sender: NSButton) {
        view.window?.performClose(nil)
    }
    
}
