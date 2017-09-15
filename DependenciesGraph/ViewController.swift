//
//  ViewController.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/1/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa
import WebKit

private struct VisJsGraphEdge {
  let edge : Edge
  let id   : String
}

extension VisJsGraphEdge: Equatable {
  static func ==(lhs: VisJsGraphEdge, rhs: VisJsGraphEdge) -> Bool {
    return lhs.edge == rhs.edge && lhs.id == rhs.id
  }
}

extension VisJsGraphEdge: Hashable {
  var hashValue: Int {
    return self.edge.hashValue ^ self.id.hashValue
  }
}

class ViewController: NSViewController {
  @IBOutlet private weak var instructionsTextField : NSTextField!
  @IBOutlet private weak var webView               : WKWebView!
  
  private var graph = Graph(nodes: Set<Node>(), edges: Set<Edge>())
  private var visJsGraphEdges: Set<VisJsGraphEdge> = []
  
  private var canUpdate: Bool = true
  
  internal var sourceFileUrl: URL? {
    didSet {
      if let _ = self.sourceFileUrl {
        self.instructionsTextField.isHidden = true
        self.webView.isHidden = false
        
        self.resizeGraphCanvas()
      } else {
        self.instructionsTextField.isHidden = false
        self.webView.isHidden = true
      }
    }
  }
  
  internal var sourceKittenBinaryPath : String!
  internal var graphvizDotBinaryPath  : String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.sourceFileUrl = nil
    
    self.webView.postsFrameChangedNotifications = true
    
    NotificationCenter.default.addObserver(
      self,
      selector : #selector(webViewFrameChanged),
      name     : NSNotification.Name.NSViewFrameDidChange,
      object   : nil
    )
    
    do {
      try self.createRequiredFilesForFutureUse()
      
      let graphFilePathsCreator = GraphFilePathsCreator()
      let graphHtmlUrl = URL(fileURLWithPath: graphFilePathsCreator.graphHtmlPath)
      let request = URLRequest(url: graphHtmlUrl)
      
      self.webView.load(request)
      self.resizeGraphCanvas()
      
      Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) {
        [unowned self]
        (timer: Timer) in
        self.update()
      }
    } catch (let error) {
      print(error)
    }
  }
  
  override var representedObject: Any? {
    didSet {
      
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func createRequiredFilesForFutureUse() throws {
    let graphFilePathsCreator = GraphFilePathsCreator()
    let graphFilesCreator = GraphFilesCreator()
    let graphCodeGenerator = GraphCodeGenerator()
    
    let graphHtmlCode: String = graphCodeGenerator.generateGraphHtmlCode(
      visJsPath            : graphFilePathsCreator.visJsPath,
      visNetworkMinCssPath : graphFilePathsCreator.visNetworkMinCssPath
    )
    
    let _ = try graphFilesCreator.createFiles(
      graphFilePathsCreator : graphFilePathsCreator,
      graphHtmlCode         : graphHtmlCode
    )
  }
  
  // MARK: - Update
  
  private func update() {
    guard self.canUpdate else {
      return
    }
    
    DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
      self.canUpdate = false
      
      do {
        guard let sourceFileUrl: URL = self.sourceFileUrl else {
          self.canUpdate = true
          
          return
        }
        
        let graphGenerator = GraphGenerator()
        let classTypesGenerator = ClassTypesGenerator()
        let sourceKittenShellCaller =
          SourceKittenShellCaller(binaryPath: self.sourceKittenBinaryPath)
        
        let classTypes: [ClassTypes] = try classTypesGenerator.generateClassTypes(
          sourceFileUrl           : sourceFileUrl,
          sourceKittenShellCaller : sourceKittenShellCaller
        )
        
        let newGraph: Graph =
          graphGenerator.generateGraph(classesTypes: classTypes, existingGraph: self.graph)
        
        guard self.graph != newGraph else {
          self.canUpdate = true
          
          return
        }
        
        DispatchQueue.main.async {
          do {
            let graphCodeGenerator = GraphCodeGenerator()
            let nodeFunctionCalls: [String] = graphCodeGenerator.generateNodeFunctionCalls(
              currentGraph : self.graph,
              newGraph     : newGraph
            )
            
            try self.updateVisJsGraph(nodeFunctionCalls: nodeFunctionCalls, newGraph: newGraph)
            
            self.graph = newGraph
            self.canUpdate = true
          } catch (let error) {
            print(error)
            
            self.canUpdate = true
          }
        }
      } catch (let error) {
        print(error)
        
        self.canUpdate = true
      }
    }
  }
  
  private func updateVisJsGraph(nodeFunctionCalls: [String], newGraph: Graph) throws {
    let graphCodeGenerator = GraphCodeGenerator()
    let graphsDifferenceCalculator = GraphsDifferenceCalculator()
    
    for nodeFunctionCall in nodeFunctionCalls {
      self.webView.evaluateJavaScript(nodeFunctionCall, completionHandler: nil)
    }
    
    let addedEdges: Set<Edge> = graphsDifferenceCalculator.getAddedEdges(self.graph, newGraph)
    
    for addedEdge in addedEdges {
      let addEdgeFnCall: String = graphCodeGenerator.generateAddEdgeFunctionCallCode(
        from : addedEdge.fromNodeId,
        to   : addedEdge.toNodeId
      )
      
      self.webView.evaluate(script: addEdgeFnCall, completion: {
        (result: Any?, error: Error?) in
        if let id: String = (result as? [String])?.first {
          let visJsGraphEdge = VisJsGraphEdge(edge: addedEdge, id: id)
          
          self.visJsGraphEdges.insert(visJsGraphEdge)
        }
      })
    }
    
    let removedEdges: Set<Edge> = graphsDifferenceCalculator.getRemovedEdges(self.graph, newGraph)
    
    for removedEdge in removedEdges {
      let visJsGraphEdge: VisJsGraphEdge? = self.visJsGraphEdges.first(where: {
        (visJsGraphEdge: VisJsGraphEdge) -> Bool in
        return visJsGraphEdge.edge == removedEdge
      })
      
      guard let graphEdge = visJsGraphEdge else {
        return
      }
      
      let removeEdgeFnCall: String =
        graphCodeGenerator.generateRemoveEdgeFunctionCallCode(edgeId: graphEdge.id)
      
      self.visJsGraphEdges.remove(graphEdge)
      
      self.webView.evaluateJavaScript(removeEdgeFnCall, completionHandler: nil)
    }
  }
  
  // MARK: - Notifications
  
  @objc private func webViewFrameChanged(notification: Notification) {
    guard let object = notification.object, (object as? WKWebView) == self.webView else {
      return
    }
    
    self.resizeGraphCanvas()
  }
  
  // MARK: - Graph canvas
  
  private func resizeGraphCanvas() {
    let graphCodeGenerator = GraphCodeGenerator()
    let insetSize: CGFloat = 20.0
    let canvasSize = CGSize(
      width  : self.webView.frame.size.width - insetSize,
      height : self.webView.frame.size.height - insetSize
    )
    
    let resizeCode = graphCodeGenerator.generateCanvasResizeCode(size: canvasSize)
    
    self.webView.evaluateJavaScript(resizeCode, completionHandler: nil)
  }
}

extension WKWebView {
  func evaluate(script: String, completion: @escaping (_ result: Any?, _ error: Error?) -> Void) {
    var finished = false
    
    self.evaluateJavaScript(script) {
      (result: Any?, error: Error?) in
      completion(result, error)
      
      finished = true
    }
    
    while !finished {
      RunLoop.current.run(mode: .defaultRunLoopMode, before: Date.distantFuture)
    }
  }
}
