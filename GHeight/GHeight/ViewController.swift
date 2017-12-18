//
//  ViewController.swift
//  GHeight
//
//  Created by user on 12/12/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
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

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messageLabel: UILabel!
    
    fileprivate lazy var session = ARSession()
    fileprivate lazy var sessionConfiguration = ARWorldTrackingConfiguration()
    fileprivate var planeExist = false
    
    let measureTime = Double(1)
    var timer = Timer()
    var lowestPlane: SCNNode?
    
    var unit: DistanceUnit!
    var measurements = [SCNVector3]()
    var startMeasurement = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapGesture))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        unit = DistanceUnit.centimeter
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc func tapGesture(sender: UITapGestureRecognizer)
    {
        
        if startMeasurement == false {
            DispatchQueue.main.async { [weak self] in
                self?.measurements = [SCNVector3]()
                self?.startMeasurement = true
                self?.timer = Timer.scheduledTimer(timeInterval: (self?.measureTime)!, target: self,   selector: (#selector(ViewController.finishTimer)), userInfo: nil, repeats: false)
            }
        }
    }
}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if lowestPlane == nil {
            
        }
        
        if let lowestPlane = lowestPlane {
            if planeAnchor.center.z < lowestPlane.worldPosition.z {
                let planeNode = createPlaneNode(anchor: planeAnchor)
                node.addChildNode(planeNode)
                self.lowestPlane = planeNode
            }
            
        } else {
            let planeNode = createPlaneNode(anchor: planeAnchor)
            node.addChildNode(planeNode)
            lowestPlane = planeNode
        }
        
    }
    
    @objc func finishTimer() {
        
        startMeasurement = false
        
        var sumY = Float(0.0)
        for measure in measurements {
            sumY += measure.y
        }
        
        let avarageY = Float(sumY / Float(measurements.count))
        
        guard let frame = sceneView.session.currentFrame else {
            return
        }
        
        guard let plane = lowestPlane else {
            return
        }
        
        let cameraPos2 = SCNVector3.positionFromTransform(frame.camera.transform)
        let distance = avarageY - (plane.worldPosition.y)
        
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = String(format: "%.2f%@", distance * (self?.unit.fator)!, (self?.unit.unit)!)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if startMeasurement == true {
            
            guard let frame = sceneView.session.currentFrame else {
                return
            }
            
            let cameraPos = SCNVector3.positionFromTransform(frame.camera.transform)
            measurements.append(cameraPos)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
    }
    
    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
//        // Create a SceneKit plane to visualize the node using its position and extent.
//
//        // Create the geometry and its materials
//        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//
//        let lavaImage = UIImage(named: "Lava")
//        let lavaMaterial = SCNMaterial()
//        lavaMaterial.diffuse.contents = lavaImage
//        lavaMaterial.isDoubleSided = true
//
//        plane.materials = [lavaMaterial]
//
//        // Create a node with the plane geometry we created
//        let planeNode = SCNNode(geometry: plane)
//        planeNode.position = SCNVector3Make(anchor.center.x, anchor.center.y, anchor.center.z)
//
//        // SCNPlanes are vertically oriented in their local coordinate space.
//        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
//        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        return VirtualPlane(anchor: anchor)
    }
    
//    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
//        // Create a SceneKit plane to visualize the node using its position and extent.
//
//        // Create the geometry and its materials
//        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//
//        let lavaImage = UIImage(named: "Lava")
//        let lavaMaterial = SCNMaterial()
//        lavaMaterial.diffuse.contents = lavaImage
//        lavaMaterial.isDoubleSided = true
//
//        plane.materials = [lavaMaterial]
//
//        // Create a node with the plane geometry we created
//        let planeNode = SCNNode(geometry: plane)
//        planeNode.position = SCNVector3Make(anchor.center.x, anchor.center.y, anchor.center.z)
//
//        // SCNPlanes are vertically oriented in their local coordinate space.
//        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
//        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
//
//        return planeNode
//    }
}
