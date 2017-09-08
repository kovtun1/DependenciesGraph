//
//  ViewController.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/1/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  @IBOutlet weak var imageView: NSImageView!
  
  private var timer: Timer!
  
  internal var sourceFileUrl: URL? {
    didSet {
      self.f()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
      [unowned self]
      (timer: Timer) in
      print("tick")
      self.f()
    }
  }
  
  override var representedObject: Any? {
    didSet {
      
    }
  }
  
  // MARK: -
  
  private func f() {
    guard let sourceFileUrl = self.sourceFileUrl else {
      return
    }
    
    let sourceFilePath: String =
      sourceFileUrl.absoluteString.replacingOccurrences(of: "file:///", with: "/")
    
    do {
      let sourceCode: String = try String(contentsOfFile: sourceFilePath)
      let syntax: String = self.createSyntaxForSourceFile(at: sourceFilePath)
      let structure: String = self.createStructureForSourceFile(at: sourceFilePath)
      
      let structureParser = SourceFileStructureParser()
      let syntaxParser = SourceFileSyntaxParser()
      let classesParser =
        SourceFileClassesParser(structureParser: structureParser, syntaxParser: syntaxParser)
      
      let classTypes: [ClassTypes] =
        classesParser.extractClassesTypes(
          fromSourceCode : sourceCode,
          structure      : structure,
          syntax         : syntax
      )
      
      let dependenciesGraphCodeGenerator = DependenciesGraphCodeGenerator()
      let graphCode: String = dependenciesGraphCodeGenerator.generateCode(forClassesTypes: classTypes)
      let graphImageGenerator =
        DependenciesGraphImageGenerator(dotBinaryPath: "/usr/local/Cellar/graphviz/2.40.1/bin/dot")
      
      guard let graphImage: NSImage = graphImageGenerator.generateImage(from: graphCode) else {
        return
      }
      
      self.imageView.image = graphImage
    } catch (let error) {
      print(error)
    }
  }
  
  // MARK: - shell
  
  private func createSyntaxForSourceFile(at sourceFilePath: String) -> String {
    return self.executeSourceKitten(withCommand: "syntax", sourceFilePath: sourceFilePath)
  }
  
  private func createStructureForSourceFile(at sourceFilePath: String) -> String {
    return self.executeSourceKitten(withCommand: "structure", sourceFilePath: sourceFilePath)
  }
  
  private func executeSourceKitten(withCommand command: String, sourceFilePath: String) -> String {
    let shell = ShellCommandsExecutor()
    let data = shell.execute(
      launchPath : "/usr/local/Cellar/sourcekitten/0.18.1/bin/sourcekitten",
      arguments  : [command, "--file", sourceFilePath]
    )
    let string = String(data: data, encoding: String.Encoding.utf8)!
    
    return string
  }
}
