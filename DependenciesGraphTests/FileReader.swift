//
//  FileReader.swift
//  DependencyGraph
//
//  Created by Oleksiy Kovtun on 9/1/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

internal class FileReader {
  internal func readFile(withName name: String, fileExtension: String) -> String {
    let bundle = Bundle(for: type(of: self))
    let fileUrl: URL = bundle.url(forResource: name, withExtension: fileExtension)!
    let fileContent: String = try! String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
    
    return fileContent
  }
}
