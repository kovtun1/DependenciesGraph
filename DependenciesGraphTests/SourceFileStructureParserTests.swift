//
//  SourceFileStructureParserTests.swift
//  DependencyGraph
//
//  Created by Oleksiy Kovtun on 9/1/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import XCTest

@testable import DependenciesGraph

class SourceFileStructureParserTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testFoo3Structure() {
    let fileReader = FileReader()
    let structureFileContent: String =
      fileReader.readFile(withName: "Foo3_structure", fileExtension: "json")
    
    let structureParser = SourceFileStructureParser()
    let extractedClasses: [Class] =
      structureParser.extractClasses(sourceFileStructure: structureFileContent)
    
    let expectedClasses: [Class] = [
      Class(name: "UserManager", bodyOffset: 575, bodyLength: 734),
      Class(name: "UserFirstNameChanger", bodyOffset: 1372, bodyLength: 214),
      Class(name: "UserLastNameChanger", bodyOffset: 1647, bodyLength: 212)
    ]
    
    XCTAssertEqual(extractedClasses, expectedClasses)
  }
}
