//
//  GraphCodeGenerator.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/13/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

internal class GraphCodeGenerator: NSObject {
  internal func generateGraphHtmlCode(visJsPath: String, visNetworkMinCssPath: String) -> String {
    let options = [
      "edges": [
        "smooth": [
          "type": "cubicBezier",
          "forceDirection": "none",
          "roundness": 0.2
        ]
      ],
      "physics": [
        "hierarchicalRepulsion": [
          "centralGravity": 0
        ],
        "maxVelocity": 40,
        "minVelocity": 0.3,
        "solver": "forceAtlas2Based",
        "timestep": 0.2
      ]
    ]
    
    let data: Data = try! JSONSerialization.data(withJSONObject: options, options: .prettyPrinted)
    let optionsString = String.init(data: data, encoding: .utf8)!
    
    let code: String =
      "<!doctype html>\n" +
      "<html>\n" +
      "<head>\n" +
      "  <script type=\"text/javascript\" src=\"\(visJsPath)\"></script>\n" +
      "  <link href=\"\(visNetworkMinCssPath)\" rel=\"stylesheet\" type=\"text/css\" />\n" +
      "  <style type=\"text/css\">\n" +
      "    #mynetwork {\n" +
      "      width  : 600px;\n" +
      "      height : 600px;\n" +
      "      border : 1px solid lightgray;\n" +
      "    }\n" +
      "  </style>\n" +
      "</head>\n" +
      "<body>\n" +
      "  <div id=\"mynetwork\"></div>\n" +
      "  <script type=\"text/javascript\">\n" +
      "    var container = document.getElementById('mynetwork');\n" +
      "    var nodesDataSet = new vis.DataSet();\n" +
      "    var edgesDataSet = new vis.DataSet();\n" +
      "    \n" +
      "    var options = \(optionsString)\n" +
      "    \n" +
      "    var data = { nodes: nodesDataSet, edges: edgesDataSet };" +
      "    \n" +
      "    var network = new vis.Network(container, data, options);\n" +
      "    \n" +
      "    function addNode(id, label) {\n" +
      "      var node = { id: id, label: label };\n" +
      "      nodesDataSet.add(node);\n" +
      "    }\n" +
      "    \n" +
      "    function removeNode(id, label) {\n" +
      "      var node = { id: id, label: label };\n" +
      "      nodesDataSet.remove(node);\n" +
      "    }\n" +
      "    \n" +
      "    function addEdge(fromNodeId, toNodeId) {\n" +
      "      var edge = { from: fromNodeId, to: toNodeId, arrows: 'to' };\n" +
      "      var edgeId = edgesDataSet.add(edge);\n" +
      "      return edgeId;\n" +
      "    }\n" +
      "    \n" +
      "    function removeEdge(edgeId) {\n" +
      "      edgesDataSet.remove(edgeId);\n" +
      "    }\n" +
      "  </script>\n" +
      "</body>\n" +
      "</html>\n"
    
    return code
  }
  
  // MARK: - Function calls
  
  internal func generateNodeFunctionCalls(currentGraph: Graph, newGraph: Graph) -> [String] {
    let graphCodeGenerator = GraphCodeGenerator()
    let graphsDifferenceCalculator = GraphsDifferenceCalculator()
    let addedNodes: Set<Node> = graphsDifferenceCalculator.getAddedNodes(currentGraph, newGraph)
    let removedNodes: Set<Node> = graphsDifferenceCalculator.getRemovedNodes(currentGraph, newGraph)
    
    let nodeFunctionCalls: [String] =
      addedNodes.map {
        (node: Node) -> String in
        return graphCodeGenerator.generateAddNodeFunctionCallCode(id: node.id, label: node.label)
      } +
      removedNodes.map {
        (node: Node) -> String in
        return graphCodeGenerator.generateRemoveNodeFunctionCallCode(id: node.id, label: node.label)
      }
    
    return nodeFunctionCalls
  }
  
  internal func generateAddNodeFunctionCallCode(id: Id, label: String) -> String {
    return "addNode(\(id), \"\(label)\")"
  }
  
  internal func generateRemoveNodeFunctionCallCode(id: Id, label: String) -> String {
    return "removeNode(\(id), \"\(label)\")"
  }
  
  internal func generateAddEdgeFunctionCallCode(from: Id, to: Id) -> String {
    return "addEdge(\(from), \(to))"
  }
  
  internal func generateRemoveEdgeFunctionCallCode(edgeId: String) -> String {
    return "removeEdge(\"\(edgeId)\")"
  }
  
  internal func generateCanvasResizeCode(size: CGSize) -> String {
    let width = Int(size.width)
    let height = Int(size.height)
    
    let code: String =
      "var container = document.getElementById('mynetwork');\n" +
      "container.style.width = '\(width)px';\n" +
      "container.style.height = '\(height)px';"
    
    return code
  }
}
