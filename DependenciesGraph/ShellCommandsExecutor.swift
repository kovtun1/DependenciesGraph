//
//  ShellCommandsExecutor.swift
//  DependencyGraph
//
//  Created by Oleksiy Kovtun on 8/31/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

internal class ShellCommandsExecutor {
  internal func execute(launchPath: String, arguments: [String]) -> Data {
    let task = Process()
    
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    
    task.standardOutput = pipe
    
    task.launch()
    
    let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    return data
  }
}
