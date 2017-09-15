//
//  GraphsDifferenceCalculatorTests.swift
//  DependenciesGraph
//
//  Created by Oleksiy Kovtun on 9/14/17.
//  Copyright © 2017  Oleksiy Kovtun. All rights reserved.
//

import XCTest

@testable import DependenciesGraph

class GraphsDifferenceCalculatorTests: XCTestCase {
  private let graphsDifferenceCalculator = GraphsDifferenceCalculator()
  
  private let graph1 = Graph(nodes: [], edges: [])
  private let graph2 = Graph(
    nodes: [Node(id: 1, label: "1")],
    edges: [Edge(fromNodeId: 1, toNodeId: 1)]
  )
  private let graph3 = Graph(
    nodes: [
      Node(id: 1, label: "1"),
      Node(id: 2, label: "2")
    ],
    edges: [
      Edge(fromNodeId: 1, toNodeId: 2),
      Edge(fromNodeId: 2, toNodeId: 1)
    ]
  )
  private let graph4 = Graph(
    nodes: [
      Node(id: 1, label: "1"),
      Node(id: 3, label: "3"),
      Node(id: 4, label: "4")
    ],
    edges: [
      Edge(fromNodeId: 1, toNodeId: 4),
      Edge(fromNodeId: 1, toNodeId: 3),
      Edge(fromNodeId: 3, toNodeId: 4)
    ]
  )
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: - Added nodes
  
  func testAddedNodesGraph1Graph2() {
    let addedNodes: Set<Node> =
      self.graphsDifferenceCalculator.getAddedNodes(self.graph1, self.graph2)
    
    let expecedAddedNodes: Set<Node> = [Node(id: 1, label: "1")]
    
    XCTAssertEqual(expecedAddedNodes, addedNodes)
  }
  
  func testAddedNodesGraph2Graph3() {
    let addedNodes: Set<Node> =
      self.graphsDifferenceCalculator.getAddedNodes(self.graph2, self.graph3)
    
    let expectedAddedNodes: Set<Node> = [Node(id: 2, label: "2")]
    
    XCTAssertEqual(expectedAddedNodes, addedNodes)
  }
  
  func testAddedNodesGraph3Graph4() {
    let addedNodes: Set<Node> =
      self.graphsDifferenceCalculator.getAddedNodes(self.graph3, self.graph4)
    
    let expectedAddedNodes: Set<Node> = [
      Node(id: 3, label: "3"),
      Node(id: 4, label: "4")
    ]
    
    XCTAssertEqual(expectedAddedNodes, addedNodes)
  }
  
  // MARK: - Removed nodes
  
  func testRemovedNodesGraph1Graph2() {
    let removedNodes: Set<Node> =
      self.graphsDifferenceCalculator.getRemovedNodes(self.graph1, self.graph2)
    
    let expectedRemovedNodes: Set<Node> = []
    
    XCTAssertEqual(expectedRemovedNodes, removedNodes)
  }
  
  func testRemovedNodesGraph2Graph3() {
    let removedNodes: Set<Node> =
      self.graphsDifferenceCalculator.getRemovedNodes(self.graph2, self.graph3)
    
    let expectedRemovedNodes: Set<Node> = []
    
    XCTAssertEqual(expectedRemovedNodes, removedNodes)
  }
  
  func testRemovedNodesGraph3Graph4() {
    let removedNodes: Set<Node> =
      self.graphsDifferenceCalculator.getRemovedNodes(self.graph3, self.graph4)
    
    let expectedRemovedNodes: Set<Node> = [Node(id: 2, label: "2")]
    
    XCTAssertEqual(expectedRemovedNodes, removedNodes)
  }
  
  // MARK: - Added edges
  
  func testAddedEdgesGraph1Graph2() {
    let addedEdges: Set<Edge> =
      self.graphsDifferenceCalculator.getAddedEdges(self.graph1, self.graph2)
    
    let expectedAddedEdges: Set<Edge> = [Edge(fromNodeId: 1, toNodeId: 1)]
    
    XCTAssertEqual(expectedAddedEdges, addedEdges)
  }
  
  func testAddedEdgesGraph2Graph3() {
    let addedEdges: Set<Edge> =
      self.graphsDifferenceCalculator.getAddedEdges(self.graph2, self.graph3)
    
    let expectedAddedEdges: Set<Edge> = [
      Edge(fromNodeId: 1, toNodeId: 2),
      Edge(fromNodeId: 2, toNodeId: 1)
    ]
    
    XCTAssertEqual(expectedAddedEdges, addedEdges)
  }
  
  func testAddedEdgesGraph3Graph4() {
    let addedEdges: Set<Edge> =
      self.graphsDifferenceCalculator.getAddedEdges(self.graph3, self.graph4)
    
    let expectedAddedEdges: Set<Edge> = [
      Edge(fromNodeId: 1, toNodeId: 4),
      Edge(fromNodeId: 1, toNodeId: 3),
      Edge(fromNodeId: 3, toNodeId: 4)
    ]
    
    XCTAssertEqual(expectedAddedEdges, addedEdges)
  }
  
  // MARK: - Removed edges
  
  func testRemovedEdgesGraph1Graph2() {
    let removedEdges: Set<Edge> =
      self.graphsDifferenceCalculator.getRemovedEdges(self.graph1, self.graph2)
    
    let expectedRemovedEdges: Set<Edge> = []
    
    XCTAssertEqual(expectedRemovedEdges, removedEdges)
  }
  
  func testRemovedEdgesGraph2Graph3() {
    let removedEdges: Set<Edge> =
      self.graphsDifferenceCalculator.getRemovedEdges(self.graph2, self.graph3)
    
    let expectedRemovedEdges: Set<Edge> = [Edge(fromNodeId: 1, toNodeId: 1)]
    
    XCTAssertEqual(expectedRemovedEdges, removedEdges)
  }
  
  func testRemovedEdgesGraph3Graph4() {
    let removedEdges: Set<Edge> =
      self.graphsDifferenceCalculator.getRemovedEdges(self.graph3, self.graph4)
    
    let expectedRemovedEdges: Set<Edge> = [
      Edge(fromNodeId: 1, toNodeId: 2),
      Edge(fromNodeId: 2, toNodeId: 1)
    ]
    
    XCTAssertEqual(expectedRemovedEdges, removedEdges)
  }
}
