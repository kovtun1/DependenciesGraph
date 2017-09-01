//
//  SourceFileSyntaxParserTests.swift
//  DependencyGraph
//
//  Created by Oleksiy Kovtun on 8/31/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import XCTest

@testable import DependenciesGraph

class SourceFileSyntaxParserTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testFoo1Syntax() {
    let extractedTypes: Set<String> = self.extractTypes(fromSourceFile: "Foo1")
    let expectedTypes: Set<String> = ["NSObject"]
    
    XCTAssertEqual(extractedTypes, expectedTypes)
  }
  
  func testFoo2Syntax() {
    let extractedTypes: Set<String> = self.extractTypes(fromSourceFile: "Foo2")
    let expectedTypes: Set<String> = ["NSObject", "TypeA", "TypeB", "TypeC"]
    
    XCTAssertEqual(extractedTypes, expectedTypes)
  }
  
  func testFoo3Syntax() {
    let extractedTypes: Set<String> = self.extractTypes(fromSourceFile: "Foo3")
    let expectedTypes: Set<String> = [
      "UserRepresentable",
      "UserFirstNameChangable",
      "UserLastNameChangable",
      "UserManagable",
      "String"
    ]
    
    XCTAssertEqual(extractedTypes, expectedTypes)
  }
  
  private func extractTypes(fromSourceFile fileName: String) -> Set<String> {
    let fileReader = FileReader()
    let sourceFileContent: String = fileReader.readFile(withName: fileName, fileExtension: "txt")
    let syntaxFileContent: String =
      fileReader.readFile(withName: "\(fileName)_syntax", fileExtension: "json")
    
    let syntaxParser = SourceFileSyntaxParser()
    let extractedTypes: Set<String> =
      syntaxParser.extractTypes(fromSourceCode: sourceFileContent, syntax: syntaxFileContent)
    
    return extractedTypes
  }
}
