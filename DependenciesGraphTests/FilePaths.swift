//
//  FilePaths.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/15/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa
import SourceKittenFramework

internal class FilePaths {
  internal func getSourceFileFromBundle(
    withName     fileName      : String,
    andExtension fileExtension : String
  ) -> File {
    let bundle = Bundle(for: type(of: self))
    let fileUrl: URL = bundle.url(forResource: fileName, withExtension: fileExtension)!
    let file = File(path: fileUrl.path)!
    
    return file
  }
}
