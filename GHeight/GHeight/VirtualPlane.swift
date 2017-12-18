//
//  VirtualPlane.swift
//  ARKitPlanesAndObjects
//
//  Created by Ignacio Nieto Carvajal on 16/10/2017.
//  Copyright © 2017 Digital Leaves. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class VirtualPlane: SCNNode {
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!
    
    /**
     * The init method will create a SCNPlane geometry and add a node generated from it.
     */
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        // initialize anchor and geometry, set color for plane
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = initializePlaneMaterial()
        self.planeGeometry!.materials = [material]
        
        // create the SceneKit plane node. As planes in SceneKit are vertical, we need to initialize the y coordinate to 0, use the z coordinate,
        // and rotate it 90º.
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
        
        // update the material representation for this plane
        updatePlaneMaterialDimensions()
        
        // add this node to our hierarchy.
        self.addChildNode(planeNode)
    }
    
    /**
     * Creates and initializes the material for our plane, a semi-transparent gray area.
     */
    func initializePlaneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.50)
        return material
    }
    
    /**
     * This method will update the plan when it changes.
     * Remember that we corrected the y and z coordinates on init, so we need to take that into account
     * when modifying the plane.
     */
    func updateWithNewAnchor(_ anchor: ARPlaneAnchor) {
        // first, we update the extent of the plan, because it might have changed
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        // now we should update the position (remember the transform applied)
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        
        // update the material representation for this plane
        updatePlaneMaterialDimensions()
    }
    
    /**
     * The material representation of the plane should be updated as the plane gets updated too.
     * This method does just that.
     */
    func updatePlaneMaterialDimensions() {
        // get material or recreate
        let material = self.planeGeometry.materials.first!
        
        // scale material to width and height of the updated plane
        let width = Float(self.planeGeometry.width)
        let height = Float(self.planeGeometry.height)
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
