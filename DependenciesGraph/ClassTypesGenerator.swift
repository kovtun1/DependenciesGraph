//
//  ClassTypesGenerator.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/15/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

internal class ClassTypesGenerator {
  internal func generateClassTypes(
    sourceFileUrl           : URL,
    sourceKittenShellCaller : SourceKittenShellCaller
  ) throws -> [ClassTypes] {
    let sourceFilePath: String =
      sourceFileUrl.absoluteString.replacingOccurrences(of: "file:///", with: "/")
    
    let sourceCodeReader = SourceCodeReader()
    let sourceCode: String = try sourceCodeReader.readSourceCode(from: sourceFilePath)
    let syntax: String = sourceKittenShellCaller.createSyntaxForSourceFile(at: sourceFilePath)
    let structure: String = sourceKittenShellCaller.createStructureForSourceFile(at: sourceFilePath)
    let structureParser = SourceFileStructureParser()
    let syntaxParser = SourceFileSyntaxParser()
    
    let classesParser =
      SourceFileClassesParser(structureParser: structureParser, syntaxParser: syntaxParser)
    
    let classTypes: [ClassTypes] = classesParser.extractClassesTypes(
      fromSourceCode : sourceCode,
      structure      : structure,
      syntax         : syntax
    )
    
    return classTypes
  }
}
