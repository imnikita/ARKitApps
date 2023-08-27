//
//  LoadingModelsViewController.swift
//  RealText
//
//  Created by Mykyta Popov on 26/08/2023.
//

import UIKit
import SceneKit
import ARKit

class LoadingModelsViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planes = [OverlayPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestures()
    }
    
    private func registerGestures() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        gestureRecognizer.numberOfTapsRequired = 1
        
        
        let doubleTapGestereRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapGestereRecognizer.numberOfTapsRequired = 2
        
        gestureRecognizer.require(toFail: doubleTapGestereRecognizer)
        
        sceneView.addGestureRecognizer(gestureRecognizer)
        sceneView.addGestureRecognizer(doubleTapGestereRecognizer)
    }
    
    @objc private func doubleTap(_ recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, options: [:])
        
        guard !hitTestResult.isEmpty, let hitResult = hitTestResult.first else { return }
        
        let node = hitResult.node
        node.physicsBody?.applyForce(SCNVector3(hitResult.worldCoordinates.x * Float(2.0), 2.0, hitResult.worldCoordinates.z * Float(2.0)), asImpulse: true)
    }
    
    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            
            guard let hitResult = hitTestResult.first else {
                return
            }
//            addBox(hitResult)
            addTable(hitResult)
        }
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
    
    private func addBox(_ hitResult: ARHitTestResult) {
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
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
    
    private func addTable(_ hitResult: ARHitTestResult) {
        let tableScene = SCNScene(named: "art.scnassets/bench.dae")
        let tableNode = tableScene?.rootNode.childNode(withName: "SketchUp",
                                                       recursively: true)
        
        let column = hitResult.worldTransform.columns
        tableNode?.position = SCNVector3(x: column.3.x,
                                         y: column.3.y,
                                         z: column.3.z)
        
        sceneView.scene.rootNode.addChildNode(tableNode!)
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
}
