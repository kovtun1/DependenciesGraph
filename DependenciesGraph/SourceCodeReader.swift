//
//  SourceCodeReader.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/8/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Foundation

internal class SourceCodeReader {
  internal func readSourceCode(from sourceFilePath: String) throws -> String {
    let sourceCode: String = try String(contentsOfFile: sourceFilePath)
    let modifiedSourceCode: String = self.removeCopyrightSymbol(from: sourceCode)
    
    return modifiedSourceCode
  }
  
  // MARK: - ©
  
  private func removeCopyrightSymbol(from sourceCode: String) -> String {
    // SourceKittend doesn't support ©
    let updatedSourceCode: String = sourceCode.replacingOccurrences(of: "©", with: "")
    
    return updatedSourceCode
  }
}
