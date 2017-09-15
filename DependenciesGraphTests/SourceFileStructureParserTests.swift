//
//  SourceFileStructureParserTests.swift
//  DependencyGraph
//
//  Created by Oleksiy Kovtun on 9/1/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import XCTest
import SourceKittenFramework

@testable import DependenciesGraph

class SourceFileStructureParserTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testFoo3Structure() {
    let file: File = self.getSourceFileFromBundle(withName: "Foo3", andExtension: "txt")
    let structureParser = SourceFileStructureParser()
    let extractedClassStructures: [ClassStructure] =
      structureParser.extractClassStructures(file: file)
    
    let expectedClassStructures: [ClassStructure] = [
      ClassStructure(name: "UserManager", bodyOffset: 575, bodyLength: 734),
      ClassStructure(name: "UserFirstNameChanger", bodyOffset: 1372, bodyLength: 214),
      ClassStructure(name: "UserLastNameChanger", bodyOffset: 1647, bodyLength: 212)
    ]
    
    XCTAssertEqual(extractedClassStructures, expectedClassStructures)
  }
  
  func testAddToDoTableViewControllerSceneStructure() {
    let file: File =
      self.getSourceFileFromBundle(withName: "AddToDoTableViewControllerScene", andExtension: "txt")
    
    let structureParser = SourceFileStructureParser()
    let extractedClassStructures: [ClassStructure] =
      structureParser.extractClassStructures(file: file)
    
    let expectedClassStructures: [ClassStructure] = [
      ClassStructure(name: "AddToDoTableViewControllerScene", bodyOffset: 260, bodyLength: 1729)
    ]
    
    XCTAssertEqual(extractedClassStructures, expectedClassStructures)
  }
  
  // MARK: - private 
  
  private func getSourceFileFromBundle(
    withName     fileName      : String,
    andExtension fileExtension : String
  ) -> File {
    let bundle = Bundle(for: type(of: self))
    let fileUrl: URL = bundle.url(forResource: fileName, withExtension: fileExtension)!
    let file = File(path: fileUrl.path)!
    
    return file
  }
}
