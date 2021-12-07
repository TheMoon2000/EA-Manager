//
//  Protocol.swift
//  EA Registration
//
//  Created by Jia Rui Shan on 12/4/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Foundation

protocol MenuDelegate {
    func pressedMenuItemWithTitle(_ title: String)
}

protocol WindowResizeDelegate {
    func windowWillResize(_ sender: AnyObject?)
    func windowHasResized(_ sender: AnyObject?)
}

func shell(_ launchPath: String, arguments: [String]) -> String
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    
    return output
}
