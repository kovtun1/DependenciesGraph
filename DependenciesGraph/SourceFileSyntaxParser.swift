//
//  SourceFileSyntaxParser.swift
//  DependencyGraph
//
//  Created by Oleksiy Kovtun on 8/31/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa
//import SwiftyJSON
import SourceKittenFramework

public class SourceFileSyntaxParser {
  public func extractTypes(
    fromSourceCode sourceCode : String,
    sourceFile                : File,
    inRange range             : Range<Int>
  ) -> Set<String> {
    let syntaxMap = SyntaxMap(file: sourceFile)
    
    let typeIdentifierSyntaxTokens: [SyntaxToken] = syntaxMap.tokens.filter {
      (syntaxToken: SyntaxToken) -> Bool in
      return syntaxToken.type == SyntaxKind.typeidentifier.rawValue
    }
    
    let allTypes: [String] = typeIdentifierSyntaxTokens.flatMap {
      (syntaxToken: SyntaxToken) -> String? in
      guard
        range.contains(syntaxToken.offset) && range.contains(syntaxToken.offset + syntaxToken.length)
      else {
        return nil
      }
      
      let typeStartIndex: String.Index =
        sourceCode.index(sourceCode.startIndex, offsetBy: syntaxToken.offset)
      
      let typeEndIndex: String.Index =
        sourceCode.index(sourceCode.startIndex, offsetBy: syntaxToken.offset + syntaxToken.length)
      
      let typeRange: Range<String.Index> = typeStartIndex ..< typeEndIndex
      let type: String = sourceCode.substring(with: typeRange)
      
      return type
    }
    
    let types = Set<String>(allTypes)
    
    return types
  }
}
