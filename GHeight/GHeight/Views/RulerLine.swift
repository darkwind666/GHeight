//
//  Line.swift
//  Measure
//
//  Created by levantAJ on 8/9/17.
//  Copyright © 2017 levantAJ. All rights reserved.
//

import SceneKit
import ARKit

enum DistanceUnit: String {
    case centimeter = "centimeter"
    case inch = "inch"
    case meter = "meter"
    
    var fator: Float {
        switch self {
        case .centimeter:
            return 100.0
        case .inch:
            return 39.3700787
        case .meter:
            return 1.0
        }
    }
    
    var unit: String {
        switch self {
        case .centimeter:
            return "cm"
        case .inch:
            return "inch"
        case .meter:
            return "m"
        }
    }
    
    var title: String {
        switch self {
        case .centimeter:
            return "Centimeter"
        case .inch:
            return "Inch"
        case .meter:
            return "Meter"
        }
    }
}

final class RulerLine {

    var startVector: SCNVector3!
    var endVector: SCNVector3!
    var lastLineStartVector: SCNVector3?
    
    var unit: DistanceUnit!

    static var color: UIColor = .white
    static fileprivate var selectedPointColor: UIColor = .orange
    static var diselectedPointColor: UIColor = .blue
    
    var startNode: SCNNode!
    var endNode: SCNNode!
    var text: SCNText!
    fileprivate var textNode: SCNNode!
    var lineNode: SCNNode?
    
    fileprivate let sceneView: ARSCNView!
    
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: DistanceUnit) {
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        let startPointDot = SCNSphere(radius: 0.5)
        startPointDot.firstMaterial?.diffuse.contents = RulerLine.diselectedPointColor
        startPointDot.firstMaterial?.lightingModel = .constant
        startPointDot.firstMaterial?.isDoubleSided = true
        startNode = SCNNode(geometry: startPointDot)
        startNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)
        
        let endPointDot = SCNSphere(radius: 0.5)
        endPointDot.firstMaterial?.diffuse.contents = RulerLine.diselectedPointColor
        endPointDot.firstMaterial?.lightingModel = .constant
        endPointDot.firstMaterial?.isDoubleSided = true
        
        endNode = SCNNode(geometry: endPointDot)
        endNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = RulerLine.color
        text.alignmentMode  = kCAAlignmentCenter
        text.truncationMode = kCATruncationMiddle
        text.firstMaterial?.isDoubleSided = true
        
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func update(to vector: SCNVector3) {
        endVector = vector
        lineNode?.removeFromParentNode()
        lineNode = startVector.line(to: vector, color: RulerLine.color)
        sceneView.scene.rootNode.addChildNode(lineNode!)
        
        text.string = distance(to: vector)
        textNode.position = SCNVector3((startVector.x+vector.x)/2.0, (startVector.y+vector.y)/2.0, (startVector.z+vector.z)/2.0)
        
        endNode.position = vector
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
        }
    }
    
    func updateStartPoint(to vector: SCNVector3) {
        startVector = vector
        lineNode?.removeFromParentNode()
        lineNode = startVector.line(to: endVector, color: RulerLine.color)
        
        if let newLineNode = lineNode {
            sceneView.scene.rootNode.addChildNode(newLineNode)
        }
        
        text.string = distance(to: endVector)
        textNode.position = SCNVector3((startVector.x+endVector.x)/2.0, (startVector.y+endVector.y)/2.0, (startVector.z+endVector.z)/2.0)
        
        startNode.position = vector
        if startNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(startNode)
        }
    }
    
    func updateAngleBetweenLastLine() {
        
        
        
    }
    
    func lineLength() -> Float {
        
        var length = Float(0.0)
        
        if let vector = startVector, let endVectorSafe = endVector {
            length = (vector.distance(from: endVectorSafe) * unit.fator)
        }
        
        return length
    }
    
    func distance(to vector: SCNVector3) -> String {
        return String(format: "%.2f%@", startVector.distance(from: vector) * unit.fator, unit.unit)
    }
    
    func hideLine() {
        startNode.isHidden = true
        endNode.isHidden = true
        textNode.isHidden = true
        lineNode?.isHidden = true
    }
    
    func showLine() {
        startNode.isHidden = false
        endNode.isHidden = false
        textNode.isHidden = false
        lineNode?.isHidden = false
    }
    
    static func selectNode(node: SCNNode) {
        node.geometry?.firstMaterial?.diffuse.contents = selectedPointColor
    }
    
    static func diselectNode(node: SCNNode?) {
        node?.geometry?.firstMaterial?.diffuse.contents = diselectedPointColor
    }
    
    static func selectLine(node: SCNNode) {
        node.geometry?.firstMaterial?.diffuse.contents = selectedPointColor
    }
    
    static func diselectLine(node: SCNNode?) {
        node?.geometry?.firstMaterial?.diffuse.contents = UIColor.white
    }
    
    func getAngleBetween3Vectors() -> String {
        let angle = CGFloat((lastLineStartVector?.SCNVector3Angle(start: lastLineStartVector!, mid: startVector, end: endVector))!)
        return String(format: "%.2f°", angle)
    }
    
    func removeFromParentNode() {
        startNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
    }
}
