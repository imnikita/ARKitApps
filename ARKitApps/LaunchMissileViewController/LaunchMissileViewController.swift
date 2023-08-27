//
//  LaunchMissileViewController.swift
//  RealText
//
//  Created by Mykyta Popov on 26/08/2023.
//

import UIKit
import SceneKit
import ARKit

class LaunchMissileViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planes = [OverlayPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        let missileScene = SCNScene(named: "art.scnassets/missile-1-scn.scn")
        
        let missile = Missile(scene: missileScene!)
        missile.name = "Missile"
        missile.position = SCNVector3(0,0,-4)
        
        // Create a new scene
        let scene = SCNScene()
        scene.rootNode.addChildNode(missile)
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestures()
    }
    
    private func registerGestures() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let missileNode = sceneView.scene.rootNode.childNode(withName: "Missile", recursively: true) else {
            fatalError("error")
        }
        missileNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        missileNode.physicsBody?.isAffectedByGravity = false
        missileNode.physicsBody?.damping = 0.0
        
        missileNode.physicsBody?.applyForce(SCNVector3(0, 50, 0), asImpulse: false)
    }
    
    private func addTable(_ recognizer: UITapGestureRecognizer) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    private func addTable(_ hitResult: ARHitTestResult) {
        let missileScene = SCNScene(named: "art.scnassets/missile-1-scn.scn")
        let missileNode = missileScene?.rootNode.childNode(withName: "missile",
                                                       recursively: true)
        
        let column = hitResult.worldTransform.columns
        missileNode?.position = SCNVector3(0, 0, -0.5)
        
        sceneView.scene.rootNode.addChildNode(missileNode!)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
//        if !(anchor is ARPlaneAnchor) {
//            return
//        }
//        
//        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
//        self.planes.append(plane)
//        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
}
