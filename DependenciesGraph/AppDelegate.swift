//
//  AppDelegate.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/1/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  // MARK: - IBActions
  
  @IBAction func open(_ sender: Any) {
    let openPanel = NSOpenPanel()
    
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.canChooseFiles = true
    openPanel.allowedFileTypes = ["swift"]
    
    openPanel.begin {
      (result: Int) in
      guard result == NSFileHandlingPanelOKButton, let sourceFileUrl = openPanel.url else {
        return
      }
      
      let vc: ViewController? =
        NSApplication.shared().mainWindow?.contentViewController as? ViewController
      
      vc?.sourceFileUrl = sourceFileUrl
    }
  }
}
