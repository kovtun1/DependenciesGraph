//
//  GraphGenerator.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/13/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

public typealias Id = Int

// MARK: - Node

public struct Node {
  let id    : Id
  let label : String
  
  public init(id: Id, label: String) {
    self.id = id
    self.label = label
  }
}

extension Node: Equatable {
  public static func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.id == rhs.id && lhs.label == rhs.label
  }
}

extension Node: Hashable {
  public var hashValue: Int {
    return id.hashValue ^ label.hashValue
  }
}

// MARK: - Edge

public struct Edge {
  let fromNodeId : Id
  let toNodeId   : Id
  
  public init(fromNodeId: Id, toNodeId: Id) {
    self.fromNodeId = fromNodeId
    self.toNodeId = toNodeId
  }
}

extension Edge: Equatable {
  public static func ==(lhs: Edge, rhs: Edge) -> Bool {
    return lhs.fromNodeId == rhs.fromNodeId && lhs.toNodeId == rhs.toNodeId
  }
}

extension Edge: Hashable {
  public var hashValue: Int {
    return fromNodeId.hashValue ^ toNodeId.hashValue
  }
}

// MARK: - Graph

public struct Graph {
  let nodes : Set<Node>
  let edges : Set<Edge>
  
  public init(nodes: Set<Node>, edges: Set<Edge>) {
    self.nodes = nodes
    self.edges = edges
  }
  
  public func getMaxNodeId() -> Id? {
    let nodeIds: [Id] = self.nodes.map { (node: Node) -> Id in
      return node.id
    }
    let maxNodeId: Id? = nodeIds.max()
    
    return maxNodeId
  }
}

extension Graph: Equatable {
  public static func ==(lhs: Graph, rhs: Graph) -> Bool {
    return lhs.edges == rhs.edges && lhs.nodes == rhs.nodes
  }
}

// MARK: - GraphGenerator

internal class GraphGenerator {
  internal func generateGraph(classesTypes: [ClassTypes], existingGraph graph: Graph) -> Graph {
    let nodes: Set<Node> = self.createNodes(classesTypes: classesTypes, existingGraph: graph)
    let edges: Set<Edge> = self.creteEdges(classesTypes: classesTypes, nodes: nodes)
    
    let graph = Graph(nodes: nodes, edges: edges)
    
    return graph
  }
  
  // MARK: -
  
  private func createNodes(classesTypes: [ClassTypes], existingGraph graph: Graph) -> Set<Node> {
    let allTypes: [String] = Array(classesTypes.map {
      (classTypes: ClassTypes) -> [String] in
      let types: [String] = [classTypes.className] + classTypes.classTypes
      
      return types
    }.joined())
    
    let types: Set<String> = Set<String>(allTypes)
    let existingGraphTypes = Set<String>(graph.nodes.map {
      (node: Node) -> String in
      return node.label
    })
    let intersectingTypes: Set<String> = existingGraphTypes.intersection(types)
    let addedTypes: Set<String> = types.subtracting(existingGraphTypes)
    
    let intersectingNodes = Set<Node>(intersectingTypes.flatMap {
      (type: String) -> Node? in
      let node: Node? = graph.nodes.first(where: {
        (node: Node) -> Bool in
        return node.label == type
      })
      
      return node
    })
    
    var nodes: Set<Node> = intersectingNodes
    var id: Id = (graph.getMaxNodeId() ?? 0) + 1
    
    for type in addedTypes {
      let node = Node(id: id, label: type)
      
      nodes.insert(node)
      
      id += 1
    }
    
    return nodes
  }
  
  private func creteEdges(classesTypes: [ClassTypes], nodes: Set<Node>) -> Set<Edge> {
    let edges = Set<Edge>(classesTypes.flatMap({
      (classTypes: ClassTypes) -> [Edge] in
      guard
        let classNameNodeId: Id = self.findNodeId(label: classTypes.className, in: nodes)
      else {
        return []
      }
      
      let classEdges: [Edge] = classTypes.classTypes.flatMap({
        (type: String) -> Edge? in
        guard let typeNodeId: Id = self.findNodeId(label: type, in: nodes) else {
          return nil
        }
        
        let edge = Edge(fromNodeId: classNameNodeId, toNodeId: typeNodeId)
        
        return edge
      })
      
      return classEdges
    }).joined())
    
    return edges
  }
  
  private func findNodeId(label: String, in nodes: Set<Node>) -> Id? {
    for node in nodes {
      if node.label == label {
        return node.id
      }
    }
    
    return nil
  }
}
