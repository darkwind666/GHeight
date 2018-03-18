//
//  SCNVector3.swift
//  Measure
//
//  Created by levantAJ on 8/9/17.
//  Copyright © 2017 levantAJ. All rights reserved.
//

import ARKit

extension SCNVector3 {
    
    func distance(from vector: SCNVector3) -> Float {
        let distanceX = self.x - vector.x
        let distanceY = self.y - vector.y
        let distanceZ = self.z - vector.z
        
        return sqrtf((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
    }
    
    func line(to vector: SCNVector3, color: UIColor = .white) -> SCNNode {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [self, vector])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: geometry)
        return node
    }
    
    func SCNVector3Angle(start: SCNVector3, mid: SCNVector3, end: SCNVector3) -> Double {
        let v1 = (start - mid)
        let v2 = (end - mid)
        let v1norm = v1.normalized
        let v2norm = v2.normalized
        
        let res = v1norm().x * v2norm().x + v1norm().y * v2norm().y + v1norm().z * v2norm().z
        let angle: Double = Double(GLKMathRadiansToDegrees(acos(res)))
        return angle
    }
    
    /**
     * Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
     */
    
    /**
     * Returns the length (magnitude) of the vector described by the SCNVector3
     */
    
    /**
     Add two vectors
     
     - parameter left: Addend 1
     - parameter right: Addend 2
     */
    /**
     Add one vector to another
     
     - parameter left: Vector to change
     - parameter right: Vector to add
     */
    /**
     Subtract one vector to another
     
     - parameter left: Vector to change
     - parameter right: Vector to subtract
     */
    static func -=( left: inout SCNVector3, right:SCNVector3) {
        left = SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    /**
     Multiply a vector times a constant
     
     - parameter vector: Vector to modify
     - parameter constant: Multiplier
     */
    /**
     Multiply a vector times a constant and update the vector inline
     
     - parameter vector: Vector to modify
     - parameter constant: Multiplier
     */
    
    /// Calculate the magnitude of this vector
    var magnitude:SCNFloat {
        get {
            return sqrt(dotProduct(self))
        }
    }
    /// Vector in the same direction as this vector with a magnitude of 1
    
    /**
     Calculate the dot product of two vectors
     
     - parameter vectorB: Other vector in the calculation
     */
    func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }
    /**
     Calculate the dot product of two vectors
     
     - parameter vectorB: Other vector in the calculation
     */
    func crossProduct(_ vectorB:SCNVector3) -> SCNVector3 {
        let computedX = (y * vectorB.z) - (z * vectorB.y)
        let computedY = (z * vectorB.x) - (x * vectorB.z)
        let computedZ = (x * vectorB.y) - (y * vectorB.x)
        return SCNVector3(computedX, computedY, computedZ)
    }
    /**
     Calculate the angle between two vectors
     
     - parameter vectorB: Other vector in the calculation
     */
    func angleBetweenVectors(_ vectorB:SCNVector3) -> SCNFloat {
        //cos(angle) = (A.B)/(|A||B|)
        let cosineAngle = (dotProduct(vectorB) / (magnitude * vectorB.magnitude))
        return SCNFloat(acos(cosineAngle))
    }
    
    static func center(_ vectors: [SCNVector3]) -> SCNVector3 {
        var x: Float = 0
        var y: Float = 0
        var z: Float = 0
        
        let size = Float(vectors.count)
        vectors.forEach {
            x += $0.x
            y += $0.y
            z += $0.z
        }
        return SCNVector3Make(x / size, y / size, z / size)
    }
}

extension SCNVector3: Equatable {
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}
