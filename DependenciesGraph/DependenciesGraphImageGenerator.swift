//
//  DependenciesGraphImageGenerator.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/8/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Foundation
import Cocoa

internal class DependenciesGraphImageGenerator {
  internal func generateImage(from graphCode: String) -> NSImage? {
    guard let grahpCodeData: Data = graphCode.data(using: String.Encoding.utf8) else {
      return nil
    }
    
    let graphSourceFilePath: String = "/Users/okovtun-lp/Desktop/1.dot"
    let successfullyCreatedGraphSourceFile: Bool = FileManager.default.createFile(
      atPath     : graphSourceFilePath,
      contents   : grahpCodeData,
      attributes : nil
    )
    
    guard successfullyCreatedGraphSourceFile else {
      return nil
    }
    
    let graphImage: NSImage? = self.creteGraphImage(dotFilePath: "/Users/okovtun-lp/Desktop/1.dot")
    
    try? FileManager.default.removeItem(atPath: graphSourceFilePath)
    
    return graphImage
  }
  
  // MARK: - Image generator
  
  private func creteGraphImage(dotFilePath: String) -> NSImage? {
    let shell = ShellCommandsExecutor()
    let data = shell.execute(
      launchPath : "/usr/local/Cellar/graphviz/2.40.1/bin/dot",
      arguments  : ["-Tpng", dotFilePath]
    )
    
    print(data)
    
    let image = NSImage(data: data)
    
    return image
  }
}
