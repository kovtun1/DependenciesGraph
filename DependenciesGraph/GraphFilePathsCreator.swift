//
//  GraphFilePathsCreator.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/14/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

internal class GraphFilePathsCreator {
  internal var visJsPath: String {
    get {
      return NSTemporaryDirectory() + "vis.min.js"
    }
  }
  
  internal var visNetworkMinCssPath: String {
    get {
      return NSTemporaryDirectory() + "vis-network.min.css"
    }
  }
  
  internal var graphHtmlPath: String {
    get {
      return NSTemporaryDirectory() + "graph.html"
    }
  }
  
  // MARK: - Bundle files
  
  internal var visNetworkMinCssBundlePath: String? {
    get {
      return Bundle.main.url(forResource: "vis-network.min", withExtension: "css")?.absoluteString
    }
  }
  
  internal var visJsBundlePath: String? {
    get {
      return Bundle.main.url(forResource: "vis.min", withExtension: "js")?.absoluteString
    }
  }
}
