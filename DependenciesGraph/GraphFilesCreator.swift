//
//  GraphFilesCreator.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/14/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

internal class GraphFilesCreator {
  internal func createFiles(
    graphFilePathsCreator : GraphFilePathsCreator,
    graphHtmlCode         : String
  ) throws -> Bool {
    guard
      let visNetworkMinCssBundlePath: String = graphFilePathsCreator.visNetworkMinCssBundlePath,
      let visJsUrlBundlePath: String = graphFilePathsCreator.visJsBundlePath
    else {
      return false
    }
    
    if !FileManager.default.fileExists(atPath: graphFilePathsCreator.visJsPath) {
      try FileManager.default.copyItem(
        atPath : visJsUrlBundlePath,
        toPath : graphFilePathsCreator.visJsPath
      )
    }
    
    if !FileManager.default.fileExists(atPath: graphFilePathsCreator.visNetworkMinCssPath) {
      try FileManager.default.copyItem(
        atPath : visNetworkMinCssBundlePath,
        toPath : graphFilePathsCreator.visNetworkMinCssPath
      )
    }
    
    guard
      self.createTemporaryFile(at: graphFilePathsCreator.graphHtmlPath, content: graphHtmlCode)
    else {
      return false
    }
    
    let successfullyCreatedGraphHtmlFile: Bool =
      self.createTemporaryFile(at: graphFilePathsCreator.graphHtmlPath, content: graphHtmlCode)
    
    return successfullyCreatedGraphHtmlFile
  }
  
  // MARK: - File
  
  private func createTemporaryFile(at path: String, content: String) -> Bool {
    guard let data: Data = content.data(using: String.Encoding.utf8) else {
      return false
    }
    
    let successfullyCreatedFile =
      FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
    
    return successfullyCreatedFile
  }
}
