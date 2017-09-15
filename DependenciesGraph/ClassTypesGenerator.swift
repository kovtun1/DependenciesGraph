//
//  ClassTypesGenerator.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/15/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa
import SourceKittenFramework

internal class ClassTypesGenerator {
  internal func generateClassTypes(sourceFileUrl: URL) throws -> [ClassTypes] {
    let sourceFilePath: String =
      sourceFileUrl.absoluteString.replacingOccurrences(of: "file:///", with: "/")
    
    let sourceCodeReader = SourceCodeReader()
    let sourceCode: String = try sourceCodeReader.readSourceCode(from: sourceFilePath)
    
    guard let sourceFile = File(path: sourceFilePath) else {
      return []
    }
    
    let structureParser = SourceFileStructureParser()
    let syntaxParser = SourceFileSyntaxParser()
    
    let classesParser =
      SourceFileClassesParser(structureParser: structureParser, syntaxParser: syntaxParser)
    
    let classTypes: [ClassTypes] = classesParser.extractClassesTypes(
      fromSourceCode : sourceCode,
      sourceFile     : sourceFile
    )
    
    return classTypes
  }
}
