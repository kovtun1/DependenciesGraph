//
//  DependenciesGraphCodeGenerator.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/4/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

public class DependenciesGraphCodeGenerator {
  public func generateCode(forClassesTypes classesTypes: [ClassTypes]) -> String {
    let uniqueTypes: Set<String> = Set<String>(
      Array(
        classesTypes.map {
          (classTypes: ClassTypes) -> [String] in
          return Array(classTypes.classTypes)
        }.joined()
      )
    )
    
    let typeNodes: String = uniqueTypes.joined(separator: ";\n  ")
    let classesEdges: String = classesTypes.map {
      (classType: ClassTypes) -> String in
      let types: String = classType.classTypes.joined(separator: "; ")
      let classEdges: String = "\(classType.className) -> { \(types) }"
      
      return classEdges
    }.joined(separator: "\n  ")
    
    let code: String =
      "digraph G {\n"     +
      "  \(typeNodes);\n" +
      "  \n"              +
      "  \(classesEdges)\n" +
      "}"
    
    return code
  }
}
