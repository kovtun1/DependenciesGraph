//
//  SourceFileClassesParserTests.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/4/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import XCTest

@testable import DependenciesGraph

class SourceFileClassesParserTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testClassesInFoo3() {
    let fileReader = FileReader()
    let sourceFileContent: String = fileReader.readFile(withName: "Foo3", fileExtension: "txt")
    
    let structureFileContent: String =
      fileReader.readFile(withName: "Foo3_structure", fileExtension: "json")
    
    let syntaxFileContent: String =
      fileReader.readFile(withName: "Foo3_syntax", fileExtension: "json")
    
    let structureParser: SourceFileStructureParser = SourceFileStructureParser()
    let syntaxParser: SourceFileSyntaxParser = SourceFileSyntaxParser()
    
    let classesParser: SourceFileClassesParser =
      SourceFileClassesParser(structureParser: structureParser, syntaxParser: syntaxParser)
    
    let extractedClassesTypes: [ClassTypes] = classesParser.extractClassesTypes(
      fromSourceCode : sourceFileContent,
      structure      : structureFileContent,
      syntax         : syntaxFileContent
    )
    let expectedClassesTypes: [ClassTypes] = [
      ClassTypes(
        className  : "UserManager",
        classTypes : [
          "UserFirstNameChangable",
          "UserLastNameChangable",
          "UserRepresentable",
          "String"
        ]
      ),
      ClassTypes(className: "UserFirstNameChanger", classTypes: ["UserRepresentable", "String"]),
      ClassTypes(className: "UserLastNameChanger", classTypes: ["UserRepresentable", "String"])
    ]
    
    XCTAssertEqual(extractedClassesTypes, expectedClassesTypes)
  }
}
