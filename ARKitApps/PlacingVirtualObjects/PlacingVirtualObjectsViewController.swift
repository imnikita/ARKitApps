//
//  PlacingVirtualObjectsViewController.swift
//  RealText
//
//  Created by Mykyta Popov on 25/08/2023.
//

import UIKit
import SceneKit
import ARKit

class PlacingVirtualObjectsViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        sceneView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        guard !hitResult.isEmpty, let hit = hitResult.first else { return }
        
        addBox(hit)
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
        
        let column = hitResult.worldTransform.columns
        
        boxNode.position = SCNVector3(x: column.3.x,
                                      y: column.3.y + Float(box.height / 2),
                                      z: column.3.z)
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
}
