//
//  OverlayPlaneViewController.swift
//  RealText
//
//  Created by Mykyta Popov on 25/08/2023.
//

import Foundation
import SceneKit
import ARKit

class OverlayPlane : SCNNode {
    
    var anchor :ARPlaneAnchor
    var planeGeometry :SCNPlane!
    
    init(anchor :ARPlaneAnchor) {
        
        self.anchor = anchor
        super.init()
        setup()
    }
    
    func update(anchor :ARPlaneAnchor) {
        
        self.planeGeometry.width = CGFloat(anchor.planeExtent.width)
        self.planeGeometry.height = CGFloat(anchor.planeExtent.height)
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        
        let planeNode = self.childNodes.first!
        
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        
    }
    
    private func setup() {
        
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.planeExtent.width),
                                      height: CGFloat(anchor.planeExtent.height))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"overlay_grid.png")
        
        self.planeGeometry.materials = [material]
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = BodyType.plane.rawValue
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);
        
        // add to the parent
        self.addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



