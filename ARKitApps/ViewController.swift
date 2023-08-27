//
//  ViewController.swift
//  RealText
//
//  Created by Mykyta Popov on 23/08/2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
		
		let text = SCNText()
		
		let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
		
		let material = SCNMaterial()
		material.diffuse.contents = UIImage(named: "wood.jpeg")
		
		let boxNode = SCNNode(geometry: box)
		boxNode.position = SCNVector3(0, 0, -1)
		boxNode.geometry?.materials = [material]
		
		let sphere = SCNSphere(radius: 0.3)
		sphere.firstMaterial?.diffuse.contents = UIImage(named: "earth.jpg")
		let sphereNode = SCNNode(geometry: sphere)
		sphereNode.position = SCNVector3(x: 0.5, y: 0, z: -1)
		
		
		sceneView.scene.rootNode.addChildNode(sphereNode)
		sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
