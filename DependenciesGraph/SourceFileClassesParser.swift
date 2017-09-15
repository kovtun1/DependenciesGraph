//
//  SourceFileClassesParser.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/4/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa
import SourceKittenFramework

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
                   sourceFile : File
  ) -> [ClassTypes] {
    let classStructures: [ClassStructure] =
      self.structureParser.extractClassStructures(file: sourceFile)
    
    let classesTypes: [ClassTypes] = classStructures.map {
      (classStructure: ClassStructure) -> ClassTypes in
      let classBodyRange: Range<Int> =
        classStructure.bodyOffset ..< (classStructure.bodyOffset + classStructure.bodyLength)
      
      let classTypes: Set<String> = self.syntaxParser.extractTypes(
        fromSourceCode : sourceCode,
        sourceFile     : sourceFile,
        inRange        : classBodyRange
      )
      
      return ClassTypes(className: classStructure.name, classTypes: classTypes)
    }
    
    return classesTypes
  }
}
