//
//  SourceFileSyntaxParser.swift
//  DependencyGraph
//
//  Created by Oleksiy Kovtun on 8/31/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa
import SwiftyJSON

public class SourceFileSyntaxParser {
  public func extractTypes(fromSourceCode sourceCode: String, syntax: String) -> Set<String> {
    let syntaxJson = JSON.parse(syntax)
    
    guard let syntaxItems: [JSON] = syntaxJson.array else {
      return []
    }
    
    let allTypes: [String] = syntaxItems.flatMap {
      (syntaxItem: JSON) -> String? in
      guard
        syntaxItem["type"].string == "source.lang.swift.syntaxtype.typeidentifier",
        let offset: Int = syntaxItem["offset"].int,
        let length: Int = syntaxItem["length"].int
      else {
        return nil
      }
      
      let startIndex: String.Index = sourceCode.index(sourceCode.startIndex, offsetBy: offset)
      let end: String.Index = sourceCode.index(sourceCode.startIndex, offsetBy: offset + length)
      let range: Range<String.Index> = startIndex ..< end
      let type: String = sourceCode.substring(with: range)
      
      return type
    }
    
    let types = Set<String>(allTypes)
    
    return types
  }
}
