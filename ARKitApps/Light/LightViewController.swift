//
//  LightViewController.swift
//  ARKitApps
//
//  Created by Mykyta Popov on 27/08/2023.
//

import UIKit
import SceneKit
import ARKit

class LightViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var spotName = "SpotName"
    
    var planes = [OverlayPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
//        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addTapGesture()
        insertSpotLight(SCNVector3(0, 1.0, 0))
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
    
    private func addTapGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func insertSpotLight(_ position: SCNVector3) {
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.spotInnerAngle = 45
        spotLight.spotOuterAngle = 45
        
        let spotNode = SCNNode()
        spotNode.name = spotName
        spotNode.light = spotLight
        spotNode.position = position
        
        spotNode.eulerAngles = SCNVector3(-Double.pi / 2, 0, -0.2)
        sceneView.scene.rootNode.addChildNode(spotNode)
    }
    
    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            
            guard let hitResult = hitTestResult.first else {
                return
            }
            addBox(hitResult)
        }
    }
    
    private func addBox(_ hitResult: ARHitTestResult) {
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        box.materials = [material]
        
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic,
                                             shape: nil)
        boxNode.physicsBody?.categoryBitMask = BodyType.box.rawValue
        
        let column = hitResult.worldTransform.columns
        
        boxNode.position = SCNVector3(x: column.3.x,
                                      y: column.3.y + Float(box.height / 2) + Float(0.5),
                                      z: column.3.z)
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let estimate = sceneView.session.currentFrame?.lightEstimate else { return }
        
        let spotNode = sceneView.scene.rootNode.childNode(withName: spotName, recursively: true)
        spotNode?.light?.intensity = estimate.ambientIntensity
    }
}
