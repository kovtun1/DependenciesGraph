//
//  SourceFileClassesParser.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/4/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

public struct ClassTypes {
  let className  : String
  let classTypes : Set<String>
}

extension ClassTypes: Equatable {
  public static func ==(lhs: ClassTypes, rhs: ClassTypes) -> Bool {
    return lhs.className == rhs.className && lhs.classTypes == rhs.classTypes
  }
}

public class SourceFileClassesParser {
  let structureParser : SourceFileStructureParser
  let syntaxParser    : SourceFileSyntaxParser
  
  public init(structureParser: SourceFileStructureParser, syntaxParser: SourceFileSyntaxParser) {
    self.structureParser = structureParser
    self.syntaxParser = syntaxParser
  }
  
  public func extractClassesTypes(
    fromSourceCode sourceCode : String,
    structure                 : String,
    syntax                    : String
  ) -> [ClassTypes] {
    let classes: [Class] = self.structureParser.extractClasses(sourceFileStructure: structure)
    let classesTypes: [ClassTypes] = classes.map {
      (`class`: Class) -> ClassTypes in
      let classBodyRange: Range<Int> =
        `class`.bodyOffset ..< (`class`.bodyOffset + `class`.bodyLength)
      
      let classTypes: Set<String> = self.syntaxParser.extractTypes(
        fromSourceCode : sourceCode,
        syntax         : syntax,
        inRange        : classBodyRange
      )
      
      return ClassTypes(className: `class`.name, classTypes: classTypes)
    }
    
    return classesTypes
  }
}
