//
//  GraphsDifferenceCalculator.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/14/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import Cocoa

public class GraphsDifferenceCalculator {
  // MARK: - Nodes
  
  public func getAddedNodes(_ graph1: Graph, _ graph2: Graph) -> Set<Node> {
    let graph1Nodes = Set<Node>(graph1.nodes)
    let graph2Nodes = Set<Node>(graph2.nodes)
    let addedNodes: Set<Node> = graph2Nodes.subtracting(graph1Nodes)
    
    return addedNodes
  }
  
  public func getRemovedNodes(_ graph1: Graph, _ graph2: Graph) -> Set<Node> {
    let graph1Nodes = Set<Node>(graph1.nodes)
    let graph2Nodes = Set<Node>(graph2.nodes)
    let removedNodes: Set<Node> = graph1Nodes.subtracting(graph2Nodes)
    
    return removedNodes
  }
  
  // MARK: - Edges
  
  public func getAddedEdges(_ graph1: Graph, _ graph2: Graph) -> Set<Edge> {
    let graph1Edges = Set<Edge>(graph1.edges)
    let graph2Edges = Set<Edge>(graph2.edges)
    let addedEdges: Set<Edge> = graph2Edges.subtracting(graph1Edges)
    
    return addedEdges
  }
  
  public func getRemovedEdges(_ graph1: Graph, _ graph2: Graph) -> Set<Edge> {
    let graph1Edges = Set<Edge>(graph1.edges)
    let graph2Edges = Set<Edge>(graph2.edges)
    let removedEdges: Set<Edge> = graph1Edges.subtracting(graph2Edges)
    
    return removedEdges
  }
}
