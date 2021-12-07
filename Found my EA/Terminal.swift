//
//  Terminal.swift
//  Innovation Center
//
//  Created by Jia Rui Shan on 9/19/16.
//  Copyright © 2016 Tenic. All rights reserved.
//

import Cocoa

class Terminal {
    
    var launchPath: String
    var arguments: [String]
    var currentPath = "/"
    
    init(launchPath: String, arguments: [String]) {
        self.launchPath = launchPath
        self.arguments = arguments
    }
    
    init() {
        self.launchPath = "/bin/ls"
        self.arguments = ["."]
    }
    
    func exec() {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        task.currentDirectoryPath = currentPath
        task.launch()
    }
    
    func execUntilExit() {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        task.currentDirectoryPath = currentPath
        task.launch()
        task.waitUntilExit()

    }
    
    func deleteFileWithPath(_ p: String) {
        let task = Process()
        task.launchPath = "/bin/rm"
        task.arguments = ["-rf", NSString(string: p).expandingTildeInPath]
        task.currentDirectoryPath = currentPath
        
        task.launch()
    }
}
