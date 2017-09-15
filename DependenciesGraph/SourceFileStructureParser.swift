//
//  SourceFileStructureParser.swift
//  DependencyGraph
//
//  Created by Oleksiy Kovtun on 9/1/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa
import SwiftyJSON
import SourceKittenFramework

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
  public func extractClassStructures(file: File) -> [ClassStructure] {
    let structure = Structure(file: file)
    let structureJson: JSON = JSON.init(structure.dictionary)
    
    guard
      let substructureItems: [JSON] = structureJson[SwiftDocKey.substructure.rawValue].array
    else {
      return []
    }
    
    let classes: [ClassStructure] = substructureItems.flatMap {
      (substructureItem: JSON) -> ClassStructure? in
      guard
        substructureItem[SwiftDocKey.kind.rawValue].string == SwiftDeclarationKind.class.rawValue,
        let name: String = substructureItem[SwiftDocKey.name.rawValue].string,
        let bodyOffset: Int = substructureItem[SwiftDocKey.bodyOffset.rawValue].int,
        let bodyLength: Int = substructureItem[SwiftDocKey.bodyLength.rawValue].int
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
