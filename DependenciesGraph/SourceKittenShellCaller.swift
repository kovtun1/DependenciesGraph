//
//  SourceKittenShellCaller.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/15/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

internal class SourceKittenShellCaller: NSObject {
  private var sourceKittenBinaryPath: String
  
  internal init(binaryPath: String) {
    self.sourceKittenBinaryPath = binaryPath
  }
  
  internal func createSyntaxForSourceFile(at sourceFilePath: String) -> String {
    return self.executeSourceKitten(withCommand: "syntax", sourceFilePath: sourceFilePath)
  }
  
  internal func createStructureForSourceFile(at sourceFilePath: String) -> String {
    return self.executeSourceKitten(withCommand: "structure", sourceFilePath: sourceFilePath)
  }
  
  // MARK: - SourceKitten
  
  private func executeSourceKitten(withCommand command: String, sourceFilePath: String) -> String {
    let shell = ShellCommandsExecutor()
    let data = shell.execute(
      launchPath : self.sourceKittenBinaryPath,
      arguments  : [command, "--file", sourceFilePath]
    )
    let string = String(data: data, encoding: String.Encoding.utf8)!
    
    return string
  }
}
