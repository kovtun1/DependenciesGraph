//
//  SourceFileStructureParser.swift
//  DependencyGraph
//
//  Created by Oleksiy Kovtun on 9/1/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa
import SwiftyJSON

public struct ClassStructure {
  let name       : String
  let bodyOffset : Int
  let bodyLength : Int
}

extension ClassStructure: Equatable {
  public static func ==(lhs: ClassStructure, rhs: ClassStructure) -> Bool {
    return
      lhs.name == rhs.name && lhs.bodyOffset == rhs.bodyOffset && lhs.bodyLength == rhs.bodyLength
  }
}

public class SourceFileStructureParser {
  public func extractClassStructures(sourceFileStructure: String) -> [ClassStructure] {
    let structure = JSON(parseJSON: sourceFileStructure)
    
    guard let structureItems: [JSON] = structure["key.substructure"].array else {
      return []
    }
    
    let classes: [ClassStructure] = structureItems.flatMap {
      (structureItem: JSON) -> ClassStructure? in
      guard
        structureItem["key.kind"] == "source.lang.swift.decl.class",
        let name: String = structureItem["key.name"].string,
        let bodyOffset: Int = structureItem["key.bodyoffset"].int,
        let bodyLength: Int = structureItem["key.bodylength"].int
      else {
        return nil
      }
      
      let classStructure =
        ClassStructure(name: name, bodyOffset: bodyOffset, bodyLength: bodyLength)
      
      return classStructure
    }
    
    return classes
  }
}
