//
//  Missile.swift
//  RealText
//
//  Created by Mykyta Popov on 26/08/2023.
//

import SceneKit
import ARKit

class Missile: SCNNode {

    private var scene: SCNScene!
    
    init(scene: SCNScene) {
        super.init()
        self.scene = scene
        setup()
    }
    
    init(missile: SCNNode) {
        super.init()
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        guard let missileNode = self.scene.rootNode.childNode(withName: "missile",
                                                              recursively: false),
        let smokeNode = self.scene.rootNode.childNode(withName: "smokeNode", recursively: false) else {
            return
        }
        
        let smoke = SCNParticleSystem(named: "smoke.scnp", inDirectory: nil)
        smokeNode.addParticleSystem(smoke!)
        
        self.addChildNode(missileNode)
        self.addChildNode(smokeNode)
    }
}
