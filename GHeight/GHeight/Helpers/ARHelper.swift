//
//  ARHelper.swift
//  GHeight
//
//  Created by user on 1/2/18.
//  Copyright © 2018 user. All rights reserved.
//

import Foundation
import SceneKit

class ARHelper {
    
    var measureScreen: ViewController!
    
    func selectNearestLine() {
        guard let worldPosition = measureScreen.sceneView.realWorldVector(screenPosition: measureScreen.view.center) else { return }
        
        RulerLine.diselectLine(node: measureScreen.selectedLineNode)
        measureScreen.selectedLineNode = nil
        
        let currentPositionProjection = measureScreen.sceneView.projectPoint(worldPosition)
        
        for line in measureScreen.lines {
            
            let currentPositionOnLine = getCurrentPositionOnLine(line: line.line!, currentPosition: currentPositionProjection)
            
            let distanceToPoint = distanceBetweenPoints(firtsPoint: currentPositionProjection, secondPoint: currentPositionOnLine)
            
            if distanceToPoint < 20  {
                if checkPointInLine(line: line.line!, point: currentPositionOnLine) {
                    measureScreen.selectedLineNode = line.line!.lineNode
                    RulerLine.selectLine(node: measureScreen.selectedLineNode!)
                    measureScreen.showMessageLabelForLength(length: line.length)
                    break
                }
            }
        }
        
        if measureScreen.selectedLineNode == nil {
            
            if let nextLine = measureScreen.lines.last {
                measureScreen.showMessageLabelForLength(length: nextLine.length)
            }
        }
    }
    
    func getCurrentPositionOnLine(line: RulerLine, currentPosition: SCNVector3) -> SCNVector3 {
        let p1 = measureScreen.sceneView.projectPoint(line.startVector)
        let p2 = measureScreen.sceneView.projectPoint(line.endVector)
        
        let v = SCNVector3(p2.x - p1.x, p2.y - p1.y, 1)
        var t: Float = (currentPosition.x * v.x - p1.x * v.x + currentPosition.y * v.y - p1.y * v.y) / (v.x * v.x + v.y * v.y)
        if t < 0 { t = 0 }
        else if t > 1 { t = 1 }
        return SCNVector3(p1.x + t * v.x, p1.y + t * v.y, 1)
    }
    
    func checkPointInLine(line: RulerLine, point: SCNVector3) -> Bool {
        let startPositionProjection = measureScreen.sceneView.projectPoint(line.startVector)
        let endPositionProjection = measureScreen.sceneView.projectPoint(line.endVector)
        
        var inXCoordinate = false
        var inYCoordinate = false
        
        if startPositionProjection.x >= endPositionProjection.x {
            if point.x >= endPositionProjection.x && point.x <= startPositionProjection.x {
                inXCoordinate = true
            }
        } else {
            if point.x <= endPositionProjection.x && point.x >= startPositionProjection.x {
                inXCoordinate = true
            }
        }
        
        if startPositionProjection.y >= endPositionProjection.y {
            if point.y >= endPositionProjection.y && point.y <= startPositionProjection.y {
                inYCoordinate = true
            }
        } else {
            if point.y <= endPositionProjection.y && point.y >= startPositionProjection.y {
                inYCoordinate = true
            }
        }
        
        return (inXCoordinate && inYCoordinate)
    }
    
    func distanceBetweenPoints(firtsPoint:SCNVector3, secondPoint:SCNVector3) -> Float{
        let xd = firtsPoint.x - secondPoint.x
        let yd = firtsPoint.y - secondPoint.y
        let zd = firtsPoint.z - secondPoint.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        
        if (distance < 0){
            return (distance * -1)
        } else {
            return (distance)
        }
    }
    
}
