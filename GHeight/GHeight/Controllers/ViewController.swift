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

class HeightMeasure {
    var line: RulerLine?
    var length = Float(0.0)
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
    var lines = [HeightMeasure]()
    var selectedLineNode:SCNNode?
    
    var arHelper = ARHelper()
    var screenshotHelper = ScreenshotHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arHelper.measureScreen = self
        screenshotHelper.measureScreen = self
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
    
    @IBAction func undoPressed(_ sender: Any) {
        if let finalLine = lines.last {
            finalLine.line?.removeFromParentNode()
            lines.removeLast()
            
            if let nextLine = lines.last {
                showMessageLabelForLength(length: nextLine.length)
            }
        }
    }
    
    @IBAction func clearPressed(_ sender: Any) {
        for line in lines {
            line.line?.removeFromParentNode()
        }
        
        lines.removeAll()
        lines = [HeightMeasure]()
        messageLabel.text = ""
    }
    
    @IBAction func turnLightPressed(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == .off {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    @IBAction func rateAppPressed(_ sender: Any) {
        
    }
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func showSettings(_ sender: Any) {
        
    }
    
    @IBAction func galleryButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func takeScreenshot() {
        let alertVC = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Save height", style: .default) { [weak self] _ in
            self?.saveUserHeight()
        })
        alertVC.addAction(UIAlertAction(title: "Take photo", style: .default) { [weak self] _ in
            self?.screenshotHelper.takeJustScreenshot()
        })
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func saveUserHeight() {
        
        let date = Date()
        let uuid = String(Int(date.timeIntervalSince1970))
        
        let userObjectRm = UserObjectRm()
        userObjectRm.createdAt = date
        userObjectRm.id = uuid
        userObjectRm.sizeUnit = self.unit.rawValue
        userObjectRm.name = "Object" + uuid
        userObjectRm.height = self.getObjectSize()
        
        DispatchQueue.main.async {
            try! GRDatabaseManager.sharedDatabaseManager.grRealm.write({
                GRDatabaseManager.sharedDatabaseManager.grRealm.add(userObjectRm, update:true)
            })
        }
    }
    
    func getObjectSize() -> Float {
        var height: Float = 0.0
        
        if let finalLine = lines.last {
            height = finalLine.length
        }
        
        return height
    }
    
    func showMessageLabelForLength(length: Float) {
        let measureText = String(format: "%.2f%@", length * (self.unit.fator), (self.unit.unit))
        messageLabel.text = measureText
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
        
        guard let plane = lowestPlane else {
            return
        }
        
        let distance = avarageY - (plane.worldPosition.y)
        
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = String(format: "%.2f%@", distance * (self?.unit.fator)!, (self?.unit.unit)!)
        }
        
        guard let frame = sceneView.session.currentFrame else {
            return
        }
        
        let currentPosition = SCNVector3.positionFromTransform(frame.camera.transform)
        var endPosition = SCNVector3()
        endPosition.x = currentPosition.x
        endPosition.y = avarageY
        endPosition.z = currentPosition.z
        
        var startPosition = SCNVector3()
        startPosition.x = currentPosition.x
        startPosition.y = (lowestPlane?.worldPosition.y)!
        startPosition.z = currentPosition.z
        
        let line = RulerLine(sceneView: sceneView, startVector: startPosition, unit: unit)
        line.update(to: endPosition)
        
        let newMeasure = HeightMeasure()
        newMeasure.line = line
        newMeasure.length = distance
        lines.append(newMeasure)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async { [weak self] in
            self?.arHelper.selectNearestLine()
        }
        
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
        return VirtualPlane(anchor: anchor)
    }
}
