//
//  DependenciesGraphCodeGeneratorTests.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/4/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import XCTest

@testable import DependenciesGraph

class DependenciesGraphCodeGeneratorTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testDependenciesGraphCodeGeneratedForClassesInFoo3() {
    let classesTypes: [ClassTypes] = [
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
    
    let codeGenerator = DependenciesGraphCodeGenerator()
    
    let generatedCode: String = codeGenerator.generateCode(forClassesTypes: classesTypes)
    let expectedCode: String =
      "digraph G {\n"               +
      "  UserFirstNameChangable;\n" +
      "  UserRepresentable;\n"      +
      "  UserLastNameChangable;\n"  +
      "  String;\n"                 +
      "  \n"                        +
      "  UserManager -> { UserFirstNameChangable; UserRepresentable; UserLastNameChangable; String }\n" +
      "  UserFirstNameChanger -> { UserRepresentable; String }\n" +
      "  UserLastNameChanger -> { UserRepresentable; String }\n" +
      "}"
    
    XCTAssertEqual(generatedCode, expectedCode)
  }
}
